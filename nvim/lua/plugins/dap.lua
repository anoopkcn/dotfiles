return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"mfussenegger/nvim-dap-python"
	},
	config = function()
		local dap, dapui = require("dap"), require("dapui")
		dapui.setup()

		require("dap-python").setup("debugpy-adapter")

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
		vim.keymap.set("n", "<leader>dt", function() dap.toggle_breakpoint() end, { desc = "DAP: Toggle Breakpoint" })

		vim.keymap.set("n", "<leader>dc", function() dap.continue() end, { desc = "DAP: Continue" })
	end,
}
