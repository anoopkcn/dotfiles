-- Populate the quickfix list with listed buffers (like :ls), open :copen,
-- and let the default quickfix mappings jump to the chosen buffer on <CR>.
-- Each entry uses bufnr so unnamed/scratch buffers also work.

local M = {}

local function buffer_items()
    local cur = vim.api.nvim_get_current_buf()
    local alt = vim.fn.bufnr('#')
    local items = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        -- The quickfix window's own buffer is buflisted; keep it out of the list.
        if vim.bo[buf].buflisted and vim.bo[buf].buftype ~= 'quickfix' then
            local name = vim.api.nvim_buf_get_name(buf)
            -- " mark: cursor position when buffer was last unloaded; (0,0) for fresh buffers.
            local mark = vim.api.nvim_buf_get_mark(buf, '"')
            local lnum = mark[1] > 0 and mark[1] or 1
            local col = mark[2]
            local display = name ~= ''
                and vim.fn.fnamemodify(name, ':~:.')
                or ('[No Name #' .. buf .. ']')
            local flag = (buf == cur and '%' or buf == alt and '^' or ' ')
                .. (vim.bo[buf].modified and '+' or ' ')
            items[#items + 1] = {
                bufnr = buf,
                lnum  = lnum,
                col   = col + 1,
                text  = flag .. ' ' .. display,
            }
        end
    end
    return items
end

-- Render each line as just our text field instead of the default
-- "file|lnum col col| text", which duplicates the buffer name.
local function qf_text(info)
    local qf_items = vim.fn.getqflist({ id = info.id, items = 0 }).items
    local lines = {}
    for i = info.start_idx, info.end_idx do
        lines[#lines + 1] = qf_items[i].text
    end
    return lines
end

local function set_list(items, action)
    vim.fn.setqflist({}, action, {
        title = 'qfbuffers',
        items = items,
        quickfixtextfunc = qf_text,
    })
end

-- Wipe the buffer on the current quickfix line and rebuild the list in place.
local function delete_under_cursor()
    if vim.fn.getqflist({ title = 0 }).title ~= 'qfbuffers' then
        return
    end
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    local qf_items = vim.fn.getqflist()
    local item = qf_items[lnum]
    if not item or item.bufnr == 0 or not vim.api.nvim_buf_is_valid(item.bufnr) then
        return
    end
    if vim.bo[item.bufnr].modified then
        vim.notify('qfbuffers: buffer has unsaved changes (use :bd! to force)', vim.log.levels.WARN)
        return
    end
    -- Deleting a buffer that is displayed in a window spawns a fresh [No Name]
    -- placeholder; switch those windows to the next listed buffer first.
    local fallback
    for offset = 1, #qf_items - 1 do
        local cand = qf_items[(lnum - 1 + offset) % #qf_items + 1].bufnr
        if cand ~= item.bufnr and vim.api.nvim_buf_is_valid(cand) then
            fallback = cand
            break
        end
    end
    if fallback then
        for _, win in ipairs(vim.fn.win_findbuf(item.bufnr)) do
            vim.api.nvim_win_set_buf(win, fallback)
        end
    end
    vim.api.nvim_buf_delete(item.bufnr, {})
    local items = buffer_items()
    if #items == 0 then
        vim.cmd('cclose')
        return
    end
    set_list(items, 'r')
    vim.api.nvim_win_set_cursor(0, { math.min(lnum, #items), 0 })
end

function M.open()
    local items = buffer_items()
    if #items == 0 then
        vim.notify('qfbuffers: no listed buffers', vim.log.levels.INFO)
        return
    end
    set_list(items, ' ')
    vim.cmd('botright copen')
    vim.keymap.set('n', 'dd', delete_under_cursor,
        { buffer = true, desc = 'qfbuffers: delete buffer under cursor' })
    vim.keymap.set('n', 'gq', '<Cmd>cclose<CR>',
        { buffer = true, desc = 'qfbuffers: close window' })
end

return M
