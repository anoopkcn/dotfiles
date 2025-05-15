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

		-- local has_words_before = function()
		--   unpack = unpack or table.unpack
		--   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		--   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
		-- end

		cmp.setup({
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(), -- Or <C-p>
				["<Up>"] = cmp.mapping.select_prev_item(),
				["<C-n>"] = cmp.mapping.select_next_item(), -- Or <C-n>
				["<Down>"] = cmp.mapping.select_next_item(),
				["<C-e>"] = cmp.mapping.abort(),
				["<CR>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
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
			-- DO NOT use this, doesnt work properly with copilot and lsp(text shifts around)
			-- experimental = {
			-- 	ghost_text = true, -- Show completion preview inline (requires Neovim 0.10+)
			-- },
		})
		vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
	end,
}
