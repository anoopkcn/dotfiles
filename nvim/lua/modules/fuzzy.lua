local M = {}

M.config = function()
    local ok, fuzzy = pcall(require, "fuzzy")
    if not ok then
        return
    end
    if vim.fn.executable("rg") ~= 1 then
        vim.notify("[fuzzy] 'rg' (ripgrep) is not installed or not found in PATH; :FuzzyGrep will be unavailable", vim.log.levels.WARN)
    end
    if vim.fn.executable("fd") ~= 1 then
        vim.notify("[fuzzy] 'fd' is not installed; :FuzzyFiles will be unavailable", vim.log.levels.WARN)
    end

    fuzzy.setup()

    local function run_fuzzy_grep(term, literal)
        term = vim.trim(term or "")
        if term == "" then
            return
        end
        local args = { term }
        if literal then
            table.insert(args, 1, "-F")
        end
        fuzzy.grep(args)
    end

    vim.keymap.set("n", "<leader>/", "<CMD>FuzzyGrep<CR>",
        { silent = false, desc = "Fuzzy grep - same as rg (FuzzyGrep)" })
    vim.keymap.set("n", "<leader>fw", function()
            run_fuzzy_grep(vim.fn.expand("<cword>"), false)
        end,
        { silent = false, desc = "Fuzzy grep current word" })
    vim.keymap.set("n", "<leader>fW", function()
            run_fuzzy_grep(vim.fn.expand("<cWORD>"), true)
        end,
        { silent = false, desc = "Fuzzy grep current WORD" })
    vim.keymap.set("n", "<leader>?", "<CMD>FuzzyFiles<CR>",
        { noremap = true, silent = true, desc = "Fuzzy find files (FuzzyFiles)" })
    vim.keymap.set("n", "<leader>fb", "<CMD>FuzzyBuffers<CR>",
        { noremap = true, silent = true, desc = "Fuzzy buffer list" })
end

return M
