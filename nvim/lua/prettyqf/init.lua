local M = {}

local config = {
    separator = "|",
    filename_max_width = 30,
    max_highlight_items = 1000,
}

function M.qfdraw(info)
    local items
    local ret = {}
    if info.quickfix == 1 then
        items = vim.fn.getqflist({ id = info.id, items = 0 }).items
    else
        items = vim.fn.getloclist(info.winid, { id = info.id, items = 0 }).items
    end

    local limit = config.filename_max_width
    local fname_fmt1 = "%-" .. limit .. "s"
    local fname_fmt2 = "...%." .. (limit - 3) .. "s"
    local valid_fmt = "%s " .. config.separator .. " %5d:%-3d " .. config.separator .. " %s"

    for i = info.start_idx, info.end_idx do
        local e = items[i]
        local fname = ""
        local str
        if e.valid == 1 then
            if e.bufnr > 0 then
                fname = vim.fn.bufname(e.bufnr)
                if fname == "" then fname = "[No Name]" end
                if #fname <= limit then
                    fname = string.format(fname_fmt1, fname)
                else
                    fname = string.format(fname_fmt2, fname:sub(1 - limit))
                end
            end
            -- IMPORTANT: We sanitize newlines here. The Highlighter must do the same.
            local text = e.text:gsub("[\r\n]", " ")
            str = string.format(valid_fmt, fname, e.lnum, e.col, text)
        else
            str = e.text
        end
        table.insert(ret, str)
    end
    return ret
end

function M.apply_ts_highlights(bufnr)
    local items = vim.fn.getqflist({ items = 0 }).items
    local ns = vim.api.nvim_create_namespace("prettyqf_ts")

    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    local count = 0
    for i, item in ipairs(items) do
        if count > config.max_highlight_items then break end

        if item.valid == 1 and item.bufnr > 0 then
            local ft = vim.fn.getbufvar(item.bufnr, "&filetype")
            if ft == "" then
                local fname = vim.fn.bufname(item.bufnr)
                ft = vim.filetype.match({ filename = fname })
            end

            if ft and ft ~= "" then
                local lang = vim.treesitter.language.get_lang(ft) or ft

                local has_parser = pcall(vim.treesitter.get_parser, 0, lang)

                if has_parser then
                    local lines = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)
                    if #lines > 0 then
                        local line_text = lines[1]

                        -- Find offset: After the second separator
                        local _, s_end = string.find(line_text,
                            config.separator .. "%s+%d+:%d+%s+" .. config.separator .. "%s")

                        if s_end then
                            pcall(function()
                                -- Sanitize text to match what is displayed
                                local msg_text = item.text:gsub("[\r\n]", " ")

                                local parser = vim.treesitter.get_string_parser(msg_text, lang)
                                local tree = parser:parse()[1]
                                local root = tree:root()
                                local query = vim.treesitter.query.get(lang, "highlights")

                                if query then
                                    for id, node, _ in query:iter_captures(root, msg_text, 0, -1) do
                                        local name = "@" .. query.captures[id]
                                        local hl_group = vim.api.nvim_get_hl_id_by_name(name)
                                        local r, c, _, end_c = node:range()

                                        -- Safety check: Ensure we don't paint past the line end
                                        if s_end + c < #line_text then
                                            vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, s_end + c, {
                                                end_col = math.min(s_end + end_c, #line_text),
                                                hl_group = hl_group,
                                                priority = 100,
                                            })
                                        end
                                    end
                                end
                            end)
                        end
                    end
                end
            end
            count = count + 1
        end
    end
end

function M.setup_syntax()
    vim.cmd([[syntax match QFFile /^[^|]*\ze\s*|/ nextgroup=QFSeparator]])
    vim.cmd([[syntax match QFSeparator /|/ contained nextgroup=QFLineInfo]])
    vim.cmd([[syntax match QFLineInfo /[^|]*\ze|/ contained nextgroup=QFSeparator]])
    vim.cmd([[
        highlight default link QFFile Directory
        highlight default link QFSeparator VertSplit
        highlight default link QFLineInfo Number
    ]])
end

function M.setup()
    vim.o.quickfixtextfunc = "v:lua.require'prettyqf'.qfdraw"

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        callback = function(args)
            M.setup_syntax()
            vim.schedule(function()
                M.apply_ts_highlights(args.buf)
            end)
        end,
    })
end

return M
