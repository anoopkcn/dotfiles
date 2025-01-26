return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ 'saghen/blink.cmp' },
		{
			"folke/lazydev.nvim",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
	},

	opts = {
		servers = {
			lua_ls = {},
			pyright = {
				settings = {
					python = {
						analysis = {
							diagnosticMode = "workspace"
						}
					}
				}
			},
			zls = {},
			marksman = {},
		},
	},
	config = function(_, opts)
		local lspconfig = require('lspconfig')
		for server, config in pairs(opts.servers) do
			config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
			lspconfig[server].setup(config)
		end
		vim.keymap.set("n", "<leader>,", vim.lsp.buf.format)
	end

}
