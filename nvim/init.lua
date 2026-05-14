-- Neovim Configuration (init.lua)
-- LICENSE: MIT
-- AUTHOR: @anoopkcn

-- nvim v 0.12.0+ {
require('vim._core.ui2').enable()
vim.opt.winborder = "rounded"
vim.opt.completeopt:append("popup")
-- }

-- OPTIONS

vim.g.mapleader = " "

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.opt.laststatus = 0
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.signcolumn = "yes"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

vim.opt.wrap = true
vim.opt.showbreak = "⤷ "

vim.opt.undofile = true
vim.opt.path:append("**")
vim.opt.swapfile = false

vim.opt.pumborder = "rounded"

vim.opt.splitkeep = "screen"
vim.opt.splitbelow = true
vim.opt.switchbuf:append("useopen")
vim.opt.winbar = "%f%m%r"

vim.g.loaded_matchit = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd.colorscheme("onehalfdark")


-- KEYMAPS (General)

local map = vim.keymap.set

map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
map({ "n", "v" }, "<C-Space>", "<Nop>", { silent = true })
map("t", "<Esc>", [[<C-\><C-n>]], { silent = true })

map("n", "<Esc>", "<CMD>nohlsearch<CR>", { silent = true })

map({ "n", "v" }, "<leader>p", [["+p]], { silent = true })
map({ "n", "v" }, "<leader>y", [["+y]], { silent = true })

map("n", "<leader>\\", ":rightbelow vsplit<CR>", { silent = true })
map("n", "<leader>-", ":rightbelow split<CR>", { silent = true })

map("n", "<M-j>", "<CMD>cnext<CR>", { silent = true })
map("n", "<M-k>", "<CMD>cprev<CR>", { silent = true })

map("n", "<C-s>", "<CMD>mksession!<CR>", { silent = true })

map("n", "<leader>bd", vim.cmd.bd, { silent = true })
map("n", "<leader>on", vim.cmd.only, { silent = true })

map("n", "<leader>t", vim.diagnostic.setqflist, { silent = true })

map("n", "<leader>x", function()
    vim.diagnostic.open_float({ border = "rounded" })
end, { silent = true })

map("n", "<leader>,", function()
    vim.lsp.buf.format({ async = true })
end, { silent = true })

map("n", "<leader>q", function()
    vim.cmd(vim.fn.getqflist({ winid = 0 }).winid > 0 and "cclose" or "copen")
end, { silent = true, desc = "Toggle quickfix" })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})


-- PLUGINS

require("brackets")
require("surround")
-- require("sessions")

vim.pack.add({
    { src = "https://github.com/stevearc/oil.nvim",               name = "oil" },
    { src = "https://github.com/NicolasGB/jj.nvim",               name = "jj.nvim" },
    { src = "https://github.com/github/copilot.vim",              name = "copilot" },
    { src = "https://github.com/anoopkcn/csub.nvim",              name = "csub" },
    { src = "https://github.com/anoopkcn/fuzzy.nvim",             name = "fuzzy" },
    { src = "https://github.com/anoopkcn/filemarks.nvim",         name = "filemarks" },
    { src = "https://github.com/neovim/nvim-lspconfig",           branch = "master" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "treesitter" },
})

vim.lsp.enable({ "clangd", "lua_ls", "pyright", "ruff", "ts_ls" })
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("CustomLspAttach", { clear = true }),
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then client.server_capabilities.semanticTokensProvider = nil end
        local map_opts = { buffer = bufnr, silent = true }
        map("n", "K", function()
            vim.lsp.buf.hover({ max_height = 30, max_width = 100, border = "rounded" })
        end, map_opts)
        map("n", "gD", vim.lsp.buf.declaration, map_opts)
        map("n", "gd", vim.lsp.buf.definition, map_opts)
    end,
})

require("csub").setup({
    default_mode = nil,
    handlers = {
        { match = "FuzzyGrep",    mode = "replace" },
        { match = "vimgrep",      mode = "replace" },
        { match = "FuzzyBuffers", mode = "buffers" },
        { match = "FuzzyFiles",   mode = "files" },
        { match = "make",         mode = nil },
    },
})

require("fuzzy").setup({
    open_single_result = true,
    window = { width = 0.45, height = 0.45 },
})

require("filemarks").setup({})

require("jj").setup({
    terminal = { window = { split_size = 0.25 } },
})

require("oil").setup({
    columns = {
        "permissions",
        "size",
        "mtime",
    },
    float = {
        border = "rounded",
        max_width = 80,
        max_height = 40,
        override = function(conf)
            conf.row = 1
            return conf
        end,
    },
    view_options = { show_hidden = true },
    confirmation = { border = "rounded" },
    keymaps = {
        ["q"] = { "actions.close", mode = "n" },
        ["<C-p>"] = false,
        ["<M-p>"] = {
            "actions.preview",
            opts = { horizontal = true, split = "belowright" },
        },
    },
})

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


-- KEYMAPS (Plugin-specific)

map("n", "<leader>s", "<CMD>Csub<CR>")

map("n", "<leader>.", "<CMD>FuzzyBuffers<CR>")
map("n", "<leader>g", "<CMD>FuzzyFiles!<CR>")
map("n", "<leader>/", "<CMD>FuzzyGrep!<CR>")
map("n", "<leader>h", "<CMD>FuzzyBuffers!<CR>")

map("n", "<leader>w", function()
    local word = vim.fn.expand("<cword>")
    if word ~= "" then require("fuzzy").grep({ word }) end
end)

map("n", "<leader>W", function()
    local word = vim.fn.expand("<cWORD>")
    if word ~= "" then require("fuzzy").grep({ "-F", word }) end
end)

map("n", "<leader>l", "<CMD>bot FilemarksList<CR>", { silent = true })

map("n", "<leader>J", "<CMD>J<CR>", { silent = true })

map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
