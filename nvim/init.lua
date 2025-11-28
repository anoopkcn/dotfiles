-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.packages")
require("modules.csub")
require("modules.fuzzy")
require("modules.filemarks")
require("modules.statusline")
require("modules.fugitive")
require("modules.minidiff")
require("modules.oil")
require("modules.treesitter")
-- vim.lsp.enable({
--     "clangd",
--     "lua_ls",
--     "pyright",
--     "marksman",
-- })
