-- Per-cwd session manager. Saves and restores window layout, buffers,
-- and tabs for each working directory. Files live in stdpath("state")/sessions/.
--   <leader>qs  load session for current cwd
--   <leader>ql  load most recently saved session (any cwd)
--   <leader>qS  pick a saved session via vim.ui.select
--   <leader>qd  skip saving on next exit (one-shot)
-- Auto-restore fires on VimEnter when nvim is launched with no file args.

vim.opt.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

local session_dir = vim.fn.stdpath("state") .. "/sessions/"
if vim.fn.isdirectory(session_dir) == 0 then
    vim.fn.mkdir(session_dir, "p")
end

local function get_session_file()
    local cwd = vim.fn.getcwd()
    local session_name = cwd:gsub("/", "%%")
    return session_dir .. session_name .. ".vim"
end

local function get_last_session_file()
    return session_dir .. "last_session.vim"
end

-- Loading a session while LSP clients are attached races ui2: detach fires
-- diagnostic.reset → redraw, and ui2 tries to (re)open its float while a
-- buffer is mid-close → E1159. Stop clients first, defer source one tick.
local function load_session_file(session_file)
    for _, client in ipairs(vim.lsp.get_clients()) do
        vim.lsp.stop_client(client.id, true)
    end
    vim.schedule(function()
        vim.cmd("source " .. vim.fn.fnameescape(session_file))
    end)
end

-- mksession chokes on plugin floats. Close them before restore, but leave
-- ui2's own windows alone so the UI keeps working mid-restore.
local ui2_ft = { cmd = true, msg = true, pager = true, dialog = true }
vim.api.nvim_create_autocmd("SessionLoadPre", {
    group = vim.api.nvim_create_augroup("sessions_pre", { clear = true }),
    callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_config(win).relative ~= "" then
                local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
                if not ui2_ft[ft] then
                    pcall(vim.api.nvim_win_close, win, true)
                end
            end
        end
    end,
})

vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("sessions_enter", { clear = true }),
    callback = function()
        if vim.fn.argc() == 0 then
            local session_file = get_session_file()
            if vim.fn.filereadable(session_file) == 1 then
                -- Workaround for mksession layout-squash when current win is wider/taller than saved.
                vim.cmd("silent! set winminwidth=1 winwidth=1 winminheight=1 winheight=1")
                vim.cmd("source " .. vim.fn.fnameescape(session_file))
            end
        end
    end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("sessions_leave", { clear = true }),
    callback = function()
        local stop_file = session_dir .. ".stop_saving"
        if vim.fn.filereadable(stop_file) == 1 then
            vim.fn.delete(stop_file)
            return
        end

        local buf_count = 0
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= "" then
                buf_count = buf_count + 1
            end
        end

        if buf_count >= 1 then
            local session_file = get_session_file()
            vim.cmd("mksession! " .. vim.fn.fnameescape(session_file))
            vim.cmd("mksession! " .. vim.fn.fnameescape(get_last_session_file()))
        end
    end,
})

local map = vim.keymap.set

map("n", "<leader>qs", function()
    local session_file = get_session_file()
    if vim.fn.filereadable(session_file) == 1 then
        load_session_file(session_file)
    else
        print("No session found for current directory")
    end
end, { desc = "Load session for current directory" })

map("n", "<leader>ql", function()
    local last_session = get_last_session_file()
    if vim.fn.filereadable(last_session) == 1 then
        load_session_file(last_session)
    else
        print("No last session found")
    end
end, { desc = "Load last session" })

map("n", "<leader>qS", function()
    local sessions = {}
    local session_files = vim.fn.glob(session_dir .. "*.vim", false, true)

    for _, file in ipairs(session_files) do
        local name = vim.fn.fnamemodify(file, ":t:r")
        name = name:gsub("%%", "/")
        table.insert(sessions, name)
    end

    if #sessions == 0 then
        print("No sessions found")
        return
    end

    vim.ui.select(sessions, {
        prompt = "Select session to load:",
    }, function(choice)
        if choice then
            load_session_file(session_dir .. choice:gsub("/", "%%") .. ".vim")
        end
    end)
end, { desc = "Select session to load" })

map("n", "<leader>qd", function()
    local stop_file = session_dir .. ".stop_saving"
    vim.fn.writefile({}, stop_file)
    print("Session saving stopped")
end, { desc = "Stop session saving" })

return {}
