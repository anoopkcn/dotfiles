-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

require("custom.options")
require("custom.functions")
require("custom.statusline")
require("custom.keymaps")
require("custom.pack").ensure_and_setup(
    {
        "https://github.com/tpope/vim-repeat",
        "https://github.com/tpope/vim-surround",
        "https://github.com/tpope/vim-unimpaired",
    },
    {
        "plugins.fzf",
        "plugins.grug",
        "plugins.blink",
        "plugins.fugitive",
        "plugins.minidiff",
        "plugins.treesitter",
    }
)
vim.lsp.enable({"lua_ls", "basedpyright", "marksman", "copilot"})
