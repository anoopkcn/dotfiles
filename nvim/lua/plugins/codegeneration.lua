-- Configuration for the CodeCompanion plugin
return {
	"olimorris/codecompanion.nvim",
	-- Required dependencies for the plugin
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("codecompanion").setup({
			-- Display settings for UI elements
			display = {
				-- Use Telescope for the action palette
				action_palette = { provider = "telescope" },
				-- Chat window configuration
				chat = {
					show_settings = false,
					intro_message = "",
					window = {
						position = "right", -- Position chat window on the right
						width = 0.40,      -- Set window width to 40% of screen
					},
				},
			},

			-- Configuration for different interaction strategies
			strategies = {
				-- Chat strategy configuration
				chat = {
					adapter = "anthropic", -- Use Anthropic (Claude) as the AI provider
					-- Define custom slash commands for the chat
					slash_commands = {
						["file"] = {
							callback = "strategies.chat.slash_commands.file",
							description = "Select a file using Telescope",
							opts = {
								provider = "telescope",
								contains_code = true,
							},
						},
						["buffer"] = {
							callback = "strategies.chat.slash_commands.buffer",
							description = "Select a file using Telescope",
							opts = {
								provider = "telescope",
								contains_code = true,
							},
						},
					},
				},

				-- Inline strategy configuration
				inline = {
					adapter = "anthropic", -- Use Anthropic (Claude) for inline operations
				},
			},
		})

		-- Keybinding configurations
		-- <C-a> to open actions in normal and visual mode
		vim.api.nvim_set_keymap("n", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("v", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
		-- <LocalLeader>a to toggle chat in normal and visual mode
		vim.api.nvim_set_keymap("n", "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("v", "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
		-- 'ga' in visual mode to add selected text to chat
		vim.api.nvim_set_keymap("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

		-- Expand 'cc' into 'CodeCompanion' in the command line
		vim.cmd([[cab cc CodeCompanion]])
	end
}

