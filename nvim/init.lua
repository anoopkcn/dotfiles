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
local packages = {
    "modules.fzf",
    "modules.oil",
    "modules.blink",
    "modules.quicker",
    "modules.fugitive",
    "modules.minidiff",
    "modules.treesitter",
}
local modules = {
    "modules.cgrep",
    "modules.makepicker"
}
local lsps = {
    "lua_ls",
    "pyright",
    "copilot",
    "marksman"
}

vim.list_extend(packages, modules)
pack.ensure(specs, packages)
vim.lsp.enable(lsps)
