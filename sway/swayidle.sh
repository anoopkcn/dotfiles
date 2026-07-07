#!/bin/sh
# Idle handling for sway (replaces xss-lock/slock/xidlehook from X11).
# Lock after 10 min, power displays off after 15, and lock before sleep.
# Fullscreen / idle-inhibiting apps (mpv, video) suppress the timeout via
# the inhibit_idle rules in sway/config.
pkill -x swayidle
exec swayidle -w \
    timeout 600 'swaylock -f -c 14161d' \
    timeout 900 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
    before-sleep 'swaylock -f -c 14161d'
