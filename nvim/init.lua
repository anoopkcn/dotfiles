-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

require("core.options")
require("core.functions")
require("core.statusline")
require("core.keymaps")
require("core.autolsp")
local pack = require("core.pack")
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
