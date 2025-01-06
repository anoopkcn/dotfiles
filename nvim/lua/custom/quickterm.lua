local state = {
  terminal = {
    buf = -1,
    win = -1,
  }
}

local function create_split_terminal()
  vim.cmd("botright split")
  vim.api.nvim_win_set_height(0, 15)

  local win = vim.api.nvim_get_current_win()
  local buf = nil

  -- Reuse existing terminal buffer if it exists and is valid
  if vim.api.nvim_buf_is_valid(state.terminal.buf) then
    buf = state.terminal.buf
    vim.api.nvim_win_set_buf(win, buf)
  else
    vim.cmd.terminal()
    buf = vim.api.nvim_get_current_buf()
  end

  vim.cmd('startinsert') -- Always enter insert mode
  return { buf = buf, win = win }
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.terminal.win) then
    state.terminal = create_split_terminal()
  else
    vim.api.nvim_win_close(state.terminal.win, true)
  end
end

vim.api.nvim_create_user_command("Quickterm", toggle_terminal, {})
vim.keymap.set({"n","t"}, "<D-j>", toggle_terminal)
