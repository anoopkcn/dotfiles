-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

vim.g.mapleader = " "
vim.g.netrw_liststyle = 1
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showtabline = 0
-- vim.opt.cursorline = true
vim.opt.laststatus = 3
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
local text = "#dcdfe4"
local background = "#22282f"
local background01 = "#272c34"
local border = "#3f444c"
vim.api.nvim_set_hl(0, "Normal", { fg = text, bg = background })
vim.api.nvim_set_hl(0, "NormalFloat", { fg = text, bg = background })
vim.api.nvim_set_hl(0, "Pmenu", { fg = text, bg = background })
vim.api.nvim_set_hl(0, "PmenuSel", { fg = text, bg = background01 })
vim.api.nvim_set_hl(0, "PmenuBorder", { fg = border, bg = background })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = border, bg = background })
vim.api.nvim_set_hl(0, "WinSeparator", { fg = border})
vim.api.nvim_set_hl(0, "StatusLine", { bg = background01 })
require("core.keymaps")
require("core.autocmds")
require("core.packages")
require("modules.csub")
require("modules.fuzzy")
require("modules.filemarks")
require("modules.fugitive")
require("modules.minidiff")
require("modules.treesitter")
vim.lsp.enable({
    "clangd",
    "lua_ls",
    "pyright",
    "marksman",
})
