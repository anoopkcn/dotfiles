vim.opt_local.colorcolumn = nil

vim.cmd([[let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro']])

local function netrw_entry()
  local dir = vim.b.netrw_curdir
  if not dir or dir == '' then
    return nil, nil, 'netrw_curdir not set'
  end

  local name = vim.fn.expand('<cfile>')
  if not name or name == '' then
    return nil, nil, 'no file under cursor'
  end

  return dir, name, nil
end

-- yp: copy *directory* path (the current netrw folder)
vim.keymap.set('n', 'yp', function()
  local dir = vim.b.netrw_curdir
  if not dir or dir == '' then
    vim.notify('netrw: no current directory', vim.log.levels.WARN)
    return
  end

  vim.fn.setreg('+', dir)
  vim.fn.setreg('"', dir)
  vim.notify('Copied directory: ' .. dir)
end, { buffer = true, desc = 'Copy netrw directory path' })

-- yf: copy *full file path* (dir + filename under cursor)
vim.keymap.set('n', 'yf', function()
  local dir, name, err = netrw_entry()
  if err then
    vim.notify('netrw: ' .. err, vim.log.levels.WARN)
    return
  end

  -- join directory + filename
  local path
  if vim.fs and vim.fs.joinpath then
    path = vim.fs.joinpath(dir, name)
  else
    path = dir .. '/' .. name
  end

  vim.fn.setreg('+', path)
  vim.fn.setreg('"', path)
  vim.notify('Copied file: ' .. path)
end, { buffer = true, desc = 'Copy netrw file path' })
