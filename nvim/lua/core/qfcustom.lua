local M = {}

local config = {
    separator = "│",
    filename_max_width = 32,
    max_highlight_items = 1000,
}

local highlight_cache = {
    lang_supported = {},
    lang_query = {},
}

local highlight_groups = {
    file = "QFFile",
    sep = "QFSeparator",
    line_info = "QFLineInfo",
}

local function ensure_highlight_links()
    vim.api.nvim_set_hl(0, highlight_groups.file, { link = "Directory", default = true })
    vim.api.nvim_set_hl(0, highlight_groups.sep, { link = "VertSplit", default = true })
    vim.api.nvim_set_hl(0, highlight_groups.line_info, { link = "Number", default = true })
end

local function find_separators(line)
    local sep = config.separator
    local first = line:find(sep, 1, true)
    if not first then
        return
    end
    local second = line:find(sep, first + #sep, true)
    if not second then
        return
    end
    return first, second, second + #sep
end

function M.qfcustom(info)
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
    local valid_fmt = "%s " .. config.separator .. "%5d:%-3d" .. config.separator .. " %s"
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
            str = string.format(valid_fmt, fname, e.lnum, e.col, text)
        else
            str = e.text
        end
        table.insert(ret, str)
    end
    return ret
end

local function apply_ts_highlights(bufnr)
    local items = vim.fn.getqflist({ items = 0 }).items
    local ns = vim.api.nvim_create_namespace("qfcustom_ts")

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
                        local line_text = lines[1]
                        if line_text then
                            local _, _, s_end = find_separators(line_text)

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

local function highlight_sections(bufnr)
    ensure_highlight_links()

    local ns = vim.api.nvim_create_namespace("qfcustom_sections")
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local sep_len = #config.separator

    for idx, line in ipairs(lines) do
        local first_sep, second_sep = find_separators(line)
        if first_sep and second_sep then
            local line_nr = idx - 1

            if first_sep > 1 then
                vim.api.nvim_buf_set_extmark(bufnr, ns, line_nr, 0, {
                    end_col = first_sep - 1,
                    hl_group = highlight_groups.file,
                    priority = 90,
                })
            end

            vim.api.nvim_buf_set_extmark(bufnr, ns, line_nr, first_sep - 1, {
                end_col = first_sep - 1 + sep_len,
                hl_group = highlight_groups.sep,
                priority = 90,
            })

            if second_sep - (first_sep + sep_len) > 0 then
                vim.api.nvim_buf_set_extmark(bufnr, ns, line_nr, first_sep - 1 + sep_len, {
                    end_col = second_sep - 1,
                    hl_group = highlight_groups.line_info,
                    priority = 90,
                })
            end

            vim.api.nvim_buf_set_extmark(bufnr, ns, line_nr, second_sep - 1, {
                end_col = second_sep - 1 + sep_len,
                hl_group = highlight_groups.sep,
                priority = 90,
            })
        end
    end
end

vim.o.quickfixtextfunc = "v:lua.require'core.qfcustom'.qfcustom"

vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function(args)
        vim.api.nvim_buf_call(args.buf, function()
            highlight_sections(args.buf)
            vim.opt_local.wrap = false
        end)
        vim.schedule(function()
            apply_ts_highlights(args.buf)
        end)
    end,
})

return M
