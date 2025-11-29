-- LICENSE: MIT
-- Author:  @anoopkcn
-- General neovim settings

vim.cmd.colorscheme("onehalfdark")
-- vim.opt.number = true
-- vim.opt.relativenumber = true
-- vim.opt.cursorline = true
-- vim.o.cursorlineopt = "number"
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1
vim.opt.showtabline = 0
vim.opt.laststatus = 3
vim.opt.winbar = "%f%m"
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.mouse = "a"
vim.opt.signcolumn = "yes"
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.path:append("**")
vim.opt.swapfile = false
vim.opt.wildmenu = true
vim.opt.pumborder = "rounded"
vim.opt.splitkeep = "screen"
vim.opt.splitbelow = true
