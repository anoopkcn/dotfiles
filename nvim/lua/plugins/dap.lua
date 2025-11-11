local pack = require("custom.pack")
local M = {}

M.specs = {
    "https://github.com/mfussenegger/nvim-dap",
    "https://github.com/rcarriga/nvim-dap-ui",
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/mfussenegger/nvim-dap-python",
}

pack.ensure_specs(M.specs)

local function safe_require(name)
    local ok, mod = pcall(require, name)
    if ok then
        return mod
    end
    return nil
end

function M.setup()
    local dap = safe_require("dap")
    local dapui = safe_require("dapui")
    if not dap or not dapui then
        return
    end

    dapui.setup({
        controls = { enabled = false },
        expand_lines = false,
        floating = { border = "rounded" },
        layouts = { {
            elements = {
                { id = "stacks", size = 0.25, },
                { id = "scopes", size = 0.75, },
            },
            position = "bottom",
            size = 12,
        } }
    })

    local dap_python = safe_require("dap-python")
    if dap_python then
        dap_python.setup("debugpy-adapter")
    end

    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
    end

    -- toggle breakpoint
    vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP: Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>dt", function() dap.run_to_cursor() end, { desc = "DAP: Run to Cursor" })
    vim.keymap.set("n", "<leader>dc", function() dap.continue() end, { desc = "DAP: Continue" })
    vim.keymap.set("n", "<leader>di", function() dap.step_into() end, { desc = "DAP: Step Into" })
    vim.keymap.set("n", "<leader>do", function() dap.step_out() end, { desc = "DAP: Step Out" })
    vim.keymap.set("n", "<leader>ds", function() dap.step_over() end, { desc = "DAP: Step Over" })
    vim.keymap.set("n", "<leader>dB", function() dap.clear_breakpoints() end,
        { desc = "DAP: Clear All Breakpoints" })
    vim.keymap.set("n", "<leader>dq", function() dap.terminate() end, { desc = "DAP: Terminate" })

    vim.keymap.set("n", "<leader>dv", function() dapui.eval() end, { desc = "DAP: Evaluate Expression" })
    vim.keymap.set("n", "<leader>de", function() dapui.eval(nil, { enter = true }) end,
        { desc = "DAP: Evaluate Expression" })
    vim.keymap.set("n", "<leader>du", function() dapui.toggle() end, { desc = "DAP: Toggle UI" })
end

return M
