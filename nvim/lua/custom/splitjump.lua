local M = {}

-- Plugin state
local tmux_is_last_pane = false

-- Configuration defaults
M.config = {
  no_mappings = false,
  disable_when_zoomed = false,
  save_on_switch = 0, -- 0: no save, 1: save current buffer, 2: save all buffers
  preserve_zoom = false,
  no_wrap = false,
  disable_netrw_workaround = false
}

local function vim_navigate(direction)
  local success, _ = pcall(vim.cmd, 'wincmd ' .. direction)
  if not success then
    vim.api.nvim_err_writeln('E11: Invalid in command-line window; <CR> executes, CTRL-C quits: wincmd ' .. direction)
  end
end

local function tmux_socket()
  return vim.split(vim.env.TMUX, ',')[1]
end

local function tmux_command(args)
  local tmux_exe = string.find(vim.env.TMUX or '', 'tmate') and 'tmate' or 'tmux'
  local cmd = string.format('%s -S %s %s', tmux_exe, tmux_socket(), args)
  return vim.fn.system(cmd)
end

local function tmux_vim_pane_is_zoomed()
  return tonumber(tmux_command("display-message -p '#{window_zoomed_flag}'")) == 1
end

local function should_forward_navigation(tmux_last_pane, at_tab_page_edge)
  if M.config.disable_when_zoomed and tmux_vim_pane_is_zoomed() then
    return false
  end
  return tmux_last_pane or at_tab_page_edge
end

local pane_position_from_direction = {
  h = 'left',
  j = 'bottom',
  k = 'top',
  l = 'right'
}

local function tmux_aware_navigate(direction)
  local nr = vim.fn.winnr()
  local tmux_last_pane = (direction == 'p' and tmux_is_last_pane)
  
  if not tmux_last_pane then
    vim_navigate(direction)
  end
  
  local at_tab_page_edge = (nr == vim.fn.winnr())
  
  if should_forward_navigation(tmux_last_pane, at_tab_page_edge) then
    if M.config.save_on_switch == 1 then
      pcall(vim.cmd, 'update')
    elseif M.config.save_on_switch == 2 then
      pcall(vim.cmd, 'wall')
    end
    
    local dir_tr = {p = 'l', h = 'L', j = 'D', k = 'U', l = 'R'}
    local args = string.format('select-pane -t %s -%s', vim.fn.shellescape(vim.env.TMUX_PANE), dir_tr[direction])
    
    if M.config.preserve_zoom then
      args = args .. ' -Z'
    end
    
    if M.config.no_wrap then
      args = string.format('if -F "#{pane_at_%s}" "" "%s"', 
        pane_position_from_direction[direction], 
        args)
    end
    
    tmux_command(args)
    tmux_is_last_pane = true
  else
    tmux_is_last_pane = false
  end
end

function M.setup(user_config)
  -- Merge user config with defaults
  M.config = vim.tbl_extend('force', M.config, user_config or {})
  
  -- Only set up if not in tmux
  if not vim.env.TMUX then
    vim.api.nvim_create_user_command('TmuxNavigateLeft', function() vim_navigate('h') end, {})
    vim.api.nvim_create_user_command('TmuxNavigateDown', function() vim_navigate('j') end, {})
    vim.api.nvim_create_user_command('TmuxNavigateUp', function() vim_navigate('k') end, {})
    vim.api.nvim_create_user_command('TmuxNavigateRight', function() vim_navigate('l') end, {})
    vim.api.nvim_create_user_command('TmuxNavigatePrevious', function() vim_navigate('p') end, {})
    return
  end
  
  -- Create commands
  vim.api.nvim_create_user_command('TmuxNavigateLeft', function() tmux_aware_navigate('h') end, {})
  vim.api.nvim_create_user_command('TmuxNavigateDown', function() tmux_aware_navigate('j') end, {})
  vim.api.nvim_create_user_command('TmuxNavigateUp', function() tmux_aware_navigate('k') end, {})
  vim.api.nvim_create_user_command('TmuxNavigateRight', function() tmux_aware_navigate('l') end, {})
  vim.api.nvim_create_user_command('TmuxNavigatePrevious', function() tmux_aware_navigate('p') end, {})
  
  -- Set up autocommand to reset tmux_is_last_pane
  vim.api.nvim_create_autocmd('WinEnter', {
    group = vim.api.nvim_create_augroup('tmux_navigator', { clear = true }),
    callback = function() tmux_is_last_pane = false end
  })
  
  -- Set up default mappings unless disabled
  if not M.config.no_mappings then
    local opts = { noremap = true, silent = true }
    vim.keymap.set('n', '<C-h>', ':TmuxNavigateLeft<CR>', opts)
    vim.keymap.set('n', '<C-j>', ':TmuxNavigateDown<CR>', opts)
    vim.keymap.set('n', '<C-k>', ':TmuxNavigateUp<CR>', opts)
    vim.keymap.set('n', '<C-l>', ':TmuxNavigateRight<CR>', opts)
    vim.keymap.set('n', '<C-\\>', ':TmuxNavigatePrevious<CR>', opts)
    
    -- Handle netrw mapping conflict
    if not M.config.disable_netrw_workaround then
      if not vim.g.Netrw_UserMaps then
        vim.g.Netrw_UserMaps = {{'<C-l>', '<C-U>TmuxNavigateRight<cr>'}}
      else
        vim.api.nvim_err_writeln(
          'vim-tmux-navigator conflicts with netrw <C-l> mapping. ' ..
          'See https://github.com/christoomey/vim-tmux-navigator#netrw or ' ..
          'set disable_netrw_workaround = true in setup() to suppress this warning.'
        )
      end
    end
  end
end

return M
