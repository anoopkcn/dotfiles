return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		fzf.setup({
			winopts = {
				backdrop = 100,
				preview  = {
					scrollbar = false,
				},
			},
			keymap = {
				builtin = {
					["<c-u>"] = "preview-page-up",
					["<c-d>"] = "preview-page-down",
				},
			},
		})

		vim.keymap.set("n", "<leader>ff", fzf.files)
		vim.keymap.set("n", "<leader>fb", fzf.buffers)
		vim.keymap.set("n", "<leader>fg", fzf.live_grep)
		vim.keymap.set("n", "<leader>/", fzf.grep)
		vim.keymap.set("n", "<leader>fw", fzf.grep_cword)
		vim.keymap.set("n", "<leader>fW", fzf.grep_cWORD)
		-- vim.keymap.set("n", "<leader>fh", builtin.help_tags)
		-- vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols)
		-- vim.keymap.set("n", "<leader>fS", builtin.lsp_workspace_symbols)
		-- vim.keymap.set("n", "<leader>fr", builtin.lsp_references)
		-- vim.keymap.set("n", "<leader>fd", builtin.lsp_definitions)
		-- vim.keymap.set("n", "<leader>fi", builtin.lsp_implementations)

		-- Setup makepicker
		require("custom.makepicker").setup()
	end,
}
