return {
	'neovim/nvim-lspconfig',
	dependencies = {
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-nvim-lsp",
	},

	opts = {
		servers = {
			lua_ls = {},
			zls = {},
			ruff = {},
			pyright = {
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic",   -- "off", "basic", or "strict"
							reportMissingImports = "warning",
							-- Add other Pyright analysis settings here
							-- e.g., diagnosticSeverityOverrides
							diagnosticSeverityOverrides = {
								reportUnusedVariable = "none",
								reportGeneralTypeIssues = "information"
							}
						}
					},
				}
			},
		}
	},
	config = function(_, opts)
		local lspconfig = require('lspconfig')

		local capabilities = require('cmp_nvim_lsp').default_capabilities()

		local on_attach = function(client, bufnr)
			-- print("LSP attached to buffer:", bufnr, "Client:", client.name)
			if client.supports_method("textDocument/semanticTokens", { full = true }) or
					client.supports_method("textDocument/semanticTokens", { range = true }) then
				client.server_capabilities.semanticTokensProvider = nil
			else
				print("Client", client.name, "does not support semantic highlighting.")
			end

			local map_opts = { buffer = bufnr, noremap = true, silent = true }
			vim.keymap.set('n', 'K', function() vim.lsp.buf.hover { border = "single", max_height = 25, max_width = 120 } end,
				map_opts)
			vim.keymap.set('n', 'gd', vim.lsp.buf.definition, map_opts)
			vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, map_opts)
			vim.keymap.set('n', 'gr', vim.lsp.buf.references, map_opts)
			vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, map_opts)
			vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, map_opts)
		end

		for server_name, server_opts in pairs(opts.servers) do
			local final_config = vim.tbl_deep_extend('force', {
				on_attach = on_attach,
				capabilities = capabilities,
			}, server_opts or {})

			lspconfig[server_name].setup(final_config)
		end
	end
}
