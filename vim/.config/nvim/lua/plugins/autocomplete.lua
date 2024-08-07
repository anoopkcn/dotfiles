-- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (auto-completion)
return {
	"hrsh7th/nvim-cmp",

	dependencies = {
		"hrsh7th/cmp-path", -- https://github.com/hrsh7th/cmp-path
		"hrsh7th/cmp-buffer", -- https://github.com/hrsh7th/cmp-buffer
		"onsails/lspkind.nvim", -- https://github.com/onsails/lspkind.nvim
	},

	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")

		-- reset some behaviors
		vim.opt.completeopt = { "menu", "menuone", "noselect" }

		cmp.setup({
			enabled = true,
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
				["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
				["<C-y>"] = cmp.mapping(
					cmp.mapping.confirm({ behavior = cmp.SelectBehavior.Select, select = true }),
					{ "i", "c" }
				),
			}),

			-- load sources for autocomplete that is from buffers and lsp servers
			sources = {
				{ name = "copilot", priority = 1, group_index = 2 },
				{ name = "buffer", priority = 1, group_index = 2, keyword_length = 3 },
				{ name = "nvim_lsp", priority = 2, group_index = 2 },
				{ name = "path", priority = 2, group_index = 2 },
			},

			window = {
				documentation = cmp.config.window.bordered(),
				completion = cmp.config.window.bordered(),
			},

			---@diagnostic disable-next-line: missing-fields
			formatting = {
				format = lspkind.cmp_format({
					mode = "symbol",
					maxwidth = 50,
					show_labelDetails = true,
					menu = {
						nvim_lsp = "[LSP]",
						buffer = "[BUFF]",
						path = "[PATH]",
						copilot = "[LLM]",
					},
				}),
			},
		})
	end,
}
