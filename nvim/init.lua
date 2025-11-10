-- Author:  @anoopkcn
-- License: MIT

require("custom.options")
require("custom.functions")
require("custom.statusline")
require("custom.keymaps")

vim.cmd("colorscheme onehalfdark")

require("custom.pack").setup()
