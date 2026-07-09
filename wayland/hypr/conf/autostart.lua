-- Autostart — ported from sway/config exec/exec_always lines.
--
-- Hyprland exports WAYLAND_DISPLAY / HYPRLAND_INSTANCE_SIGNATURE etc. to the
-- systemd user manager and D-Bus activation env by itself, so sway's
-- import-environment dance is gone. Dropbox still needs a kick: its user unit
-- started at login, before the session existed, and can't see the display.
--
-- NB: no `dex --autostart` here (same as sway) — it would pull in X11-only
-- picom.desktop and double-launch the applets. Start what we need explicitly.

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user try-restart dropbox")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("dunst")
    -- polkit agent: GUI password prompt for privilege escalation (udisks,
    -- NetworkManager, installers). Harmless no-op if not installed.
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    -- cliphist watchers record clipboard history (text + images) for SUPER+V
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- exec_always equivalent: restart waybar at start and on every config reload.
local function restart_waybar()
    hl.exec_cmd("pkill -x waybar; exec waybar")
end
hl.on("hyprland.start", restart_waybar)
hl.on("config.reloaded", restart_waybar)
