-- given a table hash print the table
Print = function(v)
	print(vim.inspect(v))
	return v
end

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Temporary highlight indicator when yanking (copying) text",
	group = vim.api.nvim_create_augroup("akc-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
