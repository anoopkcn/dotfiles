-- Showdelta: show inline diff of current buffer against file or git HEAD
local Showdelta = {}
local H = {}
local uv = vim.uv or vim.loop
local text_diff = (vim.text and vim.text.diff) or vim.diff
assert(text_diff, 'showdelta: diff API not found (need vim.text.diff)')

Showdelta.config = {
  source = 'file', -- 'file' compares to current file content; 'git' compares to HEAD when available
  view = {
    style = vim.go.number and 'number' or 'sign',
    signs = { add = '+', change = '~', delete = '-' },
    priority = 199,
  },
  delay = { text_change = 150 },
  mappings = { prev = '[h', next = ']h' },
}

H.cache = {}
H.pending = {}
H.ns = vim.api.nvim_create_namespace('Showdelta')
H.timer = uv.new_timer()
H.repo_cache = {}

Showdelta.setup = function(config)
  _G.Showdelta = Showdelta
  H.config = vim.tbl_deep_extend('force', {}, Showdelta.config, config or {})
  H.extmark_opts = H.build_extmark_opts(H.config.view)
  H.create_default_hl()
  H.create_autocmds()
  H.apply_keymaps(H.config.mappings)

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    H.maybe_enable({ buf = buf })
  end
end

Showdelta.enable = function(buf)
  buf = H.validate_buf(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
  if name == '' or buftype ~= '' then return end

  H.cache[buf] = H.cache[buf] or {}
  H.cache[buf].ref_text = H.get_ref_text(name)
  H.schedule(buf, 0)
end

Showdelta.disable = function(buf)
  buf = H.validate_buf(buf)
  H.cache[buf] = nil
  pcall(vim.api.nvim_buf_clear_namespace, buf, H.ns, 0, -1)
  if vim.b[buf] ~= nil then
    vim.b[buf].showdelta_summary = nil
    vim.b[buf].showdelta_summary_string = nil
  end
end

-- Helpers -------------------------------------------------------------------
H.validate_buf = function(buf)
  if buf == nil or buf == 0 then return vim.api.nvim_get_current_buf() end
  return buf
end

H.create_autocmds = function()
  local aug = vim.api.nvim_create_augroup('Showdelta', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
    group = aug,
    callback = function(args) H.maybe_enable(args) end,
  })

  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = aug,
    callback = function(args) H.schedule(args.buf, H.config.delay.text_change) end,
  })

  vim.api.nvim_create_autocmd('BufWritePost', {
    group = aug,
    callback = function(args)
      local cache = H.cache[args.buf]
      if cache ~= nil and H.config.source == 'file' then
        cache.ref_text = H.get_ref_text(args.file)
      end
      H.schedule(args.buf, 0)
    end,
  })

  vim.api.nvim_create_autocmd('BufWipeout', {
    group = aug,
    callback = function(args) Showdelta.disable(args.buf) end,
  })
end

H.build_extmark_opts = function(view)
  local opts = {}
  if view.style == 'sign' then
    opts.add = { sign_text = view.signs.add, sign_hl_group = 'ShowdeltaSignAdd', priority = view.priority }
    opts.change = { sign_text = view.signs.change, sign_hl_group = 'ShowdeltaSignChange', priority = view.priority }
    opts.delete = { sign_text = view.signs.delete, sign_hl_group = 'ShowdeltaSignDelete', priority = view.priority }
  elseif view.style == 'number' then
    opts.add = { number_hl_group = 'ShowdeltaSignAdd', priority = view.priority }
    opts.change = { number_hl_group = 'ShowdeltaSignChange', priority = view.priority }
    opts.delete = { number_hl_group = 'ShowdeltaSignDelete', priority = view.priority }
  else
    error('showdelta: unknown view.style ' .. tostring(view.style))
  end
  return opts
end

H.maybe_enable = function(args)
  local buf = args.buf
  if not vim.api.nvim_buf_is_loaded(buf) then return end
  if H.cache[buf] ~= nil then return end
  Showdelta.enable(buf)
end

H.schedule = function(buf, delay)
  H.pending[buf] = true
  H.timer:stop()
  H.timer:start(delay, 0, function()
    vim.schedule(function()
      H.process_pending()
    end)
  end)
end

H.process_pending = function()
  local targets = H.pending
  H.pending = {}
  for buf, _ in pairs(targets) do
    if H.cache[buf] ~= nil then H.update(buf) end
  end
end

H.get_mark_rows = function(buf)
  local extmarks = vim.api.nvim_buf_get_extmarks(buf, H.ns, 0, -1, { details = false })
  if #extmarks == 0 then return {} end

  local seen, rows = {}, {}
  for _, mark in ipairs(extmarks) do
    local row = mark[2]
    if not seen[row] then
      seen[row] = true
      table.insert(rows, row)
    end
  end
  table.sort(rows)
  return rows
end

H.jump = function(direction, buf)
  buf = H.validate_buf(buf)
  local rows = H.get_mark_rows(buf)
  if #rows == 0 then return end

  local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local target

  if direction == 'next' then
    for _, row in ipairs(rows) do
      if row > cursor_row then
        target = row
        break
      end
    end
  else
    for i = #rows, 1, -1 do
      if rows[i] < cursor_row then
        target = rows[i]
        break
      end
    end
  end

  -- Wrap around when there is no farther mark in the given direction.
  if target == nil then
    target = direction == 'next' and rows[1] or rows[#rows]
  end

  vim.api.nvim_win_set_cursor(0, { target + 1, 0 })
end

H.read_file = function(path)
  if path == '' then return nil end
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then return nil end
  return table.concat(lines, '\n') .. '\n'
end

H.get_buf_text = function(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
  return table.concat(lines, '\n') .. '\n', #lines
end

H.git_root = function(path)
  local dir = vim.fs.dirname(path)
  if dir == nil then return nil end
  dir = vim.fs.normalize(dir)

  if H.repo_cache[dir] ~= nil then return H.repo_cache[dir] or nil end

  -- Look for .git directory first (most common); fall back to .git file for worktrees.
  local git_dir = vim.fs.find('.git', { path = dir, upward = true, type = 'directory' })[1]
  if git_dir ~= nil then
    local root = vim.fs.dirname(git_dir)
    H.repo_cache[dir] = root
    return root
  end

  local git_file = vim.fs.find('.git', { path = dir, upward = true, type = 'file' })[1]
  if git_file ~= nil then
    local root = vim.fs.dirname(git_file)
    H.repo_cache[dir] = root
    return root
  end

  H.repo_cache[dir] = false
  return nil
end

H.read_git_file = function(path)
  if path == '' then return nil end
  local root = H.git_root(path)
  if root == nil then return nil end

  local rel = path:sub(#root + 2)
  if rel == '' then return nil end

  local output = vim.fn.systemlist({ 'git', '-C', root, 'show', 'HEAD:' .. rel })
  if vim.v.shell_error ~= 0 then return nil end
  return table.concat(output, '\n') .. '\n'
end

H.get_ref_text = function(path)
  if H.config.source == 'git' then
    local git_text = H.read_git_file(path)
    if git_text ~= nil then return git_text end
  end
  return H.read_file(path)
end

H.update = function(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    H.cache[buf] = nil
    return
  end

  local cache = H.cache[buf]
  local ref_text = cache and cache.ref_text or nil
  if not ref_text then
    Showdelta.disable(buf)
    return
  end

  local buf_text, n_lines = H.get_buf_text(buf)
  H.render(buf, ref_text, buf_text, n_lines)
end

H.render = function(buf, ref_text, buf_text, n_lines)
  local opts = H.extmark_opts
  vim.api.nvim_buf_clear_namespace(buf, H.ns, 0, -1)

  local add, change, delete = 0, 0, 0
  local n_ranges, last_to = 0, -math.huge

  text_diff(ref_text, buf_text, {
    algorithm = 'histogram',
    on_hunk = function(start_a, count_a, start_b, count_b)
      local hunk_type = count_a == 0 and 'add' or (count_b == 0 and 'delete' or 'change')
      local hunk_change = math.min(count_a, count_b)
      add = add + count_b - hunk_change
      change = change + hunk_change
      delete = delete + count_a - hunk_change

      local from = math.max(start_b, 1)
      local count = math.max(count_b, 1)
      local to = math.min(from + count - 1, n_lines)

      if from <= to then
        if from > last_to + 1 then n_ranges = n_ranges + 1 end
        last_to = to
      end

      for l = from, to do
        vim.api.nvim_buf_set_extmark(buf, H.ns, l - 1, 0, opts[hunk_type])
      end
    end,
  })

  local summary = { add = add, change = change, delete = delete, n_ranges = n_ranges, source_name = H.config.source }
  vim.b[buf].showdelta_summary = summary

  local parts = {}
  if summary.n_ranges > 0 then table.insert(parts, '#' .. summary.n_ranges) end
  if add > 0 then table.insert(parts, '+' .. add) end
  if change > 0 then table.insert(parts, '~' .. change) end
  if delete > 0 then table.insert(parts, '-' .. delete) end
  vim.b[buf].showdelta_summary_string = table.concat(parts, ' ')
end

H.apply_keymaps = function(mappings)
  if mappings == nil or mappings == false then return end
  local set = vim.keymap.set
  if mappings.prev then set('n', mappings.prev, Showdelta.goto_prev, { desc = 'Showdelta: previous delta' }) end
  if mappings.next then set('n', mappings.next, Showdelta.goto_next, { desc = 'Showdelta: next delta' }) end
end

H.create_default_hl = function()
  local set = vim.api.nvim_set_hl
  set(0, 'ShowdeltaSignAdd', { default = true, link = 'DiffAdd' })
  set(0, 'ShowdeltaSignChange', { default = true, link = 'DiffChange' })
  set(0, 'ShowdeltaSignDelete', { default = true, link = 'DiffDelete' })
end

Showdelta.goto_next = function(buf)
  H.jump('next', buf)
end

Showdelta.goto_prev = function(buf)
  H.jump('prev', buf)
end

return Showdelta
