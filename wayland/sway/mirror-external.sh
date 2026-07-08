#!/bin/bash
# Mirror your workspace onto the other output(s), sharpest-screen-first (toggle).
#
# Why a script and not a sway feature: wlroots has no output cloning like X11's
# `xrandr --same-as`, and a naive mirror of the low-res laptop panel onto a 4K
# screen looks soft (you can't upscale detail that isn't there).
#
# So instead of mirroring the laptop, we mirror the HIGHEST-RESOLUTION output.
# To avoid the "my apps vanished behind an empty screen" problem, we first move
# the focused workspace *onto* that high-res output, so your real windows are
# rendered there natively; every other output then shows a crisp downscaled
# copy. Toggling off moves the workspace back where it started.
#
# Pairs with toggle-external.sh, which *extends* onto the external instead.

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_dir/sway-lib.sh" || { echo "sway-lib.sh not found" >&2; exit 1; }

STATE="${XDG_RUNTIME_DIR:-/tmp}/wl-mirror-origin"

# sway's exec PATH does not include ~/.local/bin, so resolve wl-mirror by hand
# (a bare `wl-mirror` from a keybind is "command not found" -> silent failure).
WL_MIRROR=""
for p in "$HOME/.local/bin/wl-mirror" /usr/local/bin/wl-mirror /usr/bin/wl-mirror; do
    [ -x "$p" ] && { WL_MIRROR="$p"; break; }
done
[ -z "$WL_MIRROR" ] && WL_MIRROR=$(command -v wl-mirror)

# Move the recorded workspace back to the output it came from, then forget it.
restore_home() {
    [ -f "$STATE" ] || return
    IFS='|' read -r ws origin < "$STATE"
    ws_switch_move "$ws" "$origin"    # atomic switch+move (see sway-lib.sh)
    rm -f "$STATE"
}

# --- toggle OFF: kill mirrors, move the workspace back home ---------------
if pgrep -x wl-mirror >/dev/null; then
    pkill -x wl-mirror
    sleep 0.2   # let the fullscreen clone finish closing before we move things
    restore_home
    exit 0
fi

# --- toggle ON ------------------------------------------------------------
if [ -z "$WL_MIRROR" ]; then
    notify-send "Mirror" "wl-mirror binary not found"
    exit 1
fi

outputs=$(sway_outputs)

# Need at least two active outputs to mirror between.
if [ "$(active_names "$outputs" | wc -w)" -lt 2 ]; then
    notify-send "Mirror" "Need a second output connected to mirror"
    exit 1
fi

source=$(highest_res "$outputs")      # capture the sharpest screen

# The focused workspace and the output it currently lives on (its home).
IFS=$'\t' read -r ws origin < <(focused_ws)

# Move the workspace onto the source so your apps render there natively, but
# only if it isn't already there. Remember its home so we can restore later; if
# no move is needed, drop any stale record so toggle-off doesn't act on it.
if [ "$origin" != "$source" ]; then
    printf '%s|%s\n' "$ws" "$origin" > "$STATE"
    ws_move_to "$source"
else
    rm -f "$STATE"
fi

# Mirror the source onto every other active output, fullscreen.
for t in $(echo "$outputs" | jq -r --arg src "$source" \
        '.[] | select(.active and .name != $src) | .name'); do
    "$WL_MIRROR" --fullscreen-output "$t" "$source" &
done

# Fail-safe: if no mirror actually came up (e.g. wl-mirror crashed on launch),
# don't strand the apps on another screen -- move the workspace back home.
sleep 0.6
if ! pgrep -x wl-mirror >/dev/null; then
    notify-send "Mirror" "wl-mirror failed to start; workspace restored"
    restore_home
    exit 1
fi
