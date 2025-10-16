-- Author:  @anoopkcn
-- License: MIT

require("custom.options")
require("custom.functions")
require("custom.statusline")
vim.cmd("colorscheme onehalfdark")
vim.cmd([[
  highlight SpellBad   gui=undercurl guisp=#be5046
  highlight SpellCap   gui=undercurl guisp=#61afef
  highlight SpellRare  gui=undercurl guisp=#c678dd
  highlight SpellLocal gui=undercurl guisp=#98c379
]])

local lazypath = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "lazy.nvim")
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({ "git", "clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup {
	change_detection = { notify = false },
	spec = {
		{ import = "plugins" },
		{ "mason-org/mason.nvim", opts = {} },
		{ "mason-org/mason-lspconfig.nvim" },
		{ "WhoIsSethDaniel/mason-tool-installer.nvim" },

		-- Completion engine
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "tpope/vim-fugitive" },
		{ "tpope/vim-surround" },
		{ "tpope/vim-unimpaired" },
		{ "tpope/vim-repeat" },
		{ "ziglang/zig.vim" },
	},
}

-- Load LSP configuration immediately
require("custom.lsp")

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "⏺",
			[vim.diagnostic.severity.WARN] = "⚬",
			[vim.diagnostic.severity.INFO] = "⚬",
			[vim.diagnostic.severity.HINT] = "⚬",
		}
	}
})

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>")
vim.keymap.set({ "n", "v" }, "<C-Space>", "<Nop>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<leader>bd", vim.cmd.bd)
vim.keymap.set("n", "<leader>on", vim.cmd.only)

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<leader>\\", ":rightbelow vsplit<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>-", ":rightbelow split<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<M-j>", "<cmd>cnext<cr>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<cr>")
vim.keymap.set("n", "<leader>tt", vim.diagnostic.setqflist)
-- vim.keymap.set("n", "<leader>xX", vim.diagnostic.setloclist)
vim.keymap.set("n", "]t", function() vim.diagnostic.jump({ count = 1 }) end)
vim.keymap.set("n", "[t", function() vim.diagnostic.jump({ count = -1 }) end)


vim.keymap.set("n", "<leader>q", ToggleQuickfixList, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>G", "<cmd>Git<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fe", "<cmd>Oil<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dl", ":edit DEVLOG.md<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>z", ":!", { noremap = true })

vim.keymap.set("n", "<leader>,", function()
	vim.lsp.buf.format({ async = true })
end, { noremap = true, silent = true })

-- Toggle diagnostic virtual_lines: can also be replaced with virtual_text
-- vim.diagnostic.config({ virtual_lines = false })
-- vim.keymap.set("n", "<leader>e", function()
-- 	local new_config = not vim.diagnostic.config().virtual_lines
-- 	vim.diagnostic.config({ virtual_lines = new_config })
-- end, { desc = "Toggle diagnostic virtual_lines" })

vim.keymap.set("n", "<leader>e", function()
	vim.diagnostic.open_float({ border = 'single' })
end, {})

vim.keymap.set("n", "<leader>'", function()
	local raw_timestamp = os.date("%FT%T")
	local timestamp_str = string.format("%s", raw_timestamp or "")
	vim.api.nvim_put({ timestamp_str }, "c", true, true)
end, { noremap = true, silent = true, })
