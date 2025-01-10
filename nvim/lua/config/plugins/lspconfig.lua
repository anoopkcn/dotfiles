return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"folke/lazydev.nvim",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
	},
	config = function()
		local lspconfig = require('lspconfig')
		lspconfig.lua_ls.setup({})
		vim.keymap.set("n", "<leader>,", vim.lsp.buf.format)
	end
}
