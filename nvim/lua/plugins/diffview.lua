return {
	"sindrets/diffview.nvim",
	config = function()
		require('diffview').setup({
			hooks = {
				view_opened = function()
					vim.cmd('DiffviewToggleFiles')
				end,
			},
		})

		vim.keymap.set(
			"n",
			"<leader>go",
			"<CMD>DiffviewOpen<CR>",
			{ noremap = true, silent = true, desc = "Open Diffview" }
		)

		vim.keymap.set(
			"n",
			"<leader>gc",
			"<CMD>DiffviewClose<CR>",
			{ noremap = true, silent = true, desc = "Close Diffview" }
		)

		vim.keymap.set(
			"n",
			"<leader>gh",
			"<CMD>DiffviewFileHistory<CR>",
			{ noremap = true, silent = true, desc = "Show Diffview File History" }
		)
	end
}
