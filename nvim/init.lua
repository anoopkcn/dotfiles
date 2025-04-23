-- Neovim configuration
-- Author: @anoopkcn
-- License: MIT
-- Refer to README.md for more information

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.netrw_banner = 0

vim.opt.swapfile = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true
vim.opt.cursorline = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.linebreak = true
vim.opt.showmode = false
vim.opt.termguicolors = true

if vim.fn.executable("rg") == 1 then
	vim.opt.grepprg = "rg --vimgrep --smart-case"
	vim.opt.grepformat = "%f:%l:%c:%m"
end

vim.diagnostic.config({ virtual_text = false })

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>")
vim.keymap.set({ "n", "v" }, "<C-Space>", "<Nop>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "G", "Gzz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set("n", "<C-b>", "<C-b>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
-- vim.keymap.set("n", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("n", "J", "mzJ`z") -- Join lines without moving cursor
vim.keymap.set("n", "j", "v:count ? 'j' : 'gj'", { expr = true })
vim.keymap.set("n", "k", "v:count ? 'k' : 'gk'", { expr = true })
vim.keymap.set("n", "<leader>F", "<cmd>Ex<CR>")
vim.keymap.set("n", "<Leader>bd", vim.cmd.bd)
vim.keymap.set('n', '<leader>\\', ':rightbelow vsplit<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>-', ':rightbelow split<CR>', { noremap = true, silent = true })
vim.keymap.set("i", "<C-c>", "<Esc>")
-- lsp + quickfix
vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")
vim.keymap.set("n", "<leader>xX", vim.diagnostic.setqflist)
vim.keymap.set("n", "<leader>xx", vim.diagnostic.setloclist)
vim.keymap.set("n", "<leader>xs", vim.lsp.buf.document_symbol)
vim.keymap.set("n", "<leader>xr", vim.lsp.buf.references)

vim.cmd("colorscheme onehalfdark")

-- PLUGINS
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
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
		{ "tpope/vim-fugitive",
			config = function()
				vim.keymap.set("n", "<leader>G", "<cmd>Git<CR>")
			end
		},
		{ "tpope/vim-unimpaired" },
		{ "tpope/vim-repeat" },
		{ "tpope/vim-surround" },
		{ "numToStr/Comment.nvim" },
		{ "github/copilot.vim" },
		{ dir = "~/develop/split-jump.nvim" },
	},
}

require("custom.functions")
