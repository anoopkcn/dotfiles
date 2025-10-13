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
				map('n', '<leader>hs', gitsigns.stage_hunk)
				map('n', '<leader>hr', gitsigns.reset_hunk)
				map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
				map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
				map('n', '<leader>hu', gitsigns.undo_stage_hunk)
				map('n', '<leader>hv', gitsigns.preview_hunk_inline)
				map('n', '<leader>hb', gitsigns.blame_line)
				map('n', '<leader>hn', function() gitsigns.nav_hunk("next") end)
				map('n', '<leader>hp', function() gitsigns.nav_hunk("prev") end)
			end
		})
	end
}
