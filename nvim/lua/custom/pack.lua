-- A thin weapper around the built-in vim.pack

local M = {}

local ensured = {}
local hooks_installed = false

local has_pack = function()
    return vim.pack and vim.pack.add
end

local flatten_specs = function(specs)
    local items = {}
    for _, spec in ipairs(specs or {}) do
        if type(spec) == "string" and not ensured[spec] then
            ensured[spec] = true
            table.insert(items, spec)
        end
    end
    return items
end

local append_specs = function(target, specs)
    if type(specs) ~= "table" then
        return
    end
    for _, spec in ipairs(specs) do
        if type(spec) == "string" then
            table.insert(target, spec)
        end
    end
end

M.ensure = function(specs)
    if not has_pack() then
        return
    end
    local items = flatten_specs(specs)
    if #items == 0 then
        return
    end
    -- Add specs to pack without confirmation and load them
    -- loading is necessary for vim plugins to be available immediately
    -- neovim plugins require them to be loaded using setup functions
    vim.pack.add(items, { confirm = false, load = true })
end


M.hooks = function()
    -- Sets up autocommands to handle post-install/update actions for specific plugins
    -- Currently, it handles nvim-treesitter to run :TSUpdate after installation or update
    if hooks_installed or not vim.api then
        return
    end
    hooks_installed = true
    local group = vim.api.nvim_create_augroup("CustomPackHooks", { clear = true })
    vim.api.nvim_create_autocmd("PackChanged", {
        group = group,
        callback = function(ev)
            if not has_pack() then
                return
            end
            local data = ev.data or {}
            local spec = data.spec or {}
            if spec.name ~= "nvim-treesitter" then
                return
            end
            if data.kind ~= "install" and data.kind ~= "update" then
                return
            end
            if not data.active then
                vim.cmd.packadd(spec.name)
            end
            vim.schedule(function()
                pcall(function()
                    vim.cmd("TSUpdate")
                end)
            end)
        end,
    })
end

M.setup = function(plugins)
    -- Load and setup plugins from the given list of plugin names
    for _, plugin_name in ipairs(plugins) do
        local ok, plugin = pcall(require, plugin_name)
        if ok and type(plugin.setup) == "function" then
            plugin.setup()
        elseif not ok then
            vim.notify(string.format("Failed to load %s: %s", plugin_name, plugin), vim.log.levels.WARN)
        end
    end
end


M.ensure_specs = function(plugins, extra_specs)
    local combined = {}
    append_specs(combined, extra_specs)

    for _, plugin_name in ipairs(plugins or {}) do
        local ok, plugin = pcall(require, plugin_name)
        if ok and type(plugin) == "table" then
            append_specs(combined, plugin.specs)
        elseif not ok then
            vim.notify(string.format("Failed to load %s: %s", plugin_name, plugin), vim.log.levels.WARN)
        end
    end

    M.ensure(combined)
    M.setup(plugins)
end

return M
