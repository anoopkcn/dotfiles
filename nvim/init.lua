-- Neovim Configuration (init.lua)
-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

vim.g.mapleader = " "
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
vim.opt.termguicolors = true

local text = "#bcbcbc"
local text_faint = "#767676"
local cmdline_bg = "#303030"
vim.api.nvim_set_hl(0, "NormalFloat", { fg = text })
vim.api.nvim_set_hl(0, "Pmenu", { fg = text, bg = "NONE" })
vim.api.nvim_set_hl(0, "PmenuSel", { fg = text, bg = cmdline_bg })
vim.api.nvim_set_hl(0, "PmenuBorder", { fg = cmdline_bg, bg = "NONE" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = cmdline_bg, bg = "NONE" })
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

-- make background transparent
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
-- vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
vim.api.nvim_set_hl(0, "FoldColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })

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
vim.keymap.set("n", "]t", "<cmd>tabnext<cr>",
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

require("plugins")
