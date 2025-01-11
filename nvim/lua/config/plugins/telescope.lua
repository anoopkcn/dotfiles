return {
	'nvim-telescope/telescope.nvim',
	tag = '0.1.8',
	dependencies = {
		'nvim-lua/plenary.nvim',
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' }
	},

	config = function()
		require('telescope').setup({
			pickers = {
				git_files = {theme = "ivy", preview_title = false, results_title=false},
				git_branches = {theme = "ivy", preview_title = false, results_title=false},
				git_status = {theme = "ivy", preview_title = false, results_title=false},
				find_files = {theme = "ivy", preview_title = false, results_title=false},
				live_grep = {theme = "ivy", preview_title = false, results_title=false},
				buffers = {theme = "ivy", preview_title = false, results_title=false},
				grep_string= {theme = "ivy", preview_title = false, results_title=false},
			},
			extensions = { fzf = {} }
		})
		require('telescope').load_extension('fzf')
		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>gf', builtin.git_files)
		vim.keymap.set('n', '<leader>gb', builtin.git_branches)
		vim.keymap.set('n', '<leader>gs', builtin.git_status)
		vim.keymap.set('n', '<leader>ff', builtin.find_files)
		vim.keymap.set('n', '<leader>fg', builtin.live_grep)
		vim.keymap.set('n', '<leader>fb', builtin.buffers)
		vim.keymap.set('n', '<leader>fh', builtin.help_tags)
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
