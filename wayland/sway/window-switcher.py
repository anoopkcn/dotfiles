#!/usr/bin/env python3
"""Window switcher — list every window across all workspaces in fuzzel and
focus the chosen one.

This is what lets sway stay titlebar-less (default_border pixel 1): instead of
paying vertical space for always-visible titlebars/tabs, you summon an on-demand
list only when you need to find a window. Searches by app id AND title, across
every workspace at once. Bound to $mod+Tab in sway/config.

Deps: python3, swaymsg, fuzzel (>=1.9 for --index). No jq needed.
Theme/colors are inherited from ~/.config/fuzzel/fuzzel.ini automatically.
"""
import json
import subprocess


def sway(*args):
    return subprocess.run(["swaymsg", *args], capture_output=True, text=True).stdout


tree = json.loads(sway("-t", "get_tree"))

wins = []            # (con_id, workspace, app, title)
focused_id = None


def walk(node, ws):
    global focused_id
    if node.get("type") == "workspace":
        ws = node.get("name", "?")
    if node.get("pid") is not None and node.get("type") in ("con", "floating_con"):
        app = node.get("app_id") or (node.get("window_properties") or {}).get("class") or "?"
        wins.append((node["id"], ws, app, node.get("name") or ""))
        if node.get("focused"):
            focused_id = node["id"]
    for child in node.get("nodes", []) + node.get("floating_nodes", []):
        walk(child, ws)


walk(tree, "?")

if not wins:
    raise SystemExit

# Align the app column so titles line up; mark the focused window with a dot.
app_w = max(len(w[2]) for w in wins)
lines = []
for con_id, ws, app, title in wins:
    mark = "●" if con_id == focused_id else " "
    ws_disp = "S" if ws.startswith("__") else ws          # __i3_scratch -> S
    lines.append(f"{mark} {ws_disp:<2} {app:<{app_w}}  {title}")

picker = subprocess.run(
    ["fuzzel", "--dmenu", "--index", "--prompt", "window ❯ "],
    input="\n".join(lines), capture_output=True, text=True,
)

idx = picker.stdout.strip()
if idx.isdigit():
    con_id = wins[int(idx)][0]
    sway(f"[con_id={con_id}]", "focus")
