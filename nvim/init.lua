-- LICENSE: MIT
-- AUTHOR:  @anoopkcn
vim.pack.add({
    { src = "/Users/akc/develop/fuzzy.nvim", name = "fuzzy" },
    { src = "/Users/akc/develop/filemarks.nvim", name = "filemarks" },
    { src = "/Users/akc/develop/statusline.nvim", name = "statusline" },
    { src = "https://github.com/tpope/vim-repeat", name = "vim-repeat" },
    { src = "https://github.com/tpope/vim-surround", name = "vim-surround" },
    { src = "https://github.com/tpope/vim-fugitive", name = "vim-fugitive" },
    { src = "https://github.com/tpope/vim-unimpaired", name = "vim-unimpaired" },
    { src = "https://github.com/nvim-mini/mini.diff", name = "mini.diff", version = "main" },
    { src = "https://github.com/stevearc/quicker.nvim", name ="quicker", version = "master" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", name ="treesitter", version = "main" },
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

vim.lsp.enable({ "lua_ls", "pyright", "copilot", "marksman" })
