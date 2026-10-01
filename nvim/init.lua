-- neovim config file
-- by @anoopkcn

-- TASK(20260921-124325): check for neovim to check if ui2 is natively supported
require('vim._core.ui2').enable()
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
vim.g.loaded_matchit = 1
vim.opt.termguicolors = true
-- vim.opt.scrolloff = 8
-- vim.opt.scrolloffpad = 1
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 3
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.o.statusline = " "
vim.o.winbar = " %f%m%=%l:%c  %L lines  %p%% "
-- vim.opt.cmdheight = 0

vim.cmd.colorscheme("ghostty")
local _bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
vim.api.nvim_set_hl(0, "CursorLine", { bg = _bg })
vim.api.nvim_set_hl(0, "CursorLineSign", { bg = _bg })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ecbe70", bg = _bg })
vim.api.nvim_set_hl(0, "StatusLine", { bg = _bg })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = _bg })

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
map("n", "<leader>d", vim.diagnostic.setqflist,
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


vim.api.nvim_create_autocmd({ "TextYankPost", "TextPutPost" }, {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function() vim.hl.hl_op() end,
})

-- Neovim maps .smd to rmd (Sweave), whose syntax breaks on ```python fences; treat SuperMD as markdown
vim.filetype.add({ extension = { smd = "markdown" } })

-- PLUGINS
-- brackets, surround, search_replace and dirx are auto-loaded from plugin/
vim.keymap.set('n', '<leader>fb', function() require('qfbuffers').open() end, { desc = 'Buffers in quickfix' })

vim.pack.add({
    {
        src = "https://github.com/nvim-mini/mini.diff",
        name = "mini.diff"
    },
    {
        src = "https://github.com/github/copilot.vim"
    },
    {
        src = "https://github.com/tpope/vim-fugitive",
        name = "fugitive"
    },
    {
        src = "https://github.com/dmtrKovalenko/fff.nvim",
        name = "fff.nvim"
    },
    {
        src = "https://github.com/neovim/nvim-lspconfig",
        branch = "master"
    },
    {
        src = "https://github.com/anoopkcn/filemarks.nvim"
    },
    {
        src = "https://github.com/anoopkcn/tatr.nvim"
    },
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        name = "treesitter"
    }
})

require("mini.diff").setup({
    view = {
        style = 'sign',
        signs = { add = '|', change = '|', delete = '-' },
    }
})

map("n", "<leader>G", "<CMD>Git<CR>", { silent = true, desc = "Open :Git Status" })
vim.keymap.set("n", "<leader>tn", "<CMD>Tatr new<CR>", { desc = "tatr: new task" })
vim.keymap.set("n", "<leader>tt", "<CMD>Tatr todo<CR>", { desc = "tatr: TODO to task" })
vim.keymap.set("n", "<leader>tf", "<CMD>Tatr find<CR>", { desc = "tatr: find task" })
vim.keymap.set("n", "<leader>tr", "<CMD>Tatr ref<CR>", { desc = "tatr: task references" })
vim.keymap.set("n", "<leader>ty", "<CMD>Tatr yank<CR>", { desc = "tatr: yank HUID" })
vim.keymap.set("n", "<leader>tl", "<CMD>Tatr ls<CR>", { desc = "tatr: list tasks" })
vim.keymap.set("n", "<leader>tg", "<CMD>Tatr goto<CR>", { desc = "tatr: go to task under cursor" })

vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == 'fff.nvim' and (kind == 'install' or kind == 'update') then
            if not ev.data.active then vim.cmd.packadd('fff.nvim') end
            require('fff.download').download_or_build_binary()
        end
        if name == 'treesitter' and kind == 'update' then
            if not ev.data.active then vim.cmd.packadd('treesitter') end
            vim.cmd('TSUpdate')
        end
    end,
})

-- TREESITTER
local treesitter = require("nvim-treesitter")
local ensure_installed = {
    "c", "cpp", "python", "typescript", "bash", "zsh",
    "markdown", "markdown_inline", "lua", "vim", "vimdoc",
}

local already_installed = treesitter.get_installed()
local to_install = vim.tbl_filter(function(p)
    return not vim.tbl_contains(already_installed, p)
end, ensure_installed)

if #to_install > 0 then
    treesitter.install(to_install)
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true }),
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if lang and vim.list_contains(treesitter.get_installed(), lang) then
            vim.treesitter.start(args.buf)
        end
    end,
})

vim.g.fff = {
    prompt = '❯ ',
    lazy_sync = true,
    layout = {
        anchor = 'top',
        prompt_position = 'top',
        flex = { size = 130, wrap = 'bottom' },
    },
    -- debug = { enabled = true, show_scores = true },
    debug = { enabled = false, show_scores = false },
}

vim.keymap.set('n', '<leader>ff', function() require('fff').find_files() end, { desc = 'FFFind files' })
vim.keymap.set('n', '<leader>fg', function() require('fff').live_grep() end, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fw', function() require('fff').live_grep({ query = vim.fn.expand("<cword>") }) end,
    { desc = 'Live grep word under cursor' })
vim.keymap.set('n', '<leader>fW', function() require('fff').live_grep({ query = vim.fn.expand("<cWORD>") }) end,
    { desc = 'Live grep WORD under cursor' })


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

-- vim.opt.runtimepath:prepend('/home/akc/develop/stitch.nvim')

-- vim.opt.runtimepath:prepend('/Users/akc/develop/filemarks.nvim')

require("filemarks").setup({ dir_open_cmd = "edit %s" }) --  show_help = false
map("n", "<leader>l", "<CMD>FilemarksToggle<CR>", { silent = true, desc = "List filemarks" })
