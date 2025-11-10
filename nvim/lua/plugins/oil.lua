local M = {}

function M.setup()
	local ok, oil = pcall(require, "oil")
	if not ok then
		return
	end

	oil.setup({
		default_file_explorer = true,
		delete_to_trash = true,
		skip_confirm_for_simple_edits = true,
		columns = {
			"icon",
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

	vim.keymap.set("n", "<leader>s", "<CMD>lua require('oil').toggle_float('.')<CR>", { noremap = true, silent = true })
end

return M
