---@brief
--- LICENSE: MIT
--- by @anoopkcn
--- https://github.com/anoopkcn/dotfiles/blob/main/nvim/lua/modules/makepicker.lua
--- describes a Neovim module that provides an FZF-based picker for Makefile targets.

local M = {}

local function get_make_targets()
    if vim.fn.executable("make") ~= 1 then
        vim.notify("Make executable not found in PATH", vim.log.levels.WARN)
        return nil
    end

    local makefile_path = vim.fn.findfile("Makefile", ".;")
    if makefile_path == "" then
        vim.notify("Could not locate a Makefile", vim.log.levels.INFO)
        return nil
    end

    local ok, lines = pcall(vim.fn.readfile, makefile_path)
    if not ok then
        vim.notify("Failed to read Makefile: " .. tostring(lines), vim.log.levels.ERROR)
        return nil
    end

    local targets = {}
    for _, line in ipairs(lines) do
        local trimmed = vim.trim(line)

        if trimmed ~= "" and not vim.startswith(trimmed, "#") then
            local name, remainder = trimmed:match("^([%w][%w_-]*)%s*:(.*)$")
            if name and not name:match("^[A-Z]+$") then
                local description
                if remainder then
                    description = remainder:match("##%s*(.+)$")
                    if description then description = vim.trim(description) end
                end

                table.insert(targets, { name = name, description = description })
            end
        end
    end

    return targets
end

-- Creates and displays the fzf-lua picker for Makefile targets.
local function make_picker(opts)
    opts = opts or {}

    local targets = get_make_targets()
    if not targets then return end

    if vim.tbl_isempty(targets) then
        vim.notify("No make targets found in project root", vim.log.levels.INFO)
        return
    end

    local ok_fzf, fzf = pcall(require, "fzf-lua")
    if not ok_fzf then
        vim.notify("fzf-lua is not available", vim.log.levels.WARN)
        return
    end

    local entries = {}
    for _, item in ipairs(targets) do
        if item.description and item.description ~= "" then
            table.insert(entries, string.format("%-25s %s", item.name, item.description))
        else
            table.insert(entries, item.name)
        end
    end

    -- Execute selected make target
    local function execute_make_target(selected)
        if not selected or #selected == 0 then return end

        local target = selected[1]:match("^(%S+)")
        local escaped_target = vim.fn.shellescape(target)
        local command = string.format("make %s", escaped_target)

        vim.cmd(string.format("botright %dsplit term://%s", math.floor(vim.o.lines * 0.38), command))
        vim.cmd("startinsert")
    end

    fzf.fzf_exec(entries, {
        prompt = "make> ",
        actions = {
            ['default'] = execute_make_target,
        },
        -- winopts = {
        --     backdrop = 100,
        -- },
    })
end

function M.setup()
    vim.keymap.set('n', '<leader>fm', make_picker, { desc = '[F]ind [M]ake Target' })
end

return M
