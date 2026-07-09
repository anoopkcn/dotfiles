-- Keybinds — ported from sway/config. SUPER = the old $mod (Mod4).

local terminal = "kitty"

-- Applications -------------------------------------------------------------
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.close())
hl.bind("SUPER + D", hl.dsp.exec_cmd("fuzzel"))

-- Window switcher — every window across all workspaces in fuzzel, focus the
-- pick. This is what lets windows stay titlebar-less.
hl.bind("SUPER + Tab", hl.dsp.exec_cmd("~/.config/hypr/scripts/window-switcher.sh"))

-- Fuzzy-find a file under $HOME and open it.
hl.bind("SUPER + P", hl.dsp.exec_cmd([[f=$(fd -t f . "$HOME" | fuzzel --dmenu) && [ -n "$f" ] && xdg-open "$f"]]))

-- Clipboard history — cliphist stores (autostart), fuzzel picks.
hl.bind("SUPER + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))

-- Color picker — copies the hex to the clipboard.
hl.bind("SUPER + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- Focus ---------------------------------------------------------------------
hl.bind("SUPER + H",     hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + J",     hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + K",     hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + L",     hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + left",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + down",  hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + up",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))

-- Move (group_aware: moves windows in/out of groups directionally) ----------
hl.bind("SUPER + SHIFT + H",     hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind("SUPER + SHIFT + J",     hl.dsp.window.move({ direction = "d", group_aware = true }))
hl.bind("SUPER + SHIFT + K",     hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind("SUPER + SHIFT + L",     hl.dsp.window.move({ direction = "r", group_aware = true }))
hl.bind("SUPER + SHIFT + left",  hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind("SUPER + SHIFT + down",  hl.dsp.window.move({ direction = "d", group_aware = true }))
hl.bind("SUPER + SHIFT + up",    hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "r", group_aware = true }))

-- Layout ---------------------------------------------------------------------
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }))
-- hl.bind("SUPER + W", hl.dsp.group.toggle())
hl.bind("SUPER + E", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + minus",     hl.dsp.layout("preselect d"))
hl.bind("SUPER + backslash", hl.dsp.layout("preselect r"))
hl.bind("SUPER + SHIFT + space", hl.dsp.window.float({ action = "toggle" }))

-- Toggle focus between the tiled and floating layers (sway focus mode_toggle).
hl.bind("SUPER + space", function()
    local w = hl.get_active_window()
    if w ~= nil and w.floating then
        hl.dispatch(hl.dsp.focus({ window = "tiled" }))
    else
        hl.dispatch(hl.dsp.focus({ window = "floating" }))
    end
end)

-- Notifications (dunst) ------------------------------------------------------
-- Redisplay the most recent past notification; press repeatedly to walk back.
hl.bind("SUPER + N", hl.dsp.exec_cmd("dunstctl history-pop"))
-- Do Not Disturb toggle; SIGRTMIN+1 refreshes the waybar DND pill.
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd([[if [ "$(dunstctl is-paused)" = "true" ]; then dunstctl set-paused false && notify-send "Notifications" "Resumed"; else notify-send "Do Not Disturb" "Notifications paused" && dunstctl set-paused true; fi; pkill -RTMIN+1 waybar]]))

-- Workspaces 1-10 (key 0 = workspace 10) --------------------------------------
for i = 1, 10 do
    local key = i % 10
    hl.bind("SUPER + " .. key,            hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. key,    hl.dsp.window.move({ workspace = i }))
end

-- Session control --------------------------------------------------------------
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
-- Lock via logind so hypridle's lock_cmd keeps hyprlock single-instance.
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("SUPER + SHIFT + BackSpace", hl.dsp.exec_cmd("~/.config/hypr/scripts/power-menu.sh"))
hl.bind("CTRL + ALT + BackSpace", hl.dsp.exec_cmd("systemctl suspend"))

-- Resize submap (was sway mode "resize"; waybar shows it via hyprland/submap).
-- Sane mapping: h/left shrink width, l/right grow width, k/up shrink height,
-- j/down grow height.
hl.bind("SUPER + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("h",     hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
    hl.bind("l",     hl.dsp.window.resize({ x = 40,  y = 0, relative = true }), { repeating = true })
    hl.bind("k",     hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
    hl.bind("j",     hl.dsp.window.resize({ x = 0, y = 40,  relative = true }), { repeating = true })
    hl.bind("left",  hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
    hl.bind("right", hl.dsp.window.resize({ x = 40,  y = 0, relative = true }), { repeating = true })
    hl.bind("up",    hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
    hl.bind("down",  hl.dsp.window.resize({ x = 0, y = 40,  relative = true }), { repeating = true })
    hl.bind("Return",    hl.dsp.submap("reset"))
    hl.bind("escape",    hl.dsp.submap("reset"))
    hl.bind("SUPER + R", hl.dsp.submap("reset"))
end)

-- Media / hardware keys (locked: work on the lock screen too) -------------------
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Screenshots (grim/slurp) --------------------------------------------------------
hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" ~/Images/Screenshots/$(date +%F_%H-%M-%S).png]]))
-- Region shot: save to a file AND copy to clipboard, then notify with the path
hl.bind("Print", hl.dsp.exec_cmd([[f=~/Images/Screenshots/$(date +%F_%H-%M-%S).png; grim -g "$(slurp)" "$f" && wl-copy < "$f" && notify-send "Screenshot" "$f"]]))

-- Mouse: drag/resize windows with SUPER held (was floating_modifier + tiling_drag).
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
