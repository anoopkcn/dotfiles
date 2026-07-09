#!/bin/sh
# Window switcher — list every window across all workspaces in fuzzel, grouped
# by workspace, and focus the chosen one.
#
# This is what lets windows stay titlebar-less: instead of paying vertical
# space for always-visible titlebars/tabs, you summon an on-demand list only
# when you need to find a window. Searches by class AND title, across every
# workspace at once — including windows hidden inside groups. Bound to
# SUPER+Tab in conf/binds.lua.
#
# Deps: hyprctl, jq, fuzzel (>=1.9 for --index). Was a python script; jq is
# ~3x faster to the menu (no interpreter startup, one hyprctl call instead of
# two — the focused window comes from focusHistoryID==0 in the clients list).
#
# Each menu line is "address<TAB>display text"; fuzzel only sees the text.
menu=$(hyprctl -j clients | jq -r '
    def rpad($n): . + ((" " * ($n - length)) // "");
    [ .[] | select(.mapped)
      | { addr:  .address,
          ws:    ((.workspace.name // "?")
                  | if startswith("special") then "S" else . end),
          app:   (.class // "?"),
          title: ((.title // "") | gsub("\t"; " ")),
          mark:  (if .focusHistoryID == 0 then "●" else " " end) } ]
    # Numbered workspaces in order, then named ones, special (S) last.
    | sort_by(if (.ws | test("^[0-9]+$"))
              then [0, (.ws | tonumber), ""]
              else [(if .ws == "S" then 2 else 1 end), 0, .ws] end)
    | (map(.app | length) | max) as $aw
    # Workspace label only on its group first row; align the app column.
    | foreach .[] as $c ({prev: null};
        {prev: $c.ws, label: (if .prev == $c.ws then "" else $c.ws end)};
        "\($c.addr)\t\(.label | rpad(2)) \($c.mark) \($c.app | rpad($aw))  \($c.title)")
')
[ -n "$menu" ] || exit 0

idx=$(printf '%s\n' "$menu" | cut -f2- \
      | fuzzel --dmenu --index --prompt "window ❯ ")
case "$idx" in '' | *[!0-9]*) exit 0 ;; esac

# This Hyprland is the Lua-config fork: `hyprctl dispatch` evaluates its
# argument as Lua (return hl.dispatch(...)), so classic dispatcher syntax
# like `focuswindow address:...` does NOT work here.
addr=$(printf '%s\n' "$menu" | sed -n "$((idx + 1))p" | cut -f1)
exec hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })"
