local M = {}

M.config = function()
    local ok, fuzzy = pcall(require, "fuzzy")
    if not ok then
        return
    end

    fuzzy.setup()

    vim.keymap.set("n", "<leader>/", "<CMD>FuzzyGrep<CR>",
        { silent = false, desc = "Fuzzy grep - same as rg (FuzzyGrep)" })
    vim.keymap.set("n", "<leader>?", "<CMD>FuzzyFiles<CR>",
        { noremap = true, silent = true, desc = "Fuzzy find files (FuzzyFiles)" })
end

return M
