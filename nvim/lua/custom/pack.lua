-- A thin wrapper around the built-in vim.pack
-- This module exports a function called `ensure_and_setup(a,b)`
-- The first argument is a table of package URL's .
-- The second argument is a table of `config modules` for each plugin.
-- The `config module` are lua modules with optional objects 'specs' and 'setup'.
-- Object 'specs' should be a table with package URL's.
-- Object 'setup' should contain plugin configurations and keymaps (if any)
-- Example of a config module 'minidiff.lua':
--          local M = {}
--          M.specs = { "https://github.com/nvim-mini/mini.diff" }
--          M.setup = function()
--              local ok, minidiff = pcall(require, "mini.diff")
--              if ok then
--                  minidiff.setup({...})
--                  vim.kaymap.set(...)
--              end
--          end
--          return M

local M = {}

local ensured = {}
local hooks_installed = false

local function has_pack()
    return vim.pack and vim.pack.add
end

local function append_specs(target, specs)
    if type(specs) ~= "table" then
        return
    end
    for _, spec in ipairs(specs) do
        if type(spec) == "string" and not ensured[spec] then
            ensured[spec] = true
            table.insert(target, spec)
        end
    end
end

local function load_modules(modules)
    local loaded = {}
    for _, module_name in ipairs(modules or {}) do
        local ok, module = pcall(require, module_name)
        if ok and type(module) == "table" then
            table.insert(loaded, { name = module_name, module = module })
        elseif not ok then
            vim.notify(string.format("Failed to load %s: %s", module_name, module), vim.log.levels.WARN)
        end
    end
    return loaded
end

function M.hooks()
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

function M.ensure(specs)
    if type(specs) ~= "table" or #specs == 0 then
        return
    end

    if not has_pack() then
        return
    end

    M.hooks()
    -- Add specs without confirmation and load them
    -- loading is necessary for vim plugins to be available immediately
    vim.pack.add(specs, { confirm = false, load = true })
end

function M.setup(loaded_plugins)
    for _, entry in ipairs(loaded_plugins or {}) do
        local plugin = entry.module
        if type(plugin.setup) == "function" then
            plugin.setup()
        end
    end
end

function M.ensure_and_setup(specs, modules)
    local combined = {}
    if specs and type(specs) == "table" and #specs > 0 then
        append_specs(combined, specs)
    end

    local module_list = (type(modules) == "table" and modules) or {}
    local loaded = load_modules(module_list)
    for _, entry in ipairs(loaded) do
        append_specs(combined, entry.module.specs)
    end

    M.ensure(combined)
    if #loaded > 0 then
        M.setup(loaded)
    end
end

return M
