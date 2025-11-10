-- Author:  @anoopkcn
-- License: MIT

require("custom.options")
require("custom.functions")
require("custom.statusline")
require("custom.keymaps")

vim.cmd("colorscheme onehalfdark")
vim.cmd([[
  highlight SpellBad   gui=undercurl guisp=#be5046
  highlight SpellCap   gui=undercurl guisp=#61afef
  highlight SpellRare  gui=undercurl guisp=#c678dd
  highlight SpellLocal gui=undercurl guisp=#98c379
]])

require("custom.pack").setup()
