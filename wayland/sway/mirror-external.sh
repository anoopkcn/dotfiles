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

STATE="${XDG_RUNTIME_DIR:-/tmp}/wl-mirror-origin"

# sway's exec PATH does not include ~/.local/bin, so resolve wl-mirror by hand
# (a bare `wl-mirror` from a keybind is "command not found" -> silent failure).
WL_MIRROR=""
for p in "$HOME/.local/bin/wl-mirror" /usr/local/bin/wl-mirror /usr/bin/wl-mirror; do
    [ -x "$p" ] && { WL_MIRROR="$p"; break; }
done
[ -z "$WL_MIRROR" ] && WL_MIRROR=$(command -v wl-mirror)

# Move the currently focused workspace onto output $1.
move_ws_to() { swaymsg "move workspace to output \"$1\"" >/dev/null; }

# Move the recorded workspace back to the output it came from, then forget it.
# Switch + move are chained in ONE swaymsg message so sway applies them in order
# atomically -- two separate calls race (the move can fire before the focus
# switch settles and end up moving the wrong workspace).
restore_home() {
    [ -f "$STATE" ] || return
    IFS='|' read -r ws origin < "$STATE"
    swaymsg "workspace --no-auto-back-and-forth \"$ws\"; move workspace to output \"$origin\"" \
        >/dev/null 2>&1
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

outputs=$(swaymsg -t get_outputs)

# Need at least two active outputs to mirror between.
if [ "$(echo "$outputs" | jq '[.[] | select(.active)] | length')" -lt 2 ]; then
    notify-send "Mirror" "Need a second output connected to mirror"
    exit 1
fi

# Source = active output with the most pixels (current_mode w*h). Ignore any
# active output without a mode, and default missing dimensions to 0 so a
# transient null mode can't blow up the comparison. Ties: first.
source=$(echo "$outputs" | jq -r '
    [.[] | select(.active and .current_mode != null)]
    | max_by((.current_mode.width // 0) * (.current_mode.height // 0)) | .name')

# The focused workspace and the output it currently lives on (its home). Split
# on the tab only (IFS=tab) so workspace names with spaces (e.g. "1: web") stay
# intact instead of spilling into $origin.
IFS=$'\t' read -r ws origin < <(swaymsg -t get_workspaces | jq -r \
    '.[] | select(.focused) | "\(.name)\t\(.output)"')

# Move the workspace onto the source so your apps render there natively, but
# only if it isn't already there. Remember its home so we can restore later; if
# no move is needed, drop any stale record so toggle-off doesn't act on it.
if [ "$origin" != "$source" ]; then
    printf '%s|%s\n' "$ws" "$origin" > "$STATE"
    move_ws_to "$source"
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
