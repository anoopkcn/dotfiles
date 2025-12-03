local ok, fuzzy = pcall(require, "fuzzy")
if ok then
    fuzzy.setup()
    local function _fuzzy_grep(term, literal)
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
    vim.keymap.set('n', ']q', '<CMD>FuzzyNext<CR>')
    vim.keymap.set('n', '[q', '<CMD>FuzzyPrev<CR>')

    vim.keymap.set("n", "<leader>/", ":Grep ",
        { silent = false, desc = "Fuzzy grep" })

    vim.keymap.set("n", "<leader>fg", "<cmd>GrepI<cr>",
        { silent = false, desc = "Fuzzy grep" })

    vim.keymap.set("n", "<leader>?", ":Files! --type f ",
        { silent = false, desc = "Fuzzy grep files" })

    vim.keymap.set("n", "<leader>ff", "<cmd>FilesI<cr>",
        { silent = false, desc = "Fuzzy grep files" })

    vim.keymap.set("n", "<leader>fb", ":Buffers! ",
        { silent = false, desc = "Fuzzy buffer list" })

    vim.keymap.set("n", "<leader>fw", function()
            _fuzzy_grep(vim.fn.expand("<cword>"), false)
        end,
        { silent = false, desc = "Fuzzy grep current word" })

    vim.keymap.set("n", "<leader>fW", function()
            _fuzzy_grep(vim.fn.expand("<cWORD>"), true)
        end,
        { silent = false, desc = "Fuzzy grep current WORD" })

    vim.keymap.set("n", "<leader>fl", "<CMD>FuzzyList<CR>",
        { silent = false, desc = "Fuzzy list" })
end
