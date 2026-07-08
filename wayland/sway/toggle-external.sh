#!/bin/bash
# Toggle every external output (anything that is not the built-in eDP-1 panel).
#
# Why this exists: powering the Eizo off with its own button does NOT drop the
# DisplayPort link, so sway keeps DP-5 "active" and its workspaces stay stranded
# on an invisible screen. Disabling the output *does* make sway migrate those
# workspaces back to the laptop; re-enabling restores the arrangement (position
# etc. come from ~/.config/sway/outputs via the include in config).

INTERNAL="eDP-1"

# External outputs sway currently knows about (enabled or not).
externals=$(swaymsg -t get_outputs | jq -r --arg int "$INTERNAL" \
    '.[] | select(.name != $int) | .name')

# Nothing external connected (e.g. cable actually unplugged) -> nothing to do.
[ -z "$externals" ] && exit 0

# Are any externals currently active? If so we turn them off, else back on.
any_active=$(swaymsg -t get_outputs | jq -r --arg int "$INTERNAL" \
    '[.[] | select(.name != $int) | .active] | any')

for out in $externals; do
    if [ "$any_active" = "true" ]; then
        swaymsg output "$out" disable
    else
        swaymsg output "$out" enable
    fi
done
