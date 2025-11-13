-- Author:  @anoopkcn
-- License: MIT

require("custom.options")
require("custom.functions")
require("custom.keymaps")
require("custom.statusline")
vim.cmd.colorscheme("onehalfdark")

local pack = require("custom.pack")
pack.pack_hooks()

pack.ensure_specs({
    "https://github.com/tpope/vim-surround",
    "https://github.com/tpope/vim-unimpaired",
    "https://github.com/tpope/vim-repeat",
    "https://github.com/tpope/vim-rhubarb"
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

-- NOTE: When removing a plugin also remove it from the nvim-lock-file
