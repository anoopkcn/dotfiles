-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

vim.g.mapleader = " "
vim.opt.showtabline = 0
vim.opt.laststatus = 0
vim.g.netrw_liststyle = 1
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
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
vim.cmd("colorscheme habamax")
vim.opt.title = true
vim.opt.titlestring = "%t%m%r"

local text = "#bcbcbc"
local text_faint = "#767676"
local cmdline_bg = "#303030"
vim.api.nvim_set_hl(0, "NormalFloat", { fg = text })
vim.api.nvim_set_hl(0, "Pmenu", { fg = text, bg = "NONE" })
vim.api.nvim_set_hl(0, "PmenuSel", { fg = text, bg = cmdline_bg })
vim.api.nvim_set_hl(0, "PmenuBorder", { fg = cmdline_bg, bg = "NONE"})
vim.api.nvim_set_hl(0, "FloatBorder", { fg = cmdline_bg, bg = "NONE"})
vim.api.nvim_set_hl(0, "StatusLine", { fg = cmdline_bg, bg = cmdline_bg })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = cmdline_bg, bg = cmdline_bg })
vim.api.nvim_set_hl(0, "WinSeparator", { fg = cmdline_bg, bg = "NONE" })
vim.api.nvim_set_hl(0, "WinBar", { fg = text, bg = "NONE" })
vim.api.nvim_set_hl(0, "WinBarNC", { fg = text_faint, bg = "NONE" })

local function set_habamax_tabline()
    vim.api.nvim_set_hl(0, "TabLine", { fg = "#9e9e9e", bg = "#262626" })
    vim.api.nvim_set_hl(0, "TabLineFill", { fg = "#767676", bg = "#262626" })
    vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#e4e4e4", bg = "#1a3456", bold = true })
end

set_habamax_tabline()
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "habamax",
    callback = set_habamax_tabline,
})

-- keymaps {
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
vim.keymap.set("n", "]t","<cmd>tabnext<cr>",
    { noremap = true, silent = true, desc = "Next diagnostic" })
vim.keymap.set("n", "[t", "<cmd>tabprevious<cr>",
    { noremap = true, silent = true, desc = "Previous diagnostic" })
vim.keymap.set("n", "<leader>x", function() vim.diagnostic.open_float({ border = 'single' }) end,
    { noremap = true, silent = true, desc = "Open diagnostic float" })
vim.keymap.set("n", "<leader>,", function() vim.lsp.buf.format({ async = true }) end,
    { noremap = true, silent = true, desc = "Format buffer" })
vim.keymap.set("n", "<C-s>", "<cmd>mksession!<cr>",
    { noremap = true, silent = true, desc = "Save session" })
vim.keymap.set("n", "<leader>fe", "<cmd>Ex<cr>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>z", "<cmd>terminal<cr>", { desc = "Open terminal" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })


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
-- } keymaps

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})

-- LSP settings {
vim.lsp.enable({ "clangd", "lua_ls", "pyright", "marksman", })
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("CustomLspAttach", { clear = true }),
    callback = function(args)
        local bufnr = args.buf
        local map_opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ max_height = 30, max_width = 100, border = "rounded" })
        end, map_opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, map_opts)
    end,
})
-- } LSP settings

-- packages {
vim.pack.add({
    { src = "https://github.com/anoopkcn/fuzzy.nvim",     name = "fuzzy" },
    { src = "https://github.com/anoopkcn/filemarks.nvim", name = "filemarks" },
    { src = "https://github.com/anoopkcn/csub.nvim",      name = "csub" },
    { src = "https://github.com/tpope/vim-surround",      name = "vim-surround" },
    {
        src = "https://github.com/tpope/vim-unimpaired",
        name = "vim-unimpaired",
        version = "master"
    },
    { src = "https://github.com/tpope/vim-fugitive",      name = "vim-fugitive" },
    { src = "https://github.com/lewis6991/gitsigns.nvim", version = "main" },
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        name = "treesitter",
        branch = "main",
        build = ":TSUpdate",
    },
    {
        src = "https://github.com/Exafunction/windsurf.vim",
        name = "windsurf",
        version = "main"
    },
    {
        src = "https://github.com/ibhagwan/fzf-lua",
        name = "fzf-lua",
        version = "main"
    },
    -- {
    --     src = "https://github.com/mfussenegger/nvim-dap",
    --     name = "nvim-dap",
    --     version = "master"
    -- },
    -- {
    --     src = "https://github.com/stevearc/oil.nvim",
    --     name = "oil",
    --     version = "master"
    -- },
})
-- } packages

-- require("dap-config")

-- oil {
-- local ok_oil, oil = pcall(require, "oil")
-- if ok_oil then
--     oil.setup({
--         default_file_explorer = true,
--         columns = {
--             "permissions",
--             "size",
--             "mtime",
--         },
--         delete_to_trash = true,
--         skip_confirm_for_simple_edits = true,
--     })
--     vim.keymap.set("n", "<leader>fe", "<CMD>Oil<CR>", { desc = "Open parent directory" })
-- end
-- }

-- csub {
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
vim.keymap.set("n", "<leader>G", "<CMD>rightbelow vertical Git<CR>",
    { noremap = true, silent = true, desc = "Open Git interface" })
vim.keymap.set("n", "<leader>gl", "<CMD>rightbelow vertical Git log<CR>",
    { noremap = true, silent = true, desc = "Git log" })
-- } fugitive

-- fzf-lua {
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

local ok_windsurf, windsurf = pcall(require, "windsurf")
if ok_windsurf then
    windsurf.setup()
    vim.g.codeium_no_map_tab = 1

    vim.keymap.set("i", "<Tab>", function()
        return vim.fn["codeium#Accept"]()
    end, { expr = true, silent = true })
    vim.keymap.set("i", "<M-]>", function() return vim.fn["codeium#CycleCompletions"](1) end,
        { expr = true, silent = true })
    vim.keymap.set("i", "<M-[>", function() return vim.fn["codeium#CycleCompletions"](-1) end,
        { expr = true, silent = true })
    vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end, { expr = true, silent = true })
end


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
