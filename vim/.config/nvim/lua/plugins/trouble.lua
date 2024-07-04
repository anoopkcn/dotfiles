-- [trouble.nvim](https://github.com/folke/trouble.nvim)(better quick fix list)

return {
	"folke/trouble.nvim",

	opts = {
		auto_close = true,
	},

	cmd = "Trouble",

	keys = {
		{
			"<leader>tt",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Diagnostics (Trouble)",
		},
		{
			"]t",
			"<cmd>Trouble diagnostics next jump=true<cr>",
			desc = "Go to next diagnostic",
		},
		{
			"[t",
			"<cmd>Trouble diagnostics prev jump=true<cr>",
			desc = "Go to previous diagnostic",
		},
	},
	--[[ config = function()
		-- Use this to add more results without clearing the trouble list
		local add_to_trouble = require("trouble.sources.telescope").add

		-- local open_with_trouble = require("trouble.sources.telescope").open
		require("telescope").setup({
			defaults = {
				mappings = {
					i = { ["<c-t>"] = add_to_trouble },
					n = { ["<c-t>"] = add_to_trouble },
				},
			},
		})
	end, ]]
}
