-- Monitor layout + dock-aware lid switch.
--
-- The desk monitor is matched by description, not port: "HDMI-A-1" would
-- match ANY device on that connector (projectors, meeting-room displays),
-- force-feeding it 4K@30/1.6. Unknown displays fall through to the default
-- rule (preferred mode, auto position, scale 1) so presentations just work.
--
-- Positions are in logical (scaled) pixels: the Samsung is 3840x2160/1.6 =
-- 2400x1350 with eDP-1 directly below it, 222px in from its left edge.

local INTERNAL = "eDP-1"

-- disabled = false on eDP-1 is load-bearing: omitted spec fields mean "leave
-- as is", so lid_open re-applying the rule would not re-enable the panel
-- without it.
local EDP = { output = INTERNAL, mode = "1920x1200@60.003", position = "222x1350", scale = 1.0, disabled = false }

local MONITORS = {
    -- Desk monitor (4K@30 is the HDMI bandwidth limit on this port).
    { output = "desc:Samsung Electric Company U28E590 HTPM312489", mode = "3840x2160@30", position = "0x0", scale = 1.6 },
    EDP,
    -- Everything else: Hyprland's default behavior.
    { output = "", mode = "preferred", position = "auto", scale = 1.0 },
}

for _, m in ipairs(MONITORS) do
    hl.monitor(m)
end

-- Docked (external active): closing the lid disables eDP-1 so its workspaces
-- migrate to the external. Undocked: no-op, logind suspends as normal
-- (docked = ignore in logind.conf).
-- Known reload quirk: reloading while the lid is closed re-enables eDP-1
-- behind the lid (switch binds don't re-fire); close/open the lid to recover.
hl.bind("switch:on:Lid Switch", function()
    if #hl.get_monitors() > 1 then
        hl.monitor({ output = INTERNAL, disabled = true })
    end
end, { locked = true })

hl.bind("switch:off:Lid Switch", function()
    hl.monitor(EDP)
end, { locked = true })
