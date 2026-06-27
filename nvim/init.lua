-- neovim config file
-- by @anoopkcn

require('vim._core.ui2').enable({
    msg = {
        pager  = { height = 0.4 },
        dialog = { height = 0.4 },
    },
})
vim.opt.fillchars:append({ msgsep = "─" })

vim.opt.winborder = "rounded"
vim.opt.pumborder = "rounded"
vim.g.mapleader = " "
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
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
vim.g.netrw_liststyle = 1
vim.g.loaded_matchit = 1
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 3
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.o.statusline = " "
vim.o.winbar = " %f%m"
vim.opt.cmdheight = 0

vim.cmd.colorscheme("slate")
local _bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
vim.api.nvim_set_hl(0, "CursorLine", { bg = _bg })
vim.api.nvim_set_hl(0, "CursorLineSign", { bg = _bg })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ecbe70", bg = _bg })
vim.api.nvim_set_hl(0, "StatusLine", { fg = _bg, bg = _bg })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = _bg, bg = _bg })

local map = vim.keymap.set
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true, desc = "Disable Space (reserved as leader)" })
map({ "n", "v" }, "<C-Space>", "<Nop>", { silent = true, desc = "Disable Ctrl-Space" })
map({ "n", "v" }, "<leader>p", [["+p]], { silent = true, desc = "Paste from system clipboard" })
map({ "n", "v" }, "<leader>y", [["+y]], { silent = true, desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { silent = true, desc = "Delete without overwriting register" })
map("v", "<", "<gv", { silent = true, desc = "Indent left and reselect" })
map("v", ">", ">gv", { silent = true, desc = "Indent right and reselect" })
map("n", "<Esc>", "<CMD>nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })
map("n", "J", "mzJ`z", { silent = true, desc = "Join line below without moving cursor" })
map("n", "<leader>\\", ":rightbelow vsplit<CR>", { silent = true, desc = "Split window vertically (right)" })
map("n", "<leader>-", ":rightbelow split<CR>", { silent = true, desc = "Split window horizontally (below)" })
map("n", "<C-h>", "<C-w>h", { silent = true, desc = "Focus left window" })
map("n", "<C-j>", "<C-w>j", { silent = true, desc = "Focus window below" })
map("n", "<C-k>", "<C-w>k", { silent = true, desc = "Focus window above" })
map("n", "<C-l>", "<C-w>l", { silent = true, desc = "Focus right window" })
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
map("n", "<leader>z", ":! ", { desc = "Execute a command" })

map("n", "<Tab>", ">>", { silent = true, desc = "Indent line" })
map("n", "<S-Tab>", "<<", { silent = true, desc = "De-indent line" })
map("v", "<Tab>", ">gv", { silent = true, desc = "Indent selection" })
map("v", "<S-Tab>", "<gv", { silent = true, desc = "De-indent selection" })


vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})

-- PLUGINS
require("brackets")
require("surround")
require("search_replace")

vim.keymap.set('n', '<leader>fb', function() require('qfbuffers').open() end, { desc = 'Buffers in quickfix' })

vim.pack.add({
    {
        src = "https://github.com/nvim-mini/mini.diff",
        name = "mini.diff"
    },
    {
        src = "https://github.com/NicolasGB/jj.nvim",
        name = "jj.nvim"
    },
    {
        src = "https://github.com/tpope/vim-fugitive",
        name = "fugitive"
    },
    {
        src = "https://github.com/dmtrKovalenko/fff.nvim",
        name = "fff.nvim"
    },
})

require("mini.diff").setup({
    view = {
        style = 'sign',
        signs = { add = '|', change = '|', delete = '-' },
    }
})

require("jj").setup({
    cmd = {
        keymaps = { close = { "q", "<Esc>", "gq" } }
    }
})
map("n", "<leader>J", "<CMD>J<CR>", { silent = true, desc = "Open :J log" })
map("n", "<leader>G", "<CMD>Git<CR>", { silent = true, desc = "Open :Git Status" })

vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == 'fff.nvim' and (kind == 'install' or kind == 'update') then
            if not ev.data.active then vim.cmd.packadd('fff.nvim') end
            require('fff.download').download_or_build_binary()
        end
    end,
})

vim.g.fff = {
    prompt = '❯ ',
    lazy_sync = true,
    debug = { enabled = true, show_scores = true },
    layout = {
        anchor = 'top',
        prompt_position = 'top',
        flex = { size = 130, wrap = 'bottom' },
    },
    debug = {
    enabled = false,
    show_scores = false,
  },
}

vim.keymap.set('n', '<leader>ff', function() require('fff').find_files() end, { desc = 'FFFind files' })
vim.keymap.set('n', '<leader>fg', function() require('fff').live_grep() end, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fw', function() require('fff').live_grep({ query = vim.fn.expand("<cword>") }) end,
    { desc = 'Live grep word under cursor' })
vim.keymap.set('n', '<leader>fW', function() require('fff').live_grep({ query = vim.fn.expand("<cWORD>") }) end,
    { desc = 'Live grep WORD under cursor' })



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


-- LOCAL PLUGINS

-- vim.opt.runtimepath:prepend('/Users/akc/develop/oil.nvim')
vim.pack.add({ { src = "https://github.com/anoopkcn/oil.nvim" } })
function _G.get_oil_winbar()
    local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
    local dir = require("oil").get_current_dir(bufnr)
    if dir then
        return dir -- full absolute path
    else
        return vim.api.nvim_buf_get_name(0)
    end
end

require("oil").setup({
    columns = { "permissions", "size", "mtime" },
    delete_to_trash = true,
    skip_confirmation = true,
    view_options = {
        show_hidden = true,
    },
    win_options = {
        winbar = "%!v:lua.get_oil_winbar()",
    },
    keymaps = {
        ["!"] = "actions.run_command",
        ["&"] = "actions.run_command_async",
        ["<C-c>"] = "actions.stop_command",
    },
})

map("n", "<leader>fe", "<CMD>Oil<CR>", { silent = true, desc = "Open file explorer" })

-- vim.opt.runtimepath:prepend('/Users/akc/develop/filemarks.nvim')
vim.pack.add({ { src = "https://github.com/anoopkcn/filemarks.nvim" } })
require("filemarks").setup({ dir_open_cmd = "Oil %s" }) --  show_help = false
map("n", "<leader>l", "<CMD>FilemarksToggle<CR>", { silent = true, desc = "List filemarks" })
