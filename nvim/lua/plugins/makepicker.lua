local fzf = require "fzf-lua"

local M = {}

local function get_make_list_command()
    if vim.fn.executable("make") ~= 1 then
        vim.notify("Make executable not found in PATH", vim.log.levels.WARN)
        return nil
    end

    return [[
        grep -E '^[a-zA-Z0-9][a-zA-Z0-9_-]*:' Makefile 2>/dev/null |
        sed 's/:.*//' | grep -v -E '^[A-Z]+$'
    ]]
end

-- Executes the make list command and returns a table of targets.
local function get_make_targets()
    local command = get_make_list_command()
    if not command then return nil end

    local ok, result = pcall(vim.fn.systemlist, command)
    if not ok then
        vim.notify("Failed to extract make targets: " .. tostring(result), vim.log.levels.ERROR)
        return nil
    end

    local targets = {}
    for _, target in ipairs(result) do
        local trimmed = vim.trim(target)
        if trimmed ~= "" and
            not string.match(trimmed, "^/") and
            not string.match(trimmed, "^%-%-") then
            table.insert(targets, trimmed)
        end
    end

    return targets
end

-- Creates and displays the fzf-lua picker for Makefile targets.
local function make_picker(opts)
    opts = opts or {}

    local targets = get_make_targets()
    if not targets then return end

    if #targets == 0 then
        vim.notify("No make targets found in project root", vim.log.levels.INFO)
        return
    end

    -- Execute selected make target
    local function execute_make_target(selected)
        if not selected or #selected == 0 then return end

        local target = selected[1]
        local escaped_target = vim.fn.shellescape(target)
        local command = string.format("make %s", escaped_target)

        vim.cmd(string.format("botright %dsplit term://%s", math.floor(vim.o.lines * 0.38), command))
        vim.cmd("startinsert")
    end

    fzf.fzf_exec(targets, {
        prompt = "Run> ",
        actions = {
            ['default'] = execute_make_target,
        },
        winopts = {
            backdrop = 100,
        },
    })
end

-- Setup function to configure the make picker
function M.setup()
    vim.keymap.set('n', '<leader>fm', make_picker, { desc = '[F]ind [M]ake Target' })
end

return M
