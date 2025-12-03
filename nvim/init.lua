-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.cmd.colorscheme("onehalfdark")
vim.g.netrw_liststyle = 1
-- vim.opt.number = true
-- vim.opt.relativenumber = true
-- vim.opt.cursorline = true
-- vim.o.cursorlineopt = "number"
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
vim.opt.showbreak = "⤷ "
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.path:append("**")
vim.opt.swapfile = false
vim.opt.wildmenu = true
vim.opt.pumborder = "rounded"
vim.opt.splitkeep = "screen"
vim.opt.splitbelow = true
require("core.keymaps")
require("core.autocmds")
require("core.packages")
require("modules.csub")
require("modules.fuzzy")
require("modules.filemarks")
require("modules.statusline")
require("modules.fugitive")
require("modules.minidiff")
require("modules.treesitter")
vim.lsp.enable({
    "clangd",
    "lua_ls",
    "pyright",
    "marksman",
})
