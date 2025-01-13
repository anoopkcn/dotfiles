-- CUSTOM FUNCTIONS
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

-- Command to toggle inline diagnostics
vim.api.nvim_create_user_command(
  'DiagnosticsToggleVirtualText',
  function()
    local current_value = vim.diagnostic.config().virtual_text
    if current_value then
      vim.diagnostic.config({virtual_text = false})
    else
      vim.diagnostic.config({virtual_text = true})
    end
  end,
  {}
)

vim.api.nvim_set_keymap('n', '<Leader>ii', '<cmd>DiagnosticsToggleVirtualText<CR>', { noremap = true, silent = true })

-- statusline functions
function Get_mode()
    local modes = {
        ['n']    = 'NORMAL',
        ['no']   = 'NORMAL',
        ['v']    = 'VISUAL',
        ['V']    = 'V-LINE',
        ['\22']  = 'V-BLOCK',
        ['s']    = 'SELECT',
        ['S']    = 'S-LINE',
        ['\19']  = 'S-BLOCK',
        ['i']    = 'INSERT',
        ['ic']   = 'INSERT',
        ['R']    = 'REPLACE',
        ['Rv']   = 'V-REPLACE',
        ['c']    = 'COMMAND',
        ['cv']   = 'VIM-EX',
        ['ce']   = 'EX',
        ['r']    = 'PROMPT',
        ['rm']   = 'MOAR',
        ['r?']   = 'CONFIRM',
        ['!']    = 'SHELL',
        ['t']    = 'TERMINAL'
    }
    local current_mode = vim.api.nvim_get_mode().mode
    return string.format("%s", modes[current_mode] or current_mode)
end

vim.opt.statusline = [[ %{%v:lua.Get_mode()%} %f %m %r %=%l,%c %P ]]
