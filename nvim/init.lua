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
vim.opt.wrap = false
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
vim.cmd("colorscheme onehalfdark")

local text = "#dcdfe4"
-- local text_faint = "#555963"
local background = "#292c33"
local cmdline_bg = "#31353e"
local visual_bg = "#414B5E"
vim.api.nvim_set_hl(0, "NormalFloat", { bg = background })
-- vim.api.nvim_set_hl(0, "Normal", { fg = text, bg = background })
vim.api.nvim_set_hl(0, "NormalFloat", { fg = text })
vim.api.nvim_set_hl(0, "Pmenu", { fg = text, bg = background })
vim.api.nvim_set_hl(0, "PmenuSel", { fg = text, bg = cmdline_bg })
vim.api.nvim_set_hl(0, "PmenuBorder", { fg = cmdline_bg, bg = background })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = cmdline_bg, bg = background })
-- vim.api.nvim_set_hl(0, "StatusLine", { fg = text, bg = cmdline_bg })
-- vim.api.nvim_set_hl(0, "StatusLineNC", { fg = text_faint, bg = cmdline_bg })
vim.api.nvim_set_hl(0, "WinSeparator", { fg = cmdline_bg, bg = cmdline_bg })
vim.api.nvim_set_hl(0, "NetrwMarkFile", { fg = text, bg = visual_bg, bold = true })

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
vim.keymap.set("n", "]t", function() vim.diagnostic.jump({ count = 1 }) end,
    { noremap = true, silent = true, desc = "Next diagnostic" })
vim.keymap.set("n", "[t", function() vim.diagnostic.jump({ count = -1 }) end,
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
-- vim.lsp.enable({ "clangd", "lua_ls", "pyright", "marksman", })
-- vim.api.nvim_create_autocmd("LspAttach", {
--     group = vim.api.nvim_create_augroup("CustomLspAttach", { clear = true }),
--     callback = function(args)
--         local bufnr = args.buf
--         -- local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
--         -- client.server_capabilities.semanticTokensProvider = nil
--
--         -- LSP autotriggered completion
--         -- if client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
--         --     vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
--         --     vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
--         --     vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get)
--         -- end
--
--         local map_opts = { buffer = bufnr, noremap = true, silent = true }
--         vim.keymap.set("n", "K", function()
--             vim.lsp.buf.hover({ max_height = 30, max_width = 100, border = "rounded" })
--         end, map_opts)
--         vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)
--         vim.keymap.set("n", "gd", vim.lsp.buf.definition, map_opts)
--     end,
-- })
-- } LSP settings

-- packages {
vim.pack.add({
    { src = "https://github.com/anoopkcn/fuzzy.nvim", name = "fuzzy" },
    { src = "https://github.com/anoopkcn/filemarks.nvim", name = "filemarks" },
    { src = "https://github.com/anoopkcn/csub.nvim", name = "csub" },
    { src = "https://github.com/tpope/vim-surround", name = "vim-surround" },
    { src = "https://github.com/tpope/vim-unimpaired", name = "vim-unimpaired", version = "master" },
    { src = "https://github.com/tpope/vim-fugitive", name = "vim-fugitive" },
    { src = "https://github.com/lewis6991/gitsigns.nvim", version = "main" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "treesitter", version = "main" },
    { src = "https://github.com/github/copilot.vim", name = "copilot", version = "release" },
    { src ="https://github.com/mfussenegger/nvim-dap", name = "nvim-dap", version = "master" },
    { src = "https://github.com/ibhagwan/fzf-lua", name = "fzf-lua", version = "main" },
})
-- } packages

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
local ok, fuzzy = pcall(require, "fuzzy")
if ok then
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
local ok, filemarks = pcall(require, "filemarks")
if ok then
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

-- nvim-treesitter {
local ok, configs = pcall(require, "nvim-treesitter.configs")
if ok then
    configs.setup {
        ensure_installed = {
            "c", "cpp", "zig",
            "python", "bash", "lua",
            "vim", "vimdoc", "markdown",
        },
        sync_install = false,
        auto_install = false,

        modules = {},
        ignore_install = {},

        highlight = {
            enable = true,
            disable = function(_, buf)
                local max_filesize = 100 * 1024 -- 100 KB
                local ok_stat, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok_stat and stats and stats.size > max_filesize then
                    return true
                end
            end,
            additional_vim_regex_highlighting = false,
        },
    }
end
-- } nvim-treesitter
--
require("dap-config")

-- fzf-lua {
local ok, fzf = pcall(require, "fzf-lua")
if ok then
    fzf.setup({
        winopts = {
            split = "belowright new",
        }
    })
    vim.api.nvim_set_hl(0, "FzfLuaPreviewBorder", { link = "WinSeparator" })
    vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "FZF Files" })
    vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "FZF grep" })
    vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "FZF helptags" })
end
-- } fzf-lua
