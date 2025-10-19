return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
	},
	config = function()
		local neogit = require('neogit')
		neogit.setup({
			disable_hint = true,
			graph_style = "kitty",
			signs = {
				hunk = { "", "" },
				item = { "", "" },
				section = { "", "" },
			},
		})

		vim.keymap.set(
			"n",
			"<leader>gg",
			"<CMD>Neogit kind=replace<CR>",
			{ noremap = true, silent = true, desc = "Open Neogit interface" }
		)

		-- vim.keymap.set(
		-- 	"n",
		-- 	"<leader>gl",
		-- 	function() neogit.open({ "log" }) end,
		-- 	{ noremap = true, silent = true, desc = "Git log" }
		-- )

		-- vim.keymap.set(
		-- 	"n",
		-- 	"<leader>gc",
		-- 	function() neogit.action("commit", "commit")() end,
		-- 	{ noremap = true, silent = true, desc = "Commit" }
		-- )
	end
}
