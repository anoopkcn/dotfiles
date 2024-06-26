vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true -- set to true if you have a nerd font installed

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true
vim.opt.cursorline = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.clipboard = "unnamedplus" --combine system clipboard with vim clipboard
-- vim.opt.termguicolors = true -- enable 24-bit RGB colors
vim.opt.mouse = "a" -- enable mouse support
vim.opt.signcolumn = "yes" -- extra space in the gutter for signs

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

vim.opt.path:append("**")

if vim.fn.has("Mac") == 1 then
	vim.opt.linebreak = true
	vim.opt.showbreak = "⤷ "
end
