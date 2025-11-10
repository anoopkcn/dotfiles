local M = {}

local plugin_specs = {
	-- LSP
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mason-org/mason-lspconfig.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	-- Autompletion
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/hrsh7th/cmp-path",
	"https://github.com/hrsh7th/cmp-buffer",
	-- Debugging
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/mfussenegger/nvim-dap-python",
	-- tpope
	"https://github.com/tpope/vim-fugitive",
	"https://github.com/tpope/vim-surround",
	"https://github.com/tpope/vim-unimpaired",
	"https://github.com/tpope/vim-repeat",
	"https://github.com/github/copilot.vim", -- yes, it's from tpope
	-- Utilities
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/stevearc/oil.nvim",
	-- "https://github.com/mbbill/undotree",
	-- "https://github.com/onsails/lspkind.nvim",
	-- "https://github.com/zbirenbaum/copilot.lua",
	-- "https://github.com/nvim-tree/nvim-web-devicons",
}

local plugin_configs = {
	"plugins.mason",
	"plugins.cmp",
	"plugins.copilot",
	"plugins.dap",
	"plugins.fugitive",
	"plugins.fzf",
	"plugins.gitsigns",
	"plugins.oil",
	"plugins.treesitter",
}

local function setup_pack_hooks()
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

			-- vim.schedule(function()
			-- 	pcall(vim.cmd, "TSUpdate")
			-- end)
		end,
	})
end

function M.setup()
	if not vim.pack or not vim.pack.add then
		vim.notify("vim.pack is unavailable in this version of Neovim", vim.log.levels.ERROR)
		return
	end

	setup_pack_hooks()
	vim.pack.add(plugin_specs, {
		confirm = false,
		load = true,
	})

	for _, module_name in ipairs(plugin_configs) do
		local ok, mod = pcall(require, module_name)
		if ok and type(mod.setup) == "function" then
			mod.setup()
		end
	end
end

return M
