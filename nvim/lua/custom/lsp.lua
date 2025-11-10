-- LSP Configuration using Neovim 0.11+ built-in vim.lsp.config()

local servers = {
	marksman = {
		cmd = { "marksman", "server" },
		filetypes = { "markdown" },
		root_markers = { ".marksman.toml", ".git" },
	},
	texlab = {
		cmd = { "texlab" },
		filetypes = { "tex", "bib" },
		root_markers = { "texlab.tex", ".latexmkrc", ".git" },
		settings = {
			texlab = {
				build = {
					executable = "pdflatex",
					args = { "-synctex=1", "-interaction=nonstopmode", "%f" },
					onSave = true,
				},
				forwardSearch = {
					executable = "zathura",
					args = { "--synctex-forward", "%l:1:%f", "%p" },
				},
				latexFormatter = "latexindent",
			},
		},
	},
	zls = {
		cmd = { "zls" },
		filetypes = { "zig", "zir" },
		root_markers = { "zls.json", "build.zig", ".git" },
	},
	ruff = {
		cmd = { "ruff", "server" },
		filetypes = { "python" },
		root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
	},
	lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = { globals = { "vim", "require" } },
				workspace = { library = { vim.env.VIMRUNTIME, "${3rd}/luv/library" } },
				telemetry = { enable = false },
			},
		},
	},
	pyright = {
		cmd = { "pyright-langserver", "--stdio" },
		filetypes = { "python" },
		root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
		settings = {
			python = {
				analysis = {
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

-- Ensure LSP servers and tools are installed via Mason
local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, { "stylua" })
require("mason-tool-installer").setup { ensure_installed = ensure_installed }

-- Set global LSP capabilities for all servers
vim.lsp.config('*', {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

-- Configure each server with their specific settings
for server_name, server_opts in pairs(servers) do
	vim.lsp.config(server_name, server_opts)
end

-- Enable all configured LSP servers
vim.lsp.enable(vim.tbl_keys(servers))

-- Set up keybindings and behavior when LSP attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		-- Disable semantic highlighting to prevent flicker when opening files
		-- local client = vim.lsp.get_client_by_id(args.data.client_id)
		-- if client:supports_method("textDocument/semanticTokens", { full = true }) or
		-- 		client:supports_method("textDocument/semanticTokens", { range = true }) then
		-- 	client.server_capabilities.semanticTokensProvider = nil
		-- end

		-- LSP keybindings
		local bufnr = args.buf
		local map_opts = { buffer = bufnr, noremap = true, silent = true }
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover { border = "single", max_height = 25, max_width = 120 }
		end, map_opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, map_opts)
	end,
})
