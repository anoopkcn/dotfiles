-- [lazy.nvim](https://github.com/folke/lazy.nvim.git) (**plugin manager**)
-- [mason.nvim](https://github.com/williamboman/mason.nvim)(**language server, formatter and dap manager**)
-- Configuration for LSP (Language Server Protocol) and Manager(Mason)

local servers = {
	pyright = {},
	rust_analyzer = {},
	lua_ls = {
		-- capabilities = {},
		settings = {
			Lua = {
				completion = {
					callSnippet = "Replace",
				},
				-- add 'folke/neodev.nvim' for vim,
				-- diagnostics = {
				-- 	globals = { "vim" },
				-- disable = { 'missing-fields' }
				-- },
			},
		},
	},
	tsserver = {},
}

local lang_tools = {
	-- also update the list in lua/plugins/formatter.lua
	"stylua", -- Used to format Lua code
	"black", -- Used to format Python code
	"prettier", -- Used to format js, html, markdown, ts, css
}

return {
	"neovim/nvim-lspconfig",

	dependencies = {
		{ "williamboman/mason.nvim", config = true }, -- https://github.com/williamboman/mason.nvim
		"williamboman/mason-lspconfig.nvim", -- https://github.com/williamboman/mason-lspconfig.nvim
		"WhoIsSethDaniel/mason-tool-installer.nvim", -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
		"hrsh7th/cmp-nvim-lsp", -- https://github.com/hrsh7th/cmp-nvim-lsp

		-- Useful status updates for LSP.
		-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
		{ "j-hui/fidget.nvim", opts = {} },

		-- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		{ "folke/neodev.nvim", opts = {} },
	},

	config = function()
		require("mason").setup()

		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, lang_tools)

		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		-- combine the default capabilities with the nvim-cmp capabilities
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					require("lspconfig")[server_name].setup(server)
				end,
			},
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("first-lsp-attach", { clear = true }),
			desc = "LSP actions",

			callback = function(event)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinitions")
				map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
				map("gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementations")
				map("gD", vim.lsp.buf.declaration, "Goto [D]eclaration")
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
				map("<leader>ws", require("telescope.builtin").lsp_workspace_symbols, "[W]orkspace [S]ymbols")
				map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinitions")
				map("K", vim.lsp.buf.hover, "Hover Documentation")
				map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")

				-- When you move your cursor, the highlights will be cleared (the second auto command).
				local client = vim.lsp.get_client_by_id(event.data.client_id)

				if client and client.server_capabilities.documentHighlightProvider then
					local highlight_augroup = vim.api.nvim_create_augroup("first-lsp-highlight", { clear = false })

					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("first-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "first-lsp-highlight", buffer = event2.buf })
						end,
					})
				end
			end,
		})

		-- LSP symbol definition window(activated by K) should have border and rounded corner
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			border = "rounded",
		})
	end,
}
