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
		enabled = true,
		config = function()
			vim.keymap.set("n", "<leader>G", vim.cmd.Git)
		end,
	},
	{
		-- [mini.ai](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-ai.md)(better `a` and `i`)
		"echasnovski/mini.ai",
		version = "*",
		enabled = true,
		config = function()
			require("mini.ai").setup()
		end,
	},
	{
		-- [mini.surround](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-surround.md)(surround text with pairs)
		"echasnovski/mini.surround",
		version = "*",
		enabled = true,
		config = function()
			require("mini.surround").setup()
		end,
	},
	{
		-- [comment.nvim](https://github.com/numToStr/Comment.nvim) (add line/block comments easily)
		"numToStr/Comment.nvim",
		opts = {},
	},
}
