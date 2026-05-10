-- Neovim Configuration (init.lua)
-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

-- OPTIONS

require("vim._core.ui2").enable({})

vim.g.mapleader = " "
vim.g.netrw_liststyle = 1

vim.opt.laststatus = 0
vim.opt.cursorline = true
vim.opt.number = true
-- vim.opt.relativenumber = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.signcolumn = "yes"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

vim.opt.wrap = true
vim.opt.showbreak = "⤷ "
vim.opt.showmode = true

vim.opt.undofile = true
vim.opt.path:append("**")
vim.opt.swapfile = false

vim.opt.wildmenu = true
vim.opt.pumborder = "rounded"

vim.opt.splitkeep = "screen"
vim.opt.splitbelow = true
vim.opt.switchbuf:append("useopen")

-- vim.opt.title = true
-- vim.opt.titlestring = "%t%m%r"
vim.opt.winbar = "%t%m%r "
    .. "%{get(b:,'gitsigns_head','') != ''"
    .. " ? '('.b:gitsigns_head.') '.get(b:,'gitsigns_status','')"
    .. " : ''}"
vim.opt.ruler = true

vim.cmd.colorscheme("onehalfdark")


-- KEYMAPS

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>",
    { noremap = true, silent = true, desc = "Disable Space" })
vim.keymap.set({ "n", "v" }, "<C-Space>", "<Nop>",
    { noremap = true, silent = true, desc = "Disable Ctrl-Space" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>",
    { noremap = true, silent = true, desc = "Clear search highlight" })

vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]],
    { noremap = true, silent = true, desc = "Paste from system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]],
    { noremap = true, silent = true, desc = "Yank to system clipboard" })

vim.keymap.set("n", "<leader>bd", vim.cmd.bd,
    { noremap = true, silent = true, desc = "Buffer delete" })
vim.keymap.set("n", "<leader>on", vim.cmd.only,
    { noremap = true, silent = true, desc = "Close other buffers" })

vim.keymap.set("n", "<leader>\\", ":rightbelow vsplit<CR>",
    { noremap = true, silent = true, desc = "Vertical split" })
vim.keymap.set("n", "<leader>-", ":rightbelow split<CR>",
    { noremap = true, silent = true, desc = "Horizontal split" })

vim.keymap.set("n", "<M-j>", "<CMD>cnext<CR>",
    { noremap = true, silent = true, desc = "Next item in quickfixlist" })
vim.keymap.set("n", "<M-k>", "<CMD>cprev<CR>",
    { noremap = true, silent = true, desc = "Prev item in quickfixlist" })

vim.keymap.set("n", "<leader>ft", vim.diagnostic.setqflist,
    { noremap = true, silent = true, desc = "Open diagnostics in quickfixlist" })
vim.keymap.set("n", "]x", function() vim.diagnostic.jump({ count = 1 }) end,
    { noremap = true, silent = true, desc = "Next diagnostic" })
vim.keymap.set("n", "[x", function() vim.diagnostic.jump({ count = -1 }) end,
    { noremap = true, silent = true, desc = "Previous diagnostic" })
vim.keymap.set("n", "]t", "<cmd>tabnext<cr>",
    { noremap = true, silent = true, desc = "Next diagnostic" })
vim.keymap.set("n", "[t", "<cmd>tabprevious<cr>",
    { noremap = true, silent = true, desc = "Previous diagnostic" })
vim.keymap.set("n", "<leader>x", function() vim.diagnostic.open_float({ border = 'rounded' }) end,
    { noremap = true, silent = true, desc = "Open diagnostic float" })

vim.keymap.set("n", "<leader>,", function() vim.lsp.buf.format({ async = true }) end,
    { noremap = true, silent = true, desc = "Format buffer" })

vim.keymap.set("n", "<C-s>", "<cmd>mksession!<cr>",
    { noremap = true, silent = true, desc = "Save session" })

vim.keymap.set("n", "<leader>fe", "<cmd>Ex<cr>",
    { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>z", "<cmd>terminal<cr>",
    { desc = "Open terminal" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]],
    { noremap = true, silent = true })

ToggleQuickfixList = function()
    local qf = vim.fn.getqflist({ winid = 1 }).winid
    if qf > 0 then vim.cmd("cclose") else vim.cmd("copen") end
end
vim.keymap.set("n", "<leader>fq", ToggleQuickfixList,
    { noremap = true, silent = true, desc = "Toggle quickfixlist" })

TimestampInsert = function()
    local raw_timestamp = os.date("%FT%T")
    local timestamp_str = string.format("%s", raw_timestamp or "")
    vim.api.nvim_put({ timestamp_str }, "c", true, true)
end
vim.keymap.set("n", "<leader>'", TimestampInsert,
    { noremap = true, silent = true, desc = "Insert current timestamp" })


-- AUTOCOMMANDS

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "GitSignsUpdate",
    callback = function() vim.cmd("redrawstatus") end,
})

local cursorline_group = vim.api.nvim_create_augroup("cursorline_active_only", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = cursorline_group,
    callback = function() vim.wo.cursorline = true end,
})
vim.api.nvim_create_autocmd("WinLeave", {
    group = cursorline_group,
    callback = function() vim.wo.cursorline = false end,
})


-- LSP

vim.pack.add {
    { src = 'https://github.com/neovim/nvim-lspconfig' },
}
vim.lsp.enable({ "clangd", "lua_ls", "pyright", "marksman", "ts_ls" })
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("CustomLspAttach", { clear = true }),
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then client.server_capabilities.semanticTokensProvider = nil end
        local map_opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ max_height = 30, max_width = 100, border = "rounded" })
        end, map_opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, map_opts)
    end,
})


-- PLUGINS

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
    {
        src = "https://github.com/github/copilot.vim",
        name = "copilot"
    },
})

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
    vim.keymap.set("n", "<leader>/", ":FuzzyGrep ",
        { silent = false, desc = "Fuzzy grep" })
    vim.keymap.set("n", "<leader>?", ":FuzzyFiles ",
        { silent = false, desc = "Fuzzy grep files" })
    vim.keymap.set("n", "<leader>.", "<CMD>FuzzyBuffers<CR>",
        { silent = false, desc = "Fuzzy grep Buffers" })
    vim.keymap.set("n", "<leader>fh", "<CMD>FuzzyHelp<CR>",
        { silent = false, desc = "Fuzzy search neovim helptags" })
    vim.keymap.set("n", "<leader>ff", "<CMD>FuzzyFiles!<CR>",
        { silent = false, desc = "Fuzzy grep files" })
    vim.keymap.set("n", "<leader>fg", "<CMD>FuzzyGrep!<CR>",
        { silent = false, desc = "Fuzzy live grep" })
    vim.keymap.set("n", "<leader>fb", "<CMD>FuzzyBuffers!<CR>",
        { silent = false, desc = "Fuzzy buffer list" })
    vim.keymap.set("n", "<leader>fl", "<CMD>FuzzyList<CR>",
        { silent = false, desc = "Fuzzy list" })
    vim.keymap.set('n', '<leader>gb', '<CMD>FuzzyGitBranches<CR>',
        { desc = "Git branches" })
    vim.keymap.set('n', '<leader>gw', '<CMD>FuzzyGitWorktrees<CR>',
        { desc = "Git worktrees" })

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
vim.keymap.set("n", "<leader>G", "<CMD>Git<CR>",
    { noremap = true, silent = true, desc = "Open Git interface" })
vim.keymap.set("n", "<leader>gl", "<CMD>Git log<CR>",
    { noremap = true, silent = true, desc = "Git log" })
-- } fugitive

-- treesitter {
vim.pack.add({
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        name = "treesitter",
        branch = "main",
    },
})

vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == 'nvim-treesitter' and kind == 'update' then
            if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
            vim.cmd('TSUpdate')
        end
    end
})

local setup_treesitter = function()
    local treesitter = require("nvim-treesitter")
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
        "markdown_inline",
        "typescript",
        "tsx",
        "bash",
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
            local lang = vim.treesitter.language.get_lang(args.match)
            if vim.list_contains(treesitter.get_installed(), lang) then
                vim.treesitter.start(args.buf)
            end
        end,
    })
end

setup_treesitter()
-- } treesitter

-- vim.pack.add({
-- {
--     src = "https://github.com/mfussenegger/nvim-dap",
--     name = "nvim-dap",
--     version = "master"
-- },
-- })
-- require("dap-config")
