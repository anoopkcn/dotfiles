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
		{
			"mason-org/mason.nvim",
			opts = {},
		},
		{ "mason-org/mason-lspconfig.nvim" },
		{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "tpope/vim-surround" },
		{ "tpope/vim-unimpaired" },
		{ "tpope/vim-repeat" },
		{ "ziglang/zig.vim" },
	},
}

require("custom.lsp")

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "󰗖",
			[vim.diagnostic.severity.INFO] = "󰄰",
			[vim.diagnostic.severity.HINT] = "󰄰",
		}
	}
})

local set = vim.keymap.set

set({ "n", "v" }, "<Space>", "<Nop>")
set({ "n", "v" }, "<C-Space>", "<Nop>")
set("n", "<Esc>", "<cmd>nohlsearch<cr>")
set({ "n", "v" }, "<leader>p", [["+p]])
set({ "n", "v" }, "<leader>y", [["+y]])
set("n", "J", "mzJ`z")
set("n", "<C-d>", "<C-d>zz")
set("n", "<C-u>", "<C-u>zz")
set("n", "n", "nzzzv")
set("n", "N", "Nzzzv")
set("n", "<leader>bd", vim.cmd.bd)
set("n", "<leader>on", vim.cmd.only)

set("i", "<C-c>", "<Esc>")

set("n", "<leader>\\", ":rightbelow vsplit<cr>", { noremap = true, silent = true })
set("n", "<leader>-", ":rightbelow split<cr>", { noremap = true, silent = true })
set("n", "<M-j>", "<cmd>cnext<cr>")
set("n", "<M-k>", "<cmd>cprev<cr>")
set("n", "<leader>x", function() vim.diagnostic.open_float({ border = 'single' }) end, {})
set("n", "<leader>tt", vim.diagnostic.setqflist)
set("n", "]t", function() vim.diagnostic.jump({ count = 1 }) end)
set("n", "[t", function() vim.diagnostic.jump({ count = -1 }) end)

set("n", "<leader>q", ToggleQuickfixList, { noremap = true, silent = true })
set("n", "<leader>dl", ":edit DEVLOG.md<cr>", { noremap = true, silent = true })
set("n", "<leader>n", ":edit ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/notes/scratchpad.md<cr>", { noremap = true, silent = true })
set("n", "<leader>,", function() vim.lsp.buf.format({ async = true }) end, { noremap = true, silent = true })

-- Toggle diagnostic virtual_lines: can also be replaced with virtual_text
-- vim.diagnostic.config({ virtual_lines = false })
-- vim.keymap.set("n", "<leader>e", function()
-- 	local new_config = not vim.diagnostic.config().virtual_lines
-- 	vim.diagnostic.config({ virtual_lines = new_config })
-- end, { desc = "Toggle diagnostic virtual_lines" })

set("n", "<leader>'", function()
	local raw_timestamp = os.date("%FT%T")
	local timestamp_str = string.format("%s", raw_timestamp or "")
	vim.api.nvim_put({ timestamp_str }, "c", true, true)
end, { noremap = true, silent = true, })
