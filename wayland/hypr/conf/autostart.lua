-- Autostart — session daemons are systemd user units WantedBy
-- graphical-session.target (units + drop-ins live in wayland/systemd/,
-- symlinked and enabled by setup.sh). Hyprland exports WAYLAND_DISPLAY /
-- HYPRLAND_INSTANCE_SIGNATURE etc. to the systemd user manager by itself, so
-- by the time hyprland.start fires we only have to bounce the session
-- target: every daemon starts once, single-instanced, ordered (tray applets
-- After=waybar), restarted on failure, logged in the journal. `restart`
-- rather than `start` so a compositor restart within one login re-launches
-- everything with the fresh WAYLAND_DISPLAY instead of no-opping.
--
-- The old exec_cmd-per-daemon approach raced: dropbox's login-time unit
-- fought its restart kick, and applets registered their tray icons into a
-- waybar that was being pkill'd/respawned at that same instant (lost
-- bluetooth icon). Keep everything in units; don't add exec_cmd daemons here.
--
-- NB: xdg-desktop-autostart.target stays out of the session on purpose
-- (nothing Wants it) — it would double-launch dropbox/blueman/nm-applet from
-- their /etc/xdg/autostart entries and pull in X11-only picom.desktop.

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user restart hyprland-session.target")
end)

-- exec_always equivalent: bounce waybar on config reload (hyprland.start is
-- covered by the session target restart above).
hl.on("config.reloaded", function()
    hl.exec_cmd("systemctl --user try-restart waybar")
end)

-- systemd resurrects crashes (Restart=on-failure), but not clean exits or
-- wedges. waybar and dunst sometimes die on output changes (observed:
-- physical HDMI replug, un-mirroring); hyprpaper can wedge with the process
-- alive (IPC hung, wallpaper gone — observed after a boot-time hotplug), so
-- probe its IPC instead of unit state. Check shortly after any monitor comes
-- or goes (deferred: output changes settle async) — no-op while healthy.
local function resurrect_daemons()
    hl.timer(function()
        hl.exec_cmd("systemctl --user is-active --quiet waybar || systemctl --user restart waybar")
        hl.exec_cmd("hyprctl hyprpaper listactive >/dev/null 2>&1 || systemctl --user restart hyprpaper")
        hl.exec_cmd("systemctl --user is-active --quiet dunst || systemctl --user restart dunst")
    end, { timeout = 1000, type = "oneshot" })
end
hl.on("monitor.added", resurrect_daemons)
hl.on("monitor.removed", resurrect_daemons)
