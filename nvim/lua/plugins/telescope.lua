return {
	'nvim-telescope/telescope.nvim',
	tag = '0.1.8',
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			'nvim-telescope/telescope-fzf-native.nvim',
			build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
		}
	},

	config = function()
		require('telescope').setup({
			defaults = {
				border = true,
				highlights = {
					border = "TelescopeBorder",
				},
			},
			pickers = {
				git_files = { theme = "ivy", preview_title = false, results_title = false },
				git_branches = { theme = "ivy", preview_title = false, results_title = false },
				git_status = { theme = "ivy", preview_title = false, results_title = false },
				find_files = { theme = "ivy", preview_title = false, results_title = false },
				live_grep = { theme = "ivy", preview_title = false, results_title = false },
				help_tags = { theme = "ivy", preview_title = false, results_title = false },
				buffers = { theme = "ivy", preview_title = false, results_title = false },
				grep_string = { theme = "ivy", preview_title = false, results_title = false },
				lsp_workspace_symbols = { theme = "ivy", preview_title = false, results_title = false },
				lsp_document_symbols = { theme = "ivy", preview_title = false, results_title = false },
				lsp_references = { theme = "ivy", preview_title = false, results_title = false },
				lsp_definitions = { theme = "ivy", preview_title = false, results_title = false },
				lsp_implementations = { theme = "ivy", preview_title = false, results_title = false },
			},
			extensions = { fzf = {} }
		})

		vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#A8AEBA" })
		vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#3C3F4B" })
		vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#3C3F4B" })
		vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#3C3F4B" })

		require('telescope').load_extension('fzf')
		local builtin = require('telescope.builtin')
		-- git(g) something(x) g<x>
		vim.keymap.set('n', '<leader>gf', builtin.git_files)
		vim.keymap.set('n', '<leader>gc', builtin.git_bcommits)
		vim.keymap.set('n', '<leader>gC', builtin.git_commits)
		vim.keymap.set('n', '<leader>gb', builtin.git_branches)
		vim.keymap.set('n', '<leader>gs', builtin.git_status)
		-- finf(f) something(x) f<x>
		vim.keymap.set('n', '<leader>ff', builtin.find_files)
		vim.keymap.set('n', '<leader>fg', builtin.live_grep)
		vim.keymap.set('n', '<leader>fb', builtin.buffers)
		vim.keymap.set('n', '<leader>fh', builtin.help_tags)
		vim.keymap.set('n', '<leader>fs', builtin.lsp_workspace_symbols)
		vim.keymap.set('n', '<leader>fS', builtin.lsp_document_symbols)
		vim.keymap.set('n', '<leader>fr', builtin.lsp_references)
		vim.keymap.set('n', '<leader>fd', builtin.lsp_definitions)
		vim.keymap.set('n', '<leader>fi', builtin.lsp_implementations)

		vim.keymap.set('n', '<leader>fw', function()
			local word = vim.fn.expand("<cword>")
			builtin.grep_string({ search = word })
		end)

		vim.keymap.set('n', '<leader>fW', function()
			local word = vim.fn.expand("<cWORD>")
			builtin.grep_string({ search = word })
		end)

		vim.keymap.set('n', '<leader>/', function()
			local search_term = vim.fn.input("Grep > ")
			if search_term ~= "" then
				builtin.grep_string({ search = search_term })
			end
		end)
	end
}
