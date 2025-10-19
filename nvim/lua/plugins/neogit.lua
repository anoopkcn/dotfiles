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

		vim.keymap.set("n", "<leader>gg", "<CMD>Neogit kind=replace<CR>", { noremap = true, silent = true })
		-- vim.keymap.set("n", "<leader>g", "<CMD>Neogit kind=split_below_all<CR>", { noremap = true, silent = true })
		-- vim.keymap.set("n", "<leader>l", function() neogit.action("log", "log_current")() end)
		vim.keymap.set("n", "<leader>gl", function() neogit.open({"log"}) end)

		-- Stage current file
		vim.keymap.set("n", "<leader>gs", function() require('gitsigns').stage_buffer() end, { noremap = true, silent = true, desc = "Stage current file" })

		-- Unstage current file
		vim.keymap.set("n", "<leader>gu", function() require('gitsigns').reset_buffer_index() end, { noremap = true, silent = true, desc = "Unstage current file" })

		-- Discard changes in current file
		vim.keymap.set("n", "<leader>gx", "<CMD>!git checkout -- %<CR>", { noremap = true, silent = true, desc = "Discard changes in current file" })

		-- Commit
		vim.keymap.set("n", "<leader>gc", function() neogit.action("commit", "commit")() end, { noremap = true, silent = true, desc = "Commit" })
	end
}
