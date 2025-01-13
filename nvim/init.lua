-- Neovim configuration
-- Author: @anoopkcn
-- License: MIT
-- Refer to README.md for more information

-- OPTIONS
vim.g.mapleader = " "
vim.g.maplocalleader = " "
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
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
-- vim.opt.inccommand = "split"
vim.opt.linebreak = true
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.diagnostic.config({ virtual_text = false })

-- KEYBINDINGS
-- since Space is the leader key do nothing
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>")
vim.keymap.set({ "n", "v" }, "<C-Space>", "<Nop>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
-- Center some stuff zz
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "G", "Gzz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set("n", "<C-b>", "<C-b>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
-- helper windows
vim.keymap.set("n", "j", "v:count ? 'j' : 'gj'", { expr = true })
vim.keymap.set("n", "k", "v:count ? 'k' : 'gk'", { expr = true })
vim.keymap.set("n", "<Leader>bd", vim.cmd.bd)
vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")
vim.keymap.set("n", "<leader>Q", "<cmd>cclose<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setqflist)
-- Window splits
vim.keymap.set('n', '<leader>\\', ':rightbelow vsplit<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>-', ':rightbelow split<CR>', { noremap = true, silent = true })

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
		{ dir = "~/Dropbox/projects/split-jump.nvim" },
		{ "navarasu/onedark.nvim",
			lazy = false,
			priority = 1000,
			config = function()
				require('onedark').setup {
					colors = {
						green = "#8fbc8f",
						red = "#cd5c5c",
					},
				}
				require('onedark').load()
			end
		},
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
	},
}

require("custom.functions")
