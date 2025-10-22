return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-buffer",
		"onsails/lspkind.nvim",
		"zbirenbaum/copilot-cmp",
	},
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")
		require("copilot_cmp").setup()

		cmp.setup({
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			performance = {
          max_view_entries = 10,
      },
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<Up>"] = cmp.mapping.select_prev_item(),
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<Down>"] = cmp.mapping.select_next_item(),
				["<C-e>"] = cmp.mapping.abort(),
			}),

			sources = cmp.config.sources({
				{ name = "copilot",  group_index = 2 },
				{ name = "nvim_lsp", group_index = 2 },
				{ name = "buffer",   group_index = 2 },
				{ name = "path",     group_index = 2 },
			}),

			formatting = {
				format = lspkind.cmp_format({
					mode = "symbol",
					maxwidth = 20,
					ellipsis_char = "...",
					symbol_map = { Copilot = "" },
				})
			},
		})
		vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#74ADEA" })
	end,
}
