local M = {}

M.config = function()
    local ok, fuzzy = pcall(require, "fuzzy")
    if not ok then
        return
    end
    local is_rg = vim.fn.executable("rg") == 1
    if not is_rg then
        vim.notify("[fuzzy] 'rg' (ripgrep) is not installed or not found in PATH", vim.log.levels.WARN)
        return
    end

    fuzzy.setup()

    vim.keymap.set("n", "<leader>/", "<CMD>FuzzyGrep<CR>",
        { silent = false, desc = "Fuzzy grep - same as rg (FuzzyGrep)" })
    vim.keymap.set("n", "<leader>?", "<CMD>FuzzyFiles<CR>",
        { noremap = true, silent = true, desc = "Fuzzy find files (FuzzyFiles)" })
    vim.keymap.set("n", "<leader>fb", "<CMD>FuzzyBuffers<CR>",
        { noremap = true, silent = true, desc = "Fuzzy buffer list" })
end

return M
