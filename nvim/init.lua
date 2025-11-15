-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

require("custom.options")
require("custom.functions")
require("custom.statusline")
require("custom.keymaps")
require("custom.autolsp")
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
        "plugins.quicker",
        "plugins.fugitive",
        "plugins.minidiff",
        "plugins.treesitter",
    }
)
