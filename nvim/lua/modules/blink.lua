local M = {}

M.specs = {
    "https://github.com/saghen/blink.cmp",
    "https://github.com/fang2hou/blink-copilot"
}

function M.setup()
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
            default = { "copilot", 'lsp', 'path', 'snippets', 'buffer' },
            providers = {
                copilot = {
                    name = "copilot",
                    module = "blink-copilot",
                    score_offset = 100,
                    async = true,
                    opts = {
                        max_completions = 2,
                    }
                }
            },
        },
        fuzzy = {
            prebuilt_binaries = {
                force_version = "v1.7.0",
            },
        },
    })
end

return M
