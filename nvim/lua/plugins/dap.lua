return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"mfussenegger/nvim-dap-python"
	},
	config = function()
		local dap, dapui = require("dap"), require("dapui")
		dapui.setup({
			controls = { enabled = false },
			expand_lines = true,
			floating = { border = "rounded" },
			-- render = {
			-- 	max_type_length = 60,
			-- 	max_value_lines = 200,
			-- },
			layouts = { {
				elements = {
					{ id = "scopes", size = 1.0, },
				},
				position = "bottom",
				size = 15,
			} }
		})

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
		vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP: Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>dt", function() dap.run_to_cursor() end, { desc = "DAP: Run to Cursor" })
		vim.keymap.set("n", "<leader>dc", function() dap.continue() end, { desc = "DAP: Continue" })
		vim.keymap.set("n", "<leader>di", function() dap.step_into() end, { desc = "DAP: Step Into" })
		-- vim.keymap.set("n", "<leader>db", function() dap.step_back() end, { desc = "DAP: Step Back" })
		vim.keymap.set("n", "<leader>do", function() dap.step_out() end, { desc = "DAP: Step Out" })
		vim.keymap.set("n", "<leader>ds", function() dap.step_over() end, { desc = "DAP: Step Over" })
		--clear all brakepoints
		vim.keymap.set("n", "<leader>dB", function() dap.clear_breakpoints() end,
			{ desc = "DAP: Clear All Breakpoints" })
		--terminate
		vim.keymap.set("n", "<leader>dq", function() dap.terminate() end, { desc = "DAP: Terminate" })
		-- vim.keymap.set("n", "<leader>dr", function() dap.repl.open() end, { desc = "DAP: Open REPL" })

		vim.keymap.set("n", "<leader>dv", function() dapui.eval() end, { desc = "DAP: Evaluate Expression" })
		vim.keymap.set("n", "<leader>de", function() dapui.eval(nil, { enter = true }) end,
			{ desc = "DAP: Evaluate Expression" })
	end,
}
