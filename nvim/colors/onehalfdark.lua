-- Name:        One Half Dark
-- Authors:     @sonph, @mitchellh, @anoopkcn
-- URL:         https://github.com/anoopkcn/dotfiles/blob/main/nvim/colors/onehalfdark.lua
-- License:     The MIT License (MIT)
--
-- A dark vim color scheme based on Atom's One Dark theme
-- Original implementaion in vimL by github.com/sonph/onehalf
-- @anookcn - Converted to Lua and further modified for Neovim

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
    black = color("#282c34", 236),
    red = color("#e06c75", 168),
    green = color("#98c379", 114),
    yellow = color("#e5c07b", 180),
    blue = color("#61afef", 75),
    purple = color("#c678dd", 176),
    cyan = color("#56b6c2", 73),
    white = color("#dcdfe4", 188),
    comment_fg = color("#5c6370", 241),
    gutter_bg = color("#282c34", 236),
    gutter_fg = color("#919baa", 247),
    non_text = color("#373C45", 239),
    cursor_line = color("#313640", 237),
    color_col = color("#313640", 237),
    selection = color("#474e5d", 239),
    vertsplit = color("#313640", 237),
    hovercolor = color("#303030", 236),
    hoverborder = color("#585858", 242),
    popup_bg = color("#282c34", 236),
    popup_border = color("#5c6370", 241),
    popup_selection = color("#414753", 239),
}

c.fg = c.white
c.bg = c.black

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

-- Default highlight groups
local default_highlights = {
    { "Normal",                      { fg = c.fg, bg = c.bg } },
    { "Cursor",                      { fg = c.bg, bg = c.blue } },
    { "CursorColumn",                { bg = c.cursor_line } },
    { "CursorLine",                  { bg = c.cursor_line } },
    { "LineNr",                      { fg = c.gutter_fg, bg = c.gutter_bg } },
    { "CursorLineNr",                { fg = c.cyan } },
    { "DiffAdd",                     { fg = c.green } },
    { "DiffChange",                  { fg = c.yellow } },
    { "DiffDelete",                  { fg = c.red } },
    { "DiffText",                    { fg = c.blue } },
    { "IncSearch",                   { fg = c.bg, bg = c.yellow } },
    { "Search",                      { fg = c.bg, bg = c.yellow } },
    { "ErrorMsg",                    { fg = c.fg } },
    { "ModeMsg",                     { fg = c.fg } },
    { "MoreMsg",                     { fg = c.fg } },
    { "WarningMsg",                  { fg = c.red } },
    { "Question",                    { fg = c.purple } },
    { "Pmenu",                       { fg = c.fg, bg = c.popup_bg } },
    { "PmenuSel",                    { fg = c.bg, bg = c.blue } },
    { "PmenuSbar",                   { bg = c.popup_selection } },
    { "PmenuThumb",                  { bg = c.popup_border } },
    { "PmenuBorder",                 { fg = c.popup_border, bg = c.popup_bg } },
    { "PmenuKind",                   { fg = c.cyan, bg = c.popup_bg } },
    { "PmenuKindSel",                { fg = c.popup_bg, bg = c.blue } },
    { "PmenuExtra",                  { fg = c.comment_fg, bg = c.popup_bg } },
    { "PmenuExtraSel",               { fg = c.popup_bg, bg = c.blue } },
    { "NormalFloat",                 { fg = c.fg, bg = c.popup_bg } },
    { "FloatBorder",                 { fg = c.popup_border, bg = c.popup_bg } },
    { "FloatShadow",                 { bg = c.bg } },
    { "FloatShadowThrough",          { bg = c.bg } },
    { "FloatTitle",                  { fg = c.fg, bg = c.popup_bg, bold = true } },
    { "LspInfoBorder",               { fg = c.popup_border, bg = c.popup_bg } },
    { "LspFloatWinNormal",           { fg = c.fg, bg = c.popup_bg } },
    { "LspFloatWinBorder",           { fg = c.popup_border, bg = c.popup_bg } },
    { "DiagnosticFloatingError",     { fg = c.red, bg = c.popup_bg } },
    { "DiagnosticFloatingWarn",      { fg = c.yellow, bg = c.popup_bg } },
    { "DiagnosticFloatingInfo",      { fg = c.blue, bg = c.popup_bg } },
    { "DiagnosticFloatingHint",      { fg = c.cyan, bg = c.popup_bg } },
    { "SpellBad",                    { fg = c.red, undercurl = true, sp = c.red.hex } },
    { "SpellCap",                    { fg = c.yellow, undercurl = true, sp = c.blue.hex } },
    { "SpellLocal",                  { fg = c.yellow, undercurl = true, sp = c.green.hex } },
    { "SpellRare",                   { fg = c.yellow, undercurl = true, sp = c.purple.hex } },
    { "StatusLine",                  { fg = c.fg, bg = c.cursor_line } },
    { "StatusLineNC",                { fg = c.comment_fg, bg = c.cursor_line } },
    { "TabLine",                     { fg = c.comment_fg, bg = c.cursor_line } },
    { "TabLineFill",                 { fg = c.comment_fg, bg = c.cursor_line } },
    { "TabLineSel",                  { fg = c.fg, bg = c.bg } },
    { "Visual",                      { bg = c.selection } },
    { "VisualNOS",                   { bg = c.selection } },
    { "ColorColumn",                 { bg = c.color_col } },
    { "Conceal",                     { fg = c.fg } },
    { "Directory",                   { fg = c.blue } },
    { "VertSplit",                   { fg = c.vertsplit, bg = c.vertsplit } },
    { "Folded",                      { fg = c.fg } },
    { "FoldColumn",                  { fg = c.fg } },
    { "SignColumn",                  { fg = c.fg } },
    { "MatchParen",                  { fg = c.blue, underline = true } },
    { "SpecialKey",                  { fg = c.fg } },
    { "Title",                       { fg = c.green } },
    { "WildMenu",                    { fg = c.fg } },
    { "DiagnosticUnderlineError",    { undercurl = true, sp = c.red.hex } },
    { "DiagnosticUnderlineWarn",     { undercurl = true, sp = c.yellow.hex } },
    { "DiagnosticUnderlineInfo",     { undercurl = true, sp = c.blue.hex } },
    { "DiagnosticUnderlineHint",     { undercurl = true, sp = c.cyan.hex } },
    { "LspSignatureActiveParameter", { fg = c.yellow, bold = true } },
    { "Whitespace",                  { fg = c.non_text } },
    { "NonText",                     { fg = c.non_text } },
    { "Comment",                     { fg = c.comment_fg } },
    { "Constant",                    { fg = c.cyan } },
    { "String",                      { fg = c.green } },
    { "Character",                   { fg = c.green } },
    { "Number",                      { fg = c.yellow } },
    { "Boolean",                     { fg = c.yellow } },
    { "Float",                       { fg = c.yellow } },
    { "Identifier",                  { fg = c.red } },
    { "Function",                    { fg = c.blue } },
    { "Statement",                   { fg = c.purple } },
    { "Conditional",                 { fg = c.purple } },
    { "Repeat",                      { fg = c.purple } },
    { "Label",                       { fg = c.purple } },
    { "Operator",                    { fg = c.fg } },
    { "Keyword",                     { fg = c.red } },
    { "Exception",                   { fg = c.purple } },
    { "PreProc",                     { fg = c.yellow } },
    { "Include",                     { fg = c.purple } },
    { "Define",                      { fg = c.purple } },
    { "Macro",                       { fg = c.purple } },
    { "PreCondit",                   { fg = c.yellow } },
    { "Type",                        { fg = c.yellow } },
    { "StorageClass",                { fg = c.yellow } },
    { "Structure",                   { fg = c.yellow } },
    { "Typedef",                     { fg = c.yellow } },
    { "Special",                     { fg = c.blue } },
    { "SpecialChar",                 { fg = c.fg } },
    { "Tag",                         { fg = c.fg } },
    { "Delimiter",                   { fg = c.fg } },
    { "SpecialComment",              { fg = c.fg } },
    { "Debug",                       { fg = c.fg } },
    { "Underlined",                  { fg = c.fg } },
    { "Ignore",                      { fg = c.fg } },
    { "Error",                       { fg = c.red, bg = c.gutter_bg } },
    { "Todo",                        { fg = c.purple } },
    { "diffAdded",                   { fg = c.green } },
    { "diffRemoved",                 { fg = c.red } },
    { "gitcommitComment",            { fg = c.comment_fg } },
    { "gitcommitUnmerged",           { fg = c.red } },
    { "gitcommitOnBranch",           { fg = c.fg } },
    { "gitcommitBranch",             { fg = c.purple } },
    { "gitcommitDiscardedType",      { fg = c.red } },
    { "gitcommitSelectedType",       { fg = c.green } },
    { "gitcommitHeader",             { fg = c.fg } },
    { "gitcommitUntrackedFile",      { fg = c.cyan } },
    { "gitcommitDiscardedFile",      { fg = c.red } },
    { "gitcommitSelectedFile",       { fg = c.green } },
    { "gitcommitUnmergedFile",       { fg = c.yellow } },
    { "gitcommitFile",               { fg = c.fg } },
    { "gitcommitNoBranch",           { link = "gitcommitBranch" } },
    { "gitcommitUntracked",          { link = "gitcommitComment" } },
    { "gitcommitDiscarded",          { link = "gitcommitComment" } },
    { "gitcommitSelected",           { link = "gitcommitComment" } },
    { "gitcommitDiscardedArrow",     { link = "gitcommitDiscardedFile" } },
    { "gitcommitSelectedArrow",      { link = "gitcommitSelectedFile" } },
    { "gitcommitUnmergedArrow",      { link = "gitcommitUnmergedFile" } },
    { "WinSeparator",                { fg = c.comment_fg } },
}

-- Plugin highlight groups
local plugin_highlights = {
    { "CmpDocumentation",                     { fg = c.fg, bg = c.popup_bg } },
    { "CmpDocumentationBorder",               { fg = c.popup_border, bg = c.popup_bg } },
    { "BlinkCmpLabel",                        { fg = c.fg } },
    { "BlinkCmpLabelMatch",                   { fg = c.blue, bold = true } },
    { "BlinkCmpLabelDeprecated",              { fg = c.comment_fg, strikethrough = true } },
    { "BlinkCmpLabelDetail",                  { fg = c.comment_fg } },
    { "BlinkCmpLabelDescription",             { fg = c.comment_fg } },
    { "BlinkCmpSource",                       { fg = c.purple } },
    { "BlinkCmpKind",                         { fg = c.cyan } },
    { "BlinkCmpGhostText",                    { fg = c.non_text, italic = true } },
    { "BlinkCmpScrollBarThumb",               { bg = c.popup_border } },
    { "BlinkCmpScrollBarGutter",              { bg = c.popup_selection } },
    { "BlinkCmpMenu",                         { fg = c.fg, bg = c.popup_bg } },
    { "BlinkCmpMenuBorder",                   { fg = c.popup_border, bg = c.popup_bg } },
    { "BlinkCmpMenuSelection",                { fg = c.popup_bg, bg = c.blue } },
    { "BlinkCmpDoc",                          { fg = c.fg, bg = c.popup_bg } },
    { "BlinkCmpDocBorder",                    { fg = c.popup_border, bg = c.popup_bg } },
    { "BlinkCmpDocSeparator",                 { fg = c.popup_border, bg = c.popup_bg } },
    { "BlinkCmpDocCursorLine",                { fg = c.fg, bg = c.popup_selection } },
    { "BlinkCmpSignatureHelp",                { fg = c.fg, bg = c.popup_bg } },
    { "BlinkCmpSignatureHelpBorder",          { fg = c.popup_border, bg = c.popup_bg } },
    { "BlinkCmpSignatureHelpActiveParameter", { fg = c.yellow, bold = true } },
    { "GitGutterAdd",                         { fg = c.green, bg = c.gutter_bg } },
    { "GitGutterDelete",                      { fg = c.red, bg = c.gutter_bg } },
    { "GitGutterChange",                      { fg = c.yellow, bg = c.gutter_bg } },
    { "GitGutterChangeDelete",                { fg = c.red, bg = c.gutter_bg } },
    { "NetrwMarkFile",                        { fg = c.bg, bg = c.blue, bold = true } },
    { "FzfLuaBorder",                         { link = "FloatBorder" } },
    { "TreesitterContext",                    { fg = c.gutter_fg, bg = c.gutter_bg } },
    { "TreesitterContextBottom",              { underline = true } },
    { "TreesitterContextLineNumber",          { fg = c.fg, bg = c.gutter_bg } },
    { "TreesitterContextLineNumberBottom",    { underline = true } },
}

for _, spec in ipairs(default_highlights) do
    set(spec[1], spec[2])
end

for _, spec in ipairs(plugin_highlights) do
    set(spec[1], spec[2])
end

-- set("ComplHint", { link = "Comment" })
-- set("ComplHintMore", { link = "Comment" })

-- vim.g.terminal_color_0 = c.black.hex
-- vim.g.terminal_color_1 = c.red.hex
-- vim.g.terminal_color_2 = c.green.hex
-- vim.g.terminal_color_3 = c.yellow.hex
-- vim.g.terminal_color_4 = c.blue.hex
-- vim.g.terminal_color_5 = c.purple.hex
-- vim.g.terminal_color_6 = c.cyan.hex
-- vim.g.terminal_color_7 = c.white.hex
-- vim.g.terminal_color_8 = c.black.hex
-- vim.g.terminal_color_9 = c.red.hex
-- vim.g.terminal_color_10 = c.green.hex
-- vim.g.terminal_color_11 = c.yellow.hex
-- vim.g.terminal_color_12 = c.blue.hex
-- vim.g.terminal_color_13 = c.purple.hex
-- vim.g.terminal_color_14 = c.cyan.hex
-- vim.g.terminal_color_15 = c.white.hex
-- vim.g.terminal_color_background = c.bg.hex
-- vim.g.terminal_color_foreground = c.fg.hex
