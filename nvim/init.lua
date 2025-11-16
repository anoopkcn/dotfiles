-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

require("core.auto")
require("core.options")
require("core.keymaps")
require("core.statusline")
local pack = require("core.pack")
local specs = {
    "https://github.com/tpope/vim-repeat",
    "https://github.com/tpope/vim-surround",
    "https://github.com/tpope/vim-unimpaired"
}
local modules = {
    "modules.fzf",
    "modules.blink",
    "modules.cgrep",
    "modules.quicker",
    "modules.fugitive",
    "modules.minidiff",
    "modules.treesitter",
    "modules.makepicker"
}
local lsps = {
    "lua_ls",
    "pyright",
    "copilot",
    "marksman"
}

pack.ensure(specs, modules)
vim.lsp.enable(lsps)
