#!/usr/bin/env bash
# Install bt-lock-toggle.sh as a root service, so Bluetooth is blocked unless someone is at the desktop with an active,
# unlocked session. Works with any login screen; needs systemd (logind) and rfkill.
#
#   bt-lock-toggle-install.sh               install or refresh
#   bt-lock-toggle-install.sh --uninstall   stop the service and remove everything this installed
set -Eeuo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bt-lock-toggle.sh"
# The service runs as root, so it runs a root-owned copy rather than a file a user can edit.
BIN="/usr/local/bin/bt-lock-toggle.sh"
UNIT="/etc/systemd/system/bt-lock-toggle.service"

if [[ "${1:-}" == --uninstall ]]; then
  sudo systemctl disable --now bt-lock-toggle.service || true
  sudo rm -f "$UNIT" "$BIN"
  sudo systemctl daemon-reload
  echo "Removed bt-lock-toggle"
  exit
fi

sudo install -m 0755 -o root -g root "$SRC" "$BIN"
echo "Installed $BIN"

sudo tee "$UNIT" >/dev/null <<EOF
[Unit]
Description=Block Bluetooth when no unlocked desktop session is active
After=systemd-logind.service bluetooth.service

[Service]
ExecStart=$BIN daemon
Restart=always
RestartSec=2
# Holds the devices to reconnect on unlock; kept across restarts.
RuntimeDirectory=bt-lock-toggle
RuntimeDirectoryPreserve=yes

[Install]
WantedBy=multi-user.target
EOF
echo "Installed $UNIT"

sudo systemctl daemon-reload
sudo systemctl enable bt-lock-toggle.service
# Restart rather than start, so a re-run picks up a changed script.
sudo systemctl restart bt-lock-toggle.service
echo "Started bt-lock-toggle; check it with: $BIN status"

echo "** You can remove these files now via rm $SRC/bt-lock-toggle*.sh **"
