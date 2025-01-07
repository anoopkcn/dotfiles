return {
	"ibhagwan/fzf-lua",
	opts = {},
	config = function()
		local fzflua = require('fzf-lua')
		fzflua.setup {
			defaults = {
				file_icons = false,
				-- previewer = false,
			},
			winopts = {
				split = "belowright new",
				border = "single",
				preview = {
					-- hidden = "hidden",
					border = "border",
					title = false,
					layout = "horizontal",
					horizontal = "right:50%",
				},
			},
		}
		vim.keymap.set("n", "<leader>ff", function() fzflua.files({ ["winopts.preview.hidden"] = "hidden" }) end)
		vim.keymap.set("n", "<leader>fb", function() fzflua.buffers({ ["winopts.preview.hidden"] = "hidden" }) end)
		vim.keymap.set("n", "<leader>fg", fzflua.live_grep)
		vim.keymap.set("n", "<leader>ft", fzflua.helptags)
		vim.keymap.set("n", "<leader>fm", fzflua.marks)
		vim.keymap.set("n", "<leader>fr", fzflua.registers)
		vim.keymap.set("n", "<leader>fj", fzflua.jumps)
		vim.keymap.set("n", "<leader>fh", fzflua.command_history)
		vim.keymap.set("n", "<leader>gs", fzflua.git_status)
		vim.keymap.set("n", "<leader>gc", fzflua.git_bcommits)
		vim.keymap.set("n", "<leader>gC", fzflua.git_commits)
		vim.keymap.set("n", "<leader>gb", fzflua.git_branches)
	end
}
