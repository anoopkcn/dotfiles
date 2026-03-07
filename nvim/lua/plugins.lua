-- Plugins for neovim
-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

-- packages {
vim.pack.add({
    {
        src = "https://github.com/lewis6991/gitsigns.nvim",
        version = "main"
    },
    {
        src = "https://github.com/tpope/vim-surround",
        name = "vim-surround"
    },
    {
        src = "https://github.com/tpope/vim-unimpaired",
        name = "vim-unimpaired",
        version = "master"
    },
})
-- } packages

-- vim.pack.add({
-- {
--     src = "https://github.com/mfussenegger/nvim-dap",
--     name = "nvim-dap",
--     version = "master"
-- },
-- })
-- require("dap-config")

-- csub {
vim.pack.add({
    {
        src = "https://github.com/anoopkcn/csub.nvim",
        name = "csub"
    },
})
local ok, csub = pcall(require, "csub")
if ok then
    csub.setup({
        default_mode = nil,
        handlers = {
            { match = "FuzzyGrep",    mode = "replace" },
            { match = "vimgrep",      mode = "replace" },
            { match = "FuzzyBuffers", mode = "buffers" },
            { match = "FuzzyFiles",   mode = nil }, -- disabled
            { match = "make",         mode = nil }, -- disabled
        },
    })
    vim.keymap.set("n", "<leader>s", "<cmd>Csub<cr>",
        { desc = "Open Csub buffer for current active quickfix list" })
end
-- } csub

-- fuzzy {
vim.pack.add({
    {
        src = "https://github.com/anoopkcn/fuzzy.nvim",
        name = "fuzzy"
    },
})
local ok_fuzzy, fuzzy = pcall(require, "fuzzy")
if ok_fuzzy then
    fuzzy.setup()

    -- vim.keymap.set('n', ']q', '<CMD>FuzzyNext<CR>')
    -- vim.keymap.set('n', '[q', '<CMD>FuzzyPrev<CR>')
    vim.keymap.set("n", "<leader>fl", "<CMD>FuzzyList<CR>", { silent = false, desc = "Fuzzy list" })
    vim.keymap.set("n", "<leader>/", ":Grep ", { silent = false, desc = "Fuzzy grep" })
    vim.keymap.set("n", "<leader>?", ":Files! --type f ", { silent = false, desc = "Fuzzy grep files" })
    -- vim.keymap.set("n", "<leader>ff", ":Files ", { silent = false, desc = "Fuzzy grep files" })
    vim.keymap.set("n", "<leader>fb", ":Buffers! ", { silent = false, desc = "Fuzzy buffer list" })

    vim.keymap.set('n', '<leader>fw', function()
        local word = vim.fn.expand('<cword>')
        if word ~= '' then fuzzy.grep({ word }) end
    end, { desc = 'Grep word' })

    vim.keymap.set('n', '<leader>fW', function()
        local word = vim.fn.expand('<cWORD>')
        if word ~= '' then fuzzy.grep({ '-F', word }) end
    end, { desc = 'Grep WORD (literal)' })
end
-- } fuzzy

-- filemarks {
vim.pack.add({
    {
        src = "https://github.com/anoopkcn/filemarks.nvim",
        name = "filemarks"
    },
})
local ok_filemarks, filemarks = pcall(require, "filemarks")
if ok_filemarks then
    filemarks.setup({
        dir_open_cmd = "Explore"
        -- dir_open_cmd = "Oil %s"
    })
    vim.keymap.set("n", "<leader>l", "<cmd>bot FilemarksList<cr>",
        { noremap = true, silent = true, desc = "show file marks list" })
end
-- } filemarks

-- fugitive {
vim.pack.add({
    {
        src = "https://github.com/tpope/vim-fugitive",
        name = "vim-fugitive"
    },
})
vim.keymap.set("n", "<leader>G", "<CMD>rightbelow vertical Git<CR>",
    { noremap = true, silent = true, desc = "Open Git interface" })
vim.keymap.set("n", "<leader>gl", "<CMD>rightbelow vertical Git log<CR>",
    { noremap = true, silent = true, desc = "Git log" })
-- } fugitive

-- fzf-lua {
vim.pack.add({
    {
        src = "https://github.com/ibhagwan/fzf-lua",
        name = "fzf-lua",
        version = "main"
    },
})
local ok_fzf, fzf = pcall(require, "fzf-lua")
if ok_fzf then
    local actions = require("fzf-lua.actions")
    fzf.setup({
        actions = {
            files = {
                true,
                ["alt-q"] = actions.file_sel_to_qf,
                ["alt-Q"] = actions.file_sel_to_ll,
                ["ctrl-q"] = { fn = actions.file_sel_to_qf, prefix = "select-all" },
            },
        },
        winopts = {
            split = "belowright new",
            on_create = function(e)
                vim.schedule(function()
                    if e and e.winid and vim.api.nvim_win_is_valid(e.winid) then
                        vim.wo[e.winid].statusline = " "
                    end
                end)
            end,
        }
    })
    vim.api.nvim_set_hl(0, "FzfLuaPreviewBorder", { link = "WinSeparator" })
    vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "FZF Files" })
    vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "FZF grep" })
    vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "FZF helptags" })
end

-- } fzf-lua


-- treesitter {
vim.pack.add({
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        name = "treesitter",
        branch = "main",
        build = ":TSUpdate",
    },
})
local setup_treesitter = function()
    local treesitter = require("nvim-treesitter")
    treesitter.setup({})
    local ensure_installed = {
        "vim",
        "vimdoc",
        "rust",
        "c",
        "cpp",
        "go",
        "html",
        "css",
        "javascript",
        "json",
        "lua",
        "markdown",
        "typescript",
        "bash",
        "lua",
        "python",
    }

    local config = require("nvim-treesitter.config")

    local already_installed = config.get_installed()
    local parsers_to_install = {}

    for _, parser in ipairs(ensure_installed) do
        if not vim.tbl_contains(already_installed, parser) then
            table.insert(parsers_to_install, parser)
        end
    end

    if #parsers_to_install > 0 then
        treesitter.install(parsers_to_install)
    end

    local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
            if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
                vim.treesitter.start(args.buf)
            end
        end,
    })
end

setup_treesitter()
-- } treesitter

-- autofill {
vim.pack.add({ { src = "/users/akc/develop/autofill.nvim", name = "autofill" } })
local ok_autofill, autofill = pcall(require, "autofill")
if ok_autofill then
    autofill.setup({
        lsp = { enabled = false },
        treesitter = { enabled = false },
        keymaps = {
            accept = '<Tab>',
            accept_word = "<C-l>",
        },
        backend = 'gemini',
        -- log_level = 'debug'
    })
end
-- } autofill
