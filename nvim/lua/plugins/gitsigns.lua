local M = {}

function M.setup()
	local ok, gitsigns = pcall(require, "gitsigns")
	if not ok then
		return
	end

	---@diagnostic disable-next-line: redundant-parameter
	gitsigns.setup({
		on_attach = function(bufnr)
			local function map(mode, lhs, rhs, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, lhs, rhs, opts)
			end

			-- Navigation
			map('n', ']c', function()
				if vim.wo.diff then
					vim.cmd.normal({ ']c', bang = true })
				else
					gitsigns.nav_hunk('next')
				end
			end)

			map('n', '[c', function()
				if vim.wo.diff then
					vim.cmd.normal({ '[c', bang = true })
				else
					gitsigns.nav_hunk('prev')
				end
			end)

			-- Actions
			vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { noremap = true, silent = true, desc = "Stage hunk" })
			vim.keymap.set('n', '<leader>hx', gitsigns.reset_hunk, { noremap = true, silent = true, desc = "Reset hunk" })
			vim.keymap.set('n', '<leader>hu', gitsigns.undo_stage_hunk, { noremap = true, silent = true, desc = "Undo stage hunk" })
			vim.keymap.set('n', '<leader>hv', gitsigns.preview_hunk_inline, { noremap = true, silent = true, desc = "Preview hunk inline" })
			vim.keymap.set('n', '<leader>hb', gitsigns.blame_line, { noremap = true, silent = true, desc = "Blame line" })
		end
	})
end

return M
