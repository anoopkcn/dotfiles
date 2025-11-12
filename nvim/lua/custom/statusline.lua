local modes = {
    ["n"] = "NORMAL",
    ["no"] = "NORMAL",
    ["v"] = "VISUAL",
    ["V"] = "VISUAL_LINE",
    [""] = "VISUAL_BLOCK",
    ["s"] = "SELECT",
    ["S"] = "SELECT_LINE",
    [""] = "SELECT_BLOCK",
    ["i"] = "INSERT",
    ["ic"] = "INSERT",
    ["R"] = "REPLACE",
    ["Rv"] = "VISUAL_REPLACE",
    ["c"] = "COMMAND",
    ["cv"] = "VIM_EX",
    ["ce"] = "EX",
    ["r"] = "PROMPT",
    ["rm"] = "MOAR",
    ["r?"] = "CONFIRM",
    ["!"] = "SHELL",
    ["t"] = "TERMINAL",
}

local diagnostic_symbol = ""
local diagnostic_sections = {
    { key = "Error", severity = vim.diagnostic.severity.ERROR, source = "DiagnosticError", fallback = "#e06c75" },
    { key = "Warn",  severity = vim.diagnostic.severity.WARN,  source = "DiagnosticWarn",  fallback = "#e5c07b" },
    { key = "Info",  severity = vim.diagnostic.severity.INFO,  source = "DiagnosticInfo",  fallback = "#56b6c2" },
    { key = "Hint",  severity = vim.diagnostic.severity.HINT,  source = "DiagnosticHint",  fallback = "#98c379" },
}

local function get_hl_def(group)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok then
        return hl
    end
    return {}
end

local function set_statusline_diagnostic_highlights()
    local statusline_bg = get_hl_def("StatusLine").bg or "#313640"
    for _, section in ipairs(diagnostic_sections) do
        local fg = get_hl_def(section.source).fg or section.fallback
        vim.api.nvim_set_hl(0, "StatuslineDiagnostic" .. section.key, {
            fg = fg,
            bg = statusline_bg,
            bold = true,
        })
    end
end


set_statusline_diagnostic_highlights()
local statusline_hl_group = vim.api.nvim_create_augroup("StatuslineHighlights", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
    group = statusline_hl_group,
    callback = set_statusline_diagnostic_highlights,
})

local function get_git_branch()
    if vim.fn.exists("*FugitiveHead") == 1 then
        local ok, head = pcall(vim.fn.FugitiveHead)
        if ok and head ~= "" then
            return head
        end
    end
    return ""
end


local function mode()
    local current_mode = vim.api.nvim_get_mode().mode
    return string.format(" %s ", modes[current_mode]):upper()
end


local function filepath()
    local fpath
    if vim.fn.bufname('%') == "" then
        fpath = vim.fn.getcwd()
        fpath = vim.fn.fnamemodify(fpath, ":~")
    else
        fpath = vim.fn.expand('%:p:h')
        fpath = vim.fn.fnamemodify(fpath, ":~:.")
    end

    if fpath == "" then
        return " "
    end

    return string.format(" %%<%s/", fpath)
end


local function filename()
    local fname = vim.fn.expand "%:t"
    if fname == "" then
        return ""
    end
    return fname .. "%m "
end


local function lsp()
    local segments = {}
    for _, section in ipairs(diagnostic_sections) do
        local diagnostics = vim.diagnostic.get(0, {
            severity = {
                min = section.severity,
                max = section.severity,
            },
        })
        local count = #diagnostics
        if count > 0 then
            table.insert(segments,
                string.format("%%#StatuslineDiagnostic%s# %s %d ", section.key, diagnostic_symbol, count))
        end
    end

    if #segments == 0 then
        return ""
    end

    table.insert(segments, "%#Statusline#")
    return table.concat(segments)
end


local vcs = function()
    local summary = vim.b.minidiff_summary
    local summary_string = ""
    if summary and summary.source_name then
        summary_string = vim.b.minidiff_summary_string or ""
        if summary_string == "" then
            local segments = {}
            if summary.add and summary.add > 0 then
                table.insert(segments, "+" .. summary.add)
            end
            if summary.change and summary.change > 0 then
                table.insert(segments, "~" .. summary.change)
            end
            if summary.delete and summary.delete > 0 then
                table.insert(segments, "-" .. summary.delete)
            end
            summary_string = table.concat(segments, " ")
        end
    end

    local label = get_git_branch()
    if label == "" and summary and summary.source_name then
        label = summary.source_name
    end

    if label == "" and summary_string == "" then
        return ""
    end

    if summary_string ~= "" then
        summary_string = " " .. summary_string
    end

    return string.format(" %s%s ", label, summary_string)
end


local function filetype()
    return string.format(" %s ", vim.bo.filetype):upper()
end


local function lineinfo()
    if vim.bo.filetype == "alpha" then
        return ""
    end
    return " %P %l:%c "
end


local function statusline_active()
    return table.concat {
        "%#Statusline#",
        mode(),
        -- "%#Normal# ",
        filepath(),
        filename(),
        lsp(),
        "%=",
        vcs(),
        filetype(),
        lineinfo(),
    }
end


local function statusline_inactive()
    return " %F"
end

local Statusline = rawget(_G, "Statusline") or {}
Statusline.active = statusline_active
Statusline.inactive = statusline_inactive
_G.Statusline = Statusline

vim.api.nvim_exec2([[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()
  augroup END
]], {})
