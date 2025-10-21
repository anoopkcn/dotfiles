-- Author:  @anoopkcn
-- License: MIT

require("custom.options")
require("custom.functions")
require("custom.statusline")

vim.cmd("colorscheme onehalfdark")
vim.cmd([[
  highlight SpellBad   gui=undercurl guisp=#be5046
  highlight SpellCap   gui=undercurl guisp=#61afef
  highlight SpellRare  gui=undercurl guisp=#c678dd
  highlight SpellLocal gui=undercurl guisp=#98c379
]])

local lazypath = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "lazy.nvim")
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({ "git", "clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup {
	change_detection = { notify = false },
	spec = {
		{ import = "plugins" },
		{
			"mason-org/mason.nvim",
			opts = {},
		},
		{ "mason-org/mason-lspconfig.nvim" },
		{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "tpope/vim-surround" },
		{ "tpope/vim-unimpaired" },
		{ "tpope/vim-repeat" },
		{ "ziglang/zig.vim" },
		{
			'windwp/nvim-autopairs',
			event = "InsertEnter",
			config = true
		}
	},
}

require("custom.lsp")

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "󰗖",
			[vim.diagnostic.severity.INFO] = "󰄰",
			[vim.diagnostic.severity.HINT] = "󰄰",
		}
	}
})

local set = vim.keymap.set

set("i", "<C-c>", "<Esc>")
set({ "n", "v" }, "<Space>", "<Nop>")
set({ "n", "v" }, "<C-Space>", "<Nop>")
set("n", "<Esc>", "<cmd>nohlsearch<cr>")
set({ "n", "v" }, "<leader>p", [["+p]])
set({ "n", "v" }, "<leader>y", [["+y]])
set("n", "J", "mzJ`z")
set("n", "<C-d>", "<C-d>zz")
set("n", "<C-u>", "<C-u>zz")
set("n", "n", "nzzzv")
set("n", "N", "Nzzzv")

set("n", "<leader>bd",
	vim.cmd.bd,
	{ noremap = true, silent = true, desc = "Buffer delete" })

set("n", "<leader>on",
	vim.cmd.only,
	{ noremap = true, silent = true, desc = "Close other buffers" })

set("n", "<leader>\\",
	":rightbelow vsplit<CR>",
	{ noremap = true, silent = true, desc = "Vertical split" })

set("n", "<leader>-",
	":rightbelow split<CR>",
	{ noremap = true, silent = true, desc = "Horizontal split" })

set("n", "<M-j>",
	"<CMD>cnext<CR>",
	{ noremap = true, silent = true, desc = "Next item in quickfixlist" })

set("n", "<M-k>",
	"<CMD>cprev<CR>",
	{ noremap = true, silent = true, desc = "Prev item in quickfixlist" })

set("n", "<leader>qq",
	ToggleQuickfixList,
	{ noremap = true, silent = true, desc = "Toggle quickfixlist" })

set("n", "<leader>tt",
	vim.diagnostic.setqflist,
	{ noremap = true, silent = true, desc = "Open diagnostics in quickfixlist" })

set("n", "]t",
	function() vim.diagnostic.jump({ count = 1 }) end,
	{ noremap = true, silent = true, desc = "Next diagnostic" })

set("n", "[t",
	function() vim.diagnostic.jump({ count = -1 }) end,
	{ noremap = true, silent = true, desc = "Previous diagnostic" })

set("n", "<leader>x",
	function() vim.diagnostic.open_float({ border = 'single' }) end,
	{ noremap = true, silent = true, desc = "Open diagnostic float" })

set("n", "<leader>,",
	function() vim.lsp.buf.format({ async = true }) end,
	{ noremap = true, silent = true, desc = "Format buffer" })

set("n", "<leader>dl",
	":edit DEVLOG.md<cr>",
	{ noremap = true, silent = true, desc = "Open DEVLOG.md" })

set("n", "<leader>n",
	":edit ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/notes/scratchpad.md<cr>",
	{ noremap = true, silent = true, desc = "Open scratchpad.md" })

set("n", "<leader>'", function()
		local raw_timestamp = os.date("%FT%T")
		local timestamp_str = string.format("%s", raw_timestamp or "")
		vim.api.nvim_put({ timestamp_str }, "c", true, true)
	end,
	{ noremap = true, silent = true, desc = "Insert current timestamp" })

-- Toggle diagnostic virtual_lines: can also be replaced with virtual_text
-- vim.diagnostic.config({ virtual_lines = false })
-- vim.keymap.set("n", "<leader>e", function()
-- 	local new_config = not vim.diagnostic.config().virtual_lines
-- 	vim.diagnostic.config({ virtual_lines = new_config })
-- end, { desc = "Toggle diagnostic virtual_lines" })
