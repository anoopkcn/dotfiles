-- AUTHOR: @anoopkcn
-- LICENSE: MIT

require('vim._core.ui2').enable()
vim.opt.winborder = "rounded"

-- OPTIONS
vim.g.mapleader = " "
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.opt.laststatus = 3
vim.opt.number = true
-- vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.signcolumn = "yes"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.showbreak = "⤷ "

vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.path:append("**")
vim.opt.completeopt = "menuone,noselect,fuzzy,nosort"
vim.opt.shortmess:append("c")

vim.opt.isfname:append("@-@")
vim.opt.scrolloff = 8

vim.opt.pumborder = "rounded"
vim.opt.splitkeep = "screen"
vim.opt.splitbelow = true
vim.opt.switchbuf:append("useopen")
-- vim.opt.winbar = "%f%m%r"
vim.opt.ruler = true

vim.g.netrw_banner    = 0
vim.g.netrw_liststyle = 1
vim.g.loaded_matchit  = 1
vim.opt.termguicolors = true

-- colorscheme implemnted in ./nvim/colors/onehalfdark.lua
vim.cmd.colorscheme("onehalfdark")
vim.api.nvim_set_hl(0, "StatusLine", { bg ="#282c34" })

-- KEYMAPS
local map = vim.keymap.set
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true, desc = "Disable Space (reserved as leader)" })
map({ "n", "v" }, "<C-Space>", "<Nop>", { silent = true, desc = "Disable Ctrl-Space" })
map("n", "<Esc>", "<CMD>nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })
map("x", "p", [["_dP]], { silent = true, desc = "Paste without overwriting register" })
map({ "n", "v" }, "<leader>p", [["+p]], { silent = true, desc = "Paste from system clipboard" })
map({ "n", "v" }, "<leader>y", [["+y]], { silent = true, desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { silent = true, desc = "Delete without overwriting register" })
map("v", "<", "<gv", { silent = true, desc = "Indent left and reselect" })
map("v", ">", ">gv", { silent = true, desc = "Indent right and reselect" })
map("n", "J", "mzJ`z", { silent = true, desc = "Join line below without moving cursor" })
map("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor entered" })
map("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })
map("n", "n", "nzzzv", { desc = "Next search result with cursor centered" })
map("n", "N", "Nzzzv", { desc = "Previous search result with cursor centered" })
map("n", "<leader>\\", ":rightbelow vsplit<CR>", { silent = true, desc = "Split window vertically (right)" })
map("n", "<leader>-", ":rightbelow split<CR>", { silent = true, desc = "Split window horizontally (below)" })
map("n", "<leader>fe", "<CMD>Explore<CR>", { silent = true, desc = "Open file explorer" })
map("n", "<M-j>", "<CMD>cnext<CR>", { silent = true, desc = "Next quickfix item" })
map("n", "<M-k>", "<CMD>cprev<CR>", { silent = true, desc = "Previous quickfix item" })
map("n", "<leader>bd", vim.cmd.bd, { silent = true, desc = "Delete buffer" })
map("n", "<leader>on", vim.cmd.only, { silent = true, desc = "Close other windows" })
map("n", "<leader>t", vim.diagnostic.setqflist, { silent = true, desc = "Send diagnostics to quickfix" })
map("n", "<leader>x", function()
    vim.diagnostic.open_float({ border = "rounded" })
end, { silent = true, desc = "Show diagnostic in float" })
map("n", "<leader>,", function()
    vim.lsp.buf.format({ async = true })
end, { silent = true, desc = "Format buffer via LSP" })
map("n", "<leader>q", function()
    vim.cmd(vim.fn.getqflist({ winid = 0 }).winid > 0 and "cclose" or "copen")
end, { silent = true, desc = "Toggle quickfix" })
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Replace word cursor is on globally" })

-- AUTOCOMMANDS
-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})

-- write a session file
vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
    pattern = { "*.*" },
    callback = function() vim.cmd("silent! mkview") end,
})
-- load view for the current file
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    pattern = { "*.*" },
    callback = function() vim.cmd("silent! loadview") end,
})

-- -- cursorline only in active window
-- vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
--     group = vim.api.nvim_create_augroup("cursorline_active", { clear = true }),
--     callback = function() vim.wo.cursorline = true end,
-- })
-- vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
--     group = "cursorline_active",
--     callback = function() vim.wo.cursorline = false end,
-- })
--
require("brackets")
require("surround")

-- TREESITTER
vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "treesitter" } })
local treesitter = require("nvim-treesitter")
local ensure_installed = {
    "vim", "vimdoc", "rust", "c", "cpp", "go",
    "html", "css", "javascript", "json",
    "markdown", "markdown_inline",
    "typescript", "tsx", "bash", "python", "lua",
}

local already_installed = require("nvim-treesitter.config").get_installed()
local to_install = vim.tbl_filter(function(p)
    return not vim.tbl_contains(already_installed, p)
end, ensure_installed)

if #to_install > 0 then
    treesitter.install(to_install)
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

vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == "nvim-treesitter" and kind == "update" then
            if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
            vim.cmd("TSUpdate")
        end
    end,
})

-- LSP
vim.pack.add({ { src = "https://github.com/neovim/nvim-lspconfig", branch = "master" } })
vim.lsp.enable({ "clangd", "lua_ls", "pyright", "ruff", "ts_ls" })
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("CustomLspAttach", { clear = true }),
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then
            client.server_capabilities.semanticTokensProvider = nil -- don't re-paint
            -- if client:supports_method("textDocument/completion") then
            --     vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
            --     vim.bo[bufnr].autocomplete = true
            -- end
        end
        local map_opts = { buffer = bufnr, silent = true }
        map("n", "K", function()
            vim.lsp.buf.hover({ max_height = 30, max_width = 100, border = "rounded" })
        end, vim.tbl_extend("force", map_opts, { desc = "LSP hover" }))
        map("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", map_opts, { desc = "Go to declaration" }))
        map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", map_opts, { desc = "Go to definition" }))
    end,
})

-- COPILOT
-- vim.pack.add({{ src = "https://github.com/zbirenbaum/copilot.lua", name = "copilot" }})
-- vim.api.nvim_create_autocmd("InsertEnter", {
--     once = true,
--     callback = function()
--         require("copilot").setup({
--             suggestion = { auto_trigger = true },
--             filetypes = { markdown = true },
--         })
--     end,
-- })

vim.pack.add({
    { src = "https://github.com/NicolasGB/jj.nvim",       name = "jj.nvim" },
    { src = "https://github.com/anoopkcn/csub.nvim",      name = "csub" },
    { src = "https://github.com/anoopkcn/fuzzy.nvim",     name = "fuzzy" },
    { src = "https://github.com/anoopkcn/filemarks.nvim", name = "filemarks" },
    { src = "https://github.com/tpope/vim-fugitive",      name = "fugitive" },
    { src = "https://github.com/nvim-mini/mini.diff",     name = "mini.diff" },
})

require("mini.diff").setup({
    -- source = require("mini.diff").gen_source.git({ index = false }),
})

require("csub").setup({
    default_mode = nil,
    handlers = {
        { match = "FuzzyGrep",    mode = "replace" },
        { match = "vimgrep",      mode = "replace" },
        { match = "FuzzyBuffers", mode = "buffers" },
        { match = "FuzzyFiles",   mode = nil },
        { match = "make",         mode = nil },
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "qf", "csub" },
    group = vim.api.nvim_create_augroup("CsubQfMap", { clear = true }),
    callback = function(args)
        map("n", "<leader>s", "<CMD>Csub<CR>",
            { buffer = args.buf, silent = true, desc = "Substitute in quickfix (Csub)" })
    end,
})

require("fuzzy").setup({
    open_single_result = true,
    window = { width = 0.45, height = 0.45 },
})

require("filemarks").setup({
    show_help = false,
    dir_open_cmd = "Explore"
})

require("jj").setup({})

map("n", "<leader>fb", "<CMD>FuzzyBuffers!<CR>", { desc = "Fuzzy find buffers" })
map("n", "<leader>ff", "<CMD>FuzzyFiles!<CR>", { desc = "Fuzzy find files, open in picker" })
map("n", "<leader>fg", "<CMD>FuzzyGrep!<CR>", { desc = "Fuzzy live grep, open in picker" })
map("n", "<leader>fz", "<CMD>FuzzyLspSymbols!<CR>", { desc = "Fuzzy find LSP symbols" })
map("n", "<leader>?", ":FuzzyFiles ", { desc = "Fuzzy find files, open in qf" })
map("n", "<leader>/", ":FuzzyGrep ", { desc = "Fuzzy grep, open in qf" })
map("n", "<leader>fw", function()
    local word = vim.fn.expand("<cword>")
    if word ~= "" then require("fuzzy").grep({ word }) end
end, { desc = "Grep word under cursor" })
map("n", "<leader>fW", function()
    local word = vim.fn.expand("<cWORD>")
    if word ~= "" then require("fuzzy").grep({ "-F", word }) end
end, { desc = "Grep WORD under cursor (fixed string)" })
map("n", "<leader>l", "<CMD>bot FilemarksToggle<CR>", { silent = true, desc = "List filemarks" })
map("n", "<leader>J", "<CMD>J<CR>", { silent = true, desc = "Open jj log" })
map("n", "<leader>G", "<CMD>Git<CR>", { silent = true, desc = "Open fugitive Git status" })
