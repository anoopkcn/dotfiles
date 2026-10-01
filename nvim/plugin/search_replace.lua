local function get_visual_text()
  local mode = vim.fn.mode()

  local s = vim.fn.getpos("v")
  local e = vim.fn.getpos(".")

  local start_row = s[2]
  local end_row = e[2]

  if start_row > end_row then
    start_row, end_row = end_row, start_row
  end

  -- Linewise visual mode: V
  if mode == "V" then
    local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
    return table.concat(lines, "\n")
  end

  -- Characterwise visual mode: v
  local text = table.concat(vim.fn.getregion(s, e), "\n")
  return text
end

local function replace_visual_selection()
  local text = get_visual_text()

  if text == "" then
    return
  end

  if text:find("\n", 1, true) then
    vim.notify("This mapping only supports replacing one line at a time", vim.log.levels.WARN)
    return
  end

  local pattern = vim.fn.escape(text, [[\/]])
  local replacement = vim.fn.escape(text, [[\/&]])

  local cmd = "%s/\\V" .. pattern .. "/" .. replacement .. "/gI"

  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "x", false)

  vim.schedule(function()
    vim.api.nvim_feedkeys(":" .. cmd, "n", false)

    local left = vim.api.nvim_replace_termcodes("<Left><Left><Left>", true, false, true)
    vim.api.nvim_feedkeys(left, "n", false)
  end)
end

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word cursor is on globally" })

  vim.keymap.set("x", "<leader>s", replace_visual_selection,
  { desc = "Replace visual selection globally" })
