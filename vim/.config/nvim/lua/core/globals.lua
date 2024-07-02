-- Lazy plugin manager
-- https://github.com/folke/lazy.nvim.git
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

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
