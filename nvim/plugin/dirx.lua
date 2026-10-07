-- Extras for the builtin directory listing (:h dir), ported from my oil.nvim fork:
--   * ls -l style columns (permissions, size, mtime) drawn as inline virtual text,
--     so each buffer line stays the bare entry name that dir.lua resolves on <CR>.
--   * Dired-style ! / & shell commands on the entry or visual selection, with
--     output in a reusable bottom split and <C-c> to stop.
--   * File operations as keys on the read-only listing: % create, r rename/move,
--     dd / v_d delete (to Trash), yy / v_y yank and x / v_x cut, p paste.
-- TASK(20261001-100536): oil features for the builtin dir explorer
-- TASK(20261007-095118): create, delete, rename, copy and move entries

local api = vim.api

local M = {}

local ns = api.nvim_create_namespace('dirx.columns')
local group = api.nvim_create_augroup('dirx', { clear = true })

---------------------------------------------------------------------------
-- Columns
---------------------------------------------------------------------------

-- Toggled with gl; global so every listing follows the same setting.
local show_columns = true

local current_year = os.date('%Y')

local function set_hl()
    api.nvim_set_hl(0, 'DirxPerm', { link = 'Dimmed', default = true })
    api.nvim_set_hl(0, 'DirxSize', { link = 'Number', default = true })
    api.nvim_set_hl(0, 'DirxMtime', { link = 'Comment', default = true })
end

---@param exe_modifier string|false
---@param num integer
local function perm_to_str(exe_modifier, num)
    local str = (bit.band(num, 4) ~= 0 and 'r' or '-') .. (bit.band(num, 2) ~= 0 and 'w' or '-')
    if exe_modifier then
        return str .. (bit.band(num, 1) ~= 0 and exe_modifier or exe_modifier:upper())
    end
    return str .. (bit.band(num, 1) ~= 0 and 'x' or '-')
end

---@param mode integer
local function format_perm(mode)
    local extra = bit.rshift(mode, 9)
    return perm_to_str(bit.band(extra, 4) ~= 0 and 's', bit.rshift(mode, 6))
        .. perm_to_str(bit.band(extra, 2) ~= 0 and 's', bit.rshift(mode, 3))
        .. perm_to_str(bit.band(extra, 1) ~= 0 and 't', mode)
end

---@param size integer
local function format_size(size)
    if size >= 1e9 then
        return string.format('%.1fG', size / 1e9)
    elseif size >= 1e6 then
        return string.format('%.1fM', size / 1e6)
    elseif size >= 1e3 then
        return string.format('%.1fk', size / 1e3)
    end
    return tostring(size)
end

---@param sec integer
local function format_mtime(sec)
    if os.date('%Y', sec) ~= current_year then
        return os.date('%b %d  %Y', sec)
    end
    return os.date('%b %d %H:%M', sec)
end

---@param dir string
---@param line string
local function line_path(dir, line)
    return vim.fs.joinpath(dir, (line:gsub('/$', ''):gsub('%z', '\n')))
end

-- Draw the columns as real inline extmarks. Ephemeral inline virt_text from a
-- decoration provider (the :h dir-decorate approach) is never drawn, so the marks
-- are placed on each render instead (DirReadPost fires on open, R and :edit).
---@param buf integer
local function render_columns(buf)
    api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    if not show_columns then
        return
    end
    local dir = api.nvim_buf_get_name(buf)
    local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
    local stats, size_width = {}, 1
    for i, line in ipairs(lines) do
        -- lstat: describe a symlink itself, like ls -l.
        stats[i] = vim.uv.fs_lstat(line_path(dir, line))
        if stats[i] then
            size_width = math.max(size_width, #format_size(stats[i].size))
        end
    end
    for i, line in ipairs(lines) do
        local stat = stats[i]
        local chunks
        if stat then
            local size = format_size(stat.size)
            chunks = {
                { format_perm(stat.mode) .. ' ', 'DirxPerm' },
                { string.rep(' ', size_width - #size) .. size .. ' ', 'DirxSize' },
                { format_mtime(stat.mtime.sec) .. '  ', 'DirxMtime' },
            }
        elseif line ~= '' then
            -- Entry vanished between listing and stat: keep names aligned.
            chunks = { { string.rep(' ', 10 + size_width + 1 + 12 + 2) } }
        end
        if chunks then
            api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { virt_text = chunks, virt_text_pos = 'inline' })
        end
    end
end

api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'DirReadPost',
    desc = 'dirx: permissions/size/mtime columns',
    callback = function(args)
        render_columns(args.buf)
    end,
})

---------------------------------------------------------------------------
-- Shell commands (Dired's ! and &)
---------------------------------------------------------------------------

-- Reused across invocations so repeated commands share one output window.
-- job_id is the running job (nil when idle); terminated marks that the user
-- asked to stop it, so on_exit can label the result accordingly.
local output_state = { bufnr = nil, winid = nil, job_id = nil, terminated = false }

---@return boolean stopped
local function stop_job()
    local jid = output_state.job_id
    if jid and jid > 0 then
        output_state.terminated = true
        pcall(vim.fn.jobstop, jid)
        return true
    end
    return false
end

-- Entry names (no trailing /) for the visual selection, or [count] lines from the
-- cursor, like Dired's prefix argument.
---@return string[]
local function collect_targets()
    local first = vim.fn.line('.')
    local last = math.min(first + vim.v.count1 - 1, vim.fn.line('$'))
    local mode = api.nvim_get_mode().mode
    if mode == 'v' or mode == 'V' or mode == '\22' then
        first, last = math.min(vim.fn.line('v'), vim.fn.line('.')), math.max(vim.fn.line('v'), vim.fn.line('.'))
        -- Leave visual mode before the prompt; :normal! (unlike feedkeys "x")
        -- doesn't consume pending typeahead.
        vim.cmd.normal({ vim.keycode('<Esc>'), bang = true })
    end
    local names = {}
    for _, line in ipairs(api.nvim_buf_get_lines(0, first - 1, last, false)) do
        local name = line:gsub('/$', ''):gsub('%z', '\n')
        if name ~= '' then
            table.insert(names, name)
        end
    end
    return names
end

-- Is the char at byte i a whitespace-delimited token? Lua version of Dired's
-- \(^\|[ \t]\)\([*?]\)\([ \t]\|$\).
---@param template string
---@param i integer
local function is_standalone(template, i)
    local before = i == 1 or template:sub(i - 1, i - 1):match('[ \t]') ~= nil
    local after = i == #template or template:sub(i + 1, i + 1):match('[ \t]') ~= nil
    return before and after
end

---@param template string
---@param ch string
local function has_token(template, ch)
    for i = 1, #template do
        if template:sub(i, i) == ch and is_standalone(template, i) then
            return true
        end
    end
    return false
end

-- Built char by char (not gsub) so % and \ in filenames are inserted literally.
---@param template string
---@param ch string
---@param replacement string
local function replace_tokens(template, ch, replacement)
    local out = {}
    for i = 1, #template do
        local c = template:sub(i, i)
        if c == ch and is_standalone(template, i) then
            table.insert(out, replacement)
        else
            table.insert(out, c)
        end
    end
    return table.concat(out)
end

-- Dired substitution: a standalone * runs once with all names, a standalone ?
-- runs once per name substituted there, otherwise each name is appended.
---@param template string
---@param names string[] shell-escaped names
---@return string[]
local function build_commands(template, names)
    if has_token(template, '*') then
        return { replace_tokens(template, '*', table.concat(names, ' ')) }
    end
    local cmds = {}
    local per_file = has_token(template, '?')
    for _, name in ipairs(names) do
        table.insert(cmds, per_file and replace_tokens(template, '?', name) or template .. ' ' .. name)
    end
    return cmds
end

---@param cmds string[]
local function build_header(cmds)
    local lines = {}
    for _, cmd in ipairs(cmds) do
        table.insert(lines, '$ ' .. cmd)
    end
    return lines
end

-- Drop the trailing "" jobstart appends for the final newline.
---@param lines string[]
local function strip_trailing_newline(lines)
    if #lines > 0 and lines[#lines] == '' then
        return vim.list_slice(lines, 1, #lines - 1)
    end
    return lines
end

---@return integer bufnr
---@return integer winid
local function ensure_output_window()
    if not (output_state.bufnr and api.nvim_buf_is_valid(output_state.bufnr)) then
        local bufnr = api.nvim_create_buf(false, true)
        vim.bo[bufnr].bufhidden = 'hide'
        vim.bo[bufnr].filetype = 'dirx_output'
        pcall(api.nvim_buf_set_name, bufnr, 'DirxShellOutput')
        vim.keymap.set('n', 'q', function()
            M.close_output()
        end, { buffer = bufnr, nowait = true })
        vim.keymap.set('n', '<C-c>', function()
            -- Interrupt a running job; if nothing is running, dismiss the window.
            if not stop_job() then
                pcall(vim.cmd.close)
            end
        end, { buffer = bufnr, nowait = true })
        output_state.bufnr = bufnr
    end

    local win_ok = output_state.winid
        and api.nvim_win_is_valid(output_state.winid)
        and api.nvim_win_get_buf(output_state.winid) == output_state.bufnr
    if not win_ok then
        -- Focus stays in the listing, as in Dired.
        local winid = api.nvim_open_win(output_state.bufnr, false, {
            split = 'below',
            win = -1,
            height = math.max(5, math.min(15, math.floor(vim.o.lines / 3))),
        })
        vim.wo[winid].number = false
        vim.wo[winid].relativenumber = false
        vim.wo[winid].signcolumn = 'no'
        vim.wo[winid].winfixheight = true
        output_state.winid = winid
    end
    return output_state.bufnr, output_state.winid
end

---@param bufnr integer
---@param lines string[]
---@param append? boolean
local function write_output(bufnr, lines, append)
    if not api.nvim_buf_is_valid(bufnr) then
        return
    end
    vim.bo[bufnr].modifiable = true
    api.nvim_buf_set_lines(bufnr, append and -1 or 0, -1, false, lines)
    vim.bo[bufnr].modifiable = false
    local winid = output_state.winid
    if winid and api.nvim_win_is_valid(winid) and api.nvim_win_get_buf(winid) == bufnr then
        api.nvim_win_set_cursor(winid, { api.nvim_buf_line_count(bufnr), 0 })
    end
end

-- Re-list so mv/rm/touch show up. :edit fires the listing's BufReadCmd, the same
-- reload path as R.
---@param buf integer
local function reload_listing(buf)
    if api.nvim_buf_is_valid(buf) and vim.b[buf].nvim_dir ~= nil then
        api.nvim_buf_call(buf, function()
            vim.cmd.edit()
        end)
    end
end

---@param cmds string[]
---@param dir string
---@param listing integer
---@param async boolean stream output live (&) instead of showing it on exit (!)
local function start(cmds, dir, listing, async)
    local out = ensure_output_window()
    local header = build_header(cmds)
    write_output(out, async and header or vim.list_extend(vim.list_slice(header),
        { '', '[running... <C-c> to stop]' }))

    local handle = {}
    local stdout, stderr = {}, {}
    local function on_data(acc)
        return function(_, data)
            if not async then
                vim.list_extend(acc, data or {})
                return
            end
            vim.schedule(function()
                -- Ignore if a newer command has taken over the shared window.
                local lines = strip_trailing_newline(data or {})
                if output_state.job_id == handle.id and #lines > 0 then
                    write_output(ensure_output_window(), lines, true)
                end
            end)
        end
    end

    local jid = vim.fn.jobstart(table.concat(cmds, '\n'), {
        cwd = dir,
        stdout_buffered = not async,
        stderr_buffered = not async,
        on_stdout = on_data(stdout),
        on_stderr = on_data(stderr),
        on_exit = vim.schedule_wrap(function(_, code)
            if output_state.job_id ~= handle.id then
                return
            end
            local footer = output_state.terminated and '-- terminated --'
                or string.format('-- exit: %d --', code)
            output_state.job_id, output_state.terminated = nil, false
            local b = ensure_output_window()
            if async then
                write_output(b, { footer }, true)
            else
                local lines = build_header(cmds)
                table.insert(lines, '')
                vim.list_extend(lines, strip_trailing_newline(stdout))
                vim.list_extend(lines, strip_trailing_newline(stderr))
                vim.list_extend(lines, { '', footer })
                write_output(b, lines)
            end
            reload_listing(listing)
        end),
    })
    if jid <= 0 then
        local msg = jid == 0 and 'invalid arguments to jobstart' or 'shell is not executable'
        vim.notify('dirx: ' .. msg, vim.log.levels.ERROR)
        return
    end
    handle.id = jid
    output_state.job_id, output_state.terminated = jid, false
end

---@param async boolean
local function run(async)
    local listing = api.nvim_get_current_buf()
    local dir = api.nvim_buf_get_name(listing)
    local names = collect_targets()
    if #names == 0 then
        vim.notify('dirx: no entry under cursor', vim.log.levels.WARN)
        return
    end

    local desc = #names == 1 and names[1] or string.format('%d entries', #names)
    local template = vim.trim(vim.fn.input({
        prompt = string.format('%s on %s: ', async and '&' or '!', desc),
        completion = 'shellcmd',
        cancelreturn = '',
    }))
    if template == '' then
        return
    end

    -- Stop a command still running so outputs don't interleave.
    stop_job()
    start(build_commands(template, vim.tbl_map(vim.fn.shellescape, names)), dir, listing, async)
end

function M.run_command()
    run(false)
end

function M.run_command_async()
    run(true)
end

function M.stop_command()
    if not stop_job() then
        vim.notify('dirx: no command is running', vim.log.levels.INFO)
    end
end

-- Close the output window, stopping a running job (its next output would reopen it).
---@return boolean closed
local function output_win_open()
    local winid = output_state.winid
    return winid ~= nil and api.nvim_win_is_valid(winid) and api.nvim_win_get_buf(winid) == output_state.bufnr
end

function M.close_output()
    if not output_win_open() then
        return false
    end
    local winid = output_state.winid
    stop_job()
    -- Disown the job so its on_exit doesn't reopen the window for the footer.
    output_state.job_id, output_state.terminated = nil, false
    return pcall(api.nvim_win_close, winid, false)
end

function M.toggle_columns()
    show_columns = not show_columns
    for _, buf in ipairs(api.nvim_list_bufs()) do
        if vim.b[buf].nvim_dir ~= nil then
            render_columns(buf)
        end
    end
end

---------------------------------------------------------------------------
-- File operations
---------------------------------------------------------------------------

local uv = vim.uv

-- Paths taken by yy/y (copy) or x (move) and put into a listing by p, so entries
-- can travel between listings.
---@type { paths: string[], mode: 'copy'|'move' }
local clipboard = { paths = {}, mode = 'copy' }

---@param msg string
---@param level? integer
local function notify(msg, level)
    vim.notify('dirx: ' .. msg, level or vim.log.levels.INFO)
end

---@param prompt string
---@param default? string
---@return string? input nil when cancelled
local function ask(prompt, default)
    local input = vim.fn.input({ prompt = prompt, default = default or '', completion = 'file', cancelreturn = '' })
    if input ~= '' then
        return input
    end
end

-- Prompt input is relative to the listing unless it is an absolute or ~ path.
---@param dir string
---@param input string
local function resolve(dir, input)
    if not input:match('^[/~]') then
        input = vim.fs.joinpath(dir, input)
    end
    return vim.fs.normalize(input)
end

-- The entry of listing dir that path is, or lies under.
---@param dir string
---@param path string
---@return string?
local function entry_of(dir, path)
    local rel = vim.fs.relpath(dir, path)
    return rel and rel ~= '.' and rel:match('^[^/]+') or nil
end

-- Same inode, e.g. foo and Foo on a case-insensitive filesystem.
---@param a string
---@param b string
local function same_file(a, b)
    local sa, sb = uv.fs_lstat(a), uv.fs_lstat(b)
    return sa ~= nil and sb ~= nil and sa.ino == sb.ino and sa.dev == sb.dev
end

---@param name string
---@return integer?
local function find_buf(name)
    for _, buf in ipairs(api.nvim_list_bufs()) do
        if api.nvim_buf_get_name(buf) == name then
            return buf
        end
    end
end

-- Re-list every listing of one of dirs, then put the cursor of the current
-- listing on the entry select.
---@param dirs table<string, true>
---@param select? string
local function refresh(dirs, select)
    for _, buf in ipairs(api.nvim_list_bufs()) do
        if vim.b[buf].nvim_dir ~= nil and dirs[api.nvim_buf_get_name(buf)] then
            reload_listing(buf)
        end
    end
    if not select then
        return
    end
    local encoded = select:gsub('\n', '\0')
    for i, line in ipairs(api.nvim_buf_get_lines(0, 0, -1, false)) do
        if line:gsub('/$', '') == encoded then
            api.nvim_win_set_cursor(0, { i, 0 })
            return
        end
    end
end

-- Point buffers of src, or of anything under it, at their new path. Unmodified
-- files are re-read so :w doesn't stop at E13 (file exists); modified ones keep
-- their changes and need :w!.
---@param src string
---@param dst string
local function rename_buffers(src, dst)
    for _, buf in ipairs(api.nvim_list_bufs()) do
        local name = api.nvim_buf_get_name(buf)
        local listing = vim.b[buf].nvim_dir ~= nil
        if (vim.bo[buf].buftype == '' or listing) and (name == src or vim.startswith(name, src .. '/')) then
            if pcall(api.nvim_buf_set_name, buf, dst .. name:sub(#src + 1)) then
                -- set_name leaves an unlisted buffer behind under the old name.
                local stale = find_buf(name)
                if stale then
                    pcall(api.nvim_buf_delete, stale, { force = true })
                end
                if listing then
                    reload_listing(buf)
                elseif vim.bo[buf].modified then
                    notify(api.nvim_buf_get_name(buf) .. ' has unsaved changes, save with :w!', vim.log.levels.WARN)
                elseif api.nvim_buf_is_loaded(buf) then
                    api.nvim_buf_call(buf, function()
                        vim.cmd.edit({ bang = true, mods = { keepalt = true } })
                    end)
                end
            end
        end
    end
end

-- Move paths to the Trash, or delete them where there is no trash command.
---@param paths string[]
---@return string? err
local function trash(paths)
    if vim.fn.executable('trash') == 1 then
        local res = vim.system(vim.list_extend({ 'trash' }, paths), { text = true }):wait()
        if res.code ~= 0 then
            return vim.trim(res.stderr ~= '' and res.stderr or res.stdout)
        end
        return nil
    end
    for _, path in ipairs(paths) do
        local ok, err = pcall(vim.fs.rm, path, { recursive = true })
        if not ok then
            return tostring(err)
        end
    end
end

---@param src string
---@param dst string
---@return string? err
local function copy(src, dst)
    local res = vim.system({ 'cp', '-R', src, dst }, { text = true }):wait()
    if res.code ~= 0 then
        return vim.trim(res.stderr)
    end
end

---@param src string
---@param dst string
---@return string? err
local function move(src, dst)
    local ok, err, code = uv.fs_rename(src, dst)
    if not ok then
        if code ~= 'EXDEV' then
            return err
        end
        -- Across filesystems: copy, then remove the source (the copy is the backup).
        err = copy(src, dst)
        if err then
            return err
        end
        local rm_ok, rm_err = pcall(vim.fs.rm, src, { recursive = true })
        if not rm_ok then
            return tostring(rm_err)
        end
    end
    rename_buffers(src, dst)
end

-- Copy or move src to dst. An existing dst is replaced only after confirmation,
-- and goes to the Trash.
---@param src string
---@param dst string
---@param mode 'copy'|'move'
---@return 'done'|'skipped'|'cancelled'
local function transfer(src, dst, mode)
    if vim.startswith(dst, src .. '/') then
        notify(string.format('cannot %s %s into itself', mode, src), vim.log.levels.ERROR)
        return 'skipped'
    end
    if uv.fs_lstat(dst) and not (mode == 'move' and same_file(src, dst)) then
        local choice = vim.fn.confirm(dst .. ' exists. Overwrite?', '&Yes\n&Skip\n&Cancel', 2)
        if choice ~= 1 then
            return choice == 2 and 'skipped' or 'cancelled'
        end
        local err = trash({ dst })
        if err then
            notify(err, vim.log.levels.ERROR)
            return 'skipped'
        end
    end
    vim.fn.mkdir(vim.fs.dirname(dst), 'p')
    local err = (mode == 'copy' and copy or move)(src, dst)
    if err then
        notify(string.format('%s %s: %s', mode, src, err), vim.log.levels.ERROR)
        return 'skipped'
    end
    return 'done'
end

function M.create()
    local dir = api.nvim_buf_get_name(0)
    local input = ask('Create (end with / for a directory): ')
    if not input then
        return
    end
    local path = resolve(dir, input)
    if uv.fs_lstat(path) then
        notify(path .. ' already exists', vim.log.levels.WARN)
        return
    end
    local ok, err = pcall(function()
        if input:sub(-1) == '/' then
            vim.fn.mkdir(path, 'p')
        else
            vim.fn.mkdir(vim.fs.dirname(path), 'p')
            -- wx: fail rather than truncate a file created since the check.
            uv.fs_close(assert(uv.fs_open(path, 'wx', tonumber('644', 8))))
        end
    end)
    if not ok then
        notify(tostring(err), vim.log.levels.ERROR)
        return
    end
    refresh({ [dir] = true, [vim.fs.dirname(path)] = true }, entry_of(dir, path))
end

-- Like mv: a target that is a directory, or ends in /, receives the entry.
function M.rename()
    local dir = api.nvim_buf_get_name(0)
    local name = collect_targets()[1]
    if not name then
        notify('no entry under cursor', vim.log.levels.WARN)
        return
    end
    local input = ask('Rename to: ', name)
    if not input or input == name then
        return
    end
    local src, dst = vim.fs.joinpath(dir, name), resolve(dir, input)
    local stat = uv.fs_stat(dst)
    if input:sub(-1) == '/' or (stat and stat.type == 'directory' and not same_file(src, dst)) then
        dst = vim.fs.joinpath(dst, name)
    end
    if transfer(src, dst, 'move') == 'done' then
        refresh({ [dir] = true, [vim.fs.dirname(dst)] = true }, entry_of(dir, dst))
    end
end

function M.delete()
    local dir = api.nvim_buf_get_name(0)
    local names = collect_targets()
    if #names == 0 then
        notify('no entry under cursor', vim.log.levels.WARN)
        return
    end
    local desc = #names == 1 and names[1] or string.format('%d entries', #names)
    if vim.fn.confirm('Delete ' .. desc .. '?', '&Yes\n&No', 2) ~= 1 then
        return
    end
    local err = trash(vim.tbl_map(function(name)
        return vim.fs.joinpath(dir, name)
    end, names))
    if err then
        notify(err, vim.log.levels.ERROR)
    end
    refresh({ [dir] = true })
end

---@param mode 'copy'|'move'
local function take(mode)
    local register = vim.v.register
    local dir = api.nvim_buf_get_name(0)
    local names = collect_targets()
    if #names == 0 then
        notify('no entry under cursor', vim.log.levels.WARN)
        return
    end
    local paths = vim.tbl_map(function(name)
        return vim.fs.joinpath(dir, name)
    end, names)
    clipboard = { paths = paths, mode = mode }
    vim.fn.setreg(register, paths, 'l')
    local desc = #names == 1 and names[1] or string.format('%d entries', #names)
    notify(string.format('%s %s, p to paste', mode == 'copy' and 'yanked' or 'cut', desc))
end

function M.yank()
    take('copy')
end

function M.cut()
    take('move')
end

function M.paste()
    local dir = api.nvim_buf_get_name(0)
    if #clipboard.paths == 0 then
        notify('nothing to paste (yy/y yanks, x cuts)', vim.log.levels.WARN)
        return
    end
    local mode = clipboard.mode
    local dirs, select = { [dir] = true }, nil
    for _, src in ipairs(clipboard.paths) do
        local dst = vim.fs.joinpath(dir, vim.fs.basename(src))
        local result = 'skipped'
        if not uv.fs_lstat(src) then
            notify(src .. ' no longer exists', vim.log.levels.WARN)
        elseif dst ~= src then
            result = transfer(src, dst, mode)
        elseif mode == 'copy' then
            -- A copy next to its source needs a new name.
            local input = ask('Copy as: ', vim.fs.basename(src))
            if input and input ~= vim.fs.basename(src) then
                dst = resolve(dir, input)
                result = transfer(src, dst, mode)
            end
        end
        if result == 'cancelled' then
            break
        elseif result == 'done' then
            dirs[vim.fs.dirname(src)], dirs[vim.fs.dirname(dst)] = true, true
            select = entry_of(dir, dst)
        end
    end
    if mode == 'move' then
        -- Keep what wasn't moved (skipped or cancelled) for another p.
        clipboard.paths = vim.tbl_filter(function(path)
            return uv.fs_lstat(path) ~= nil
        end, clipboard.paths)
    end
    refresh(dirs, select)
end

-- Exposed for tests.
M._build_commands = build_commands

---------------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------------

set_hl()
api.nvim_create_autocmd('ColorScheme', { group = group, desc = 'dirx: highlight links', callback = set_hl })

api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'directory',
    desc = 'dirx: listing keymaps',
    callback = function(args)
        local function bmap(modes, lhs, rhs, desc)
            vim.keymap.set(modes, lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
        end
        bmap({ 'n', 'x' }, '!', M.run_command, 'Run shell command on entry (output on exit)')
        bmap({ 'n', 'x' }, '&', M.run_command_async, 'Run shell command on entry (output streams)')
        bmap('n', '<C-c>', M.stop_command, 'Stop running shell command')
        bmap('n', 'gl', M.toggle_columns, 'Toggle permissions/size/mtime columns')
        bmap('n', '%', M.create, 'Create file, or directory if the name ends in /')
        bmap('n', 'r', M.rename, 'Rename/move entry')
        bmap('n', 'dd', M.delete, 'Delete entry (to Trash)')
        bmap('x', 'd', M.delete, 'Delete selected entries (to Trash)')
        bmap('n', 'yy', M.yank, 'Yank entry for p (copy)')
        bmap('x', 'y', M.yank, 'Yank selected entries for p (copy)')
        bmap('n', 'x', M.cut, 'Cut entry for p (move)')
        bmap('x', 'x', M.cut, 'Cut selected entries for p (move)')
        bmap('n', 'p', M.paste, 'Paste yanked/cut entries here')
        -- Without an output window, q stays the macro-record command. An <expr>
        -- mapping keeps the stopping q out of the recorded register; the close is
        -- scheduled because windows can't be closed under textlock.
        vim.keymap.set('n', 'q', function()
            if output_win_open() then
                vim.schedule(M.close_output)
                return ''
            end
            return 'q'
        end, { buffer = args.buf, expr = true, desc = 'Close shell command output window' })
    end,
})

return M
