-- https://github.com/nvim-lualine/lualine.nvim

-- get count of buffers(total number of opend buffers)
local get_nbuff = function()
	local nbuff = #vim.fn.getbufinfo({ buflisted = 1 })
	return nbuff
end

return {
	"nvim-lualine/lualine.nvim",
	enabled = true,
	dependencies = { "nvim-tree/nvim-web-devicons" },

	config = function()
		require("lualine").setup({
			-- options = { fmt = string.lower },
			sections = {
				lualine_a = { {
					"mode",
					fmt = function(str)
						return str:sub(1, 1)
					end,
				} },
				lualine_b = {
					{
						"branch",
						"diff",
					},
				},
				lualine_c = {},
				lualine_x = {
					{
						"diagnostics",
						"encoding",
						"filetype",
					},
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			tabline = {
				lualine_a = {
					{
						"buffers",
						icons_enabled = false,
						mode = 2,
						symbols = {
							modified = " +",
							alternate_file = "",
							directory = "",
						},
					},
				},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = { "fileformat" },
				lualine_z = { get_nbuff },
			},
		})
	end,
}
