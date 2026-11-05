---
title: Toggling Bluetooth on Linux Login Status
date: "2026-11-04T00:00:00.000-07:00"
author: awalsh128
tags:
  - Linux
modified_time: "2026-11-04T00:00:00.000-07:00"
summary: "Automate a way to turn off Bluetooth on logout and turn back on for login."
---

I have a few Bluetooth enabled devices like my laptop, desktop, and phone. Frequently I would try to connect to connect to my Bluetooth headset from my phone after jumping off the desktop and it would just refuse. After a few minutes I realized I was still connected to my locked desktop and felt like a complete idiot.

So like any lazy person, I ended up automating it on my Linux desktop.

## Implementation

First the script to toggle the Bluetooth.

{{< code-include source="bt-lock-toggle.sh" collapse="true" title="Toggling script" >}}

Then the one-time script to install it as a systemd service, which works with any login screen (GDM, SDDM,
LightDM, ...).

{{< code-include source="bt-lock-toggle-install.sh" collapse="true" title="Install toggling service" >}}

Here is the command line to install it:

```bash
cd ~/bin
curl -fsSLO https://awalsh128.com/bt-toggle-linux-logins/bt-lock-toggle.sh
curl -fsSLO https://awalsh128.com/bt-toggle-linux-logins/bt-lock-toggle-install.sh
bash bt-lock-toggle-install.sh
```

## Checking It Works

Lock your screen, then unlock it and look at the service log. You should see the headset disconnect, Bluetooth get
blocked, then the reverse on unlock.

```bash
journalctl -u bt-lock-toggle -f
```

If Bluetooth doesn't change when you lock, run `status` over SSH (or from a text console) while the desktop is locked.
It shows every session
[logind](https://www.freedesktop.org/software/systemd/man/latest/systemd-logind.service.html) knows about and whether
it keeps Bluetooth on.

```bash
bt-lock-toggle.sh status
```

## Caveats

The script never talks to the login manager. It only asks logind (i.e. systemd's session tracker) which sessions are
open, so GDM, SDDM, and LightDM should all work the same way. I've only run it on GNOME with GDM though.

- **Locking depends on your screen locker.** The script sees a lock through logind's `LockedHint`, which the locker has
  to set. GNOME and KDE set it. Standalone lockers (e.g. i3lock, swaylock, xscreensaver) usually don't, so Bluetooth
  stays on while locked. Logging in and out still works.
- **You need systemd.** Distros without it (e.g. Devuan, or Artix and Gentoo with OpenRC) can't use the installer
  as-is. The script itself may work with elogind, but you'd have to start it some other way.
- **You need a fairly recent BlueZ.** Disconnecting the headset first relies on `bluetoothctl devices Connected`,
  which is only in BlueZ from around 2022 on. On older versions Bluetooth still gets blocked, but the headset won't
  hear about it and will think it's still connected.
- **Bluetooth is off at the login screen.** It stays blocked until you log in, so a Bluetooth keyboard can't type your
  password. A login manager that doesn't mark its login screen as a greeter session would leave Bluetooth on there
  instead.
- **Unlocking reconnects what was connected.** If your phone grabbed the headset while you were away, unlocking may
  pull it back to the desktop.

That's it. I hope it saves you from the same moment I had with my headset.
