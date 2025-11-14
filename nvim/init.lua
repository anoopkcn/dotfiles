-- LICENSE: MIT
-- AUTHOR:  @anoopkcn
-- WARNING: (n)vim can run shell commands; audit 3rd-party plugins for malicious code.
-- NOTE: When removing a plugin also remove it from nvim-pack-lock.json

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
-- NOTE: LSP requires installation of language servers
vim.lsp.enable({"lua_ls", "basedpyright", "marksman", "copilot"})
