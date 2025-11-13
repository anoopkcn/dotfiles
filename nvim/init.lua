-- Author:  @anoopkcn
-- License: MIT
-- WARNING: Since vim/neovim can execute any shell command, It is the resposibility 
-- of the user to read/check the 3rd party plugins to make sure no malicious
-- codes exist.
-- NOTE: When removing a plugin also remove it from nvim-lock-file.json

require("custom.options")
require("custom.functions")
require("custom.keymaps")
require("custom.statusline")
vim.cmd.colorscheme("onehalfdark")

local pack = require("custom.pack")
pack.pack_hooks()
pack.ensure_specs({
    -- These plugins doesnt require a setup call since no additional
    -- customization are imposed on them
    "https://github.com/tpope/vim-surround",
    "https://github.com/tpope/vim-unimpaired",
    "https://github.com/tpope/vim-repeat",
    "https://github.com/tpope/vim-rhubarb" -- A fugitive companion
})

local plugins = {
    "plugins.mason",
    "plugins.lsp",
    "plugins.fzf",
    "plugins.fugitive",
    "plugins.treesitter",
    "plugins.copilot",
    "plugins.makepicker",
    "plugins.minidiff",
    "plugins.blink",
    "plugins.grug",
    -- "plugins.dap",
}

pack.setup(plugins)
