local M = {}

local state = {
    bufnr = nil,
}

local function chomp(str)
    local s = str or ""
    local without_cr = s:gsub("\r$", "")
    return without_cr
end

local function echoerr(msg)
    vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
end

local function close_list_windows()
    for _, win in ipairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 then
            pcall(vim.api.nvim_win_close, win.winid, false)
        end
    end
end

local function get_effectual_lines(qf)
    local effectual = {}
    for _, entry in ipairs(qf or {}) do
        if entry.bufnr and entry.bufnr ~= 0 then
            table.insert(effectual, entry)
        end
    end
    return effectual
end

local function populate_buffer(bufnr, qflist)
    vim.b[bufnr].csubstitute_orig_qflist = qflist
    local lines = {}
    for _, entry in ipairs(get_effectual_lines(qflist)) do
        table.insert(lines, chomp(entry.text))
    end
    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.bo[bufnr].modified = false
end

local function do_replace(bufnr)
    local qf_orig = vim.b[bufnr].csubstitute_orig_qflist or {}
    local qf = get_effectual_lines(qf_orig)
    local new_text_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    if #new_text_lines ~= #qf then
        echoerr(string.format("csubstitute: Illegal edit: line number was changed from %d to %d.", #qf, #new_text_lines))
        return
    end

    vim.bo[bufnr].modified = false

    local after_cmd
    if vim.o.hidden and (vim.g.csubstitute_no_save or 0) ~= 0 then
        after_cmd = "if &modified | setlocal buflisted | endif"
    else
        after_cmd = "update" .. (vim.v.cmdbang == 1 and "!" or "")
    end

    local prev_bufnr = -1
    local qf_bufnr = bufnr

    for i, entry in ipairs(qf) do
        local new_text = new_text_lines[i]
        if entry.text == new_text then
            goto continue
        end

        if prev_bufnr ~= entry.bufnr then
            if prev_bufnr ~= -1 then
                vim.cmd(after_cmd)
            end
            vim.cmd(string.format("%dbuffer", entry.bufnr))
        end

        local current_line = (vim.api.nvim_buf_get_lines(entry.bufnr, entry.lnum - 1, entry.lnum, false)[1]) or ""
        local original_text = chomp(entry.text)
        if current_line ~= original_text then
            if current_line ~= new_text then
                echoerr(string.format("csubstitute: Original text has changed: %s:%d", vim.fn.bufname(entry.bufnr), entry.lnum))
            end
        else
            vim.api.nvim_buf_set_lines(entry.bufnr, entry.lnum - 1, entry.lnum, false, { new_text })
            entry.text = new_text
        end

        prev_bufnr = entry.bufnr
        ::continue::
    end

    vim.cmd(after_cmd)
    vim.cmd(string.format("%dbuffer", qf_bufnr))
    vim.fn.setqflist(qf_orig, "r")
end

local function open_replace_window(cmd, close_lists)
    local open_cmd = (cmd and cmd ~= "") and cmd or "split"
    local bufnr = state.bufnr
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        local wins = vim.fn.win_findbuf(bufnr)
        if wins[1] then
            vim.api.nvim_set_current_win(wins[1])
        else
            vim.cmd(open_cmd)
            vim.api.nvim_set_current_buf(bufnr)
        end
    else
        vim.cmd(open_cmd)
        vim.cmd("enew")
        bufnr = vim.api.nvim_get_current_buf()
        state.bufnr = bufnr
        vim.bo[bufnr].swapfile = false
        vim.bo[bufnr].bufhidden = "hide"
        vim.bo[bufnr].buftype = "acwrite"
        vim.bo[bufnr].filetype = "csubstitute"
        vim.api.nvim_buf_set_name(bufnr, "[csubstitute]")
        vim.api.nvim_create_autocmd("BufWriteCmd", {
            buffer = bufnr,
            nested = true,
            callback = function()
                do_replace(bufnr)
            end,
        })
    end

    if close_lists then
        close_list_windows()
    end

    populate_buffer(bufnr, vim.fn.getqflist())
end

function M.start(cmd, close_lists)
    open_replace_window(cmd, close_lists)
end

function M.setup()
    vim.api.nvim_create_user_command("Csubstitute", function(opts)
        M.start(opts.args, opts.bang)
    end, { nargs = "?", bang = true })
end

return M
