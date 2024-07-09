return {
	{
		-- [vim-unimpaired](https://github.com/tpope/vim-unimpaired)(sensible `[` and `]` commands)
		"tpope/vim-unimpaired",
		enabled = true,
	},
	{
		-- [vim-surround](https://github.com/tpope/vim-surround)(surround text with pairs)
		"tpope/vim-sleuth",
		enabled = true,
	},
	{
		-- [vim-repeat](https://github.com/tpope/vim-repeat)(repeat motions with dot)
		"tpope/vim-repeat",
		enabled = true,
	},
	{
		-- [vim-fugitive](https://github.com/tpope/vim-fugitive)(best git plugin)
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>G", vim.cmd.Git)
			vim.keymap.set("n", "gh", "<cmd>diffget //2<CR>")
			vim.keymap.set("n", "gl", "<cmd>diffget //3<CR>")
		end,
	},
	{
		-- [surround](https://github.com/tpope/vim-surround)(surround motion for pairs)
		"tpope/vim-surround",
		enabled = true,
	},
	{
		-- [comment.nvim](https://github.com/numToStr/Comment.nvim) (add line/block comments easily)
		"numToStr/Comment.nvim",
		enabled = true,
		opts = {},
	},
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	},
}
