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
		{ import = "config.plugins" },
		-- { "folke/tokyonight.nvim",  config = function() vim.cmd.colorscheme "tokyonight-storm" end },
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
		{ "tpope/vim-fugitive",
			config = function()
				vim.keymap.set("n", "<leader>G", "<Cmd>Git<CR>")
			end
		},
		{ "tpope/vim-unimpaired" },
		{ "tpope/vim-repeat" },
		{ "tpope/vim-surround" },
		{ "numToStr/Comment.nvim" },
	},
}
