-- Author:  @anoopkcn
-- License: MIT
require("custom.options")
require("custom.functions")
require("custom.keymaps")
require("custom.statusline")
vim.cmd.colorscheme("onehalfdark")

local pack = require("custom.pack")
pack.setup_pack_hooks()

pack.ensure_specs({
    "https://github.com/tpope/vim-surround",
    "https://github.com/tpope/vim-unimpaired",
    "https://github.com/tpope/vim-repeat",
    -- "https://github.com/mbbill/undotree",
    "https://github.com/wellle/context.vim"
})

local plugin_modules = {
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

pack.plugin_setup(plugin_modules)
