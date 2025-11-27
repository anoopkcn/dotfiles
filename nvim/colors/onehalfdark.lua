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
    text = color("#dcdfe4", 188),
    background = color("#282c34", 236),
    surface = color("#313640", 237), -- subtle surfaces like cursor line or tabline
    -- panel = color("#343847", 236),   -- floating/popup panels
    selection = color("#474e5d", 239),
    muted = color("#5c6370", 241), -- comments, borders
    line = color("#919baa", 247),  -- gutters and line numbers
    dim = color("#373C45", 239),   -- whitespace / non-text
    scrollbar = color("#3b4252", 237),
    red = color("#e06c75", 168),
    green = color("#98c379", 114),
    yellow = color("#e5c07b", 180),
    blue = color("#61afef", 75),
    purple = color("#a66fc1", 176),
    cyan = color("#56b6c2", 73),
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

-- General highlights 
-- UI{
set("Normal", { fg = c.text, bg = c.background })
set("Cursor", { fg = c.background, bg = c.blue })
set("CursorColumn", { bg = c.surface })
set("CursorLine", { bg = c.surface })
set("LineNr", { fg = c.line, bg = c.background })
set("CursorLineNr", { fg = c.cyan, bold = true })
set("DiffAdd", { fg = c.green })
set("DiffChange", { fg = c.yellow })
set("DiffDelete", { fg = c.red })
set("DiffText", { fg = c.blue })
set("IncSearch", { fg = c.background, bg = c.yellow })
set("Search", { fg = c.background, bg = c.yellow })
set("ErrorMsg", { fg = c.text })
set("ModeMsg", { fg = c.text })
set("MoreMsg", { fg = c.text })
set("WarningMsg", { fg = c.red })
set("Question", { fg = c.purple })
set("Pmenu", { fg = c.text , bg = c.background })
set("PmenuSel", { fg = c.text, bg = c.selection })
set("PmenuSbar", { bg = c.scrollbar })
set("PmenuThumb", { bg = c.selection })
set("PmenuBorder", { fg = c.muted, bg = c.background })
set("NormalFloat", { fg = c.text, bg = c.background })
set("FloatBorder", { fg = c.muted, bg = c.background })
set("FloatShadow", { bg = c.background })
set("FloatShadowThrough", { bg = c.background })
set("LspInfoBorder", { fg = c.muted, bg = c.background })
set("LspFloatWinNormal", { fg = c.text, bg = c.background })
set("LspFloatWinBorder", { fg = c.muted, bg = c.background })
set("DiagnosticFloatingError", { fg = c.red, bg = c.background })
set("DiagnosticFloatingWarn", { fg = c.yellow, bg = c.background })
set("DiagnosticFloatingInfo", { fg = c.blue, bg = c.background })
set("DiagnosticFloatingHint", { fg = c.cyan, bg = c.background })
set("FloatTitle", { fg = c.text, bg = c.background, bold = true })
set("SpellBad", { fg = c.red, undercurl = true, sp = c.red.hex })
set("SpellCap", { fg = c.yellow, undercurl = true, sp = c.blue.hex })
set("SpellLocal", { fg = c.yellow, undercurl = true, sp = c.green.hex })
set("SpellRare", { fg = c.yellow, undercurl = true, sp = c.purple.hex })
set("StatusLine", { fg = c.text, bg = c.surface })
set("StatusLineNC", { fg = c.muted, bg = c.surface })
set("WinBar", { fg = c.text, bg = c.background, bold = true })
set("WinBarNC", { fg = c.muted, bg = c.background })
set("TabLine", { fg = c.muted, bg = c.surface })
set("TabLineFill", { fg = c.muted, bg = c.surface })
set("TabLineSel", { fg = c.text, bg = c.background })
set("Visual", { bg = c.selection })
set("VisualNOS", { bg = c.selection })
set("ColorColumn", { bg = c.surface })
set("Conceal", { fg = c.text })
set("Directory", { fg = c.blue })
set("VertSplit", { fg = c.muted, bg = c.background })
set("Folded", { fg = c.text })
set("FoldColumn", { fg = c.text })
set("SignColumn", { fg = c.text })
set("MatchParen", { fg = c.blue, underline = true })
set("SpecialKey", { fg = c.text })
set("Title", { fg = c.green })
set("WildMenu", { fg = c.text })
set("DiagnosticUnderlineError", { undercurl = true, sp = c.red.hex })
set("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow.hex })
set("DiagnosticUnderlineInfo", { undercurl = true, sp = c.blue.hex })
set("DiagnosticUnderlineHint", { undercurl = true, sp = c.cyan.hex })
set("LspSignatureActiveParameter", { fg = c.yellow, bold = true })
set("WinSeparator", { fg = c.muted })
set("NetrwMarkFile", { fg = c.background, bg = c.selection, bold = true })
set("QuickFixLine", { bg = c.surface })
-- }

-- Syntax highlights {
set("Whitespace", { fg = c.dim })
set("NonText", { fg = c.dim })
set("Comment", { fg = c.muted })
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
set("Operator", { fg = c.text })
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
set("SpecialChar", { fg = c.text })
set("Tag", { fg = c.text })
set("Delimiter", { fg = c.text })
set("SpecialComment", { fg = c.text })
set("Debug", { fg = c.text })
set("Underlined", { fg = c.text })
set("Ignore", { fg = c.text })
set("Error", { fg = c.red, bg = c.background })
set("Todo", { fg = c.purple })
-- }

-- Plugin highlights
-- Treesittter {
set("TreesitterContext", { fg = c.line, bg = c.background })
set("TreesitterContextBottom", { underline = true })
set("TreesitterContextLineNumber", { fg = c.text, bg = c.background })
set("TreesitterContextLineNumberBottom", { underline = true })
-- }
-- Copilot {
set("ComplHint", { fg = c.selection, italic = true })
set("ComplHintMore", { fg = c.selection })
-- }
-- Minidiff {
set("MiniDiffSignAdd", { fg = c.green })
set("MiniDiffSignChange", { fg = c.yellow })
set("MiniDiffSignDelete", { fg = c.red })
-- }
