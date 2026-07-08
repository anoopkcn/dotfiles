#!/bin/sh
# Idle handling for sway (replaces xss-lock/slock/xidlehook from X11).
# Lock after 10 min, power displays off after 15, and lock before sleep.
# Fullscreen windows suppress the timeout via the inhibit_idle rules in
# sway/config. Audio playback is handled here: lock() skips locking while any
# PipeWire sink is RUNNING, replacing xidlehook's --not-when-audio so videos
# in a window (browser, non-fullscreen mpv) don't get locked out.
pkill -x swayidle

# swayidle runs each timeout command via `sh -c`; skip the lock when a sink is
# RUNNING (audio playing), otherwise lock.
exec swayidle -w \
    timeout 600 'pactl list sinks | grep -q RUNNING || swaylock -f -c 14161d' \
    timeout 900 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
    before-sleep 'swaylock -f -c 14161d'
