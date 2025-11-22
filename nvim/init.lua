-- LICENSE: MIT
-- AUTHOR:  @anoopkcn
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.packages")
require("modules.fuzzy")
require("modules.quicker")
require("modules.minidiff")
require("modules.filemarks")
require("modules.treesitter")
require("modules.statusline")

vim.lsp.enable({
    "lua_ls",
    "pyright",
    "copilot",
    "marksman"
})
