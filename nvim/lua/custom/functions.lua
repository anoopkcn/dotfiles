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

-- vim.api.nvim_create_autocmd('LspAttach', {
-- callback = function (ev)
-- 	local client = vim.lsp.get_client_by_id(ev.data.client_id)
-- 	if client:supports_method ('textDocument/completion') then
-- 		vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true})
-- 	end
-- end,
-- })

-- Command to toggle inline diagnostics
vim.diagnostic.config({ virtual_text = false }) -- Disable virtual text by default
vim.api.nvim_create_user_command(
	"DiagnosticsToggleVirtualText",
	function()
		local current_value = vim.diagnostic.config().virtual_text
		if current_value then
			vim.diagnostic.config({ virtual_text = false })
		else
			vim.diagnostic.config({ virtual_text = true })
		end
	end,
	{}
)


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

-- statusline functions
-- function Get_mode()
-- 	local modes = {
-- 		['n']   = 'NORMAL',
-- 		['no']  = 'NORMAL',
-- 		['v']   = 'VISUAL',
-- 		['V']   = 'V-LINE',
-- 		['\22'] = 'V-BLOCK',
-- 		['s']   = 'SELECT',
-- 		['S']   = 'S-LINE',
-- 		['\19'] = 'S-BLOCK',
-- 		['i']   = 'INSERT',
-- 		['ic']  = 'INSERT',
-- 		['R']   = 'REPLACE',
-- 		['Rv']  = 'V-REPLACE',
-- 		['c']   = 'COMMAND',
-- 		['cv']  = 'VIM-EX',
-- 		['ce']  = 'EX',
-- 		['r']   = 'PROMPT',
-- 		['rm']  = 'MOAR',
-- 		['r?']  = 'CONFIRM',
-- 		['!']   = 'SHELL',
-- 		['t']   = 'TERMINAL'
-- 	}
-- 	local current_mode = vim.api.nvim_get_mode().mode
-- 	return string.format("%%#Bold#%s%%*", modes[current_mode] or current_mode)
-- 	-- return string.format("%%#Bold#%%s%%*", modes[current_mode] or current_mode)
-- end

-- vim.opt.statusline = [[%{%v:lua.Get_mode()%}  %f %m %r %=%l,%c %P]]
-- vim.opt.statusline = [[%{%v:lua.Get_mode()%} %#Comment#%f%* %m %r %=%l,%c %P]]
