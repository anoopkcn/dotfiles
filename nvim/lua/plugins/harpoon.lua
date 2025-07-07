return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },

	config = function()
		local harpoon = require('harpoon')
		harpoon:setup({})
		local toggle_opts = {
			title = "",
			title_pos = "center",
			border = "rounded",
		}
		vim.keymap.set("n", "<leader>s", function()
			harpoon.ui:toggle_quick_menu(harpoon:list(), toggle_opts)
		end)
		vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
		vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
		vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
		vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
		vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
		vim.keymap.set("n", "<leader>5", function() harpoon:list():select(5) end)

		-- Toggle previous & next buffers stored within Harpoon list
		vim.keymap.set("n", "]h", function() harpoon:list():next() end)
		vim.keymap.set("n", "[h", function() harpoon:list():prev() end)
	end

}
