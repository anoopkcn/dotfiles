-- Author:  @anoopkcn
-- License: MIT

require("custom.options")
require("custom.functions")
require("custom.statusline")
require("custom.pack").setup()

vim.cmd("colorscheme onehalfdark")
vim.cmd([[
  highlight SpellBad   gui=undercurl guisp=#be5046
  highlight SpellCap   gui=undercurl guisp=#61afef
  highlight SpellRare  gui=undercurl guisp=#c678dd
  highlight SpellLocal gui=undercurl guisp=#98c379
]])

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "",
		}
	}
})

vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>")
vim.keymap.set({ "n", "v" }, "<C-Space>", "<Nop>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>bd",
	vim.cmd.bd,
	{ noremap = true, silent = true, desc = "Buffer delete" })

vim.keymap.set("n", "<leader>on",
	vim.cmd.only,
	{ noremap = true, silent = true, desc = "Close other buffers" })

vim.keymap.set("n", "<leader>\\",
	":rightbelow vsplit<CR>",
	{ noremap = true, silent = true, desc = "Vertical split" })

vim.keymap.set("n", "<leader>-",
	":rightbelow split<CR>",
	{ noremap = true, silent = true, desc = "Horizontal split" })

vim.keymap.set("n", "<M-j>",
	"<CMD>cnext<CR>",
	{ noremap = true, silent = true, desc = "Next item in quickfixlist" })

vim.keymap.set("n", "<M-k>",
	"<CMD>cprev<CR>",
	{ noremap = true, silent = true, desc = "Prev item in quickfixlist" })

vim.keymap.set("n", "<leader>qq",
	ToggleQuickfixList,
	{ noremap = true, silent = true, desc = "Toggle quickfixlist" })

vim.keymap.set("n", "<leader>tt",
	vim.diagnostic.setqflist,
	{ noremap = true, silent = true, desc = "Open diagnostics in quickfixlist" })

vim.keymap.set("n", "]t",
	function() vim.diagnostic.jump({ count = 1 }) end,
	{ noremap = true, silent = true, desc = "Next diagnostic" })

vim.keymap.set("n", "[t",
	function() vim.diagnostic.jump({ count = -1 }) end,
	{ noremap = true, silent = true, desc = "Previous diagnostic" })

vim.keymap.set("n", "<leader>x",
	function() vim.diagnostic.open_float({ border = 'single' }) end,
	{ noremap = true, silent = true, desc = "Open diagnostic float" })

vim.keymap.set("n", "<leader>,",
	function() vim.lsp.buf.format({ async = true }) end,
	{ noremap = true, silent = true, desc = "Format buffer" })

vim.keymap.set("n", "<leader>u",
	":UndotreeToggle<cr>",
	{ noremap = true, silent = true, desc = "Toggle Undotree" })

vim.keymap.set("n", "<leader>dl",
	":edit DEVLOG.md<cr>",
	{ noremap = true, silent = true, desc = "Open DEVLOG.md" })

vim.keymap.set("n", "<leader>'", function()
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
