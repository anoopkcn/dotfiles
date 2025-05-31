-- Custom functions for Neovim configuration
-- @anoopkcn

Print = function(v)
	print(vim.inspect(v))
	return v
end

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Temporary highlight indicator when yanking (copying) text",
	group = vim.api.nvim_create_augroup("custom-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	desc = "Vim terminal configurations",
	group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
	end,
})

-- Function to toggle quickfix list
ToggleQuickfixList = function()
	local quickfix_exists = false
	local loclist_exists = false

	for _, win in pairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			if win.loclist == 1 then
				loclist_exists = true
			else
				quickfix_exists = true
			end
		end
	end

	if quickfix_exists and loclist_exists then
		-- Both are open, close both
		vim.cmd('cclose')
		vim.cmd('lclose')
	elseif quickfix_exists then
		-- Only quickfix is open, close it
		vim.cmd('cclose')
	elseif loclist_exists then
		-- Only location list is open, close it
		vim.cmd('lclose')
	else
		-- Neither is open, open quickfix
		vim.cmd('copen')
	end
end
