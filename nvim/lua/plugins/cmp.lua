local M = {}

function M.setup()
	local ok_cmp, cmp = pcall(require, "cmp")
	if not ok_cmp then
		return
	end

	-- local ok_lspkind, lspkind = pcall(require, "lspkind")
	-- if not ok_lspkind then
	-- 	return
	-- end

	---@diagnostic disable-next-line: redundant-parameter
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
			-- { name = "copilot",  group_index = 2 },
			{ name = "nvim_lsp", group_index = 2 },
			{ name = "buffer",   group_index = 2 },
			{ name = "path",     group_index = 2 },
		}),

		-- formatting = {
		-- 	format = lspkind.cmp_format({
		-- 		mode = "symbol",
		-- 		maxwidth = 20,
		-- 		ellipsis_char = "...",
		-- 		symbol_map = { Copilot = "" },
		-- 	})
		-- },
	})
	vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#74ADEA" })
end

return M
