-- Extras for the builtin directory listing (:h dir)
--   * Dired-style ! / & shell commands on the entry or visual selection, with
--     output in a reusable bottom split and <C-c> to stop.
--   * oil-style editing: the listing is an ordinary editable buffer and :w applies
--     the edits after a confirm. A renamed line renames (a path moves the entry),
--     a deleted line sends the entry to the Trash, a new line creates a file (or a
--     directory when it ends in /). A line yanked (yy) or cut (dd) and put, in
--     the same listing or another, copies or moves the entry; a put that clashes
--     with a name is renamed name_copy_N.ext. :w in any listing applies the edits
--     of all of them together.
-- TASK(20261001-100536): oil features for the builtin dir explorer
-- TASK(20261007-095118): create, delete, rename, copy and move entries
-- TASK(20261009-102036): edit the listing and :w to apply
-- TASK(20261009-111329): native APIs, redundancy and bug pass
-- TASK(20261009-112136): drop the metadata columns
-- TASK(20261009-112932): ~/$ names, copies from yanks only, no M

local api = vim.api
local uv = vim.uv

-- One mark per listed entry, id = its line number in the render. Marks follow their
-- line through edits and are invalidated when it is deleted, so :w can tell a
-- renamed entry from a deleted one and a new line.
local ns_entries = api.nvim_create_namespace('dirx.entries')
-- One mark per line put as a copy of an entry; listing.copies holds its source path.
local ns_copies = api.nvim_create_namespace('dirx.copies')
local group = api.nvim_create_augroup('dirx', { clear = true })

-- Per listing buffer, as of its last render: the lines, by mark id; and the source
-- of the copies put since, by mark id.
---@class dirx.Listing
---@field lines string[]
---@field copies table<integer, string>

---@type table<integer, dirx.Listing>
local listings = {}

---@param msg string
---@param level? integer
local function notify(msg, level)
    vim.notify('dirx: ' .. msg, level or vim.log.levels.INFO)
end

-- Entry name on a listing line: without the trailing / of a directory, newlines
-- decoded (dir.lua writes them as NUL).
---@param line string
local function entry_name(line)
    return (line:gsub('/$', ''):gsub('%z', '\n'))
end

---@param dir string
---@param line string
local function line_path(dir, line)
    return vim.fs.joinpath(dir, entry_name(line))
end

-- Ids of the valid marks of namespace on each row (0-based).
---@param buf integer
---@param namespace integer
---@return table<integer, integer[]>
local function mark_rows(buf, namespace)
    local rows = {}
    for _, mark in ipairs(api.nvim_buf_get_extmarks(buf, namespace, 0, -1, { details = true })) do
        if not mark[4].invalid then
            rows[mark[2]] = rows[mark[2]] or {}
            table.insert(rows[mark[2]], mark[1])
        end
    end
    return rows
end

-- Forget undo history, so u can't bring back the lines of an earlier render.
---@param buf integer
local function clear_undo(buf)
    local undolevels = vim.bo[buf].undolevels
    vim.bo[buf].undolevels = -1
    api.nvim_buf_set_lines(buf, 0, 1, false, api.nvim_buf_get_lines(buf, 0, 1, false))
    vim.bo[buf].undolevels = undolevels
end

api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'DirReadPost',
    desc = 'dirx: snapshot entries, make the listing editable',
    callback = function(args)
        local buf = args.buf
        local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
        listings[buf] = { lines = lines, copies = {} }
        clear_undo(buf)
        api.nvim_buf_clear_namespace(buf, ns_entries, 0, -1)
        api.nvim_buf_clear_namespace(buf, ns_copies, 0, -1)
        for i, line in ipairs(lines) do
            if line ~= '' then
                api.nvim_buf_set_extmark(buf, ns_entries, i - 1, 0, { id = i, invalidate = true })
            end
        end
        -- dir.lua locks the buffer (nowrite, readonly, nomodifiable) right after
        -- DirReadPost; unlock it once the render is done. acwrite routes :w to
        -- BufWriteCmd.
        vim.schedule(function()
            if api.nvim_buf_is_valid(buf) and vim.b[buf].nvim_dir ~= nil then
                vim.bo[buf].buftype = 'acwrite'
                vim.bo[buf].readonly = false
                vim.bo[buf].modifiable = true
            end
        end)
    end,
})

-- dir.lua re-lists a buffer whenever - or <CR> navigates into it, which would throw
-- away the edits of a listing that was left unsaved. Keep them (R and :e! still
-- reload).
local nvim_dir = require('nvim.dir')
local dir_open = nvim_dir.open
---@diagnostic disable-next-line: duplicate-set-field
function nvim_dir.open(buf, ...)
    local b = buf == 0 and api.nvim_get_current_buf() or buf
    if vim.b[b].nvim_dir ~= nil and vim.bo[b].modified then
        return
    end
    return dir_open(buf, ...)
end

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
        local name = entry_name(line)
        if name ~= '' then
            table.insert(names, name)
        end
    end
    return names
end

-- Replace each whitespace-delimited ch, as Dired's \(^\|[ \t]\)\([*?]\)\([ \t]\|$\),
-- with replacement, inserted literally (a function replacement, so % in names is
-- safe). Also returns the number of replacements.
---@param template string
---@param ch '*'|'?'
---@param replacement string
---@return string
---@return integer
local function sub_token(template, ch, replacement)
    local out, n = (' ' .. template .. ' '):gsub('(%s)%' .. ch .. '%f[%s]', function(space)
        return space .. replacement
    end)
    return out:sub(2, -2), n
end

-- Dired substitution: a standalone * runs once with all names, a standalone ?
-- runs once per name substituted there, otherwise each name is appended.
---@param template string
---@param names string[] shell-escaped names
---@return string[]
local function build_commands(template, names)
    local all, n = sub_token(template, '*', table.concat(names, ' '))
    if n > 0 then
        return { all }
    end
    local per_file = select(2, sub_token(template, '?', '')) > 0
    return vim.tbl_map(function(name)
        return per_file and (sub_token(template, '?', name)) or template .. ' ' .. name
    end, names)
end

local function output_win_open()
    local winid = output_state.winid
    return winid ~= nil and api.nvim_win_is_valid(winid) and api.nvim_win_get_buf(winid) == output_state.bufnr
end

-- Close the output window, stopping a running job (its next output would reopen it).
local function close_output()
    if not output_win_open() then
        return
    end
    stop_job()
    -- Disown the job so its on_exit doesn't reopen the window for the footer.
    output_state.job_id, output_state.terminated = nil, false
    pcall(api.nvim_win_close, output_state.winid, false)
end

---@return integer bufnr
local function ensure_output_window()
    if not (output_state.bufnr and api.nvim_buf_is_valid(output_state.bufnr)) then
        local bufnr = api.nvim_create_buf(false, true)
        vim.bo[bufnr].bufhidden = 'hide'
        vim.bo[bufnr].filetype = 'dirx_output'
        pcall(api.nvim_buf_set_name, bufnr, 'DirxShellOutput')
        vim.keymap.set('n', 'q', close_output, { buffer = bufnr, nowait = true })
        vim.keymap.set('n', '<C-c>', function()
            -- Interrupt a running job; if nothing is running, dismiss the window.
            if not stop_job() then
                pcall(vim.cmd.close)
            end
        end, { buffer = bufnr, nowait = true })
        output_state.bufnr = bufnr
    end
    if not output_win_open() then
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
    return output_state.bufnr
end

-- Show lines in the output window (reopened if closed), replacing or appending.
---@param lines string[]
---@param append? boolean
local function write_output(lines, append)
    local bufnr = ensure_output_window()
    vim.bo[bufnr].modifiable = true
    api.nvim_buf_set_lines(bufnr, append and -1 or 0, -1, false, lines)
    vim.bo[bufnr].modifiable = false
    api.nvim_win_set_cursor(output_state.winid, { api.nvim_buf_line_count(bufnr), 0 })
end

-- Re-list so mv/rm/touch show up. :edit fires the listing's BufReadCmd, the same
-- reload path as R. A listing with unsaved edits, or of a directory that is gone,
-- is left alone.
---@param buf integer
---@return boolean reloaded
local function reload_listing(buf)
    if
        api.nvim_buf_is_valid(buf)
        and vim.b[buf].nvim_dir ~= nil
        and not vim.bo[buf].modified
        and vim.fn.isdirectory(api.nvim_buf_get_name(buf)) == 1
    then
        api.nvim_buf_call(buf, function()
            vim.cmd.edit()
        end)
        return true
    end
    return false
end

-- Job callbacks run on the main loop, so they write to the buffer directly.
---@param cmds string[]
---@param dir string
---@param listing integer
---@param async boolean stream output live (&) instead of showing it on exit (!)
local function start(cmds, dir, listing, async)
    local header = vim.tbl_map(function(cmd)
        return '$ ' .. cmd
    end, cmds)
    write_output(async and header or vim.list_extend(vim.list_slice(header), { '', '[running... <C-c> to stop]' }))

    local handle = {}
    -- !: the whole output of each stream. &: the unfinished last line of each,
    -- as a handler may get a line in pieces (:h channel-lines).
    local output = { stdout = {}, stderr = {} }
    local partial = { stdout = '', stderr = '' }
    ---@param data string[]
    ---@param stream 'stdout'|'stderr'
    local function on_data(_, data, stream)
        if not async then
            output[stream] = data
        elseif output_state.job_id == handle.id then -- not taken over by a newer command
            data[1] = partial[stream] .. data[1]
            partial[stream] = table.remove(data)
            if #data > 0 then
                write_output(data, true)
            end
        end
    end

    local jid = vim.fn.jobstart(table.concat(cmds, '\n'), {
        cwd = dir,
        stdout_buffered = not async,
        stderr_buffered = not async,
        on_stdout = on_data,
        on_stderr = on_data,
        on_exit = function(_, code)
            if output_state.job_id ~= handle.id then
                return
            end
            local footer = output_state.terminated and '-- terminated --' or string.format('-- exit: %d --', code)
            output_state.job_id, output_state.terminated = nil, false
            if async then
                local rest = vim.tbl_filter(function(line)
                    return line ~= ''
                end, { partial.stdout, partial.stderr })
                write_output(vim.list_extend(rest, { footer }), true)
            else
                local lines = vim.list_extend(vim.list_slice(header), { '' })
                for _, data in ipairs({ output.stdout, output.stderr }) do
                    -- Drop the "" after the final newline.
                    vim.list_extend(lines, data, 1, data[#data] == '' and #data - 1 or #data)
                end
                write_output(vim.list_extend(lines, { '', footer }))
            end
            reload_listing(listing)
        end,
    })
    if jid <= 0 then
        notify(jid == 0 and 'invalid arguments to jobstart' or 'shell is not executable', vim.log.levels.ERROR)
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
        notify('no entry under cursor', vim.log.levels.WARN)
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

---------------------------------------------------------------------------
-- Editing (oil-style): :w turns the edited listings into file operations
---------------------------------------------------------------------------

-- A typed name is relative to the listing, unless absolute or ~/. Only ~/ is
-- expanded: ~foo and $VAR are taken as written, as they are valid file names.
---@param dir string
---@param input string
local function resolve(dir, input)
    local path = vim.fs.abspath(input, { cwd = dir, plain = not vim.startswith(input, '~/') })
    return vim.fs.normalize(path, { expand_env = false })
end

-- Same inode, e.g. foo and Foo on a case-insensitive filesystem.
---@param a string
---@param b string
local function same_file(a, b)
    local sa, sb = uv.fs_lstat(a), uv.fs_lstat(b)
    return sa ~= nil and sb ~= nil and sa.ino == sb.ino and sa.dev == sb.dev
end

-- Re-list every listing of one of dirs. Listing names end in /, dirs (from
-- vim.fs.dirname) don't.
---@param dirs table<string, true>
local function refresh(dirs)
    for _, buf in ipairs(api.nvim_list_bufs()) do
        if dirs[vim.fs.normalize(api.nvim_buf_get_name(buf), { expand_env = false })] then
            reload_listing(buf)
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
                local stale = vim.iter(api.nvim_list_bufs()):find(function(b)
                    return api.nvim_buf_get_name(b) == name
                end)
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

-- The file operations below raise on failure; write_listings catches it.

-- Move paths to the Trash, or delete them where there is no trash command.
---@param paths string[]
local function trash(paths)
    if #paths == 0 then
        return
    end
    if vim.fn.executable('trash') == 0 then
        for _, path in ipairs(paths) do
            vim.fs.rm(path, { recursive = true })
        end
        return
    end
    local res = vim.system(vim.list_extend({ 'trash' }, paths), { text = true }):wait()
    if res.code ~= 0 then
        error(vim.trim(res.stderr ~= '' and res.stderr or res.stdout), 0)
    end
end

---@param src string
---@param dst string
local function copy(src, dst)
    vim.fs.mkdir(vim.fs.dirname(dst), { parents = true })
    local res = vim.system({ 'cp', '-R', src, dst }, { text = true }):wait()
    if res.code ~= 0 then
        error(vim.trim(res.stderr), 0)
    end
end

---@param src string
---@param dst string
local function move(src, dst)
    vim.fs.mkdir(vim.fs.dirname(dst), { parents = true })
    local ok, err, code = uv.fs_rename(src, dst)
    if not ok then
        if code ~= 'EXDEV' then
            error(err, 0)
        end
        -- Across filesystems: copy, then remove the source (the copy is the backup).
        copy(src, dst)
        vim.fs.rm(src, { recursive = true })
    end
    rename_buffers(src, dst)
end

---@param path string
---@param is_dir boolean
local function create(path, is_dir)
    if is_dir then
        vim.fs.mkdir(path, { parents = true })
    else
        vim.fs.mkdir(vim.fs.dirname(path), { parents = true })
        -- wx: fail rather than truncate a file created since the check.
        uv.fs_close(assert(uv.fs_open(path, 'wx', tonumber('644', 8))))
    end
end

-- Name typed on a line, and whether it asks for a directory (trailing /).
---@param line string
---@return string name
---@return boolean is_dir
local function parse_line(line)
    local name = vim.trim(line)
    local is_dir = name:sub(-1) == '/'
    return (name:gsub('/+$', ''):gsub('%z', '\n')), is_dir
end

-- notes.txt -> notes_copy_1.txt, src/ -> src_copy_1/, with the first N that is free
-- on disk and not in taken. Copying a copy counts on: notes_copy_1.txt ->
-- notes_copy_2.txt.
---@param dir string
---@param line string
---@param taken table<string, integer> entry names in use
---@return string line
local function copy_name(dir, line, taken)
    local slash = line:match('/$') or ''
    local name = line:sub(1, #line - #slash)
    local stem, ext = name, ''
    if slash == '' then
        -- The last extension only (a.tar.gz -> a.tar_copy_1.gz); a dotfile has none.
        -- Decoded for vim.fs.ext (a NUL can't cross into Vimscript); \n and \0 are
        -- both one byte, so its length still slices the line.
        local len = #vim.fs.ext((name:gsub('%z', '\n')))
        if len > 0 then
            stem, ext = name:sub(1, -len - 2), name:sub(-len - 1)
        end
    end
    stem = stem:gsub('_copy_%d+$', '')
    local n = 1
    while true do
        local candidate = string.format('%s_copy_%d%s', stem, n, ext)
        if not taken[entry_name(candidate)] and not uv.fs_lstat(line_path(dir, candidate)) then
            return candidate .. slash
        end
        n = n + 1
    end
end

-- Lines last yanked or deleted from a listing, per register, with the path each
-- stands for, so a put copies (or, after dd, moves) the entry.
---@type table<string, { lines: string[], paths: table<string, string> }>
local yanks = {}

-- Path of the entry or copy on each row of a listing, by row (0-based).
---@param buf integer
---@param first integer
---@param last integer
---@return table<integer, string>
local function row_paths(buf, first, last)
    local listing = listings[buf]
    local dir = api.nvim_buf_get_name(buf)
    local paths = {}
    for row, ids in pairs(mark_rows(buf, ns_entries)) do
        if row >= first and row <= last and #ids == 1 then
            paths[row] = line_path(dir, listing.lines[ids[1]])
        end
    end
    for row, ids in pairs(mark_rows(buf, ns_copies)) do
        if row >= first and row <= last and #ids == 1 then
            -- A row with both marks (joined lines) stands for neither.
            paths[row] = not paths[row] and listing.copies[ids[1]] or nil
        end
    end
    return paths
end

-- TextYankPost fires before dd removes the lines, so their marks still say
-- which entries they are.
---@param buf integer
local function remember_yank(buf)
    local event = vim.v.event
    local reg = event.regname == '' and '"' or event.regname
    if event.regtype ~= 'V' then
        return
    end
    local first = api.nvim_buf_get_mark(buf, '[')[1] - 1
    local last = api.nvim_buf_get_mark(buf, ']')[1] - 1
    local lines = api.nvim_buf_get_lines(buf, first, last + 1, false)
    local paths = {}
    for row, path in pairs(row_paths(buf, first, last)) do
        paths[lines[row - first + 1]] = path
    end
    local yank = next(paths) and { lines = event.regcontents, paths = paths } or nil
    yanks[reg] = yank
    if event.regname == '' then
        -- Vim also puts an unnamed yank in "0 and a deleted line in "1, so "0p after
        -- a dd still puts the yank.
        yanks[event.operator == 'y' and '0' or '1'] = yank
    end
end

-- Path that line stands for when it was put from a listing's yank that is still
-- in its register. Only the text is known, so when registers hold the same text
-- for different entries, the unnamed one wins (sorts first).
---@param line string
---@return string?
local function yanked_path(line)
    local regs = vim.tbl_keys(yanks)
    table.sort(regs)
    for _, reg in ipairs(regs) do
        local yank = yanks[reg]
        if
            yank.paths[line]
            and vim.fn.getregtype(reg) == 'V'
            and vim.deep_equal(vim.fn.getreg(reg, 1, true), yank.lines)
        then
            return yank.paths[line]
        end
    end
end

-- A put line from a live yank (yy/dd, in this listing or another) becomes a copy
-- of the entry it stands for, which :w turns into a move when the entry's own line
-- is gone. It keeps its name unless another line has it, or a file has it that
-- stays (its line wasn't deleted here); then it gets copy_name. Runs after each
-- change, so the buffer always shows the names :w will create.
---@param buf integer
local function mark_copies(buf)
    local listing = listings[buf]
    if not listing or not vim.bo[buf].modifiable then
        return
    end
    local dir = api.nvim_buf_get_name(buf)
    local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
    local entries, copies = mark_rows(buf, ns_entries), mark_rows(buf, ns_copies)
    -- taken: how many lines use each name. deleted: names whose entry line is gone.
    local taken, present, deleted = {}, {}, {}
    for _, line in ipairs(lines) do
        local name = entry_name(line)
        taken[name] = (taken[name] or 0) + 1
    end
    for _, ids in pairs(entries) do
        for _, id in ipairs(ids) do
            present[id] = true
        end
    end
    for id, line in ipairs(listing.lines) do
        if line ~= '' and not present[id] then
            deleted[entry_name(line)] = true
        end
    end

    local joined = false
    for i, line in ipairs(lines) do
        local src = line ~= '' and not entries[i - 1] and not copies[i - 1] and yanked_path(line)
        if src then
            local name = entry_name(line)
            if taken[name] > 1 or (not deleted[name] and uv.fs_lstat(line_path(dir, line))) then
                taken[name] = taken[name] - 1
                line = copy_name(dir, line, taken)
                taken[entry_name(line)] = 1
                -- One u takes back the put and the rename. Not allowed right after an
                -- undo, where the rename becomes its own step.
                if not joined then
                    joined = pcall(vim.cmd.undojoin)
                end
                api.nvim_buf_set_lines(buf, i - 1, i, false, { line })
            end
            local id = api.nvim_buf_set_extmark(buf, ns_copies, i - 1, 0, { invalidate = true })
            listing.copies[id] = src
        end
    end
end

---@class dirx.Plan
---@field copies { src: string, dst: string }[]
---@field deletes string[]
---@field moves { src: string, dst: string }[]
---@field creates { path: string, dir: boolean }[]

-- Add the changes of one listing against its last render to plan.
---@param buf integer
---@param plan dirx.Plan
---@param errors string[]
local function collect(buf, plan, errors)
    local dir = api.nvim_buf_get_name(buf)
    local listing = listings[buf]
    local orig = listing.lines
    local rows, copy_rows = mark_rows(buf, ns_entries), mark_rows(buf, ns_copies)
    local kept = {}

    for i, line in ipairs(api.nvim_buf_get_lines(buf, 0, -1, false)) do
        local ids, copy_ids = rows[i - 1], copy_rows[i - 1]
        local name, is_dir = parse_line(line)
        local count = (ids and #ids or 0) + (copy_ids and #copy_ids or 0)
        if count > 1 then
            table.insert(errors, string.format('%s line %d holds %d entries (joined lines?)', dir, i, count))
        elseif copy_ids then
            -- A copy whose name was blanked is dropped.
            if name ~= '' then
                table.insert(plan.copies, { src = listing.copies[copy_ids[1]], dst = resolve(dir, name) })
            end
        elseif ids then
            local id = ids[1]
            kept[id] = true
            local src = line_path(dir, orig[id])
            if name == '' then
                table.insert(plan.deletes, src)
            elseif line ~= orig[id] then
                local dst = resolve(dir, name)
                if dst ~= src then
                    table.insert(plan.moves, { src = src, dst = dst })
                end
            end
        elseif name ~= '' then
            table.insert(plan.creates, { path = resolve(dir, name), dir = is_dir })
        end
    end
    for id, line in ipairs(orig) do
        if line ~= '' and not kept[id] then
            table.insert(plan.deletes, line_path(dir, line))
        end
    end
end

-- One plan for the edits of all of bufs, so moves between listings, and edits
-- inside a directory that another listing renames or deletes, are checked and
-- applied together. Paths are as they are before the write.
---@param bufs integer[]
---@return dirx.Plan? plan
---@return string[] errors
local function build_plan(bufs)
    local plan = { copies = {}, deletes = {}, moves = {}, creates = {} } ---@type dirx.Plan
    local errors = {}
    for _, buf in ipairs(bufs) do
        collect(buf, plan, errors)
    end

    local deleted = {}
    for _, path in ipairs(plan.deletes) do
        deleted[path] = true
    end
    -- A line cut and put back elsewhere in its listing (dd, p) reads as delete +
    -- create of the same name: it means nothing changed.
    plan.creates = vim.tbl_filter(function(c)
        if deleted[c.path] then
            deleted[c.path] = nil
            return false
        end
        return true
    end, plan.creates)
    -- A copy of an entry whose line was deleted (dd, then p here or in another
    -- listing) is a move: no change when put back under its own name. Further
    -- copies of it still copy, before the move.
    plan.copies = vim.tbl_filter(function(c)
        if deleted[c.src] and c.dst == c.src then
            deleted[c.src] = nil
            return false
        end
        return true
    end, plan.copies)
    plan.copies = vim.tbl_filter(function(c)
        if deleted[c.src] then
            deleted[c.src] = nil
            table.insert(plan.moves, { src = c.src, dst = c.dst })
            return false
        end
        return true
    end, plan.copies)
    plan.deletes = vim.tbl_filter(function(path)
        return deleted[path] ~= nil
    end, plan.deletes)

    -- Each target must be free once deletes and moves have run.
    local freed, taken = {}, {}
    for _, path in ipairs(plan.deletes) do
        freed[path] = true
    end
    for _, m in ipairs(plan.moves) do
        freed[m.src] = true
    end
    ---@param path string
    ---@param may_exist boolean
    local function claim(path, may_exist)
        if taken[path] then
            table.insert(errors, path .. ' is named twice')
        elseif uv.fs_lstat(path) and not may_exist then
            table.insert(errors, path .. ' already exists')
        end
        for _, d in ipairs(plan.deletes) do
            if vim.startswith(path, d .. '/') then
                table.insert(errors, string.format('%s goes into %s, which is deleted', path, d))
            end
        end
        taken[path] = true
    end
    -- Copies run first, so their targets must be free, or deleted in this write (a
    -- put replacing an entry; apply trashes it just before).
    for _, c in ipairs(plan.copies) do
        if not uv.fs_lstat(c.src) then
            table.insert(errors, c.src .. ' no longer exists')
        elseif vim.startswith(c.dst, c.src .. '/') then
            table.insert(errors, string.format('cannot copy %s into itself', c.src))
        end
        claim(c.dst, vim.list_contains(plan.deletes, c.dst))
    end
    for _, m in ipairs(plan.moves) do
        if vim.startswith(m.dst, m.src .. '/') then
            table.insert(errors, string.format('cannot move %s into itself', m.src))
        end
        claim(m.dst, freed[m.dst] or same_file(m.src, m.dst))
    end
    for _, c in ipairs(plan.creates) do
        claim(c.path, freed[c.path] or false)
    end
    if #errors > 0 then
        return nil, errors
    end
    return plan, errors
end

-- path, or what it becomes once from is moved to to.
---@param path string
---@param from string
---@param to string
local function rebase(path, from, to)
    if vim.startswith(path, from .. '/') then
        return to .. path:sub(#from + 1)
    end
    return path
end

-- Copies first (this write may move or delete their source), then deletes (they
-- may free a target), moves, deletes of directories that moves empty first, and
-- creates. Every move rebases the paths still pending under it, so an edit inside
-- a renamed directory lands in its new place. Stops at the first error; whatever
-- ran shows up in the reloaded listings.
---@param plan dirx.Plan
---@param dirs table<string, true> receives the directories that changed
local function apply(plan, dirs)
    local function touched(...)
        for _, path in ipairs({ ... }) do
            dirs[vim.fs.dirname(path)] = true
        end
    end

    local replaced = {}
    for _, c in ipairs(plan.copies) do
        touched(c.dst)
        if vim.list_contains(plan.deletes, c.dst) then
            trash({ c.dst })
            replaced[c.dst] = true
        end
        copy(c.src, c.dst)
    end

    local pending, creates = vim.deepcopy(plan.moves), vim.deepcopy(plan.creates)
    local now, later = {}, {}
    for _, path in ipairs(vim.tbl_filter(function(path)
        return not replaced[path]
    end, plan.deletes)) do
        touched(path)
        local holds_source = vim.iter(pending):any(function(m)
            return vim.startswith(m.src, path .. '/')
        end)
        table.insert(holds_source and later or now, path)
    end
    trash(now)

    ---@param src string
    ---@param dst string
    local function move_rebasing(src, dst)
        touched(src, dst)
        move(src, dst)
        for _, m in ipairs(pending) do
            m.src, m.dst = rebase(m.src, src, dst), rebase(m.dst, src, dst)
        end
        for i, path in ipairs(later) do
            later[i] = rebase(path, src, dst)
        end
        for _, c in ipairs(creates) do
            c.path = rebase(c.path, src, dst)
        end
    end
    while #pending > 0 do
        local ready
        for i, m in ipairs(pending) do
            if not uv.fs_lstat(m.dst) or same_file(m.src, m.dst) then
                ready = i
                break
            end
        end
        if ready then
            local m = table.remove(pending, ready)
            move_rebasing(m.src, m.dst)
        else
            -- Every target is held by another pending source (a -> b, b -> a): park
            -- one source under a temporary name to break the cycle.
            local m = pending[1]
            if m.parked then
                error(m.dst .. ' already exists', 0)
            end
            local tmp = string.format('%s.dirx-%d', m.src, uv.hrtime())
            move_rebasing(m.src, tmp)
            -- Not by the rebase, which leaves y -> x pointing at the freed x.
            m.src, m.parked = tmp, true
        end
    end

    trash(later)
    for _, c in ipairs(creates) do
        touched(c.path)
        create(c.path, c.dir)
    end
end

-- Deepest directory that holds all of paths.
---@param paths string[]
local function common_dir(paths)
    local root = paths[1]
    for _, path in ipairs(paths) do
        while root ~= '/' and path ~= root and not vim.startswith(path, root .. '/') do
            root = vim.fs.dirname(root)
        end
    end
    return root
end

-- :w in any listing applies the edits of every listing with unsaved ones, after
-- one confirm.
---@param buf integer
local function write_listings(buf)
    local bufs = vim.tbl_filter(function(b)
        return listings[b] ~= nil and vim.b[b].nvim_dir ~= nil and (b == buf or vim.bo[b].modified)
    end, api.nvim_list_bufs())
    if #bufs == 0 then
        return
    end
    local plan, errors = build_plan(bufs)
    if not plan then
        notify('not applied:\n' .. table.concat(errors, '\n'), vim.log.levels.ERROR)
        return
    end

    local paths = vim.tbl_map(function(b)
        return vim.fs.normalize(api.nvim_buf_get_name(b), { expand_env = false })
    end, bufs)
    for _, c in ipairs(vim.list_extend(vim.list_slice(plan.copies), plan.moves)) do
        vim.list_extend(paths, { vim.fs.dirname(c.src), vim.fs.dirname(c.dst) })
    end
    for _, c in ipairs(plan.creates) do
        table.insert(paths, vim.fs.dirname(c.path))
    end
    local root = common_dir(paths)
    -- Not vim.fs.relpath, which would expand a $VAR or ~ in a name.
    ---@param path string
    local function display(path)
        return vim.startswith(path, root .. '/') and path:sub(#root + 2) or vim.fn.fnamemodify(path, ':~')
    end
    local summary = {}
    for _, c in ipairs(plan.copies) do
        table.insert(summary, string.format('  copy    %s -> %s', display(c.src), display(c.dst)))
    end
    for _, path in ipairs(plan.deletes) do
        table.insert(summary, '  delete  ' .. display(path))
    end
    for _, m in ipairs(plan.moves) do
        table.insert(summary, string.format('  move    %s -> %s', display(m.src), display(m.dst)))
    end
    for _, c in ipairs(plan.creates) do
        table.insert(summary, '  create  ' .. display(c.path) .. (c.dir and '/' or ''))
    end
    if #summary > 0 then
        -- Enter confirms, unless something is being deleted.
        local choice = vim.fn.confirm(
            string.format('Apply changes in %s?\n%s', vim.fn.fnamemodify(root, ':~'), table.concat(summary, '\n')),
            '&Yes\n&No',
            #plan.deletes > 0 and 2 or 1
        )
        if choice ~= 1 then
            return
        end
    end

    local dirs = {}
    local ok, err = pcall(apply, plan, dirs)
    if not ok then
        notify(tostring(err), vim.log.levels.ERROR)
    end
    -- Re-list even after an error so the listings show what did happen. By buffer,
    -- as a written listing may have been renamed along with its directory. The
    -- listing of a deleted directory goes too, unless a window shows it.
    for _, b in ipairs(bufs) do
        if api.nvim_buf_is_valid(b) then
            vim.bo[b].modified = false
            if not reload_listing(b) and #vim.fn.win_findbuf(b) == 0 then
                api.nvim_buf_delete(b, { force = true })
            end
        end
    end
    refresh(dirs)
end

local function reload()
    if vim.bo.modified and vim.fn.confirm('Discard changes to the listing?', '&Yes\n&No', 2) ~= 1 then
        return
    end
    nvim_dir._reload()
end

---------------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------------

-- dir.lua maps a and o (open in a split) only when nothing maps to their <Plug>s
-- yet. Claim those from <Plug> keys nobody can type, so a and o stay append and
-- open line in the editable listing.
vim.keymap.set('n', '<Plug>(dirx-vsplit)', '<Plug>(nvim-dir-vsplit)')
vim.keymap.set('n', '<Plug>(dirx-split)', '<Plug>(nvim-dir-split)')

api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'directory',
    desc = 'dirx: listing keymaps and :w',
    callback = function(args)
        local buf = args.buf
        local function bmap(modes, lhs, rhs, desc)
            vim.keymap.set(modes, lhs, rhs, { buffer = buf, silent = true, desc = desc })
        end
        bmap({ 'n', 'x' }, '!', function()
            run(false)
        end, 'Run shell command on entry (output on exit)')
        bmap({ 'n', 'x' }, '&', function()
            run(true)
        end, 'Run shell command on entry (output streams)')
        bmap('n', '<C-c>', function()
            if not stop_job() then
                notify('no command is running')
            end
        end, 'Stop running shell command')
        -- Replaces dir.lua's R, which would drop unsaved edits without asking.
        bmap('n', 'R', reload, 'Reload listing (asks before dropping edits)')

        api.nvim_clear_autocmds({ group = group, buffer = buf })
        -- nested: the reload after applying goes through the listing's BufReadCmd.
        api.nvim_create_autocmd('BufWriteCmd', {
            group = group,
            buffer = buf,
            nested = true,
            desc = 'dirx: apply the edits of all listings',
            callback = function()
                write_listings(buf)
            end,
        })
        api.nvim_create_autocmd('TextYankPost', {
            group = group,
            buffer = buf,
            desc = 'dirx: remember yanked entries for a put in another listing',
            callback = function()
                remember_yank(buf)
            end,
        })
        api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
            group = group,
            buffer = buf,
            desc = 'dirx: name put copies',
            callback = function()
                mark_copies(buf)
            end,
        })
        api.nvim_create_autocmd('BufWipeout', {
            group = group,
            buffer = buf,
            desc = 'dirx: forget listing',
            callback = function()
                listings[buf] = nil
            end,
        })
        -- gq, not q, so q still records macros in the listing.
        bmap('n', 'gq', close_output, 'Close shell command output window')
    end,
})
