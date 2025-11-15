-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

require("custom.options")
require("custom.functions")
require("custom.statusline")
require("custom.keymaps")
local pack = require("custom.pack")
pack.ensure(
    {
        "https://github.com/tpope/vim-repeat",
        "https://github.com/tpope/vim-surround",
        "https://github.com/tpope/vim-unimpaired",
    },
    {
        "plugins.fzf",
        "plugins.blink",
        "plugins.fugitive",
        "plugins.minidiff",
        "plugins.treesitter",
    }
)

vim.lsp.enable(
    {
        "lua_ls",
        "basedpyright",
        "marksman",
        "copilot"
    }
)

