-- [copilot](https://github.com/zbirenbaum/copilot.lua)(ai auto-completion)
return {
	{
		"zbirenbaum/copilot-cmp",

		dependencies = {
			"zbirenbaum/copilot.lua",
		},

		config = function()
			require("copilot").setup({
				-- the following are set so that they can be habdled by copilot-cmp plugin
				suggestion = { enabled = false },
				panel = { enabled = false },
			})

			require("copilot_cmp").setup()
		end,
	},
}
