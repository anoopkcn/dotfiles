-- [vim-fugitive](https://github.com/tpope/vim-fugitive)(best git plugin)
return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>G", vim.cmd.Git)
		vim.keymap.set("n", "gh", "<cmd>diffget //2<CR>")
		vim.keymap.set("n", "gl", "<cmd>diffget //3<CR>")
	end,
}
