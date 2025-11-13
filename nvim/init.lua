-- LICENSE: MIT
-- AUTHOR:  @anoopkcn
-- WARNING: (n)vim can run shell commands; audit 3rd-party plugins for malicious code.
-- NOTE: When removing a plugin also remove it from nvim-pack-lock.json

require("custom.options")
require("custom.functions")
require("custom.statusline")
require("custom.keymaps")
require("custom.pack").ensure_and_setup(
    {
        -- plugins without setup
        "https://github.com/tpope/vim-repeat",
        "https://github.com/tpope/vim-rhubarb",
        "https://github.com/tpope/vim-surround",
        "https://github.com/tpope/vim-unimpaired",
    },
    {
        -- plugins with setup and configs
        "plugins.mason",
        "plugins.lsp",
        "plugins.fzf",
        "plugins.grug",
        "plugins.blink",
        "plugins.copilot",
        "plugins.fugitive",
        "plugins.minidiff",
        "plugins.treesitter",
    }
)
