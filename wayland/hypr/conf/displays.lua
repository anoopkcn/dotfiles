-- Display logic — replaces the sway-era sway-lib.sh, toggle-external.sh,
-- mirror-external.sh, lid-switch.sh and output-notify.sh with in-compositor Lua.
--
-- State lives in files under XDG_RUNTIME_DIR, NOT in Lua variables: a config
-- reload recreates the Lua context, and reloads also re-run monitors.lua's
-- apply_all(), so the config.reloaded handler at the bottom re-asserts
-- whatever runtime display state the files say should still be in effect.
--
-- Object field names verified against /usr/share/hypr/stubs (0.55.4).

local monitors = require("conf/monitors")

local INTERNAL = monitors.INTERNAL
local RUNTIME = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
local MIRROR_STATE = RUNTIME .. "/hypr-mirror-on"
local EXTERNALS_STATE = RUNTIME .. "/hypr-externals-off"
local LID_STATE = RUNTIME .. "/hypr-lid-workspaces"

-- Small file helpers ---------------------------------------------------------

local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close() return true end
    return false
end

-- Read lines from a state file; {} if the file doesn't exist.
local function read_lines(path)
    local lines = {}
    local f = io.open(path, "r")
    if not f then return lines end
    for line in f:lines() do
        if line ~= "" then table.insert(lines, line) end
    end
    f:close()
    return lines
end

local function write_lines(path, lines)
    local f = io.open(path, "w")
    if not f then return end
    f:write(table.concat(lines, "\n"), "\n")
    f:close()
end

local function notify(text)
    hl.notification.create({ text = text, timeout = 4000 })
end

-- Monitor helpers -------------------------------------------------------------

-- Disabled outputs don't enumerate in hl.get_monitors() (Monitor objects have
-- no `disabled` field), so everything it returns is active.
local function active_monitors()
    return hl.get_monitors()
end

-- Physical pixel area.
local function pixel_area(m)
    local w, h = m.width or 0, m.height or 0
    return w * h, w, h
end

-- Workspace.monitor is a Monitor object (nil if orphaned).
local function ws_monitor_name(ws)
    local m = ws.monitor
    return m and m.name or nil
end

-- Workspace selector for dispatchers: numeric names are IDs, else name:.
local function ws_selector(name)
    return tonumber(name) or ("name:" .. name)
end

-- Mirror (SUPER+SHIFT+I) --------------------------------------------------------
-- Native mirroring, sharpest-source: the highest-resolution active monitor
-- keeps rendering normally (ALL workspaces, live switching included) and every
-- other monitor becomes a clone of it. No wl-mirror, no workspace juggling.

local function mirror_on(quiet)
    local act = active_monitors()
    if #act < 2 then
        if not quiet then notify("Mirror: need a second output connected") end
        return false
    end
    local src = act[1]
    for _, m in ipairs(act) do
        if pixel_area(m) > pixel_area(src) then src = m end
    end
    for _, m in ipairs(act) do
        if m.name ~= src.name then
            hl.monitor({ output = m.name, mode = "preferred", position = "auto", scale = 1, mirror = src.name })
        end
    end
    if not quiet then notify("Mirroring " .. src.name .. " onto every other output") end
    return true
end

local function mirror_toggle()
    if file_exists(MIRROR_STATE) then
        os.remove(MIRROR_STATE)
        monitors.apply_all()
        notify("Mirror off")
    elseif mirror_on(false) then
        write_lines(MIRROR_STATE, { "on" })
    end
end

-- External toggle (SUPER+SHIFT+M) ------------------------------------------------
-- Disable/re-enable all external outputs. Use this instead of the monitor's own
-- power button: disabling removes the output from the layout so workspaces
-- migrate back to the laptop (power-cycling the screen alone strands them).

local function toggle_external()
    if file_exists(EXTERNALS_STATE) then
        for _, name in ipairs(read_lines(EXTERNALS_STATE)) do
            monitors.apply(name)
        end
        os.remove(EXTERNALS_STATE)
        return
    end
    local ext = {}
    for _, m in ipairs(active_monitors()) do
        if m.name ~= INTERNAL then table.insert(ext, m.name) end
    end
    if #ext == 0 then
        notify("No external output connected")
        return
    end
    -- Record names BEFORE disabling: disabled monitors may not enumerate.
    write_lines(EXTERNALS_STATE, ext)
    for _, name in ipairs(ext) do
        hl.monitor({ output = name, disabled = true })
    end
end

hl.bind("SUPER + SHIFT + M", toggle_external)
hl.bind("SUPER + SHIFT + I", mirror_toggle)

-- Lid switch — dock-aware (was lid-switch.sh) ---------------------------------------
-- Closing the lid WITH an external active moves eDP-1's workspaces onto the
-- external and disables eDP-1 (logind is docked=ignore, so no suspend).
-- Undocked, this no-ops and logind suspends as normal. Opening restores the
-- stashed workspaces and focus. State file format: line 1 = focused workspace,
-- rest = workspaces that lived on eDP-1.
-- NB: verify the switch name with `hyprctl devices` ("Lid Switch" is typical).

local function lid_close()
    local has_external = false
    for _, m in ipairs(active_monitors()) do
        if m.name ~= INTERNAL then has_external = true end
    end
    if not has_external then return end -- undocked: let logind suspend

    -- First close only (file is the source of truth across reloads).
    if not file_exists(LID_STATE) then
        local lines = {}
        local focused = hl.get_active_workspace()
        table.insert(lines, focused and tostring(focused.name) or "")
        for _, ws in ipairs(hl.get_workspaces()) do
            if ws_monitor_name(ws) == INTERNAL then
                table.insert(lines, tostring(ws.name))
            end
        end
        write_lines(LID_STATE, lines)
    end
    hl.monitor({ output = INTERNAL, disabled = true })
end

local function lid_open()
    monitors.apply(INTERNAL)
    if not file_exists(LID_STATE) then return end

    -- Poll until the panel is back (up to ~5s), then move workspaces home.
    local tries = 0
    local poll
    poll = hl.timer(function()
        tries = tries + 1
        local ready = false
        for _, m in ipairs(active_monitors()) do
            if m.name == INTERNAL then ready = true end
        end
        if not ready and tries < 50 then return end
        poll:set_enabled(false)
        if ready then
            local lines = read_lines(LID_STATE)
            local focused = table.remove(lines, 1)
            for _, name in ipairs(lines) do
                hl.dispatch(hl.dsp.workspace.move({ workspace = ws_selector(name), monitor = INTERNAL }))
            end
            if focused and focused ~= "" then
                hl.dispatch(hl.dsp.focus({ workspace = ws_selector(focused) }))
            end
        end
        os.remove(LID_STATE)
    end, { timeout = 100, type = "repeat" })
end

hl.bind("switch:on:Lid Switch",  lid_close, { locked = true })
hl.bind("switch:off:Lid Switch", lid_open,  { locked = true })

-- Monitor hotplug notification (was output-notify.sh) --------------------------------
-- Suggest a scale: monitor diagonal (px) relative to the laptop panel's, so an
-- output with ~1.6x the pixel diagonal reads comfortably at scale 1.6.

hl.on("monitor.added", function(m)
    if m.name == INTERNAL then return end -- lid re-opens aren't "new displays"
    local _, w, h = pixel_area(m)
    local ref = math.sqrt(1920 * 1920 + 1200 * 1200)
    local ideal = math.floor(math.sqrt(w * w + h * h) / ref / 0.25 + 0.5) * 0.25
    if ideal < 1.0 then ideal = 1.0 end
    local desc = (m.description or ""):gsub("'", "")
    hl.exec_cmd(string.format(
        "notify-send -i video-display 'Display connected: %s' '%s\n%dx%d\nsuggested scale ~%.2f'",
        m.name, desc, w, h, ideal))
end)

-- Reload survival -----------------------------------------------------------------
-- A reload just re-ran monitors.lua (canonical layout). Re-assert whatever the
-- state files say is still in effect. (Hyprland does not re-fire switch binds
-- on reload the way sway's bindswitch --reload did; the files carry the state.)

hl.on("config.reloaded", function()
    if file_exists(LID_STATE) then
        hl.monitor({ output = INTERNAL, disabled = true })
    end
    for _, name in ipairs(read_lines(EXTERNALS_STATE)) do
        hl.monitor({ output = name, disabled = true })
    end
    if file_exists(MIRROR_STATE) then
        mirror_on(true)
    end
end)
