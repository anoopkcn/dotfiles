return {
	"nvim-telescope/telescope.nvim",
	-- tag = '0.1.8',
	branch = "master", -- commit: b4da76b
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make"
		},
	},

	config = function()
		require("telescope").setup({
			extensions = {
				fzf = {
					fuzzy = true,              -- false will only do exact matching
					override_generic_sorter = true, -- override the generic sorter
					override_file_sorter = true, -- override the file sorter
					case_mode = "smart_case",  -- or "ignore_case" or "respect_case"
				},
			},
			defaults = require("telescope.themes").get_ivy({
				layout_config = {
					height = 0.4,
				},
			}),
		})

		require("telescope").load_extension("fzf")
		local builtin = require("telescope.builtin")
		-- git(g) something(x) g<x>
		vim.keymap.set("n", "<leader>gf", builtin.git_files)
		vim.keymap.set("n", "<leader>gc", builtin.git_bcommits)
		vim.keymap.set("n", "<leader>gC", builtin.git_commits)
		vim.keymap.set("n", "<leader>gb", builtin.git_branches)
		vim.keymap.set("n", "<leader>gs", builtin.git_status)
		-- find(f) something(x) f<x>
		vim.keymap.set("n", "<leader>ff", builtin.find_files)
		vim.keymap.set("n", "<leader>fg", builtin.live_grep)
		vim.keymap.set("n", "<leader>fb", builtin.buffers)
		vim.keymap.set("n", "<leader>fh", builtin.help_tags)
		vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols)
		vim.keymap.set("n", "<leader>fS", builtin.lsp_workspace_symbols)
		vim.keymap.set("n", "<leader>fr", builtin.lsp_references)
		vim.keymap.set("n", "<leader>fd", builtin.lsp_definitions)
		vim.keymap.set("n", "<leader>fi", builtin.lsp_implementations)
		-- vim.keymap.set('n', '<leader>fm', builtin.marks)
		vim.keymap.set("n", "<leader>fn", function()
			builtin.find_files({
				cwd = vim.fn.stdpath("config")
			})
		end)

		vim.keymap.set("n", "<leader>fw", function()
			local word = vim.fn.expand("<cword>")
			builtin.grep_string({ search = word })
		end)

		vim.keymap.set("n", "<leader>fW", function()
			local word = vim.fn.expand("<cWORD>")
			builtin.grep_string({ search = word })
		end)

		vim.keymap.set("n", "<leader>/", function()
			local search_term = vim.fn.input("grep: ")
			if search_term ~= "" then
				builtin.grep_string({ search = search_term })
			end
		end)

		require "custom.makepicker".setup()
	end
}
