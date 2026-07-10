-- Runtime display behavior: lid switch, external toggle, mirror toggle,
-- workspace throw, hotplug notification. Stateless by design — everything is
-- derived from hl.get_monitors() and a config reload resets displays to the
-- canonical layout in conf/monitors.lua ("reload = reset").
--
-- Workspaces are sway-style (see monitors.lua): they live where created and
-- only move between outputs via native migration (an output going away) or
-- the SUPER+O throw below. Nothing moves back automatically.
--
-- Known reload quirk: reloading while the lid is closed re-enables eDP-1
-- behind the lid (switch binds don't re-fire); close/open the lid to recover.

local monitors = require("conf/monitors")

local INTERNAL = monitors.INTERNAL

-- Through dunst (notify-send), not hl.notification.create — the latter is the
-- compositor's own overlay (where config errors appear), which ignores dunst
-- theming and Do Not Disturb.
local function notify(text)
    hl.exec_cmd(string.format("notify-send -i video-display 'Displays' '%s'", text:gsub("'", "")))
end

-- For messages sent while outputs are being reconfigured: dunst itself can
-- crash on output changes (autostart.lua resurrects it after ~1s), so a
-- same-tick notification would die with it. Deliver after the churn settles.
local function notify_later(text)
    hl.timer(function() notify(text) end, { timeout = 1500, type = "oneshot" })
end

-- Active monitors only: disabled outputs don't enumerate (HL.Monitor has no
-- `disabled` field), which is the foundation of the stateless toggles below.
local function externals()
    local ext = {}
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= INTERNAL then table.insert(ext, m) end
    end
    return ext
end

local function pixel_area(m)
    return (m.width or 0) * (m.height or 0)
end

-- Mirrored outputs are invisible to the Lua API (get_monitors/get_monitor
-- return nothing for them, verified live), so mirror state can't be derived;
-- this flag is consistent anyway because a reload resets both it and the
-- actual mirror (monitors.lua apply_all carries mirror = "").
-- The snapshot makes mirroring transparent to workspaces: outputs that become
-- mirrors leave the layout and their workspaces migrate away, so placement is
-- recorded at mirror-on and restored at mirror-off. Reload while mirrored
-- drops the snapshot — workspaces then stay where they migrated ("reload =
-- reset"), same as any other manual placement.
local mirrored = false
local mirror_snapshot = nil -- { focused = ws id, placement = { [ws id] = monitor name } }

-- External toggle (SUPER+SHIFT+M) ---------------------------------------------
-- Disable/re-enable all external outputs. Use this instead of the monitor's
-- own power button: disabling removes the output from the layout so pinned
-- workspaces migrate to the laptop (power-cycling the screen strands them).

local function toggle_external()
    mirrored = false -- both branches re-apply canonical specs, un-mirroring
    mirror_snapshot = nil
    local ext = externals()
    if #ext == 0 then
        -- Nothing external active: re-assert the canonical layout, which
        -- re-enables any disabled output (specs carry disabled = false).
        monitors.apply_all()
        notify_later("Externals on (canonical layout)")
        return
    end
    -- Keep at least one output alive: with the lid closed only externals are
    -- active, so bring eDP-1 back before switching them off.
    if #ext == #hl.get_monitors() then
        monitors.apply(INTERNAL)
    end
    for _, m in ipairs(ext) do
        hl.monitor({ output = m.name, disabled = true })
    end
end

-- Mirror toggle (SUPER+SHIFT+I) -------------------------------------------------
-- Native mirroring. The source is always an external display — the highest-
-- resolution one if several are connected (first found wins a resolution
-- tie) — and every other output, laptop panel included, becomes its clone.

local function restore_snapshot(snap)
    -- Deferred: the un-mirrored outputs re-add asynchronously and a same-tick
    -- move would still see the old monitor set.
    hl.timer(function()
        for id, mon in pairs(snap.placement) do
            local ws = hl.get_workspace(id)
            if ws and hl.get_monitor(mon) then
                local cur = ws.monitor and ws.monitor.name
                if cur ~= mon then
                    hl.dispatch(hl.dsp.workspace.move({ workspace = id, monitor = mon }))
                end
            end
        end
        if snap.focused and hl.get_workspace(snap.focused) then
            hl.dispatch(hl.dsp.focus({ workspace = snap.focused }))
        end
    end, { timeout = 500, type = "oneshot" })
end

local function mirror_toggle()
    if mirrored then
        mirrored = false
        monitors.apply_all()
        if mirror_snapshot then
            restore_snapshot(mirror_snapshot)
            mirror_snapshot = nil
        end
        notify_later("Mirror off")
        return
    end
    local act = hl.get_monitors()
    if #act < 2 then
        notify("Mirror: need a second output connected")
        return
    end
    -- With >= 2 active monitors at least one is external, so src is never nil.
    local src
    for _, m in ipairs(act) do
        if m.name ~= INTERNAL and (not src or pixel_area(m) > pixel_area(src)) then
            src = m
        end
    end
    local snap = { placement = {} }
    local focused = hl.get_active_workspace()
    snap.focused = focused and focused.id or nil
    for _, ws in ipairs(hl.get_workspaces()) do
        if ws.monitor then snap.placement[ws.id] = ws.monitor.name end
    end
    mirror_snapshot = snap
    for _, m in ipairs(act) do
        if m.name ~= src.name then
            hl.monitor({ output = m.name, mode = "preferred", position = "auto", scale = 1, mirror = src.name })
        end
    end
    mirrored = true
    notify_later("Mirroring " .. src.name .. " onto every other output")
end

-- Workspace throw (SUPER+O) ------------------------------------------------------
-- Move the focused workspace to the other monitor. This is the manual "what
-- goes on the external" control; press again to bring it back.

local function throw_workspace()
    local act = hl.get_monitors()
    if #act < 2 then
        notify("No other monitor to throw to")
        return
    end
    local cur = hl.get_active_monitor()
    local ws = hl.get_active_workspace()
    if not cur or not ws then return end
    for _, m in ipairs(act) do
        if m.name ~= cur.name then
            hl.dispatch(hl.dsp.workspace.move({ workspace = ws.id, monitor = m.name }))
            return
        end
    end
end

hl.bind("SUPER + SHIFT + M", toggle_external)
hl.bind("SUPER + SHIFT + I", mirror_toggle)
hl.bind("SUPER + O",         throw_workspace)

-- Lid switch — dock-aware -------------------------------------------------------
-- Docked (external active): closing the lid disables eDP-1; its workspaces
-- migrate to the external natively and STAY there on reopen (sway-style, no
-- pinning) — throw them back with SUPER+O as needed. Undocked: no-op, logind
-- suspends as normal (docked = ignore in logind.conf).
-- NB: verify the switch name with `hyprctl devices` ("Lid Switch" is typical).

local function lid_close()
    if #externals() > 0 then
        hl.monitor({ output = INTERNAL, disabled = true })
    end
end

local function lid_open()
    monitors.apply(INTERNAL)
end

hl.bind("switch:on:Lid Switch",  lid_close, { locked = true })
hl.bind("switch:off:Lid Switch", lid_open,  { locked = true })

-- Monitor hotplug notification --------------------------------------------------
-- Suggest a scale: monitor diagonal (px) relative to the laptop panel's, so an
-- output with ~1.6x the pixel diagonal reads comfortably at scale 1.6.

hl.on("monitor.added", function(m)
    if m.name == INTERNAL then return end -- lid re-opens aren't "new displays"
    local w, h = m.width or 0, m.height or 0
    local ref = math.sqrt(1920 * 1920 + 1200 * 1200)
    local ideal = math.floor(math.sqrt(w * w + h * h) / ref / 0.25 + 0.5) * 0.25
    if ideal < 1.0 then ideal = 1.0 end
    local desc = (m.description or ""):gsub("'", "")
    hl.exec_cmd(string.format(
        "notify-send -i video-display 'Display connected: %s' '%s\n%dx%d\nsuggested scale ~%.2f'",
        m.name, desc, w, h, ideal))
end)

-- Exported only so `hyprctl dispatch 'function() ... end'` can drive these for
-- live testing (require() returns this cached module).
return {
    toggle_external = toggle_external,
    mirror_toggle = mirror_toggle,
    throw_workspace = throw_workspace,
    lid_close = lid_close,
    lid_open = lid_open,
}
