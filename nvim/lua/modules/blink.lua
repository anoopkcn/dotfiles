local M = {}

M.specs = {
    "https://github.com/saghen/blink.cmp",
}

M.config = function()
    local ok, blink = pcall(require, "blink.cmp")
    if not ok then
        return
    end

    blink.setup({
        signature = {
            enabled = true,
            window = {
                border = "single",
            },
        },
        completion = {
            menu = {
                auto_show = true,
                border = "single",
            },
            documentation = {
                auto_show = true,
                window = {
                    border = "single",
                },
            },
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
