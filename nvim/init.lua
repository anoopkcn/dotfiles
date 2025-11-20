-- LICENSE: MIT
-- AUTHOR:  @anoopkcn
vim.pack.add({
    { src = "https://github.com/tpope/vim-repeat" },
    { src = "https://github.com/tpope/vim-surround" },
    { src = "https://github.com/tpope/vim-fugitive" },
    { src = "https://github.com/tpope/vim-unimpaired" },
    { src = "https://github.com/nvim-mini/mini.diff" },
    { src = "https://github.com/stevearc/quicker.nvim", version="master" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.fuzzy")
require("core.filemarks")
require("core.statusline")

require("modules.quicker")
require("modules.minidiff")
require("modules.treesitter")
vim.lsp.enable({
    "lua_ls",
    "pyright",
    "copilot",
    "marksman"
})
