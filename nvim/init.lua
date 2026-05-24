require('vim._core.ui2').enable()
vim.opt.winborder = "rounded"
vim.opt.pumborder = "rounded"
vim.g.mapleader = " "
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.opt.laststatus = 3
vim.opt.number = true
vim.opt.ignorecase = true
vim.opt.signcolumn = "yes"
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.showbreak = "⤷ "
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.path:append("**")
vim.opt.completeopt = "menuone,noselect,fuzzy,nosort" -- popup
vim.opt.shortmess:append("c")
vim.opt.isfname:append("@-@")
vim.opt.splitbelow = true
vim.opt.switchbuf:append("useopen")
vim.opt.ruler = true
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 1
vim.g.loaded_matchit = 1
vim.opt.termguicolors = true
vim.cmd.colorscheme("onehalfdark")
vim.api.nvim_set_hl(0, "StatusLine", { bg = "#282c34" })

local map = vim.keymap.set
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true, desc = "Disable Space (reserved as leader)" })
map({ "n", "v" }, "<C-Space>", "<Nop>", { silent = true, desc = "Disable Ctrl-Space" })
map("n", "<Esc>", "<CMD>nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })
map({ "n", "v" }, "<leader>p", [["+p]], { silent = true, desc = "Paste from system clipboard" })
map({ "n", "v" }, "<leader>y", [["+y]], { silent = true, desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { silent = true, desc = "Delete without overwriting register" })
map("v", "<", "<gv", { silent = true, desc = "Indent left and reselect" })
map("v", ">", ">gv", { silent = true, desc = "Indent right and reselect" })
map("n", "J", "mzJ`z", { silent = true, desc = "Join line below without moving cursor" })
map("n", "<leader>\\", ":rightbelow vsplit<CR>", { silent = true, desc = "Split window vertically (right)" })
map("n", "<leader>-", ":rightbelow split<CR>", { silent = true, desc = "Split window horizontally (below)" })
map("n", "<C-h>", "<C-w>h", { silent = true, desc = "Focus left window" })
map("n", "<C-j>", "<C-w>j", { silent = true, desc = "Focus window below" })
map("n", "<C-k>", "<C-w>k", { silent = true, desc = "Focus window above" })
map("n", "<C-l>", "<C-w>l", { silent = true, desc = "Focus right window" })
map("n", "<leader>fe", "<CMD>Explore<CR>", { silent = true, desc = "Open file explorer" })
map("n", "<M-j>", "<CMD>cnext<CR>", { silent = true, desc = "Next quickfix item" })
map("n", "<M-k>", "<CMD>cprev<CR>", { silent = true, desc = "Previous quickfix item" })
map("n", "<leader>bd", vim.cmd.bd, { silent = true, desc = "Delete buffer" })
map("n", "<leader>on", vim.cmd.only, { silent = true, desc = "Close other windows" })
map("n", "<leader>t", vim.diagnostic.setqflist,
    { silent = true, desc = "Send diagnostics to quickfix" })
map("n", "<leader>x", function() vim.diagnostic.open_float() end,
    { silent = true, desc = "Show diagnostics" })
map("n", "<leader>q", function() vim.cmd(vim.fn.getqflist({ winid = 0 }).winid > 0 and "cclose" or "copen") end,
    { silent = true, desc = "Toggle quickfix" })
map("n", "<leader>,", function() vim.lsp.buf.format({ async = true }) end,
    { silent = true, desc = "Format buffer via LSP" })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})
local cursorline_group = vim.api.nvim_create_augroup("cursorline_active", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
    group = cursorline_group,
    callback = function() vim.wo.cursorline = true end,
})
vim.api.nvim_create_autocmd("WinLeave", {
    group = cursorline_group,
    callback = function() vim.wo.cursorline = false end,
})

require("brackets")
require("surround")

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("TreeSitterStart", { clear = true }),
    callback = function(args) pcall(vim.treesitter.start, args.buf) end,
})
vim.pack.add({
    { src = "https://github.com/anoopkcn/csub.nvim",      name = "csub" },
    { src = "https://github.com/anoopkcn/fuzzy.nvim",     name = "fuzzy" },
    { src = "https://github.com/anoopkcn/filemarks.nvim", name = "filemarks" },
    { src = "https://github.com/nvim-mini/mini.diff",     name = "mini.diff" },
    { src = "https://github.com/NicolasGB/jj.nvim",       name = "jj.nvim" },
})

require("mini.diff").setup({})

require("jj").setup({})
map("n", "<leader>J", "<CMD>J<CR>", { silent = true, desc = "Open jj log" })

require("csub").setup({
    default_mode = nil,
    handlers = {
        { match = "FuzzyGrep",    mode = "replace" },
        { match = "vimgrep",      mode = "replace" },
        { match = "FuzzyBuffers", mode = "buffers" },
        { match = "FuzzyFiles",   mode = nil },
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

require("filemarks").setup({ show_help = false, dir_open_cmd = "Explore" })
map("n", "<leader>l", "<CMD>bot FilemarksToggle<CR>", { silent = true, desc = "List filemarks" })

require("fuzzy").setup({ open_single_result = true, window = { width = 0.45, height = 0.45 } })
map("n", "<leader>fb", "<CMD>FuzzyBuffers!<CR>", { desc = "Fuzzy find buffers" })
map("n", "<leader>ff", "<CMD>FuzzyFiles!<CR>", { desc = "Fuzzy find files, open in picker" })
map("n", "<leader>fg", "<CMD>FuzzyGrep!<CR>", { desc = "Fuzzy live grep, open in picker" })
map("n", "<leader>fs", "<CMD>FuzzyLspSymbols!<CR>", { desc = "Fuzzy grep document lsp symbols" })
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


vim.pack.add({ { src = "https://github.com/neovim/nvim-lspconfig", branch = "master" } })
vim.lsp.enable({ "clangd", "lua_ls", "pyright", "ruff", "ts_ls" })
vim.g.lsp_autocomplete = false
vim.api.nvim_create_user_command("LspAutocomplete", function(opts)
    local on = (opts.args == "on") or (opts.args == "" and not vim.g.lsp_autocomplete)
    vim.g.lsp_autocomplete = on
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client:supports_method("textDocument/completion") then
            for bufnr in pairs(client.attached_buffers) do
                vim.lsp.completion.enable(on, client.id, bufnr, { autotrigger = true })
                vim.bo[bufnr].autocomplete = on
            end
        end
    end
    vim.notify("LSP autocomplete: " .. (on and "on" or "off"))
end, { nargs = "?", complete = function() return { "on", "off" } end })

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("CustomLspAttach", { clear = true }),
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then
            client.server_capabilities.semanticTokensProvider = nil -- don't re-paint
            if vim.g.lsp_autocomplete and client:supports_method("textDocument/completion") then
                vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
                vim.bo[bufnr].autocomplete = true
            end
        end
        local map_opts = { buffer = bufnr, silent = true }
        map("n", "K", function()
            vim.lsp.buf.hover({ max_height = 30, max_width = 100, border = "rounded" })
        end, vim.tbl_extend("force", map_opts, { desc = "LSP hover" }))
        map("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", map_opts, { desc = "Go to declaration" }))
        map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", map_opts, { desc = "Go to definition" }))
    end,
})
