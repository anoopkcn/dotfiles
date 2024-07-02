-- [trouble.nvim](https://github.com/folke/trouble.nvim)(better quick fix list)

return {
	"folke/trouble.nvim",

	opts = {
		auto_close = true,
	},

	cmd = "Trouble",

	keys = {
		{
			"<leader>tt",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Diagnostics (Trouble)",
		},
		{
			"]t",
			"<cmd>Trouble diagnostics next jump=true<cr>",
			desc = "Go to next diagnostic",
		},
		{
			"[t",
			"<cmd>Trouble diagnostics prev jump=true<cr>",
			desc = "Go to previous diagnostic",
		},
	},
}
