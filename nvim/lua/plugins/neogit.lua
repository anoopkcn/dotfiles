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
				-- CLOSED, OPENED
				hunk = { "", "" },
				item = { "", "" },
				section = { "", "" },
			},
		})

		vim.keymap.set("n", "<leader>g", "<CMD>Neogit kind=replace<CR>", { noremap = true, silent = true })
		-- vim.keymap.set("n", "<leader>g", "<CMD>Neogit kind=split_below_all<CR>", { noremap = true, silent = true })
		-- vim.keymap.set("n", "<leader>l", function() neogit.action("log", "log_current")() end)
		vim.keymap.set("n", "<leader>l", function() neogit.open({"log"}) end)
	end
}
