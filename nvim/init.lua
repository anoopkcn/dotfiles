-- Neovim configuration
-- Author: @anoopkcn
-- License: MIT
-- Refer to README.md for more information
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

require("custom.options")
require("custom.keymaps")
require("custom.functions")
require("lazy").setup {
	spec = {
		{ import = "plugins" },
		{ "navarasu/onedark.nvim",
			lazy = false,
			priority = 1000,
			config = function()
				require('onedark').load()
			end
		},
		{ "lewis6991/gitsigns.nvim",
			config = function()
				require("gitsigns").setup()
			end
		},
		{ "tpope/vim-fugitive" },
		{ "tpope/vim-unimpaired" },
		{ "tpope/vim-repeat" },
		{ "tpope/vim-surround" },
		{ "numToStr/Comment.nvim" },
	},
}
