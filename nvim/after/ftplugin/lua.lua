vim.opt_local.makeprg = "luacheck --formatter plain --codes %"
vim.opt_local.errorformat = "%f:%l:%c: (%t%n) %m,%f:%l:%c: %m"

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  buffer = 0,
  callback = function() vim.cmd("cwindow") end,
})

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "")
  .. " | setl makeprg< errorformat<"
