-- LICENSE: MIT
-- AUTHOR:  @anoopkcn
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.packages")
require("modules.fuzzy")
require("modules.minidiff")
require("modules.filemarks")
require("modules.treesitter")
require("modules.statusline")
vim.cmd.packadd("cfilter")
vim.cmd.colorscheme("onehalfdark")
vim.lsp.enable({ "lua_ls", "pyright", "copilot", "marksman" })
