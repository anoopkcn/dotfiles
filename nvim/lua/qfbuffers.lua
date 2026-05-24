-- Populate the quickfix list with listed buffers (like :ls), open :copen,
-- and let the default quickfix mappings jump to the chosen buffer on <CR>.
-- Each entry uses bufnr so unnamed/scratch buffers also work.

local M = {}

local function buffer_items()
    local cur = vim.api.nvim_get_current_buf()
    local items = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted then
            local name = vim.api.nvim_buf_get_name(buf)
            -- " mark: cursor position when buffer was last unloaded; (0,0) for fresh buffers.
            local mark = vim.api.nvim_buf_get_mark(buf, '"')
            local lnum = mark[1] > 0 and mark[1] or 1
            local col = mark[2]
            local display = name ~= ''
                and vim.fn.fnamemodify(name, ':~:.')
                or ('[No Name #' .. buf .. ']')
            local flag = (buf == cur and '%' or ' ')
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

function M.open()
    local items = buffer_items()
    if #items == 0 then
        vim.notify('qfbuffers: no listed buffers', vim.log.levels.INFO)
        return
    end
    vim.fn.setqflist({}, ' ', { title = 'qfbuffers', items = items })
    vim.cmd('botright copen')
end

return M
