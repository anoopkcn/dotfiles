-- One Half Dark — Lua port of onehalfdark.vim
-- Original: Son A. Pham (https://github.com/sonph/onehalf), MIT
-- Customisations: @anoopkcn

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.o.background = "dark"
vim.g.colors_name = "onehalfdark"

local c = {
    black       = { gui = "#292d33", cterm = 236 },
    red         = { gui = "#dc6a74", cterm = 168 },
    green       = { gui = "#94bf77", cterm = 108 },
    yellow      = { gui = "#e0bd79", cterm = 180 },
    blue        = { gui = "#5facea", cterm = 74  },
    purple      = { gui = "#c276d9", cterm = 140 },
    cyan        = { gui = "#54b3bf", cterm = 73  },
    white       = { gui = "#c2c5ca", cterm = 251 },
    comment_fg  = { gui = "#5a616e", cterm = 241 },
    muted_fg    = { gui = "#bdc2ce", cterm = 251 },
    gutter_fg   = { gui = "#8f99a7", cterm = 247 },
    non_text    = { gui = "#3d414b", cterm = 238 },
    cursor_line = { gui = "#32373f", cterm = 237 },
    color_col   = { gui = "#353b46", cterm = 237 },
    selection   = { gui = "#464c5c", cterm = 239 },
    vertsplit   = { gui = "#353b46", cterm = 237 },
}
c.fg = c.white
c.bg = c.black

local set_hl = vim.api.nvim_set_hl

local function h(group, fg, bg, attr)
    local spec = {}
    if fg then spec.fg, spec.ctermfg = fg.gui, fg.cterm end
    if bg then spec.bg, spec.ctermbg = bg.gui, bg.cterm end
    if attr then spec[attr] = true end
    set_hl(0, group, spec)
end

-- UI
h("Normal",        c.fg,        nil,           nil)
h("Cursor",        c.bg,        c.blue,        nil)
h("CursorColumn",  nil,         c.cursor_line, nil)
h("CursorLine",    nil,         c.cursor_line, nil)
h("LineNr",        c.gutter_fg, nil,           nil)
h("CursorLineNr",  c.fg,        nil,           nil)
h("DiffAdd",       c.green,     nil,           nil)
h("DiffChange",    c.yellow,    nil,           nil)
h("DiffDelete",    c.red,       nil,           nil)
h("DiffText",      c.blue,      nil,           nil)
h("IncSearch",     c.bg,        c.yellow,      nil)
h("Search",        c.bg,        c.yellow,      nil)
h("ErrorMsg",      c.fg,         nil,           nil)
h("ModeMsg",       c.fg,         nil,           nil)
h("MoreMsg",       c.fg,         nil,           nil)
h("WarningMsg",    c.red,        nil,           nil)
h("MsgSeparator",  c.comment_fg, nil,           nil)
h("MsgArea",       c.fg,         nil,           nil)
h("Question",      c.purple,    nil,           nil)
h("Pmenu",         c.fg,        c.cursor_line, nil)
h("PmenuSel",      c.fg,        c.selection,   "bold")
h("PmenuSbar",     nil,         c.selection,   nil)
h("PmenuThumb",    nil,         c.gutter_fg,   nil)
h("NormalFloat",   c.fg,        c.bg,          nil)
h("FloatBorder",   c.gutter_fg, c.bg,          nil)
h("PmenuBorder",   c.gutter_fg, c.bg,          nil)
h("FloatTitle",    c.blue,      c.bg,          "bold")
h("@punctuation.special.markdown", c.gutter_fg, nil, nil)
h("@punctuation.special",          c.gutter_fg, nil, nil)
h("@markup.list.markdown",         c.gutter_fg, nil, nil)
h("markdownRule",  c.gutter_fg, nil,           nil)
h("SpellBad",      c.red,       nil,           nil)
h("SpellCap",      c.yellow,    nil,           nil)
h("SpellLocal",    c.yellow,    nil,           nil)
h("SpellRare",     c.yellow,    nil,           nil)
h("StatusLine",    c.blue,      c.cursor_line, nil)
h("StatusLineNC",  c.comment_fg, c.cursor_line, nil)
h("WinBar",        c.fg,        nil,           "bold")
h("WinBarNC",      c.comment_fg, nil,          nil)
h("TabLine",       c.comment_fg, c.cursor_line, nil)
h("TabLineFill",   c.comment_fg, c.cursor_line, nil)
h("TabLineSel",    c.fg,        c.bg,          nil)
h("Visual",        nil,         c.selection,   nil)
h("VisualNOS",     nil,         c.selection,   nil)
h("ColorColumn",   nil,         c.color_col,   nil)
h("Conceal",       c.fg,        nil,           nil)
h("Directory",     c.blue,      nil,           nil)
h("VertSplit",     c.vertsplit, c.vertsplit,   nil)
h("Folded",         c.comment_fg, c.cursor_line, "italic")
h("FoldColumn",     c.gutter_fg,  nil,           nil)
h("CursorLineFold", c.yellow,     c.cursor_line, nil)
h("SignColumn",    c.fg,        nil,           nil)
h("MatchParen",    c.blue,      nil,           "underline")
h("SpecialKey",    c.fg,        nil,           nil)
h("Title",         c.green,     nil,           nil)
h("WildMenu",      c.fg,        nil,           nil)

-- Syntax
h("Whitespace",    c.non_text,   nil, nil)
h("NonText",       c.non_text,   nil, nil)
h("Comment",       c.comment_fg, nil, nil)
h("Constant",      c.cyan,       nil, nil)
h("String",        c.green,      nil, nil)
h("Character",     c.green,      nil, nil)
h("Number",        c.yellow,     nil, nil)
h("Boolean",       c.yellow,     nil, nil)
h("Float",         c.yellow,     nil, nil)
h("Identifier",    c.red,        nil, nil)
h("Function",      c.blue,       nil, nil)
h("Statement",     c.purple,     nil, nil)
h("Conditional",   c.purple,     nil, nil)
h("Repeat",        c.purple,     nil, nil)
h("Label",         c.purple,     nil, nil)
h("Operator",      c.fg,         nil, nil)
h("Keyword",       c.red,        nil, nil)
h("Exception",     c.purple,     nil, nil)
h("PreProc",       c.yellow,     nil, nil)
h("Include",       c.purple,     nil, nil)
h("Define",        c.purple,     nil, nil)
h("Macro",         c.purple,     nil, nil)
h("PreCondit",     c.yellow,     nil, nil)
h("Type",          c.yellow,     nil, nil)
h("StorageClass",  c.yellow,     nil, nil)
h("Structure",     c.yellow,     nil, nil)
h("Typedef",       c.yellow,     nil, nil)
h("Special",       c.blue,       nil, nil)
h("SpecialChar",   c.fg,         nil, nil)
h("Tag",           c.fg,         nil, nil)
h("Delimiter",     c.fg,         nil, nil)
h("SpecialComment", c.fg,        nil, nil)
h("Debug",         c.fg,         nil, nil)
h("Underlined",    c.fg,         nil, nil)
h("Ignore",        c.fg,         nil, nil)
h("Error",         c.red,        nil, nil)
h("Todo",          c.purple,     nil, nil)

-- Treesitter
h("@variable", c.muted_fg, nil, nil)

-- Plugins: GitGutter / Fugitive
h("GitGutterAdd",          c.green,  nil, nil)
h("GitGutterDelete",       c.red,    nil, nil)
h("GitGutterChange",       c.yellow, nil, nil)
h("GitGutterChangeDelete", c.red,    nil, nil)
h("diffAdded",             c.green,  nil, nil)
h("diffRemoved",           c.red,    nil, nil)

-- Plugin: mini.diff (25% dimmer than diff palette)
local mini_diff = {
    add    = { gui = "#6f9059", cterm = 65  },
    change = { gui = "#a88e5a", cterm = 137 },
    delete = { gui = "#a64f56", cterm = 131 },
}
h("MiniDiffSignAdd",     mini_diff.add,    nil, nil)
h("MiniDiffSignChange",  mini_diff.change, nil, nil)
h("MiniDiffSignDelete",  mini_diff.delete, nil, nil)
h("MiniDiffOverAdd",     nil, mini_diff.add,    nil)
h("MiniDiffOverChange",  nil, mini_diff.change, nil)
h("MiniDiffOverContext", nil, mini_diff.change, nil)
h("MiniDiffOverDelete",  nil, mini_diff.delete, nil)

-- Git commit
h("gitcommitComment",       c.comment_fg, nil, nil)
h("gitcommitUnmerged",      c.red,        nil, nil)
h("gitcommitOnBranch",      c.fg,         nil, nil)
h("gitcommitBranch",        c.purple,     nil, nil)
h("gitcommitDiscardedType", c.red,        nil, nil)
h("gitcommitSelectedType",  c.green,      nil, nil)
h("gitcommitHeader",        c.fg,         nil, nil)
h("gitcommitUntrackedFile", c.cyan,       nil, nil)
h("gitcommitDiscardedFile", c.red,        nil, nil)
h("gitcommitSelectedFile",  c.green,      nil, nil)
h("gitcommitUnmergedFile",  c.yellow,     nil, nil)
h("gitcommitFile",          c.fg,         nil, nil)
set_hl(0, "gitcommitNoBranch",        { link = "gitcommitBranch" })
set_hl(0, "gitcommitUntracked",       { link = "gitcommitComment" })
set_hl(0, "gitcommitDiscarded",       { link = "gitcommitComment" })
set_hl(0, "gitcommitSelected",        { link = "gitcommitComment" })
set_hl(0, "gitcommitDiscardedArrow",  { link = "gitcommitDiscardedFile" })
set_hl(0, "gitcommitSelectedArrow",   { link = "gitcommitSelectedFile" })
set_hl(0, "gitcommitUnmergedArrow",   { link = "gitcommitUnmergedFile" })

-- Splits and treesitter-context
h("WinSeparator",                    c.comment_fg, nil, nil)
h("TreesitterContext",               c.gutter_fg,  nil, nil)
h("TreesitterContextBottom",         nil,          nil, "underline")
h("TreesitterContextLineNumber",     c.fg,         nil, nil)
h("TreesitterContextLineNumberBottom", nil,        nil, "underline")

-- Terminal colors
vim.g.terminal_color_0  = c.black.gui
vim.g.terminal_color_1  = c.red.gui
vim.g.terminal_color_2  = c.green.gui
vim.g.terminal_color_3  = c.yellow.gui
vim.g.terminal_color_4  = c.blue.gui
vim.g.terminal_color_5  = c.purple.gui
vim.g.terminal_color_6  = c.cyan.gui
vim.g.terminal_color_7  = c.white.gui
vim.g.terminal_color_8  = c.comment_fg.gui
vim.g.terminal_color_9  = c.red.gui
vim.g.terminal_color_10 = c.green.gui
vim.g.terminal_color_11 = c.yellow.gui
vim.g.terminal_color_12 = c.blue.gui
vim.g.terminal_color_13 = c.purple.gui
vim.g.terminal_color_14 = c.cyan.gui
vim.g.terminal_color_15 = c.white.gui
vim.g.terminal_color_background = c.bg.gui
vim.g.terminal_color_foreground = c.fg.gui
