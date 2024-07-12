-- [nvm-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)(code highlighting)
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"vimdoc",
			"javascript",
			"typescript",
			"c",
			"lua",
			"rust",
			"jsdoc",
			"bash",
			"python",
		},
		sync_install = false,
		auto_install = true,
		indent = { enable = true },

		highlight = {
			enable = true,
			additional_vim_regex_highlighting = { "markdown" },
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
