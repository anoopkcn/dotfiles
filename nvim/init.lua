-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

require("core.options")
require("core.keymaps")
require("core.autocmds")

local pack = require("core.pack")
local specs = {
    "https://github.com/tpope/vim-repeat",
    "https://github.com/tpope/vim-surround",
    "https://github.com/tpope/vim-unimpaired"
}
local packages = {
    "modules.fugitive",
    "modules.minidiff",
    "modules.treesitter",
}
local modules = {
    "modules.fuzzy",
    "modules.cfdofix",
    "modules.prettyqf",
    "modules.filemarks",
    "modules.statusline",
}
local lsps = { "lua_ls", "pyright", "copilot", "marksman" }

vim.list_extend(packages, modules)
pack.ensure(specs, packages)
vim.cmd("packadd! cfilter")
vim.lsp.enable(lsps)
