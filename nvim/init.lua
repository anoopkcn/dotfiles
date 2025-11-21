-- LICENSE: MIT
-- AUTHOR:  @anoopkcn
vim.pack.add({
    { src = "https://github.com/anoopkcn/fuzzy.nvim" },
    { src = "https://github.com/anoopkcn/filemarks.nvim" },
    { src = "https://github.com/anoopkcn/statusline.nvim" },
    { src = "https://github.com/tpope/vim-repeat" },
    { src = "https://github.com/tpope/vim-surround" },
    { src = "https://github.com/tpope/vim-fugitive" },
    { src = "https://github.com/tpope/vim-unimpaired" },
    { src = "https://github.com/nvim-mini/mini.diff" },
    { src = "https://github.com/stevearc/quicker.nvim", version = "master" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

require("core.options")
require("core.keymaps")
require("core.autocmds")

require("modules.fuzzy")
require("modules.quicker")
require("modules.minidiff")
require("modules.filemarks")
require("modules.treesitter")
require("modules.statusline")

vim.lsp.enable({
    "lua_ls",
    "pyright",
    "copilot",
    "marksman"
})
