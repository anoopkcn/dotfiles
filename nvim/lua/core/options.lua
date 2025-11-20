vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = false
vim.opt.showtabline = 0
vim.opt.laststatus = 2
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
vim.opt.wildmenu = true
vim.opt.pumborder = "rounded"
vim.cmd.colorscheme("onehalfdark")
vim.filetype.add({
    extension = {
        smd = "markdown",
    }
})
