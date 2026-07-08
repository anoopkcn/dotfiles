#!/bin/bash
# Lid-switch handler. Arg: close | open.
#
#   close (lid:on) : if an external output is active, stash eDP-1's workspaces
#                    (first close only) and disable eDP-1 so sway migrates them
#                    to the external. Undocked -> no-op, so logind suspends.
#   open  (lid:off): re-enable eDP-1 and move the stashed workspaces back.
#
# Why this exists: sway never disables eDP-1 on lid close, so with an external
# connected the workspaces stay stranded on the dark panel. logind is
# docked=ignore here (it won't suspend while an external is attached), so sway
# is free to take over -- we just have to do the workspace move it won't.
#
# Bound via `bindswitch --reload --locked` in sway/config, so it MUST be
# reload-safe: `swaymsg reload` re-fires the binding for the current lid state
# and re-applies the output config (which can re-enable a runtime-disabled
# eDP-1). The STATE FILE's existence -- not live output state -- is therefore
# the source of truth for "already closed", so a reload can't clobber the saved
# workspace list with an empty one. Pairs with toggle-external.sh (extend) and
# mirror-external.sh (whose atomic switch+move restore idiom lives in sway-lib).

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_dir/sway-lib.sh" || { echo "sway-lib.sh not found" >&2; exit 1; }

STATE="${XDG_RUNTIME_DIR:-/tmp}/lid-internal-workspaces"

case "$1" in
close)
    has_external || exit 0               # undocked: leave it to logind (suspend)

    # Record only on the FIRST close (state absent). A --reload refire while
    # already closed must NOT re-record -- that would overwrite with an empty
    # list, since eDP-1 has no workspaces once they've migrated. One
    # get_workspaces call emits the focus line first, then eDP-1's workspaces.
    if [ ! -f "$STATE" ]; then
        swaymsg -t get_workspaces | jq -r --arg o "$INTERNAL" '
            [.[] | select(.focused) | .name]
            + [.[] | select(.output == $o) | .name]
            | .[]' > "$STATE"
    fi

    # Idempotent: hide eDP-1 (also re-hides it if a reload re-enabled it).
    # Disabling migrates eDP-1's workspaces to the external automatically.
    output_active "$INTERNAL" && swaymsg output "$INTERNAL" disable >/dev/null
    ;;

open)
    swaymsg output "$INTERNAL" enable >/dev/null
    wait_output_active "$INTERNAL"       # settle before moving workspaces onto it

    [ -f "$STATE" ] || exit 0

    # Line 1 = pre-close focus; lines 2+ = workspaces that were on eDP-1.
    focus=$(head -n1 "$STATE")
    while IFS= read -r ws; do
        [ -n "$ws" ] && ws_switch_move "$ws" "$INTERNAL"   # atomic (see sway-lib.sh)
    done < <(tail -n +2 "$STATE")

    [ -n "$focus" ] && ws_focus "$focus"
    rm -f "$STATE"
    ;;

*)
    echo "usage: $0 {close|open}" >&2
    exit 2
    ;;
esac
