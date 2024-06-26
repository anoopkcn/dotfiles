-- https://github.com/nvim-lualine/lualine.nvim
return {
	"nvim-lualine/lualine.nvim",
	enabled = true,
	dependencies = { "nvim-tree/nvim-web-devicons" },

	config = function()
		require("lualine").setup({
			sections = {
				lualine_a = {},
				lualine_b = { "mode", "diagnostics" },
				lualine_c = { "branch", "diff", "searchcount", "filename" },
				lualine_x = { "encoding", "fileformat", "filetype", "progress" },
				lualine_y = { "location" },
				lualine_z = {},
			},
			tabline = {
				lualine_a = {
					{
						"buffers",
					},
				},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {
					{
						"datetime",
						style = "%H:%M",
					},
				},
				lualine_y = {},
				lualine_z = {},
			},
		})
	end,
}
