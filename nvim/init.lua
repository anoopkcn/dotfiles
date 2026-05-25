-- neovim config file
-- by @anoopkcn

require('vim._core.ui2').enable({
    msg = {
        pager  = { height = 0.5 },
        dialog = { height = 0.5 },
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

local c = {
    black  = { gui = "#1d1f27", cterm = 236 },
    red    = { gui = "#f5c3bb", cterm = 168 },
    green  = { gui = "#c1f4c4", cterm = 114 },
    yellow = { gui = "#f7e19e", cterm = 180 },
    blue   = { gui = "#b1dafb", cterm = 75 },
    purple = { gui = "#b26cc7", cterm = 176 },
    cyan   = { gui = "#a6f5f6", cterm = 73 },
    white  = { gui = "#e0e2e9", cterm = 188 },
    border = { gui = "#505257", cterm = 237 },
}

local set_hl = vim.api.nvim_set_hl

local function h(group, fg, bg, attr)
    local spec = {}
    if fg then spec.fg, spec.ctermfg = fg.gui, fg.cterm end
    if bg then spec.bg, spec.ctermbg = bg.gui, bg.cterm end
    if attr then spec[attr] = true end
    set_hl(0, group, spec)
end


h("Normal", nil, c.black, nil)
h("StatusLine", nil, c.black)
h("NormalFloat", c.fg, c.bg, nil)
h("FloatBorder", c.border, c.bg, nil)
h("FloatTitle", c.blue, c.bg, "bold")
h("Pmenu", c.fg, c.bg, nil)
h("PmenuSel", c.fg, c.border, "bold")
h("PmenuBorder", c.border, c.bg, nil)
h("MsgSeparator", c.border, nil, nil)
h("WinSeparator", c.border, nil, nil)

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
map("n", "<leader>z", ":! ", { desc = "Execute a command" })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})


-- PLUGINS

require("brackets")
require("surround")

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("TreeSitterStart", { clear = true }),
    callback = function(args) pcall(vim.treesitter.start, args.buf) end,
})
vim.pack.add({
    { src = "https://github.com/anoopkcn/csub.nvim",      name = "csub" },
    { src = "https://github.com/anoopkcn/filemarks.nvim", name = "filemarks" },
    { src = "https://github.com/nvim-mini/mini.diff",     name = "mini.diff" },
    { src = "https://github.com/NicolasGB/jj.nvim",       name = "jj.nvim" },
})

require("mini.diff").setup({})

require("jj").setup({})
map("n", "<leader>J", "<CMD>J<CR>", { silent = true, desc = "Open jj log" })

vim.pack.add({ 'https://github.com/dmtrKovalenko/fff.nvim' })

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
    prompt = '> ',
    lazy_sync = true,
    debug = { enabled = true, show_scores = true },
    layout = {
        anchor = 'top',
        prompt_position = 'top',
        flex = { size = 130, wrap = 'bottom' },
    }
}

vim.keymap.set('n', 'ff', function() require('fff').find_files() end, { desc = 'FFFind files' })
vim.keymap.set('n', 'fg', function() require('fff').live_grep() end, { desc = 'Live grep' })
vim.keymap.set('n', 'fw', function() require('fff').live_grep({ query = vim.fn.expand("<cword>") }) end,
    { desc = 'Live grep word under cursor' })
vim.keymap.set('n', 'fW', function() require('fff').live_grep({ query = vim.fn.expand("<cWORD>") }) end,
    { desc = 'Live grep WORD under cursor' })
vim.keymap.set('n', 'fb', function() require('qfbuffers').open() end, { desc = 'Buffers in quickfix' })

require("csub").setup({
    default_mode = nil,
    handlers = {
        { match = "vimgrep",   mode = "replace" },
        { match = "qfbuffers", mode = "buffers" },
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
