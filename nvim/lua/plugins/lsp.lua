return {
	'neovim/nvim-lspconfig',
	dependencies = {
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{
			'mason-org/mason.nvim',
			opts = {}
		},
		{ 'mason-org/mason-lspconfig.nvim' },
		{ 'WhoIsSethDaniel/mason-tool-installer.nvim' },
	},

	config = function()
		local servers = {
			lua_ls = {
				settings = {
					Lua = {
						runtime = { version = 'LuaJIT', },
						diagnostics = { globals = { 'vim', 'require' }, },
						workspace = { library = vim.api.nvim_get_runtime_file("", true), },
						telemetry = { enable = false, },
					},
				},
			},
			zls = {},
			ruff = {},
			pyright = {
				settings = {
					python = {
						analysis = {
							-- "off", "basic", or "strict"
							typeCheckingMode = "basic",
							reportMissingImports = "warning",
							diagnosticSeverityOverrides = {
								reportUnusedVariable = "none",
								reportGeneralTypeIssues = "information"
							}
						}
					},
				}
			},
		}

		-- Using mason to install LSP servers
		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, { "stylua" })
		require("mason-tool-installer").setup { ensure_installed = ensure_installed }


		local on_attach = function(client, bufnr)
			-- Disable semantic highlighting if the client doesn't support it
			-- Removed the flicker when opening a file
			if client.supports_method("textDocument/semanticTokens", { full = true }) or
					client.supports_method("textDocument/semanticTokens", { range = true }) then
				client.server_capabilities.semanticTokensProvider = nil
			else
				print("Client", client.name, "does not support semantic highlighting.")
			end

			local map_opts = { buffer = bufnr, noremap = true, silent = true }
			vim.keymap.set("n", "K",
				function()
					vim.lsp.buf.hover { border = "single", max_height = 25, max_width = 120 }
				end,
				map_opts
			)
		end

		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		for server_name, server_opts in pairs(servers) do
			local server_config = vim.tbl_deep_extend(
				"force",
				{
					on_attach = on_attach,
					capabilities = capabilities,
				},
				server_opts or {}
			)

			require("lspconfig")[server_name].setup(server_config)
		end
	end
}
