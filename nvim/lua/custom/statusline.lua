local diagnostic_symbol = ""
local diagnostic_sections = {
    { key = "Error", severity = vim.diagnostic.severity.ERROR, source = "DiagnosticError", fallback = "#e06c75" },
    { key = "Warn",  severity = vim.diagnostic.severity.WARN,  source = "DiagnosticWarn",  fallback = "#e5c07b" },
    { key = "Info",  severity = vim.diagnostic.severity.INFO,  source = "DiagnosticInfo",  fallback = "#56b6c2" },
    { key = "Hint",  severity = vim.diagnostic.severity.HINT,  source = "DiagnosticHint",  fallback = "#98c379" },
}

local uv = vim.uv or vim.loop

local severity_lookup = {}
for _, section in ipairs(diagnostic_sections) do
    severity_lookup[section.severity] = section
end

local function get_hl_def(group)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok then
        return hl
    end
    return {}
end

local function set_statusline_highlights()
    local statusline_hl = get_hl_def("StatusLine")
    local statusline_bg = statusline_hl.bg or "#313640"
    local statusline_fg = statusline_hl.fg or "#d0d0d0"
    for _, section in ipairs(diagnostic_sections) do
        local fg = get_hl_def(section.source).fg or section.fallback
        vim.api.nvim_set_hl(0, "StatuslineDiagnostic" .. section.key, {
            fg = fg,
            bg = statusline_bg,
            bold = true,
        })
    end

    vim.api.nvim_set_hl(0, "StatuslineMode", {
        fg = statusline_fg,
        bg = statusline_bg,
        bold = true,
    })
end

set_statusline_highlights()
local statusline_hl_group = vim.api.nvim_create_augroup("StatuslineHighlights", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
    group = statusline_hl_group,
    callback = set_statusline_highlights,
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
    return table.concat({
        "%#StatuslineMode#",
        " ",
        current_mode:upper(),
        " ",
        "%#Statusline#",
    })
end


local function get_buffer_paths()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname == "" then
        local cwd = (uv and uv.cwd and uv.cwd()) or vim.fn.getcwd()
        return vim.fn.fnamemodify(cwd, ":~"), ""
    end
    local display_dir = vim.fn.fnamemodify(bufname, ":~:.:h")
    local display_name = vim.fs.basename(bufname)
    return display_dir, display_name
end

local function filepath(dir)
    if dir == "" then
        return " "
    end

    return string.format(" %%<%s/", dir)
end


local function filename(name)
    if name == "" then
        return ""
    end
    return name .. "%m "
end


local function lsp()
    local diagnostics = vim.diagnostic.get(0)
    if not diagnostics or vim.tbl_isempty(diagnostics) then
        return ""
    end

    local counts = {}
    for _, diagnostic in ipairs(diagnostics) do
        local section = severity_lookup[diagnostic.severity]
        if section then
            counts[section.key] = (counts[section.key] or 0) + 1
        end
    end

    local segments = {}
    for _, section in ipairs(diagnostic_sections) do
        local count = counts[section.key]
        if count and count > 0 then
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


local function filetype(buf_ft)
    if buf_ft == "" then
        return ""
    end
    return string.format(" %s ", buf_ft):upper()
end


local function lineinfo(buf_ft)
    if buf_ft == "alpha" then
        return ""
    end
    return " %P %l:%c "
end


local function statusline_active()
    local dir, name = get_buffer_paths()
    local buf_ft = vim.bo.filetype
    return table.concat {
        "%#Statusline#",
        mode(),
        -- "%#Normal# ",
        filepath(dir),
        filename(name),
        lsp(),
        "%=",
        vcs(),
        filetype(buf_ft),
        lineinfo(buf_ft),
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
