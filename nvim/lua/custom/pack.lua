local M = {}
local plugin_specs
local plugin_configs

function M.setup()
    if not vim.pack or not vim.pack.add then
        vim.notify("vim.pack is unavailable in this version of Neovim", vim.log.levels.ERROR)
        return
    end

    local group = vim.api.nvim_create_augroup("CustomPackHooks", { clear = true })
    vim.api.nvim_create_autocmd("PackChanged", {
        group = group,
        callback = function(ev)
            local data = ev.data or {}
            local spec = data.spec or {}
            local name = spec.name
            if name ~= "nvim-treesitter" then
                return
            end

            if data.kind ~= "install" and data.kind ~= "update" then
                return
            end

            if not data.active then
                vim.cmd.packadd(name)
            end
        end,
    })

    vim.pack.add(plugin_specs, {
        confirm = false,
        load = true,
    })

    local iter = vim.iter
    local function setup_plugin(module_name)
        local ok, mod = pcall(require, module_name)
        if ok and type(mod.setup) == "function" then
            mod.setup()
        end
    end

    if iter then
        iter(plugin_configs):each(setup_plugin)
    else
        for _, module_name in ipairs(plugin_configs) do
            setup_plugin(module_name)
        end
    end
end

plugin_specs = {
    -- LSP
    "mason-org/mason.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- Autompletion
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    -- Debugging
    -- "mfussenegger/nvim-dap",
    -- "rcarriga/nvim-dap-ui",
    -- "nvim-neotest/nvim-nio",
    -- "mfussenegger/nvim-dap-python",
    -- tpope
    "tpope/vim-fugitive",
    "tpope/vim-surround",
    "tpope/vim-unimpaired",
    "tpope/vim-repeat",
    "github/copilot.vim", -- yes, it's from tpope
    -- Utilities
    "lewis6991/gitsigns.nvim",
    "ibhagwan/fzf-lua",
}

plugin_configs = {
    "plugins.mason",
    "plugins.lsp",
    "plugins.cmp",
    -- "plugins.dap",
    "plugins.fzf",
    "plugins.fugitive",
    "plugins.gitsigns",
    "plugins.treesitter",
    "plugins.copilot",
    "plugins.makepicker"
}

return M
