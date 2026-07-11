-- Look, feel, and input — slate theme carried over from the sway config.

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
        layout      = "dwindle",
        border_size = 2,
        gaps_in     = 4,
        gaps_out    = 6,
        col = {
            active_border   = "rgb(3c4e7a)", -- $sel
            inactive_border = "rgb(32384a)", -- $border
        },
    },

    decoration = {
        rounding = 2,
        shadow = { enabled = false }, -- on by default; sway-style flat look
    },

    -- sway has no animations; keep the same feel. Delete to get the defaults.
    animations = {
        enabled = false,
    },

    dwindle = {
        preserve_split = true, -- needed for the togglesplit bind (SUPER+E)
        force_split    = 2,    -- new windows always split right/bottom (sway-style)
    },

    misc = {
        font_family = "Berkeley Mono Variable",
        -- xdg-activation focuses the window instead of marking it urgent —
        -- needed for kitty's focus-window RC (ks session switcher).
        focus_on_activate       = true,
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        -- Any input wakes DPMS'd-off displays. Off by default, which means a
        -- stray dpms-off leaves screens black with no obvious way back —
        -- indistinguishable from a hang (learned the hard way 2026-07-11).
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,
    },

    cursor = {
        -- i915 ghost-cursor-trail fix; replaces WLR_NO_HARDWARE_CURSORS
        -- from environment.d (wlroots-only, ignored by Hyprland).
        no_hardware_cursors = 1,
    },

    binds = {
        -- Focus keys walk a group's tabs before leaving the group, which is
        -- how sway's tabbed containers navigated.
        movefocus_cycles_groupfirst = true,
    },

    input = {
        kb_layout = "us",
        touchpad = {
            tap_to_click         = true,
            tap_button_map       = "lrm", -- 1 finger=left, 2=right, 3=middle
            tap_and_drag         = true,
            drag_lock            = 0,
            clickfinger_behavior = true,  -- physical click by finger count
            natural_scroll       = true,
            disable_while_typing = true,
            scroll_factor        = 0.5,
        },
    },

    -- Groups replace sway's tabbed layout; the groupbar is the tab strip.
    group = {
        auto_group = true, -- new windows join the focused group (sway-tabbed feel)
        col = {
            border_active   = "rgb(3c4e7a)",
            border_inactive = "rgb(32384a)",
        },
        groupbar = {
            font_family         = "Berkeley Mono Variable",
            font_size           = 11,
            height              = 22,
            gradients           = false,
            text_color          = "rgb(e0e2ea)", -- $fg
            text_color_inactive = "rgb(828c9e)", -- $muted
            col = {
                active   = "rgb(3c4e7a)", -- $sel
                inactive = "rgb(1d2029)", -- $bg_alt
            },
        },
    },
})
