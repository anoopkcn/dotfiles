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
vim.cmd.colorscheme("onehalfdark")

local pack = require("custom.pack")
pack.hooks()

local plugins = {
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

pack.ensure_specs(plugins, {
    "https://github.com/tpope/vim-surround",
    "https://github.com/tpope/vim-unimpaired",
    "https://github.com/tpope/vim-repeat",
    "https://github.com/tpope/vim-rhubarb",
})
