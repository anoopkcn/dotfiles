-- Minimal Hyprland instance that renders the ReGreet login screen.
-- Deployed to /etc/greetd/ (see setup.sh); launched by greetd as:
--   dbus-run-session start-hyprland -- -c /etc/greetd/hyprland-greeter.lua
-- ReGreet exits after a session is picked, then the trailing hyprctl kills
-- this compositor so greetd can hand the seat to the chosen session.

-- Same monitor layout as the real session (hypr/conf/monitors.lua) so the
-- greeter renders sharp on both screens instead of tuigreet's smeared VT text.
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@30",     position = "0x0",      scale = 1.6 })
hl.monitor({ output = "eDP-1",    mode = "1920x1200@60.003", position = "222x1350", scale = 1.0 })
hl.monitor({ output = "",         mode = "preferred",        position = "auto",     scale = 1.0 })

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")

hl.config({
    -- No animations, same as the real session (hypr/conf/options.lua).
    animations = {
        enabled = false,
    },

    misc = {
        -- Backdrop shown before ReGreet maps its window; match the average
        -- tone of the wallpaper so startup doesn't flash black -> bright.
        background_color                = "rgb(a8a199)",
        disable_hyprland_logo           = true,
        disable_splash_rendering        = true,
        disable_hyprland_guiutils_check = true,
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("regreet; hyprctl dispatch 'hl.dsp.exit()'")
end)
