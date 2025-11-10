local M = {}

function M.setup()
	local ok, copilot = pcall(require, "copilot")
	if not ok then
		return
	end

	---@diagnostic disable-next-line: redundant-parameter
	copilot.setup({
		suggestion = { enabled = false },
		panel = { enabled = false },
	})
end

return M
