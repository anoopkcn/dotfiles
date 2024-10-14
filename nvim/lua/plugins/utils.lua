return {
	{
		-- [vim-unimpaired](https://github.com/tpope/vim-unimpaired)(sensible `[` and `]` commands)
		"tpope/vim-unimpaired",
		enabled = true,
	},
	{
		--[vim-sleuth](https://github.com/tpope/vim-sleuth)(automatic adjustment of tabs)
		"tpope/vim-sleuth",
		enabled = true,
	},
	{
		-- [vim-repeat](https://github.com/tpope/vim-repeat)(repeat motions with dot)
		"tpope/vim-repeat",
		enabled = true,
	},
	{
		-- [vim-surround](https://github.com/tpope/vim-surround)(surround text with pairs)
		"tpope/vim-surround",
		enabled = true,
	},
	{
		--[undo tree](https://github.com/mbbill/undotree)(poor-man's git)
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
		end,
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
