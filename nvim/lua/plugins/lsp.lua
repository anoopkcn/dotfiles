local M = {}

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
				workspace = { library = vim.api.nvim_get_runtime_file("", true) },
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

local function ensure_tools()
	local ensure_installed = vim.tbl_keys(servers)
	vim.list_extend(ensure_installed, { "stylua" })

	local ok, installer = pcall(require, "mason-tool-installer")
	if ok then
		installer.setup { ensure_installed = ensure_installed }
	else
		vim.notify("mason-tool-installer is not available", vim.log.levels.WARN)
	end
end

local function shared_capabilities()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
	if ok and cmp_lsp and cmp_lsp.default_capabilities then
		capabilities = cmp_lsp.default_capabilities(capabilities)
	end
	return capabilities
end

local function configure_servers()
	if not (vim.lsp and vim.lsp.config and vim.lsp.enable) then
		vim.notify("vim.lsp config helpers are not available in this build", vim.log.levels.ERROR)
		return
	end

	vim.lsp.config('*', {
		capabilities = shared_capabilities(),
	})

	for server_name, server_opts in pairs(servers) do
		vim.lsp.config(server_name, server_opts)
	end

	vim.lsp.enable(vim.tbl_keys(servers))
end

local function setup_lsp_autocmd()
	local group = vim.api.nvim_create_augroup("CustomLspAttach", { clear = true })
	vim.api.nvim_create_autocmd('LspAttach', {
		group = group,
		callback = function(args)
			local client = args.data and vim.lsp.get_client_by_id(args.data.client_id)
			if client then
				local has_full = client:supports_method("textDocument/semanticTokens", { full = true })
				local has_range = client:supports_method("textDocument/semanticTokens", { range = true })
				if has_full or has_range then
					client.server_capabilities.semanticTokensProvider = nil
				end
			end

			local bufnr = args.buf
			local map_opts = { buffer = bufnr, noremap = true, silent = true }
			vim.keymap.set("n", "K", function()
				vim.lsp.buf.hover { border = "single", max_height = 25, max_width = 120 }
			end, map_opts)
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, map_opts)
		end,
	})
end

function M.setup()
	ensure_tools()
	configure_servers()
	setup_lsp_autocmd()
end

return M
