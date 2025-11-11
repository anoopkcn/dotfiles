local pack = require("custom.pack")

local M = {}

M.specs = {
    "https://github.com/saghen/blink.cmp"
}

pack.ensure_specs(M.specs)

function M.setup()
    local ok, blink = pcall(require, "blink.cmp")
    if not ok then
        return
    end

    blink.setup({
        signature = { enabled = true },
        completion = {
            menu = {
                auto_show = true,
            },
            -- <ctrl-space> to manually trigger documentation
            -- documentation = { auto_show = true},
        },
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
        fuzzy = {
            prebuilt_binaries = {
                force_version = "v1.7.0",
            },
        },
    })
end

return M
