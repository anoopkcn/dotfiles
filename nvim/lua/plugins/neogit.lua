return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",       -- required
		"sindrets/diffview.nvim",      -- optional - Diff integration
	},
	config = function()
		local neogit = require('neogit')
		neogit.setup({
			disable_hint = true,
			graph_style = "kitty",
			signs = {
				-- { CLOSED, OPENED }
				hunk = { "", "" },
				item = { "", "" },
				section = { "", "" },
			},
		})

		vim.keymap.set("n", "<leader>g", "<CMD>Neogit kind=split_above_all<CR>", { noremap = true, silent = true })
	end
}
