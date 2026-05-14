-- Neovim Configuration (init.lua)
-- LICENSE: MIT
-- AUTHOR: @anoopkcn

-- OPTIONS

vim.g.mapleader = " "

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.opt.laststatus = 0
vim.opt.number = true
vim.opt.relativenumber = true
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
vim.opt.winbar = "%f%m%r"
vim.opt.ruler = true

vim.g.loaded_matchit = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd.colorscheme("onehalfdark")


-- KEYMAPS

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<C-Space>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })

vim.keymap.set("n", "<Esc>", "<CMD>nohlsearch<CR>", { noremap = true, silent = true })

vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]], { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { noremap = true, silent = true })

vim.keymap.set("n", "<leader>\\", ":rightbelow vsplit<CR>", { noremap = true, silent = true, })
vim.keymap.set("n", "<leader>-", ":rightbelow split<CR>", { noremap = true, silent = true, })

vim.keymap.set("n", "<M-j>", "<CMD>cnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<M-k>", "<CMD>cprev<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-s>", "<CMD>mksession!<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>bd", vim.cmd.bd, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>on", vim.cmd.only, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>ft", vim.diagnostic.setqflist, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>x", function()
    vim.diagnostic.open_float({ border = 'rounded' })
end, { noremap = true, silent = true, })

vim.keymap.set("n", "<leader>,", function()
    vim.lsp.buf.format({ async = true })
end, { noremap = true, silent = true, })

vim.keymap.set("n", "<leader>fq", function()
    local qf = vim.fn.getqflist({ winid = 1 }).winid
    if qf > 0 then vim.cmd("cclose") else vim.cmd("copen") end
end, { noremap = true, silent = true, })

vim.keymap.set("n", "<leader>'", function()
    local raw_timestamp = os.date("%FT%T")
    local timestamp_str = string.format("%s", raw_timestamp or "")
    vim.api.nvim_put({ timestamp_str }, "c", true, true)
end, { noremap = true, silent = true, })


vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})


-- PLUGINS

require("brackets")
require("surround")

vim.pack.add({
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
        local map_opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ max_height = 30, max_width = 100, border = "rounded" })
        end, map_opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, map_opts)
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

local treesitter = require("nvim-treesitter")
local ensure_installed = {
    "vim", "vimdoc", "rust", "c", "cpp", "go",
    "html", "css", "javascript", "json",
    "markdown", "markdown_inline",
    "typescript", "tsx", "bash", "python", "lua",
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

vim.keymap.set("n", "<leader>s", "<CMD>Csub<CR>", {})
vim.keymap.set("n", "<leader>/", ":FuzzyGrep ", { silent = false })
vim.keymap.set("n", "<leader>?", ":FuzzyFiles ", { silent = false })
vim.keymap.set("n", "<leader>.", "<CMD>FuzzyBuffers<CR>", { silent = false })
vim.keymap.set("n", "<leader>fh", "<CMD>FuzzyHelp<CR>", { silent = false })
vim.keymap.set("n", "<leader>ff", "<CMD>FuzzyFiles!<CR>", { silent = false })
vim.keymap.set("n", "<leader>fg", "<CMD>FuzzyGrep!<CR>", { silent = false })
vim.keymap.set("n", "<leader>fb", "<CMD>FuzzyBuffers!<CR>", { silent = false })
vim.keymap.set("n", "<leader>fl", "<CMD>FuzzyList<CR>", { silent = false })
vim.keymap.set("n", "<leader>gb", "<CMD>FuzzyGitBranches<CR>", { silent = false })
vim.keymap.set("n", "<leader>gw", "<CMD>FuzzyGitWorktrees<CR>", { silent = false })

vim.keymap.set("n", "<leader>fw", function()
    local word = vim.fn.expand("<cword>")
    if word ~= "" then require("fuzzy").grep({ word }) end
end, {})

vim.keymap.set("n", "<leader>fW", function()
    local word = vim.fn.expand("<cWORD>")
    if word ~= "" then require("fuzzy").grep({ "-F", word }) end
end, {})

vim.keymap.set("n", "<leader>l", "<CMD>bot FilemarksList<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>J", "<CMD>J<CR>", { noremap = true, silent = true })
