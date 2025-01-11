-- Neovim configuration
-- Author: @anoopkcn
-- License: MIT
-- Refer to README.md for more information

-- OPTIONS
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.netrw_banner = 0
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true
vim.opt.cursorline = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
-- vim.opt.inccommand = "split"
vim.opt.linebreak = true
vim.diagnostic.config({virtual_text = false})

-- KEYBINDINGS
-- since Space is the leader key do nothing
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>")
vim.keymap.set({ "n", "v" }, "<C-Space>", "<Nop>")
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>")
-- Center some stuff zz
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "G", "Gzz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set("n", "<C-b>", "<C-b>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
-- helper windows
vim.keymap.set("n", "<leader>F", "<cmd>Ex<CR>")
vim.keymap.set("n", "<Leader>bd", vim.cmd.bd)
vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")
vim.keymap.set("n", "<leader>Q", "<cmd>cclose<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setqflist)
-- Window splits
vim.keymap.set('n', '<leader>\\', ':rightbelow vsplit<CR>', { noremap = true, silent = true})
vim.keymap.set('n', '<leader>-', ':rightbelow split<CR>', { noremap = true, silent = true })

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

-- Command to toggle inline diagnostics
vim.api.nvim_create_user_command(
  'DiagnosticsToggleVirtualText',
  function()
    local current_value = vim.diagnostic.config().virtual_text
    if current_value then
      vim.diagnostic.config({virtual_text = false})
    else
      vim.diagnostic.config({virtual_text = true})
    end
  end,
  {}
)

vim.api.nvim_set_keymap('n', '<Leader>ii', '<cmd>DiagnosticsToggleVirtualText<CR>', { noremap = true, silent = true })

-- PLUGINS
require("custom.split_jump").setup()
require("config.lazy")

