#!/bin/sh

# Root-owned counterpart to setup.sh.
#
# setup.sh only ever touches $HOME — user configs, ~/.local/bin, systemctl
# --user. Anything under /etc needs root, so it lives here instead of bolting
# sudo onto setup.sh. Run it explicitly:
#
#     sudo ./setup-system.sh
#
# Everything installed here is lid/sleep/wakeup policy that hypr/conf/monitors.lua
# and hypr/hypridle.conf depend on. See system/README.md for what each file does
# and how to back it out.

PATH_TO_DOTFILES='/home/akc/develop/dotfiles'

if [ "$(id -u)" -ne 0 ]; then
  echo "setup-system.sh must run as root: sudo $0" >&2
  exit 1
fi

if [ ! -d "$PATH_TO_DOTFILES/system" ]; then
  echo "PATH_TO_DOTFILES/system not found at $PATH_TO_DOTFILES" >&2
  exit 1
fi

# Symlink rather than copy, matching setup.sh, so edits in the repo are live.
# /home is on the root filesystem here, so udev and logind can read these
# whenever it matters (the dock is never plugged before userspace is up).
# If /home ever moves to its own late-mounted volume, switch these to
# `install -m 644` copies and re-run this script after every edit.

# logind — pins HandleLidSwitchDocked=ignore, which monitors.lua is built on.
mkdir -p /etc/systemd/logind.conf.d
ln -sfn $PATH_TO_DOTFILES/system/etc/systemd/logind.conf.d/10-lid.conf \
        /etc/systemd/logind.conf.d/10-lid.conf

# udev — lets the USB-C dock (and its keyboard) wake the machine from suspend.
mkdir -p /etc/udev/rules.d
ln -sfn $PATH_TO_DOTFILES/system/etc/udev/rules.d/90-dock-wakeup.rules \
        /etc/udev/rules.d/90-dock-wakeup.rules

# Apply without a reboot. `udevadm trigger` re-runs the rules against devices
# that are already enumerated, so a dock plugged in right now gets armed too.
udevadm control --reload
udevadm trigger --subsystem-match=usb --action=add

# Sessions survive a logind restart on systemd >= 230 (they are pinned by fd),
# and this box is on 261. The drop-in would otherwise wait for the next boot.
systemctl restart systemd-logind

echo
echo "Installed. Verify:"
echo "  systemd-analyze cat-config systemd/logind.conf | grep HandleLidSwitchDocked"
echo "  cat /sys/bus/usb/devices/usb*/power/wakeup    # expect: enabled x4"
