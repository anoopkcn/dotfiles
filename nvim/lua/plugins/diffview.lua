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

		-- Keybinding to open DiffView
		vim.keymap.set(
			"n",
			"<leader>go",
			"<CMD>DiffviewOpen<CR>",
			{ noremap = true, silent = true, desc = "Open Diffview" }
		)

		-- Keybinding to close DiffView
		vim.keymap.set(
			"n",
			"<leader>gq",
			"<CMD>DiffviewClose<CR>",
			{ noremap = true, silent = true, desc = "Close Diffview" }
		)
	end
}
