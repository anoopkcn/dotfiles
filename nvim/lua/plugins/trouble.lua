-- [trouble.nvim](https://github.com/folke/trouble.nvim)(better quick fix list)

return {
	"folke/trouble.nvim",
	opts = {
		-- icons = false,
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
			"<leader>tr",
			"<cmd>Trouble lsp_references toggle focus=false<cr>",
			desc = "LSP References (Trouble)",
		},
		{
			"<leader>ts",
			"<cmd>Trouble symbols toggle pinned=true results.win.relative=win results.win.position=right<cr>",
			desc = "Symbols (Trouble)",
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
