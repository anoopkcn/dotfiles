#!/bin/bash
# Toggle every external output (anything that is not the built-in eDP-1 panel).
#
# Why this exists: powering the Eizo off with its own button does NOT drop the
# DisplayPort link, so sway keeps DP-5 "active" and its workspaces stay stranded
# on an invisible screen. Disabling the output *does* make sway migrate those
# workspaces back to the laptop; re-enabling restores the arrangement (position
# etc. come from ~/.config/sway/outputs via the include in config).

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_dir/sway-lib.sh" || { echo "sway-lib.sh not found" >&2; exit 1; }

outputs=$(sway_outputs)

# External outputs sway currently knows about (enabled or not).
externals=$(external_names "$outputs")

# Nothing external connected (e.g. cable actually unplugged) -> nothing to do.
[ -z "$externals" ] && exit 0

# Any external currently active? If so turn them all off, else back on.
if has_external "$outputs"; then action=disable; else action=enable; fi
for out in $externals; do
    swaymsg output "$out" "$action" >/dev/null
done
