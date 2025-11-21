if vim.fn.executable("rg") ~= 1 then
    vim.notify("[fuzzy] 'rg' is not found in PATH; :FuzzyGrep will be unavailable", vim.log.levels.WARN)
end
if vim.fn.executable("fd") ~= 1 then
    vim.notify("[fuzzy] 'fd' is not found in PATH; :FuzzyFiles will be unavailable", vim.log.levels.WARN)
end

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

    local function _fuzzy_help()
        local pattern = vim.fn.input("FuzzyHelp: ")
        if vim.trim(pattern) == "" then
            return
        end
        local help_dirs = vim.api.nvim_get_runtime_file("doc/", true)
        if #help_dirs == 0 then
            vim.notify("No help directories found.", vim.log.levels.WARN)
            return
        end
        local args = { pattern, "--type", "txt" }
        vim.list_extend(args, help_dirs)
        fuzzy.grep(args)
    end

    vim.keymap.set("n", "<leader>fl", "<CMD>FuzzyList<CR>",
        { silent = false, desc = "Fuzzy list" })
    vim.keymap.set("n", "<leader>fh", _fuzzy_help,
        { silent = false, desc = "Fuzzy grep vim help docs" })
    vim.keymap.set("n", "<leader>/", "<CMD>FuzzyGrep<CR>",
        { silent = false, desc = "Fuzzy grep - same as rg (FuzzyGrep)" })
    vim.keymap.set("n", "<leader>fw", function() _fuzzy_grep(vim.fn.expand("<cword>"), false) end,
        { silent = false, desc = "Fuzzy grep current word" })
    vim.keymap.set("n", "<leader>fW", function() _fuzzy_grep(vim.fn.expand("<cWORD>"), true) end,
        { silent = false, desc = "Fuzzy grep current WORD" })
    vim.keymap.set("n", "<leader>ff", "<CMD>FuzzyFiles!<CR>",
        { noremap = true, silent = true, desc = "Fuzzy find files (FuzzyFiles)" })
    vim.keymap.set("n", "<leader>fb", "<CMD>FuzzyBuffers<CR>",
        { noremap = true, silent = true, desc = "Fuzzy buffer list" })
    vim.keymap.set("n", "<leader>fB", "<CMD>FuzzyBuffers!<CR>",
        { noremap = true, silent = true, desc = "Fuzzy buffer list (live)" })
    vim.keymap.set("n", "<leader>dl", "<CMD>FuzzyFiles --noignore DEVLOG<CR>",
        { noremap = true, silent = true, desc = "Open DEVLOG.md" })
end
