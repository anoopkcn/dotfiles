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

-- Reload used to re-enable eDP-1 behind a closed lid (rules re-apply with
-- disabled = false and switch binds don't re-fire), stranding its workspaces
-- on an invisible panel. Read the ACPI lid state directly and load the panel
-- disabled when the lid is down and an external is active. EDP itself keeps
-- disabled = false for the lid-open/mirror paths below. eDP-1 can't be the
-- "external active" witness: when already disabled it is invisible to
-- get_monitors(), which is exactly the reload case. On first boot
-- get_monitors() is empty, so the panel comes up as before.
local function lid_closed()
    local f = io.open("/proc/acpi/button/lid/LID0/state", "r")
    if f == nil then return false end
    local s = f:read("*a") or ""
    f:close()
    return s:find("closed") ~= nil
end

local function external_active()
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= INTERNAL then return true end
    end
    return false
end

for _, m in ipairs(MONITORS) do
    if m == EDP and lid_closed() and external_active() then
        m = { output = INTERNAL, disabled = true }
    end
    hl.monitor(m)
end

-- Presentation mirror (Fn+F11, the projector key): mirror everything onto an unknown
-- classroom display. The highest-resolution external is the mirror SOURCE
-- (content renders there at its native mode); eDP-1 and any lesser externals
-- become mirrors of it — mirroring the other direction would upscale the
-- 1200p panel and look soft. Toggling off puts every workspace back on the
-- monitor it came from.
--
-- State is Lua-local: a reload wipes it, but a reload also clears the
-- mirrors themselves, so state and reality reset together — after a reload
-- mid-presentation, just toggle again.
local mirror = { active = false, busy = false, source = nil, targets = {}, specs = {}, snapshot = {}, focused_ws = nil }

-- Reject toggles while a transition's timers are still running: a rapid
-- double-press mid-churn would read a half-settled monitor list. The lock
-- self-clears on a timer so a lost callback can never wedge the keybind;
-- the generation counter lets a later, longer hold outlive an earlier one.
local busy_gen = 0
local function hold_busy(ms)
    mirror.busy = true
    busy_gen = busy_gen + 1
    local gen = busy_gen
    hl.timer(function()
        if busy_gen == gen then mirror.busy = false end
    end, { timeout = ms, type = "oneshot" })
end

-- Move each snapshotted workspace home. A monitor can still be settling
-- when this first runs (seen when the mirror source was yanked and its
-- ex-mirrors were re-promoted late) — entries whose monitor is not up yet
-- get one retry pass instead of being dropped.
local function restore_workspaces(snapshot, focused, attempt)
    local missed = {}
    for id, mon in pairs(snapshot) do
        if hl.get_workspace(id) ~= nil then
            if hl.get_monitor(mon) ~= nil then
                hl.dispatch(hl.dsp.workspace.move({ workspace = id, monitor = mon }))
            else
                missed[id] = mon
            end
        end
    end
    if focused ~= nil and hl.get_workspace(focused) ~= nil then
        hl.dispatch(hl.dsp.focus({ workspace = focused }))
    end
    if next(missed) ~= nil and attempt < 2 then
        hl.timer(function()
            restore_workspaces(missed, nil, attempt + 1)
        end, { timeout = 800, type = "oneshot" })
    end
end

-- Dunst, not Hyprland's built-in overlay. The stack tag makes a quick
-- on/off replace the previous toast instead of piling up.
-- Output changes can kill dunst (it's D-Bus-activated back, so delivery
-- still works, but a toast sent just BEFORE the change dies with it) —
-- toasts around a mirror transition pass a delay to outlive the churn.
local function notify(text, delay)
    local cmd = "dunstify -t 3000 -h string:x-dunst-stack-tag:mirror 'Mirror' '" .. text .. "'"
    if delay == nil then
        hl.exec_cmd(cmd)
    else
        hl.timer(function() hl.exec_cmd(cmd) end, { timeout = delay, type = "oneshot" })
    end
end

-- Mirrored outputs are hidden from hl.get_monitors(), so the is_mirror
-- checks below only matter if that ever changes.
local function pick_source()
    local best = nil
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= INTERNAL and not m.is_mirror then
            if best == nil
                or m.width * m.height > best.width * best.height
                or (m.width * m.height == best.width * best.height and m.refresh_rate > best.refresh_rate) then
                best = m
            end
        end
    end
    return best
end

-- Make an output mirror the source, tracking it for cleanup at toggle-off.
-- Idempotent: re-joining an existing target is a no-op.
local function join_mirror(name)
    for _, t in ipairs(mirror.targets) do
        if t == name then return end
    end
    -- Capture the pre-mirror mode/position/scale: re-enabling a bounced
    -- output with "leave as is" can come back at a bogus low mode (observed:
    -- Samsung at 1280x720 after un-mirroring), so toggle-off restores this
    -- exact spec instead.
    local m = hl.get_monitor(name)
    if m ~= nil then
        mirror.specs[name] = {
            output = name,
            mode = ("%dx%d@%.3f"):format(m.width, m.height, m.refresh_rate),
            position = ("%dx%d"):format(m.x, m.y),
            scale = m.scale,
            disabled = false,
            mirror = "none",
        }
    end
    table.insert(mirror.targets, name)
    hl.monitor({ output = name, mirror = mirror.source })
end

local function mirror_on()
    local source = pick_source()
    if source == nil then
        notify("No external display connected")
        return
    end

    local targets = {}
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= source.name and not m.is_mirror then
            table.insert(targets, m.name)
        end
    end
    if #targets == 0 then
        notify("Only one display active")
        return
    end

    -- Snapshot workspace -> monitor before the compositor migrates everything
    -- to the source. Specials follow their monitor on their own.
    mirror.snapshot = {}
    for _, ws in ipairs(hl.get_workspaces()) do
        if not ws.special and ws.monitor ~= nil then
            mirror.snapshot[ws.id] = ws.monitor.name
        end
    end
    local active = hl.get_active_workspace()
    mirror.focused_ws = active and active.id or nil

    hold_busy(1200)
    mirror.active, mirror.source, mirror.targets = true, source.name, {}
    for _, name in ipairs(targets) do
        join_mirror(name)
    end
    notify(("Mirroring on %s (%dx%d)"):format(source.name, source.width, source.height), 2000)
end

local function mirror_off(source_gone)
    hold_busy(2800)
    -- Clear each mirror, then BOUNCE targets still hidden from
    -- get_monitors() through disable/enable: un-mirroring alone sometimes
    -- brings the output back without re-advertising its wl_output, leaving
    -- it blank — no waybar, no wallpaper — and restarting the clients does
    -- not help because they cannot bind the output at all. The mirror
    -- source (still visible) is never bounced, so one display stays up
    -- throughout.
    local bounced = {}
    for _, name in ipairs(mirror.targets) do
        hl.monitor({ output = name, mirror = "none" })
        if hl.get_monitor(name) == nil then
            bounced[name] = true
            hl.monitor({ output = name, disabled = true })
        end
    end

    local targets, specs = mirror.targets, mirror.specs
    local snapshot, focused = mirror.snapshot, mirror.focused_ws
    mirror.active, mirror.source, mirror.targets = false, nil, {}
    mirror.snapshot, mirror.focused_ws, mirror.specs = {}, nil, {}

    hl.timer(function()
        -- Re-assert every captured spec, not only the bounced ones: when
        -- the source is yanked the compositor promotes the ex-mirrors on
        -- its own — visible again, so not bounced, but at a bogus mode
        -- (observed: Samsung back at 1280x720, scale 1.0).
        for _, name in ipairs(targets) do
            if specs[name] ~= nil then
                hl.monitor(specs[name])
            elseif name == INTERNAL then
                hl.monitor(EDP)
            elseif bounced[name] then
                hl.monitor({ output = name, disabled = false })
            end
        end
    end, { timeout = 300, type = "oneshot" })

    hl.timer(function()
        restore_workspaces(snapshot, focused, 1)
        -- Un-mirroring is a known waybar killer (see autostart.lua); the
        -- resurrect hook there only covers add/remove events.
        hl.exec_cmd("systemctl --user is-active --quiet waybar || systemctl --user restart waybar")
    end, { timeout = 800, type = "oneshot" })

    -- VERIFY the recovery: one bounce is usually enough to get a target's
    -- wl_output re-advertised, but not always (observed after a lid cycle
    -- while mirrored: monitor configured fine, yet zero layer surfaces —
    -- no waybar, no wallpaper, and clients cannot bind it). Any restored
    -- target still bare gets one slower re-bounce plus a daemon nudge.
    hl.timer(function()
        local bare = {}
        for _, name in ipairs(targets) do
            local ls = hl.get_layers({ monitor = name })
            if hl.get_monitor(name) ~= nil and (ls == nil or #ls == 0) then
                table.insert(bare, name)
            end
        end
        if #bare == 0 then return end
        hold_busy(2000)
        for _, name in ipairs(bare) do
            hl.monitor({ output = name, disabled = true })
        end
        hl.timer(function()
            for _, name in ipairs(bare) do
                if specs[name] ~= nil then
                    hl.monitor(specs[name])
                elseif name == INTERNAL then
                    hl.monitor(EDP)
                else
                    hl.monitor({ output = name, disabled = false })
                end
            end
            hl.exec_cmd("systemctl --user is-active --quiet waybar || systemctl --user restart waybar")
            hl.exec_cmd("hyprctl hyprpaper listactive >/dev/null 2>&1 || systemctl --user restart hyprpaper")
        end, { timeout = 1000, type = "oneshot" })
    end, { timeout = 1800, type = "oneshot" })

    notify(source_gone and "Source unplugged — layout restored" or "Mirroring off", 2000)
end

-- Global so it's also scriptable: hyprctl eval 'mirror_toggle()'
function _G.mirror_toggle()
    if mirror.busy then
        notify("Displays are settling — try again in a second")
        return
    end
    if mirror.active then mirror_off(false) else mirror_on() end
end

-- Fn+F11, the key with the projector glyph. It emits raw keycode 240
-- (KEY_UNKNOWN — no keysym exists for it), so it is bound by keycode;
-- found via `libinput debug-events --show-keycodes`. Note the fork takes
-- KERNEL keycodes here, not XKB (kernel + 8).
hl.bind("code:240", mirror_toggle)

-- A display plugged in mid-presentation joins the mirror. 50ms event budget:
-- read the name now, do the work in a timer.
hl.on("monitor.added", function(m)
    if not mirror.active then return end
    local ok, name = pcall(function() return m.name end)
    if not ok or name == nil then return end
    hl.timer(function()
        if mirror.active and name ~= mirror.source then
            join_mirror(name)
        end
    end, { timeout = 500, type = "oneshot" })
end)

-- Source yanked mid-presentation: end the mode; its workspaces have already
-- migrated and the restore skips vanished monitors. A removed non-source
-- target intentionally stays in mirror.targets so toggle-off still clears
-- its persistent rule (rules re-apply on the next hotplug otherwise). The
-- event can fire more than once per removal; only the first deferred call
-- still sees active = true.
hl.on("monitor.removed", function(m)
    if not mirror.active then return end
    local ok, name = pcall(function() return m.name end)
    if not ok or name ~= mirror.source then return end
    hl.timer(function()
        if mirror.active then mirror_off(true) end
    end, { timeout = 500, type = "oneshot" })
end)

-- Docked (external active): closing the lid disables eDP-1 so its workspaces
-- migrate to the external. Undocked: no-op, logind suspends as normal
-- (docked = ignore in logind.conf). The reload-behind-closed-lid case is
-- handled at load time above via the ACPI lid state.
hl.bind("switch:on:Lid Switch", function()
    -- Mirrored outputs are hidden from get_monitors(), so while presenting
    -- the count alone would say "one monitor"; mirror.active covers that.
    if #hl.get_monitors() > 1 or mirror.active then
        hl.monitor({ output = INTERNAL, disabled = true })
    end
end, { locked = true })

hl.bind("switch:off:Lid Switch", function()
    hl.monitor(EDP)
    -- The mirror assignment survives disable/re-enable, so a target eDP-1
    -- comes back still mirrored on its own; join covers the case where the
    -- mirror started while the lid was closed.
    if mirror.active then
        join_mirror(INTERNAL)
    end
end, { locked = true })
