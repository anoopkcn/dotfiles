local dap = require("dap")

vim.keymap.set("n", "<leader>dc", dap.continue)
vim.keymap.set("n", "<leader>do", dap.step_over)
vim.keymap.set("n", "<leader>di", dap.step_into)
vim.keymap.set("n", "<leader>dx", dap.step_out)
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>B", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end)
vim.keymap.set("n", "<leader>dr", dap.repl.open)

-- Open a dap-eval:// buffer (type an expression, then :w to evaluate)
vim.keymap.set("n", "<leader>de", "<cmd>DapEval<CR>", { desc = "DAP: open eval buffer" })

-- Visual: prefill dap-eval:// with the selection (then :w to evaluate)
vim.keymap.set("v", "<leader>de", function()
  vim.cmd("'<,'>DapEval")
end, { desc = "DAP: eval selection (prefill)" })

-- Convenience: eval word under cursor immediately (writes the dap-eval buffer)
vim.keymap.set("n", "<leader>dw", function()
  local expr = vim.fn.expand("<cword>")
  vim.cmd("DapEval")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { expr })
  require("dap").repl.open()     -- where the result shows up
  vim.cmd("silent write")        -- triggers evaluation
  vim.cmd("wincmd p")            -- back to previous window
end, { desc = "DAP: eval cword now" })

-- C/C++ DAP configuration (LLDB DAP)
-- Requires: lldb-dap (or lldb-vscode on older LLVM) available on PATH
dap.adapters.lldb = {
  type = "executable",
  command = "lldb-dap", -- try "lldb-vscode" if this isn't found
  name = "lldb",
}

local function split_args(s)
  if not s or s == "" then return {} end
  return vim.split(s, "%s+")
end

dap.configurations.c = {
  {
    name = "LLDB: Launch",
    type = "lldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = function()
      return split_args(vim.fn.input("Args: "))
    end,
  },
  {
    name = "LLDB: Attach (pick process)",
    type = "lldb",
    request = "attach",
    pid = require("dap.utils").pick_process,
  },
}

dap.configurations.cpp = dap.configurations.c

-- Python DAP configuration
local function get_python()
  local venv = os.getenv("VIRTUAL_ENV")
  if venv and venv ~= "" then
    return venv .. "/bin/python"
  end
  local cwd = vim.fn.getcwd()
  if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
    return cwd .. "/.venv/bin/python"
  end
  return "python3"
end

dap.adapters.python = function(cb, _)
  cb({
    type = "executable",
    command = get_python(),
    args = { "-m", "debugpy.adapter" },
  })
end

dap.configurations.python = {
  {
    name = "Python: launch file",
    type = "python",
    request = "launch",
    program = "${file}",
    pythonPath = get_python,
    console = "integratedTerminal",
  },
  {
    name = "Python: attach (debugpy :5678)",
    type = "python",
    request = "attach",
    connect = { host = "127.0.0.1", port = 5678 },
    pythonPath = get_python,
  },
}
