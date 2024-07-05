-- Neovim configuration file
-- Author: @anoopkcn
-- License: MIT
-- Refer to README.md for more information

require("core.options")
require("core.keymaps")
require("core.globals")

-- Lazy plugin manager (https://github.com/folke/lazy.nvim.git)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
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
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = { { import = "plugins" }, { import = "colors" } },
	change_detection = { notify = false },
})

vim.cmd.colorscheme("catppuccin")
