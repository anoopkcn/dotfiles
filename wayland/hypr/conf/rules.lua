-- Window rules — ported from sway/config for_window lines.
-- `class` matches both the Wayland app-id and the XWayland class, so the old
-- paired app_id/class rules collapse into one regex each.

hl.window_rule({
    name  = "float-thunar",
    match = { class = "^(thunar|Thunar)$" },
    float = true,
})

hl.window_rule({
    name  = "float-blueman",
    match = { class = "^(blueman-manager|Blueman-manager)$" },
    float = true,
})

hl.window_rule({
    name  = "float-nwg-displays",
    match = { class = "^(nwg-displays)$" },
    float = true,
})

hl.window_rule({
    name  = "float-satty",
    match = { class = "^(com.gabm.satty)$" },
    float = true,
})

-- Don't idle-lock/DPMS while any window is fullscreen (video playback).
-- Windowed audio playback is handled by the pactl check in hypridle.conf.
hl.window_rule({
    name         = "idle-inhibit-fullscreen",
    match        = { class = ".*" },
    idle_inhibit = "fullscreen",
})
