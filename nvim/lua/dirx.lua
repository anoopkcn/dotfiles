-- Extras for the builtin directory listing (:h dir), ported from my oil.nvim fork:
--   * ls -l style columns (permissions, size, mtime) drawn as inline virtual text,
--     so each buffer line stays the bare entry name that dir.lua resolves on <CR>.
--   * Dired-style ! / & shell commands on the entry or visual selection, with
--     output in a reusable bottom split and <C-c> to stop.
-- TASK(20261001-100536): oil features for the builtin dir explorer

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

-- Entry names (no trailing /) for the visual selection, or the line under the cursor.
---@return string[]
local function collect_targets()
    local first, last = vim.fn.line('.'), vim.fn.line('.')
    local mode = api.nvim_get_mode().mode
    if mode == 'v' or mode == 'V' or mode == '\22' then
        first, last = math.min(vim.fn.line('v'), first), math.max(vim.fn.line('v'), last)
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
