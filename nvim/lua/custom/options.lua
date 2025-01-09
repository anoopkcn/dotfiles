-- netrw Explore options
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
