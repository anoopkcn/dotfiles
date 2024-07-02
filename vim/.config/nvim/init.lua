-- Neovim configuration file
-- Author: @anoopkcn
-- License: MIT
-- Refer to README.md for more information

require("core.options")
require("core.keymaps")
require("core.globals")
require("lazy").setup({
	spec = {
		{ import = "plugins" },
		{ import = "colors" },
	},
	change_detection = {
		notify = false,
	},
})

vim.cmd.colorscheme("catppuccin")
