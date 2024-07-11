-- netrw Explore options (This is replaced by Oil.nvim now)
-- vim.g.netrw_browse_split = 0
-- vim.g.netrw_banner = 0
-- vim.g.netrw_winsize = 25

vim.g.have_nerd_font = true -- set to true if you have a nerd font installed
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true
vim.opt.cursorline = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.clipboard = "unnamedplus" --combine system clipboard with vim clipboard
-- vim.opt.termguicolors = true -- enable 24-bit RGB colors
vim.opt.mouse = "a" -- enable mouse support
vim.opt.signcolumn = "yes" -- extra space in the gutter for signs
vim.opt.scrolloff = 5 -- keep # lines above and below the cursor
vim.opt.sidescrolloff = 5 -- keep # columns to the left and right of the cursor

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

-- vim.opt.path:append("**")
vim.opt.updatetime = 250
vim.opt.inccommand = "split" -- Preview substitutions live, as you type!
-- set laststatus=3
vim.opt.laststatus = 3

if vim.fn.has("Mac") == 1 then
	vim.opt.linebreak = true
	vim.opt.showbreak = "⤷ "
end

-- configure status line
vim.opt.statusline = [[%f %m %= %{get(b:,'gitsigns_status','')} %{fugitive#statusline()} %y %l:%c %p%%]]
