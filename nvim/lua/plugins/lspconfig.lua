-- LSP settings
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		}
	},
	config = function()
		require("lspconfig").lua_ls.setup {}
		vim.keymap.set("n", "<leader>,", function() vim.lsp.buf.format() end)
	end
}
