-- Neovim configuration
-- Author: @anoopkcn
-- License: MIT
-- Refer to README.md for more information

require("custom.options")
require("custom.functions")
vim.cmd("colorscheme defaultshade")

local lazypath = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "lazy.nvim")
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
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
		{ "tpope/vim-fugitive" },
		{ "tpope/vim-surround" },
		{ "tpope/vim-unimpaired" },
		{ "tpope/vim-repeat" },
		{ "ziglang/zig.vim" },
	},
}

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>")
vim.keymap.set({ "n", "v" }, "<C-Space>", "<Nop>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "G", "Gzz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set("n", "<C-b>", "<C-b>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
-- vim.keymap.set("n", "j", "v:count ? 'j' : 'gj'", { expr = true })
-- vim.keymap.set("n", "k", "v:count ? 'k' : 'gk'", { expr = true })
vim.keymap.set("n", "<leader>bd", vim.cmd.bd)
vim.keymap.set("n", "<leader>on", vim.cmd.only)
vim.keymap.set("n", "<leader>\\", ":rightbelow vsplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>-", ":rightbelow split<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-c>", "<Esc>")
-- lsp + quickfix
vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")
vim.keymap.set("n", "<leader>xX", vim.diagnostic.setqflist)
vim.keymap.set("n", "<leader>xx", vim.diagnostic.setloclist)
vim.keymap.set("n", "]]", function() vim.diagnostic.jump({ count = 1 }) end)
vim.keymap.set("n", "[[", function() vim.diagnostic.jump({ count = -1 }) end)


vim.keymap.set("n", "<leader>q",
	ToggleQuickfixList,
	{ noremap = true, silent = true, desc = "Toggle quickfix list" }
)

vim.keymap.set("n", "<leader>G",
	"<cmd>Git<CR>",
	{ noremap = true, silent = true, desc = "git" }
)

vim.keymap.set("n", "<leader>fe",
	"<CMD>Oil<CR>",
	{ desc = "Open parent directory" }
)

vim.keymap.set("n", "<leader>e",
	"<cmd>DiagnosticsToggleVirtualText<CR>",
	{ noremap = true, silent = true }
)

vim.keymap.set("n", "<leader>t",
	function()
		local raw_timestamp = os.date("%FT%T")
		local timestamp_str = string.format("%s", raw_timestamp or "")
		vim.api.nvim_put({ timestamp_str }, "c", true, true)
	end,
	{ noremap = true, silent = true, }
)


vim.keymap.set("n", "<leader>dl",
	":edit DEVLOG.md<CR>",
	{ noremap = true, silent = true, desc = "Open DEVLOG.md" }
)


vim.keymap.set("n", "<leader>,",
	function()
		vim.lsp.buf.format({ async = true })
	end,
	{ noremap = true, silent = true, desc = "Format buffer" }
)

vim.keymap.set("n", "<leader>z",
	":!", { noremap = true }
)
