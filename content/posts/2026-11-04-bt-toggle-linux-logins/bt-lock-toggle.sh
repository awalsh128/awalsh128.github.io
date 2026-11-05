#!/usr/bin/env bash
# Block Bluetooth unless someone is at the desktop with an active, unlocked session.
#
#   bt-lock-toggle.sh daemon   watch logind and apply the rule after every event (run by bt-lock-toggle.service)
#   bt-lock-toggle.sh status   print each session, whether it counts, and the resulting Bluetooth state
#
# Works with any login screen (GDM, SDDM, LightDM, ...) because it reads logind, not display manager hooks.
# Install it as a root service with bt-lock-toggle-install.sh.
set -uo pipefail

# Make rfkill (in /usr/sbin) available when started with a minimal PATH.
PATH="/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# Print "yes" if a session keeps Bluetooth on, "no" otherwise.
session_counts() {
  local seat="" class="" type="" active="" locked="" state="" key value
  while IFS='=' read -r key value; do
    case "$key" in
      Seat) seat="$value" ;;
      Class) class="$value" ;;
      Type) type="$value" ;;
      Active) active="$value" ;;
      LockedHint) locked="$value" ;;
      State) state="$value" ;;
    esac
  done < <(loginctl show-session "$1" -p Seat -p Class -p Type -p Active -p LockedHint -p State 2>/dev/null)

  # A local desktop session (not SSH, not the login screen) that is on screen, unlocked, and not closing.
  if [[ "$seat" == seat0 && "$class" == user && ("$type" == x11 || "$type" == wayland) &&
        "$active" == yes && "$locked" == no && ("$state" == active || "$state" == online) ]]; then
    echo yes
  else
    echo no
  fi
}

# Print "unblock" if any session keeps Bluetooth on, "block" otherwise.
wanted_state() {
  local id
  for id in $(loginctl list-sessions --no-legend | awk '{print $1}'); do
    if [[ "$(session_counts "$id")" == yes ]]; then
      echo unblock
      return
    fi
  done
  echo block
}

# Devices to reconnect on unblock. RUNTIME_DIRECTORY is set by systemd (RuntimeDirectory= in the unit).
DEVICES_FILE="${RUNTIME_DIRECTORY:-/run/bt-lock-toggle}/devices"

# Disconnect devices cleanly before cutting the radio. A bare rfkill block drops the link without telling the device,
# so a headset keeps thinking it is connected and won't pair with a phone until the stale link times out.
block_bluetooth() {
  local addr connected
  connected="$(bluetoothctl devices Connected | awk '{print $2}')"
  # Keep the old list when nothing is connected (e.g. the service restarted while already blocked).
  if [[ -n "$connected" ]]; then
    mkdir -p "$(dirname "$DEVICES_FILE")"
    echo "$connected" > "$DEVICES_FILE"
  fi
  for addr in $connected; do
    timeout 10 bluetoothctl disconnect "$addr" >/dev/null && echo "Disconnected $addr"
  done
  rfkill block bluetooth && echo "Bluetooth: block"
}

# Unblock, then reconnect what was connected at block time. BlueZ doesn't do this on its own after an rfkill unblock.
unblock_bluetooth() {
  local addr i
  rfkill unblock bluetooth && echo "Bluetooth: unblock"
  [[ -s "$DEVICES_FILE" ]] || return 0
  for ((i = 0; i < 20; i++)); do
    bluetoothctl show | grep -q 'Powered: yes' && break
    sleep 0.5
  done
  while read -r addr; do
    timeout 15 bluetoothctl connect "$addr" >/dev/null && echo "Reconnected $addr" || echo "Couldn't reconnect $addr"
  done < "$DEVICES_FILE"
  rm -f "$DEVICES_FILE"
}

daemon() {
  local last="" want line

  apply() {
    want="$(wanted_state)"
    if [[ "$want" != "$last" ]]; then
      "${want}_bluetooth"
      last="$want"
    fi
  }

  apply
  while read -r line; do
    # One lock or login fires a burst of signals; let it finish, then work the rule out once.
    while read -r -t 0.5 line; do :; done
    apply
  done < <(gdbus monitor --system --dest org.freedesktop.login1)

  echo "gdbus monitor exited" >&2
  exit 1
}

status() {
  local id
  printf '%-8s %-6s %-8s %-12s %-7s %-7s %-8s %s\n' SESSION SEAT CLASS TYPE ACTIVE LOCKED STATE COUNTS
  for id in $(loginctl list-sessions --no-legend | awk '{print $1}'); do
    printf '%-8s %-6s %-8s %-12s %-7s %-7s %-8s %s\n' "$id" \
      "$(loginctl show-session "$id" --value -p Seat)" \
      "$(loginctl show-session "$id" --value -p Class)" \
      "$(loginctl show-session "$id" --value -p Type)" \
      "$(loginctl show-session "$id" --value -p Active)" \
      "$(loginctl show-session "$id" --value -p LockedHint)" \
      "$(loginctl show-session "$id" --value -p State)" \
      "$(session_counts "$id")"
  done
  echo "Bluetooth should be: $(wanted_state)ed"
}

case "${1:-}" in
  daemon) daemon ;;
  status) status ;;
  *)
    sed -n '4,5s/^#  *//p' "$0" >&2
    exit 2
    ;;
esac
