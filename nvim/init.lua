-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

require("core.options")
require("core.functions")
require("core.statusline")
require("core.keymaps")
local pack = require("core.pack")
pack.ensure(
    {
        "https://github.com/tpope/vim-repeat",
        "https://github.com/tpope/vim-surround",
        "https://github.com/tpope/vim-unimpaired",
    },
    {
        "modules.fzf",
        "modules.blink",
        "modules.quicker",
        "modules.fugitive",
        "modules.minidiff",
        "modules.treesitter",
        "modules.makepicker"
    }
)
vim.lsp.enable({
    "lua_ls",
    "pyright",
    "marksman",
    "copilot"
})
