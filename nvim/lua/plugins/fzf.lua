return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		fzf.setup({
			defaults = { file_icons = false },
			winopts = {
				backdrop = 100,
				preview  = {
					scrollbar = false,
					-- hidden = true,
				},
			},
			keymap = {
				builtin = {
					["<c-u>"] = "preview-page-up",
					["<c-d>"] = "preview-page-down",
					["<c-p>"] = "toggle-preview",
				},
				fzf = {
					["ctrl-q"] = "select-all+accept",
				},
			},
		})

		vim.keymap.set("n", "<leader>ff", fzf.files)
		vim.keymap.set("n", "<leader>fb", fzf.buffers)
		vim.keymap.set("n", "<leader>fg", fzf.live_grep)
		vim.keymap.set("n", "<leader>/", fzf.grep)
		vim.keymap.set("n", "<leader>fw", fzf.grep_cword)
		vim.keymap.set("n", "<leader>fW", fzf.grep_cWORD)
		vim.keymap.set("n", "<leader>fh", fzf.helptags)
		-- vim.keymap.set("n", "<leader>fs", fzf.lsp_live_workspace_symbols)
		-- vim.keymap.set("n", "<leader>fS", fzf.lsp_document_symbols)
		vim.keymap.set("n", "<leader>fr", fzf.lsp_references)
		vim.keymap.set("n", "<leader>fd", fzf.lsp_definitions)
		vim.keymap.set("n", "<leader>fi", fzf.lsp_implementations)
		vim.keymap.set("n", "<leader>r", fzf.resume)
		vim.keymap.set("n", "<leader>z", fzf.spell_suggest)
		vim.keymap.set("n", "<leader>s", fzf.builtin)

		vim.keymap.set("n", "<leader>gt", fzf.git_worktrees)
		vim.keymap.set("n", "<leader>gb", fzf.git_branches)
		-- vim.keymap.set("n", "<leader>gl", fzf.git_bcommits)
		-- vim.keymap.set("n", "<leader>gl", fzf.git_commits)
		-- vim.keymap.set("n", "<leader>gs", fzf.git_status)

		-- Setup makepicker
		require("custom.makepicker").setup()
	end,
}
