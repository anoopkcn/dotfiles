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
vim.opt.laststatus = 3
vim.opt.number = true
vim.opt.relativenumber = true
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
vim.opt.cursorline = true
vim.o.statusline = " "
vim.o.winbar = " %t%m%=%l:%c/%L  %p%%"

vim.cmd.colorscheme("slate")

for _, group in ipairs({ "StatusLine", "StatusLineNC" }) do
    local hl = vim.api.nvim_get_hl(0, { name = group })
    hl.bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
    vim.api.nvim_set_hl(0, group, hl)
end

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
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Replace word cursor is on globally" })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})

-- PLUGINS
require("brackets")
require("surround")

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
        keymaps = { close = { "q", "<Esc>", "gq" }} 
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
    }
}

vim.keymap.set('n', '<leader>ff', function() require('fff').find_files() end, { desc = 'FFFind files' })
vim.keymap.set('n', '<leader>fg', function() require('fff').live_grep() end, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fw', function() require('fff').live_grep({ query = vim.fn.expand("<cword>") }) end,
    { desc = 'Live grep word under cursor' })
vim.keymap.set('n', '<leader>fW', function() require('fff').live_grep({ query = vim.fn.expand("<cWORD>") }) end,
    { desc = 'Live grep WORD under cursor' })

-- LOCAL PLUGINS
vim.opt.runtimepath:prepend('/Users/akc/develop/stitch.nvim')
require("stitch").setup({
    context = 0
})

map("n", "]c", function() require('stitch').next() end)
map("n", "[c", function() require('stitch').prev() end)
map("n", "<leader>c", function() require('stitch').from_qflist() end)
map("n", "<leader>/", function() require('stitch').grep() end)
map("n", "<leader>d", function() require('stitch').diff() end)

vim.opt.runtimepath:prepend('/Users/akc/develop/oil.nvim')
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
})

map("n", "<leader>fe", "<CMD>Oil<CR>", { silent = true, desc = "Open file explorer" })

vim.opt.runtimepath:prepend('/Users/akc/develop/filemarks.nvim')
require("filemarks").setup({ dir_open_cmd = "Oil %s" }) --  show_help = false
map("n", "<leader>l", "<CMD>bot FilemarksToggle<CR>", { silent = true, desc = "List filemarks" })
