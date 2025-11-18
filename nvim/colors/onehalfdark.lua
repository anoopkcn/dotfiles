---@brief
-- Name:        One Half Dark
-- Authors:     @anoopkcn
-- URL:         https://github.com/anoopkcn/dotfiles/blob/main/nvim/colors/onehalfdark.lua
-- License:     The MIT License (MIT)
--
-- A dark vim color scheme based on Atom's One Dark theme
-- Inspierd by @sonph's (github.com/sonph/onehalf) vimscript version of the same theme

vim.o.background = "dark"
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end

vim.g.colors_name = "onehalfdark"

local function color(hex, cterm)
    return { hex = hex, cterm = tonumber(cterm) }
end

local c = {
    fg = color("#dcdfe4", 188), -- white
    bg = color("#282c34", 236), -- black
    red = color("#e06c75", 168),
    green = color("#98c379", 114),
    yellow = color("#e5c07b", 180),
    blue = color("#61afef", 75),
    purple = color("#c678dd", 176),
    cyan = color("#56b6c2", 73),
    comment_fg = color("#5c6370", 241),
    gutter_bg = color("#282c34", 236),
    gutter_fg = color("#919baa", 247),
    non_text = color("#373C45", 239),
    cursor_line = color("#313640", 237),
    color_col = color("#313640", 237),
    selection = color("#474e5d", 239),
    vertsplit = color("#313640", 237),
    hovercolor = color("#303030", 236),
    hoverborder = color("#5c6370", 242),
    popup_bg = color("#282c34", 236),
    popup_border = color("#5c6370", 241),
    popup_selection = color("#414753", 239),
}

local function set(group, opts)
    if opts.link then
        vim.api.nvim_set_hl(0, group, { link = opts.link })
        return
    end

    local def = {}

    if opts.fg then
        def.fg = opts.fg.hex
        def.ctermfg = opts.fg.cterm
    end
    if opts.bg then
        def.bg = opts.bg.hex
        def.ctermbg = opts.bg.cterm
    end
    if opts.sp then def.sp = opts.sp end
    if opts.blend then def.blend = opts.blend end
    if opts.bold ~= nil then def.bold = opts.bold end
    if opts.italic ~= nil then def.italic = opts.italic end
    if opts.underline ~= nil then def.underline = opts.underline end
    if opts.undercurl ~= nil then def.undercurl = opts.undercurl end
    if opts.strikethrough ~= nil then def.strikethrough = opts.strikethrough end

    vim.api.nvim_set_hl(0, group, def)
end

set("Normal", { fg = c.fg, bg = c.bg })
set("Cursor", { fg = c.bg, bg = c.blue })
set("CursorColumn", { bg = c.cursor_line })
set("CursorLine", { bg = c.cursor_line })
set("LineNr", { fg = c.gutter_fg, bg = c.gutter_bg })
set("CursorLineNr", { fg = c.cyan })
set("DiffAdd", { fg = c.green })
set("DiffChange", { fg = c.yellow })
set("DiffDelete", { fg = c.red })
set("DiffText", { fg = c.blue })
set("IncSearch", { fg = c.bg, bg = c.yellow })
set("Search", { fg = c.bg, bg = c.yellow })
set("ErrorMsg", { fg = c.fg })
set("ModeMsg", { fg = c.fg })
set("MoreMsg", { fg = c.fg })
set("WarningMsg", { fg = c.red })
set("Question", { fg = c.purple })
set("Pmenu", { fg = c.fg, bg = c.popup_bg })
set("PmenuSel", { fg = c.bg, bg = c.selection })
set("PmenuSbar", { bg = c.popup_selection })
set("PmenuThumb", { bg = c.popup_border })
set("PmenuBorder", { fg = c.popup_border, bg = c.popup_bg })
set("PmenuKind", { fg = c.cyan, bg = c.popup_bg })
set("PmenuKindSel", { fg = c.popup_bg, bg = c.blue })
set("PmenuExtra", { fg = c.comment_fg, bg = c.popup_bg })
set("PmenuExtraSel", { fg = c.popup_bg, bg = c.blue })
set("NormalFloat", { fg = c.fg, bg = c.popup_bg })
set("FloatBorder", { fg = c.popup_border, bg = c.popup_bg })
set("FloatShadow", { bg = c.bg })
set("FloatShadowThrough", { bg = c.bg })
set("LspInfoBorder", { fg = c.popup_border, bg = c.popup_bg })
set("LspFloatWinNormal", { fg = c.fg, bg = c.popup_bg })
set("LspFloatWinBorder", { fg = c.popup_border, bg = c.popup_bg })
set("DiagnosticFloatingError", { fg = c.red, bg = c.popup_bg })
set("DiagnosticFloatingWarn", { fg = c.yellow, bg = c.popup_bg })
set("DiagnosticFloatingInfo", { fg = c.blue, bg = c.popup_bg })
set("DiagnosticFloatingHint", { fg = c.cyan, bg = c.popup_bg })
set("FloatTitle", { fg = c.fg, bg = c.popup_bg, bold = true })
set("SpellBad", { fg = c.red, undercurl = true, sp = c.red.hex })
set("SpellCap", { fg = c.yellow, undercurl = true, sp = c.blue.hex })
set("SpellLocal", { fg = c.yellow, undercurl = true, sp = c.green.hex })
set("SpellRare", { fg = c.yellow, undercurl = true, sp = c.purple.hex })
set("StatusLine", { fg = c.fg, bg = c.cursor_line })
set("StatusLineNC", { fg = c.comment_fg, bg = c.cursor_line })
set("TabLine", { fg = c.comment_fg, bg = c.cursor_line })
set("TabLineFill", { fg = c.comment_fg, bg = c.cursor_line })
set("TabLineSel", { fg = c.fg, bg = c.bg })
set("Visual", { bg = c.selection })
set("VisualNOS", { bg = c.selection })
set("ColorColumn", { bg = c.color_col })
set("Conceal", { fg = c.fg })
set("Directory", { fg = c.blue })
set("VertSplit", { fg = c.vertsplit, bg = c.vertsplit })
set("Folded", { fg = c.fg })
set("FoldColumn", { fg = c.fg })
set("SignColumn", { fg = c.fg })
set("MatchParen", { fg = c.blue, underline = true })
set("SpecialKey", { fg = c.fg })
set("Title", { fg = c.green })
set("WildMenu", { fg = c.fg })
set("DiagnosticUnderlineError", { undercurl = true, sp = c.red.hex })
set("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow.hex })
set("DiagnosticUnderlineInfo", { undercurl = true, sp = c.blue.hex })
set("DiagnosticUnderlineHint", { undercurl = true, sp = c.cyan.hex })
set("LspSignatureActiveParameter", { fg = c.yellow, bold = true })
set("Whitespace", { fg = c.non_text })
set("NonText", { fg = c.non_text })
set("Comment", { fg = c.comment_fg })
set("Constant", { fg = c.cyan })
set("String", { fg = c.green })
set("Character", { fg = c.green })
set("Number", { fg = c.yellow })
set("Boolean", { fg = c.yellow })
set("Float", { fg = c.yellow })
set("Identifier", { fg = c.red })
set("Function", { fg = c.blue })
set("Statement", { fg = c.purple })
set("Conditional", { fg = c.purple })
set("Repeat", { fg = c.purple })
set("Label", { fg = c.purple })
set("Operator", { fg = c.fg })
set("Keyword", { fg = c.red })
set("Exception", { fg = c.purple })
set("PreProc", { fg = c.yellow })
set("Include", { fg = c.purple })
set("Define", { fg = c.purple })
set("Macro", { fg = c.purple })
set("PreCondit", { fg = c.yellow })
set("Type", { fg = c.yellow })
set("StorageClass", { fg = c.yellow })
set("Structure", { fg = c.yellow })
set("Typedef", { fg = c.yellow })
set("Special", { fg = c.blue })
set("SpecialChar", { fg = c.fg })
set("Tag", { fg = c.fg })
set("Delimiter", { fg = c.fg })
set("SpecialComment", { fg = c.fg })
set("Debug", { fg = c.fg })
set("Underlined", { fg = c.fg })
set("Ignore", { fg = c.fg })
set("Error", { fg = c.red, bg = c.gutter_bg })
set("Todo", { fg = c.purple })
set("diffAdded", { fg = c.green })
set("diffRemoved", { fg = c.red })
set("WinSeparator", { fg = c.comment_fg })
set("NetrwMarkFile", { fg = c.bg, bg = c.blue, bold = true })

-- Plugin highlights
set("BlinkCmpLabel", { fg = c.fg })
set("BlinkCmpLabelMatch", { fg = c.blue, bold = true })
set("BlinkCmpLabelDeprecated", { fg = c.comment_fg, strikethrough = true })
set("BlinkCmpLabelDetail", { fg = c.comment_fg })
set("BlinkCmpLabelDescription", { fg = c.comment_fg })
set("BlinkCmpSource", { fg = c.purple })
set("BlinkCmpKind", { fg = c.cyan })
set("BlinkCmpGhostText", { fg = c.non_text, italic = true })
set("BlinkCmpScrollBarThumb", { bg = c.popup_border })
set("BlinkCmpScrollBarGutter", { bg = c.popup_selection })
set("BlinkCmpMenu", { fg = c.fg, bg = c.popup_bg })
set("BlinkCmpMenuBorder", { fg = c.popup_border, bg = c.popup_bg })
set("BlinkCmpMenuSelection", { fg = c.popup_bg, bg = c.blue })
set("BlinkCmpDoc", { fg = c.fg, bg = c.popup_bg })
set("BlinkCmpDocBorder", { fg = c.popup_border, bg = c.popup_bg })
set("BlinkCmpDocSeparator", { fg = c.popup_border, bg = c.popup_bg })
set("BlinkCmpDocCursorLine", { fg = c.fg, bg = c.popup_selection })
set("BlinkCmpSignatureHelp", { fg = c.fg, bg = c.popup_bg })
set("BlinkCmpSignatureHelpBorder", { fg = c.popup_border, bg = c.popup_bg })
set("BlinkCmpSignatureHelpActiveParameter", { fg = c.yellow, bold = true })
-- set("CmpDocumentation", { fg = c.fg, bg = c.popup_bg })
-- set("CmpDocumentationBorder", { fg = c.popup_border, bg = c.popup_bg })
set("TreesitterContext", { fg = c.gutter_fg, bg = c.gutter_bg })
set("TreesitterContextBottom", { underline = true })
set("TreesitterContextLineNumber", { fg = c.fg, bg = c.gutter_bg })
set("TreesitterContextLineNumberBottom", { underline = true })
set("FzfLuaBorder", { link = "FloatBorder" })
set("ComplHint", { fg = c.selection, italic = true })
set("ComplHintMore", { fg = c.selection })
set("GitGutterAdd", { fg = c.green, bg = c.gutter_bg })
set("GitGutterDelete", { fg = c.red, bg = c.gutter_bg })
set("GitGutterChange", { fg = c.yellow, bg = c.gutter_bg })
set("GitGutterChangeDelete", { fg = c.red, bg = c.gutter_bg })
set("gitcommitComment", { fg = c.comment_fg })
set("gitcommitUnmerged", { fg = c.red })
set("gitcommitOnBranch", { fg = c.fg })
set("gitcommitBranch", { fg = c.purple })
set("gitcommitDiscardedType", { fg = c.red })
set("gitcommitSelectedType", { fg = c.green })
set("gitcommitHeader", { fg = c.fg })
set("gitcommitUntrackedFile", { fg = c.cyan })
set("gitcommitDiscardedFile", { fg = c.red })
set("gitcommitSelectedFile", { fg = c.green })
set("gitcommitUnmergedFile", { fg = c.yellow })
set("gitcommitFile", { fg = c.fg })
set("gitcommitNoBranch", { link = "gitcommitBranch" })
set("gitcommitUntracked", { link = "gitcommitComment" })
set("gitcommitDiscarded", { link = "gitcommitComment" })
set("gitcommitSelected", { link = "gitcommitComment" })
set("gitcommitDiscardedArrow", { link = "gitcommitDiscardedFile" })
set("gitcommitSelectedArrow", { link = "gitcommitSelectedFile" })
set("gitcommitUnmergedArrow", { link = "gitcommitUnmergedFile" })
