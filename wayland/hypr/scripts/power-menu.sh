#!/bin/bash
# Power menu — fuzzel picker (replaces swaynag, which ships with sway).
# Lock routes through loginctl so hypridle's lock_cmd keeps hyprlock
# single-instance.

choice=$(printf '%s\n' Lock Logout Suspend Reboot Poweroff \
    | fuzzel --dmenu --prompt "power ❯ " --lines 5)

case "$choice" in
    Lock)     loginctl lock-session ;;
    Logout)   hyprctl dispatch 'hl.dsp.exit()' ;;  # Lua fork: dispatch args are Lua
    Suspend)  systemctl suspend ;;
    Reboot)   systemctl reboot ;;
    Poweroff) systemctl poweroff ;;
esac
