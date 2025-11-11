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
}

for _, module_name in ipairs(plugin_modules) do
    local ok, mod = pcall(require, module_name)
    if ok and type(mod.setup) == "function" then
        mod.setup()
    elseif not ok then
        vim.notify(string.format("Failed to load %s: %s", module_name, mod), vim.log.levels.WARN)
    end
end
