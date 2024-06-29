-- [nvm-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)(code highlighting)

return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdateSync",
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"diff",
			"html",
			"lua",
			"luadoc",
			"markdown",
			"vim",
			"vimdoc",
			"python",
			"javascript",
			"typescript",
		},

		auto_install = true,

		highlight = {
			enable = true,
			additional_vim_regex_highlighting = { "ruby" },
		},

		indent = { enable = true, disable = { "ruby" } },
	},

	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
