local M = {}

local ensured = {}
local hooks_installed = false

local function has_pack()
    return vim.pack and vim.pack.add
end

local function flatten_specs(specs)
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
    if not has_pack() then
        return
    end
    local items = flatten_specs(specs)
    if #items == 0 then
        return
    end
    vim.pack.add(items, { confirm = false, load = true })
end

function M.setup_pack_hooks()
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

return M
