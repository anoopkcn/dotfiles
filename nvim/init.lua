-- Neovim configuration
-- Author: @anoopkcn
-- License: MIT
-- Refer to README.md for more information

-- OPTIONS
vim.g.netrw_banner = 0
-- vim.g.netrw_browse_split = 0
-- vim.g.netrw_banner = 0
-- vim.g.netrw_winsize = 25

-- set to true if you have a nerd-font
-- vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true
vim.opt.cursorline = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
--combine system clipboard with vim clipboard
vim.opt.clipboard = "unnamedplus"
-- enable mouse support
vim.opt.mouse = "a"
-- extra space in the gutter for signs
vim.opt.signcolumn = "yes"
-- keep # lines above and below the cursor
vim.opt.scrolloff = 5
-- keep # columns to the left and right of the cursor
vim.opt.sidescrolloff = 5

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

vim.opt_local.conceallevel = 2
vim.opt.conceallevel = 1

-- vim.opt.path:append("**")
vim.opt.updatetime = 250
-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"
-- vim.opt.laststatus = 3

if vim.fn.has("Mac") == 1 then
	vim.opt.linebreak = true
	vim.opt.showbreak = "⤷ "
end

-- configure status line
-- vim.opt.statusline = [[%f %m %{fugitive#statusline()} %= %y %l:%c %p%%]]

-- KEYBINDINGS
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- since Space is the leader key do nothing
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>")
vim.keymap.set({ "n", "v" }, "<C-Space>", "<Nop>")

-- search highlight on escape
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>")

-- ctrl+c as escape
vim.keymap.set("i", "<C-c>", "<Esc>")

-- vrertical scroll half a page up and center it
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- vrertical scroll half a page down and center it
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- vertically move all the way to the end of the file and center it
vim.keymap.set("n", "G", "Gzz")

-- vertically move full page doen and center it
vim.keymap.set("n", "<C-f>", "<C-f>zz")

-- vertically move full page up and center it
vim.keymap.set("n", "<C-b>", "<C-b>zz")

-- go to the next search result and center it
vim.keymap.set("n", "n", "nzz")

-- go to the previous search result and center it
vim.keymap.set("n", "N", "Nzz")

-- navigate to splits using i,j,h,l [Deprecated since it it handled plugin]
-- vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
-- vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
-- vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
-- vim.keymap.set("n", "<C-l>", "<C-w><C-l>")

-- remove buffer from currect active buffers
vim.keymap.set("n", "<Leader>bd", vim.cmd.bd)
-- jump to previous and next buffer
-- vim.keymap.set("n", "<leader>bn", vim.cmd.bn)
-- vim.keymap.set("n", "<leader>bp", vim.cmd.bp)

-- keep cursor at the bottom of visual once yanked
vim.keymap.set("v", "y", "ygv")

-- escape terminal mode in term
vim.keymap.set("t",'<Esc>', [[<C-\><C-n>]])

-- netrw keybindings
vim.keymap.set("n", "<leader>p", vim.cmd.Hex)

-- Splits
-- Window splits
vim.keymap.set('n', '<leader>h', ':leftabove vsplit<CR>', { noremap = true, silent = true })  -- Split left
vim.keymap.set('n', '<leader>l', ':rightbelow vsplit<CR>', { noremap = true, silent = true }) -- Split right
vim.keymap.set('n', '<leader>k', ':leftabove split<CR>', { noremap = true, silent = true })   -- Split up
vim.keymap.set('n', '<leader>j', ':rightbelow split<CR>', { noremap = true, silent = true })  -- Split down

-- CUSTOM FUNCTIONS
Print = function(v)
	print(vim.inspect(v))
	return v
end

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Temporary highlight indicator when yanking (copying) text",
	group = vim.api.nvim_create_augroup("custom-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	desc = "Vim terminal configurations",
	group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
	end,
})

-- PLUGINS
require("custom.splitjump").setup()
require("config.lazy")

