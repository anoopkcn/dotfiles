local M = {}

function M.setup()
    local ok_cmp, cmp = pcall(require, "cmp")
    if not ok_cmp then
        return
    end

    ---@diagnostic disable-next-line: redundant-parameter
    cmp.setup({
        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
        performance = {
            max_view_entries = 10,
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<Up>"] = cmp.mapping.select_prev_item(),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<Down>"] = cmp.mapping.select_next_item(),
            ["<C-e>"] = cmp.mapping.abort(),
        }),

        sources = cmp.config.sources({
            { name = "nvim_lsp", group_index = 2 },
            { name = "buffer",   group_index = 2 },
        }),
    })
end

return M
