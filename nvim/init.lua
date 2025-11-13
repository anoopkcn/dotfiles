-- Author:  @anoopkcn
-- License: MIT
-- WARNING: Since vim/neovim can execute any shell command,
-- it is the resposibility of the user to read/check
-- the 3rd party plugins to make sure no malicious codes exist.
-- NOTE: When removing a plugin also remove it from nvim-lock-file.json

require("custom.options")
require("custom.functions")
require("custom.keymaps")
require("custom.statusline")
require("custom.pack").ensure_and_setup(
    {
        -- plugins without a setup
        "https://github.com/tpope/vim-surround",
        "https://github.com/tpope/vim-unimpaired",
        "https://github.com/tpope/vim-repeat",
        "https://github.com/tpope/vim-rhubarb",
    },
    {
        -- plugins with a setup and other configs
        "plugins.mason",
        "plugins.lsp",
        "plugins.fzf",
        "plugins.treesitter",
        "plugins.fugitive",
        "plugins.minidiff",
        "plugins.copilot",
        "plugins.grug",
        "plugins.blink",
        "plugins.makepicker",
        -- "plugins.dap",
    }
)
