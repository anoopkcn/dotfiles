# sway-lib.sh — shared helpers for the sway output/workspace scripts
# (toggle-external, mirror-external, lid-switch, output-notify).
#
# Sourced, not executed — has no shebang and is not chmod +x. sway ignores it
# (only `config` + the `include`d `outputs` are read). Sibling scripts source it
# via their own directory so it works with the ~/.config/sway symlink deploy.
#
# Convention: functions that inspect outputs take an OPTIONAL pre-fetched
# `swaymsg -t get_outputs` JSON as their last argument. Pass it when you already
# have the JSON (avoids re-running swaymsg); omit it for a one-off check.

INTERNAL="eDP-1"        # built-in laptop panel; every other output is "external"

# Raw get_outputs JSON ("" on failure).
sway_outputs() { swaymsg -t get_outputs 2>/dev/null; }

# Echo provided JSON ($1) or fetch it fresh. Internal helper.
_outputs() { if [ -n "$1" ]; then printf '%s' "$1"; else sway_outputs; fi; }

# Sorted, space-separated names of active outputs.            active_names [json]
active_names() {
    _outputs "$1" | jq -r '[.[] | select(.active) | .name] | sort | join(" ")' 2>/dev/null
}

# Exit 0 if the named output is currently active.        output_active NAME [json]
output_active() {
    _outputs "$2" | jq -e --arg o "$1" 'any(.[]; .name == $o and .active)' >/dev/null 2>&1
}

# Exit 0 if any active output other than the internal panel exists. has_external [json]
has_external() {
    _outputs "$1" | jq -e --arg o "$INTERNAL" 'any(.[]; .name != $o and .active)' >/dev/null 2>&1
}

# All external output names, active or not, one per line.    external_names [json]
external_names() {
    _outputs "$1" | jq -r --arg o "$INTERNAL" '.[] | select(.name != $o) | .name' 2>/dev/null
}

# Active output with the most pixels (modeless outputs ignored; ties -> first).
# Missing dimensions default to 0 so a transient null mode can't error out.
#                                                              highest_res [json]
highest_res() {
    _outputs "$1" | jq -r '
        [.[] | select(.active and .current_mode != null)]
        | max_by((.current_mode.width // 0) * (.current_mode.height // 0)) | .name' 2>/dev/null
}

# Focused workspace and its output as "name<TAB>output" (tab-split preserves
# workspace names with spaces).                                     focused_ws
focused_ws() {
    swaymsg -t get_workspaces 2>/dev/null | jq -r '.[] | select(.focused) | "\(.name)\t\(.output)"'
}

# Move the *focused* workspace to an output.                    ws_move_to OUTPUT
ws_move_to() { swaymsg "move workspace to output \"$1\"" >/dev/null 2>&1; }

# Focus a workspace by name (no back-and-forth toggle).            ws_focus NAME
ws_focus() { swaymsg "workspace --no-auto-back-and-forth \"$1\"" >/dev/null 2>&1; }

# Atomically focus a workspace then move it to an output. Chained in ONE swaymsg
# message so sway orders them — two separate calls race (the move can fire
# before the focus switch settles and move the wrong workspace).
#                                                        ws_switch_move WS OUTPUT
ws_switch_move() {
    swaymsg "workspace --no-auto-back-and-forth \"$1\"; move workspace to output \"$2\"" >/dev/null 2>&1
}

# Poll until an output is active, or give up.       wait_output_active NAME [tries=50]
wait_output_active() {
    local n=${2:-50}
    while [ "$n" -gt 0 ]; do
        output_active "$1" && return 0
        sleep 0.05
        n=$((n - 1))
    done
    return 1
}
