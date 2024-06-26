return {
	{
		"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
		enabled = true,
	},
	{
		"tpope/vim-fugitive",
		enabled = true,
		config = function()
			vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
		end,
	},
	{
		"kylechui/nvim-surround",
		enabled = true,
		version = "*",
		event = "VeryLazy",
		config = true,
	},
	{
		"tpope/vim-unimpaired",
		enabled = true,
	},
}
