local M = {}

local config = {
    separator = "|",
    filename_max_width = 30,
    text_max_width = 80,
    max_highlight_items = 1000,
}

local highlight_cache = {
    lang_supported = {},
    lang_query = {},
}

local function truncate_text(text, max_width)
    if not max_width then
        return text
    end
    if max_width <= 0 then
        return text
    end
    local display_width = vim.fn.strdisplaywidth(text)
    if display_width <= max_width then
        return text
    end
    local limit = math.max(max_width - 3, 1)
    local truncated = vim.fn.strcharpart(text, 0, limit)
    return truncated .. "..."
end

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
    local fname_cache = {}

    for i = info.start_idx, info.end_idx do
        local e = items[i]
        local fname = ""
        local str
        if e.valid == 1 then
            if e.bufnr > 0 then
                fname = fname_cache[e.bufnr]
                if not fname then
                    local buf_name = vim.fn.bufname(e.bufnr)
                    if buf_name == "" then
                        buf_name = "[No Name]"
                    else
                        buf_name = vim.fn.fnamemodify(buf_name, ":.")
                    end
                    if #buf_name <= limit then
                        fname = string.format(fname_fmt1, buf_name)
                    else
                        fname = string.format(fname_fmt2, buf_name:sub(1 - limit))
                    end
                    fname_cache[e.bufnr] = fname
                end
            end
            local text = e.text:gsub("[\r\n]", " ")
            text = truncate_text(text, config.text_max_width)
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
    local ft_cache = {}
    local lang_cache = {}

    local count = 0
    for i, item in ipairs(items) do
        if count >= config.max_highlight_items then
            break
        end

        if item.valid == 1 and item.bufnr > 0 then
            local ft = ft_cache[item.bufnr]
            if ft == nil then
                ft = vim.fn.getbufvar(item.bufnr, "&filetype")
                if ft == "" then
                    local fname = vim.fn.bufname(item.bufnr)
                    ft = vim.filetype.match({ filename = fname })
                end
                ft_cache[item.bufnr] = ft ~= "" and ft or false
            end

            if ft and ft ~= false and ft ~= "" then
                local lang = lang_cache[ft]
                if not lang then
                    lang = vim.treesitter.language.get_lang(ft) or ft
                    lang_cache[ft] = lang
                end

                local supported = highlight_cache.lang_supported[lang]
                if supported == nil then
                    supported = pcall(vim.treesitter.get_parser, 0, lang)
                    highlight_cache.lang_supported[lang] = supported
                end

                if supported then
                    local query = highlight_cache.lang_query[lang]
                    if query == nil then
                        query = vim.treesitter.query.get(lang, "highlights")
                        highlight_cache.lang_query[lang] = query
                    end

                    if query then
                        local lines = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)
                        if #lines > 0 then
                            local line_text = lines[1]

                            local _, s_end = string.find(
                                line_text,
                                config.separator .. "%s+%d+:%d+%s+" .. config.separator .. "%s"
                            )

                            if s_end then
                                pcall(function()
                                    local msg_text = item.text:gsub("[\r\n]", " ")

                                    local parser = vim.treesitter.get_string_parser(msg_text, lang)
                                    local tree = parser:parse()[1]
                                    local root = tree:root()

                                    for id, node in query:iter_captures(root, msg_text, 0, -1) do
                                        local name = "@" .. query.captures[id]
                                        local hl_group = vim.api.nvim_get_hl_id_by_name(name)
                                        local _, c, _, end_c = node:range()

                                        if s_end + c < #line_text then
                                            vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, s_end + c, {
                                                end_col = math.min(s_end + end_c, #line_text),
                                                hl_group = hl_group,
                                                priority = 100,
                                            })
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
            count = count + 1
        end
    end
end

function M.setup_syntax()
    if vim.b.prettyqf_syntax_setup then
        return
    end
    vim.b.prettyqf_syntax_setup = true
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
            vim.api.nvim_buf_call(args.buf, M.setup_syntax)
            vim.schedule(function()
                M.apply_ts_highlights(args.buf)
            end)
        end,
    })
end

return M
