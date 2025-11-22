-- LICENSE: MIT
-- AUTHOR:  @anoopkcn
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.packages")
require("modules.fuzzy")
require("modules.filemarks")
require("modules.statusline")
require("modules.csubstitute")
require("modules.minidiff")
require("modules.treesitter")
vim.cmd.packadd("cfilter")
vim.cmd.colorscheme("onehalfdark")
vim.lsp.enable({ "lua_ls", "pyright", "copilot", "marksman" })
vim.diagnostic.config({ signs = false })
