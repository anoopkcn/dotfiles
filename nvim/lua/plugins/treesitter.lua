local pack = require("custom.pack")

local M = {}

M.specs = {
    "https://github.com/nvim-treesitter/nvim-treesitter",
}

pack.ensure_specs(M.specs)

function M.setup()
    local ok, configs = pcall(require, "nvim-treesitter.configs")
    if not ok then
        return
    end

    configs.setup {
        ensure_installed = {
            "c", "cpp", "zig", "rust", "go", "fortran",
            "python", "bash", "lua", "vim", "vimdoc",
            "query", "markdown", "markdown_inline", "html",
            "toml", "yaml", "json", "xml",
        },
        sync_install = false,
        auto_install = false,

        modules = {},
        ignore_install = {},

        highlight = {
            enable = true,
            disable = function(_, buf)
                local max_filesize = 100 * 1024 -- 100 KB
                local ok_stat, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok_stat and stats and stats.size > max_filesize then
                    return true
                end
            end,
            additional_vim_regex_highlighting = false,
        },
    }
end

return M
