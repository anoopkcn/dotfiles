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
-- vim.opt.clipboard = "unnamedplus"
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
vim.opt.showtabline = 0

if vim.fn.executable("rg") == 1 then
	vim.opt.grepprg = "rg --vimgrep --smart-case"
	vim.opt.grepformat = "%f:%l:%c:%m"
end

-- vim.opt.includeexpr = [[substitute(v:fname,'\(.*\):\d\+:\d\+.*','\1','')]]
