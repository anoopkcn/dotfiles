local M = {}

local ensured = {}
local hooks_installed = false

local function has_pack()
    return vim.pack and vim.pack.add
end

local function flatten_specs(specs)
    -- Flatten and deduplicate specs
    local items = {}
    for _, spec in ipairs(specs or {}) do
        if type(spec) == "string" and not ensured[spec] then
            ensured[spec] = true
            table.insert(items, spec)
        end
    end
    return items
end

function M.ensure_specs(specs)
    -- Ensure that pack functionality is available
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

function M.setup_pack_hooks()
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

function M.plugin_setup(plugin_modules)
    -- Load and setup plugins from the given list of module names
    for _, module_name in ipairs(plugin_modules) do
        local ok, mod = pcall(require, module_name)
        if ok and type(mod.setup) == "function" then
            mod.setup()
        elseif not ok then
            vim.notify(string.format("Failed to load %s: %s", module_name, mod), vim.log.levels.WARN)
        end
    end
end

return M
