-- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)(multi purpose navigation)
return {
	"nvim-telescope/telescope.nvim",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"folke/trouble.nvim",
	},

	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")

		telescope.setup({
			defaults = {
				file_ignore_patterns = { "node_modules", "env", "venv", ".env", ".git" },
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--trim",
				},
			},
		})

		-- file related
		vim.keymap.set("n", "<leader>ff", function()
			builtin.find_files({ hidden = true })
		end, {})
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
		vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
		vim.keymap.set("n", "<leader>fj", builtin.jumplist, {})
		vim.keymap.set("n", "<leader>fr", builtin.registers, {})
		vim.keymap.set("n", "<leader>fc", function()
			builtin.find_files({ cwd = vim.fn.expand("%:p:h") })
		end)
		-- vim.keymap.set("n", "<leader>fm", builtin.marks, {})
		vim.keymap.set("n", "<leader>fd", builtin.diagnostics, {})
		vim.keymap.set("n", "<space>/", builtin.current_buffer_fuzzy_find)
		vim.keymap.set("n", "<leader>gs", builtin.git_status, {})
		vim.keymap.set("n", "<leader>gc", builtin.git_commits, {})
		vim.keymap.set("n", "<leader>gb", builtin.git_branches, {})
		vim.keymap.set("n", "<leader>gl", builtin.git_bcommits, {})
		-- Shortcut for searching your Neovim configuration files
		vim.keymap.set("n", "<leader>ni", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[N]eovim [I]nit files" })

		-- Use this to add more results without clearing the trouble list
		local add_to_trouble = require("trouble.sources.telescope").add

		-- local open_with_trouble = require("trouble.sources.telescope").open
		telescope.setup({
			defaults = {
				mappings = {
					i = { ["<c-t>"] = add_to_trouble },
					n = { ["<c-t>"] = add_to_trouble },
				},
			},
		})
	end,
}
