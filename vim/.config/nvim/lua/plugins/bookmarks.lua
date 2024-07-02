return {
	"MattesGroeger/vim-bookmarks",
	dependencies = {
		"tom-anders/telescope-vim-bookmarks.nvim",
	},
	config = function()
		vim.g.bookmark_sign = "♥"
		vim.g.bookmark_highlight_lines = 1

		require("telescope").load_extension("vim_bookmarks")
		local vim_bookmarks = require("telescope").extensions.vim_bookmarks

		vim.keymap.set("n", "<leader>fm", vim_bookmarks.all, {})
		-- vim.keymap.set("n", "<leader>f,", vim_bookmarks.current_file, {})
	end,
}
