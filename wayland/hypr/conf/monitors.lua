-- Canonical monitor layout.
--
-- Positions are in logical (scaled) pixels: HDMI-A-1 is 3840x2160/1.6 =
-- 2400x1350 with eDP-1 directly below it, 222px in from the HDMI's left edge.
--
-- Workspaces are deliberately NOT pinned to monitors (sway-style): a
-- workspace lives on whichever monitor it was created on, connecting an
-- output steals nothing, and moving workspaces between outputs is manual
-- (SUPER+O in displays.lua).
--
-- Exported as a module so displays.lua can re-apply the canonical layout to
-- undo runtime mirror/disable states.
--
-- NB: wayland/greetd/hyprland-greeter.lua duplicates the layout table (it runs
-- from /etc/greetd and cannot require this file) — keep them in sync by hand.

local M = {}

M.INTERNAL = "eDP-1" -- built-in panel; every other output is "external"

-- disabled = false and mirror = "" are load-bearing: omitted spec fields mean
-- "leave as is", so re-applying a rule without them would NOT re-enable a
-- runtime-disabled output or clear a runtime mirror (toggle_external,
-- lid_open and mirror_toggle depend on this).
M.MONITORS = {
    { output = "HDMI-A-1", mode = "3840x2160@30",     position = "0x0",      scale = 1.6, disabled = false, mirror = "" },
    { output = "eDP-1",    mode = "1920x1200@60.003", position = "222x1350", scale = 1.0, disabled = false, mirror = "" },
    -- Fallback for any monitor not listed above.
    { output = "",         mode = "preferred",        position = "auto",     scale = 1.0, disabled = false, mirror = "" },
}

-- Re-apply the configured rule for one output (fallback rule if unknown).
function M.apply(name)
    for _, m in ipairs(M.MONITORS) do
        if m.output == name then
            hl.monitor(m)
            return
        end
    end
    hl.monitor({ output = name, mode = "preferred", position = "auto", scale = 1.0, disabled = false, mirror = "" })
end

-- Re-apply the whole canonical layout (undoes mirror/disabled states).
function M.apply_all()
    for _, m in ipairs(M.MONITORS) do
        hl.monitor(m)
    end
end

M.apply_all()

return M
