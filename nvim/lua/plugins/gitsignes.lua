return {
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup({
			on_attach = function(bufnr)
				local gitsigns = require('gitsigns')

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
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
				-- vim.keymap.set('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
				-- vim.keymap.set('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
				-- vim.keymap.set('n', '<leader>hn', function() gitsigns.nav_hunk("next") end)
				-- vim.keymap.set('n', '<leader>hp', function() gitsigns.nav_hunk("prev") end)
			end
		})
	end
}
