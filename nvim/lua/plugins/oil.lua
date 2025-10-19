return {
	"stevearc/oil.nvim",
	---@module 'oil'
	opts = {},
	lazy = false,
	config = function()
		require("oil").setup({
			default_file_explorer = true,
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			columns = {
				-- "icon",
				-- "permissions",
				-- "size",
				-- "mtime",
			},
			view_options = {
				show_hidden = true,
				natural_order = true,
				is_always_hidden = function(name, _)
					return name == ".git"
				end,
			},
			float = {
				border = "rounded",
				max_width = 0.7,
				max_height = 0.5,
			},
			confirmation = {
				border = "rounded",
			},
			keymaps = {
				["<C-c>"] = false,
				["q"] = "actions.close",
			},
		})

		vim.keymap.set("n", "<leader>fe", "<cmd>Oil --float<cr>", { noremap = true, silent = true })
	end
}
