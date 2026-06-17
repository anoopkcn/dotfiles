-- slate — soft pastel-on-slate dark theme
-- lifted cool-slate background, soft off-white text, desaturated
-- pastel accents. Easy on the eyes for long sessions. Port: @anoopkcn

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.o.background = "dark"
vim.g.colors_name = "slate"

local c = {
    -- Neutral slate ramp (lifted off black -> soft cool white)
    bg_1   = { gui = "#1d2029", cterm = 235 }, -- deepest (popup / float depth)
    bg     = { gui = "#232732", cterm = 235 }, -- Normal background  [measured]
    bg1    = { gui = "#2a2f3d", cterm = 236 }, -- CursorLine / Pmenu
    bg2    = { gui = "#32384a", cterm = 237 }, -- NonText / separators
    bg3    = { gui = "#303a54", cterm = 238 }, -- Visual (blue-tinted)
    bg4    = { gui = "#4d5566", cterm = 240 }, -- fold / conceal / sign chrome
    gutter = { gui = "#5b647b", cterm = 242 }, -- line numbers (lifted for legibility)
    fg     = { gui = "#e0e2ea", cterm = 254 }, -- Normal text        [measured]
    fg1    = { gui = "#f0f1f6", cterm = 255 }, -- emphasised text
    fdim   = { gui = "#b5bbc4", cterm = 250 }, -- secondary text / punctuation [measured]
    white  = { gui = "#ffffff", cterm = 231 },
    black  = { gui = "#000000", cterm = 16  },

    -- Soft pastel accents (measured where noted)
    comment = { gui = "#828c9e", cterm = 245 }, -- muted slate-gray
    blue    = { gui = "#88a0c8", cterm = 110 }, -- keywords / control flow (softened slate-blue)
    purple2 = { gui = "#c099ff", cterm = 141 }, -- control (airy lilac, bold)
    green   = { gui = "#a0ddac", cterm = 114 }, -- strings             [measured]
    green2  = { gui = "#8cc570", cterm = 107 }, -- diff-add / raw      [measured]
    cyan    = { gui = "#a0def3", cterm = 153 }, -- types / builtins    [measured]
    orange  = { gui = "#ef9f64", cterm = 215 }, -- numbers / constants
    yellow  = { gui = "#ecbe70", cterm = 222 }, -- preproc / labels    [measured]
    red     = { gui = "#f7768e", cterm = 211 }, -- errors / self
    pink    = { gui = "#db9fd6", cterm = 182 }, -- escapes / special
}

local set_hl = vim.api.nvim_set_hl

-- h(group, fg, bg, ...attrs) — attrs are strings like "bold", "italic", "underline"
local function h(group, fg, bg, ...)
    local spec = {}
    if fg then spec.fg, spec.ctermfg = fg.gui, fg.cterm end
    if bg then spec.bg, spec.ctermbg = bg.gui, bg.cterm end
    for _, a in ipairs({ ... }) do spec[a] = true end
    set_hl(0, group, spec)
end

-- undercurl with a wave colour (used for spell / diagnostics)
local function uc(group, color)
    set_hl(0, group, { undercurl = true, sp = color.gui, cterm = { undercurl = true } })
end

local function link(from, to) set_hl(0, from, { link = to }) end

-- UI: editor surface
h("Normal",       c.fg,     c.bg)            -- set bg = nil here for terminal transparency
link("NormalNC", "Normal")
h("Cursor",       c.bg,     c.fg)
link("lCursor",     "Cursor")
link("CursorIM",    "Cursor")
link("TermCursor",  "Cursor")
h("CursorLine",     nil,      c.bg1)
h("CursorColumn",   nil,      c.bg1)
h("CursorLineNr",   c.yellow, c.bg1, "bold")
h("CursorLineSign", c.bg4,    c.bg1)
h("CursorLineFold", c.bg4,    c.bg1)
h("LineNr",         c.gutter, nil)
link("LineNrAbove", "LineNr")
link("LineNrBelow", "LineNr")
h("SignColumn",   c.bg4,    c.bg)
h("FoldColumn",   c.bg4,    c.bg)
h("Folded",       c.comment, c.bg1, "italic")
h("ColorColumn",  nil,      c.bg1)
h("VertSplit",    c.bg2,    nil)
h("WinSeparator", c.bg2,    nil)
h("Visual",       nil,      c.bg3)
h("VisualNOS",    nil,      c.bg3)
h("QuickFixLine", nil,      c.bg1)
h("MatchParen",   c.cyan,   c.bg3, "bold")
h("Conceal",      c.bg4,    nil)
h("NonText",      c.bg2,    nil)
h("Whitespace",   c.bg2,    nil)
h("SpecialKey",   c.bg2,    nil)
h("EndOfBuffer",  c.bg,     nil)
h("Directory",    c.purple2,   nil)
h("Title",        c.purple2,   nil, "bold")
h("SnippetTabstop", nil,    c.bg3)

-- Search
-- h("Search",     c.bg,    c.purple2)      -- all / lazy matches
-- h("IncSearch",  c.bg,    c.yellow)       -- current match
-- h("CurSearch",  c.bg,    c.yellow)
h("Substitute", c.bg,    c.red)

-- Messages
h("ErrorMsg",   c.red)
h("WarningMsg", c.yellow)
h("ModeMsg",    c.fg)
h("MoreMsg",    c.green)
h("Question",   c.green)
h("MsgArea",    c.fg)
h("MsgSeparator", c.bg2)

-- Popup / completion menus
h("Pmenu",         c.fg,      c.bg_1)
h("PmenuSel",      c.fg1,     c.bg3)
h("PmenuSbar",     nil,       c.bg2)
h("PmenuThumb",    nil,       c.bg4)
h("PmenuKind",     c.cyan,    c.bg_1)
h("PmenuKindSel",  c.cyan,    c.bg3)
h("PmenuExtra",    c.comment, c.bg_1)
h("PmenuExtraSel", c.comment, c.bg3)
h("PmenuMatch",    c.purple2, c.bg_1, "bold")  -- fuzzy-matched chars (nvim 0.11+)
h("PmenuMatchSel", c.purple2, c.bg3, "bold")
h("ComplMatchIns", c.comment)                     -- inline insert preview (nvim 0.11+)
h("NormalFloat",   c.fg,      c.bg)
h("FloatBorder",   c.bg4,     c.bg)
h("FloatTitle",    c.purple2, c.bg, "bold")
link("FloatFooter", "FloatTitle")
link("WildMenu",    "IncSearch")

-- Statusline / tabline / winbar
h("StatusLine",   c.fg,      c.bg1)
h("StatusLineNC", c.comment, c.bg1)
link("StatusLineTerm",   "StatusLine")
link("StatusLineTermNC", "StatusLineNC")
h("WinBar",       c.fg,      nil, "bold")
h("WinBarNC",     c.comment, nil)
h("TabLine",      c.comment, c.bg1)
h("TabLineFill",  nil,       c.bg1)
h("TabLineSel",   c.fg1,     c.bg3, "bold")

-- Quickfix / debug
h("qfFileName", c.purple2)
h("qfLineNr",   c.yellow)
h("qfText",     c.fg)
h("debugPC",         nil,   c.bg3)
h("debugBreakpoint", c.red, nil)

-- Diff (background tints, readable text kept on top)
local diff = {
    add    = { gui = "#1f3a2c", cterm = 22  },
    change = { gui = "#2a3145", cterm = 237 },
    text   = { gui = "#3a4a6a", cterm = 24  },
    delete = { gui = "#3a2630", cterm = 52  },
}
h("DiffAdd",    nil,    diff.add)
h("DiffChange", nil,    diff.change)
h("DiffText",   nil,    diff.text)
h("DiffDelete", c.red,  diff.delete)
h("Added",      c.green2)
h("Changed",    c.yellow)
h("Removed",    c.red)

-- Spell
uc("SpellBad",   c.red)
uc("SpellCap",   c.yellow)
uc("SpellRare",  c.blue)
uc("SpellLocal", c.cyan)

-- Syntax (legacy groups)
h("Comment",        c.comment, nil, "italic")
h("Constant",       c.orange)
h("String",         c.green)
h("Character",      c.green)
h("Number",         c.orange)
h("Boolean",        c.orange)
h("Float",          c.orange)
h("Identifier",     c.fg)
h("Function",       c.cyan)
h("Statement",      c.blue, nil, "bold")
h("Conditional",    c.blue, nil, "bold")
h("Repeat",         c.blue, nil, "bold")
h("Label",          c.yellow)
h("Operator",       c.fdim)
h("Keyword",        c.blue, nil, "bold")
h("Exception",      c.blue, nil, "bold")
h("PreProc",        c.yellow)
h("Include",        c.blue, nil, "bold")
h("Define",         c.yellow)
h("Macro",          c.yellow)
h("PreCondit",      c.yellow)
h("Type",           c.cyan)
h("StorageClass",   c.cyan)
h("Structure",      c.cyan)
h("Typedef",        c.cyan)
h("Special",        c.pink)
h("SpecialChar",    c.pink)
h("Tag",            c.yellow)
h("Delimiter",      c.fdim)
h("SpecialComment", c.comment, nil, "italic")
h("Debug",          c.red)
h("Underlined",     c.purple2,    nil, "underline")
h("Bold",           nil,       nil, "bold")
h("Italic",         nil,       nil, "italic")
h("Ignore",         c.bg4)
h("Error",          c.red)
h("Todo",           c.yellow,  nil, "bold")
h("healthError",    c.red)
h("healthWarning",  c.yellow)
h("healthSuccess",  c.green)

-- Treesitter: variables / constants / modules
h("@variable",                   c.fg)
h("@variable.builtin",           c.red)
h("@variable.parameter",         c.fdim)
h("@variable.parameter.builtin", c.red)
h("@variable.member",            c.fg)
h("@constant",                   c.orange)
h("@constant.builtin",           c.orange)
h("@constant.macro",             c.yellow)
h("@module",                     c.fg)
h("@module.builtin",             c.fg)
h("@label",                      c.yellow)
-- Treesitter: literals
h("@string",              c.green)
h("@string.regexp",       c.pink)
h("@string.escape",       c.pink)
h("@string.special",      c.pink)
h("@string.special.symbol", c.orange)
h("@string.special.url",  c.cyan,  nil, "underline")
h("@string.special.path", c.green)
h("@character",           c.green)
h("@character.special",   c.pink)
h("@number",              c.orange)
h("@number.float",        c.orange)
h("@boolean",             c.orange)
-- Treesitter: functions / types
h("@function",            c.cyan)
h("@function.builtin",    c.cyan)
h("@function.call",       c.cyan)
h("@function.macro",      c.yellow)
h("@function.method",     c.cyan)
h("@function.method.call", c.cyan)
h("@constructor",         c.cyan)
h("@type",                c.cyan)
h("@type.builtin",        c.cyan)
h("@type.definition",     c.cyan)
h("@type.qualifier",      c.blue, nil, "bold")
h("@attribute",           c.yellow)
h("@attribute.builtin",   c.yellow)
h("@property",            c.fg)
h("@field",               c.fg)
h("@namespace",           c.fg)
-- Treesitter: keywords
h("@keyword",             c.blue, nil, "bold")
h("@keyword.function",    c.blue, nil, "bold")
h("@keyword.operator",    c.blue, nil, "bold")
h("@keyword.return",      c.blue, nil, "bold")
h("@keyword.conditional", c.blue, nil, "bold")
h("@keyword.repeat",      c.blue, nil, "bold")
h("@keyword.exception",   c.blue, nil, "bold")
h("@keyword.import",      c.blue, nil, "bold")
h("@keyword.coroutine",   c.blue, nil, "bold")
h("@keyword.debug",       c.blue, nil, "bold")
h("@keyword.directive",   c.yellow, nil, "bold")
h("@keyword.directive.define", c.yellow, nil, "bold")
h("@operator",            c.fdim)
-- Treesitter: punctuation / tags
h("@punctuation.delimiter", c.fdim)
h("@punctuation.bracket", c.fdim)
h("@punctuation.special", c.pink)
h("@tag",                 c.blue)
h("@tag.builtin",         c.blue)
h("@tag.attribute",       c.yellow)
h("@tag.delimiter",       c.fdim)
-- Treesitter: comments
h("@comment",             c.comment, nil, "italic")
h("@comment.documentation", c.comment, nil, "italic")
h("@comment.error",       c.red)
h("@comment.warning",     c.yellow)
h("@comment.todo",        c.yellow,  nil, "bold")
h("@comment.note",        c.purple2)
-- Treesitter: markup (markdown etc.)
h("@markup.heading",       c.purple2,   nil, "bold")
h("@markup.heading.1",     c.purple2,   nil, "bold")
h("@markup.heading.2",     c.cyan,   nil, "bold")
h("@markup.heading.3",     c.green,  nil, "bold")
h("@markup.heading.4",     c.yellow, nil, "bold")
h("@markup.heading.5",     c.orange, nil, "bold")
h("@markup.heading.6",     c.blue, nil, "bold")
h("@markup.strong",        nil,      nil, "bold")
h("@markup.italic",        nil,      nil, "italic")
h("@markup.strikethrough", nil,      nil, "strikethrough")
h("@markup.underline",     nil,      nil, "underline")
h("@markup.raw",           c.green2)
h("@markup.raw.block",     c.green2)
h("@markup.math",          c.cyan)
h("@markup.quote",         c.comment)
h("@markup.list",          c.yellow)
h("@markup.list.checked",   c.green2)
h("@markup.list.unchecked", c.comment)
h("@markup.link",          c.purple2,   nil, "underline")
h("@markup.link.url",      c.cyan,   nil, "underline")
h("@markup.link.label",    c.purple2)
h("@diff.plus",            c.green2)
h("@diff.minus",           c.red)
h("@diff.delta",           c.yellow)

-- LSP semantic tokens (fall back to the treesitter captures above)
link("@lsp.type.namespace", "@namespace")
link("@lsp.type.type",      "@type")
link("@lsp.type.class",     "@type")
link("@lsp.type.enum",      "@type")
link("@lsp.type.interface", "@type")
link("@lsp.type.struct",    "@type")
link("@lsp.type.parameter", "@variable.parameter")
link("@lsp.type.variable",  "@variable")
link("@lsp.type.property",  "@property")
link("@lsp.type.function",  "@function")
link("@lsp.type.method",    "@function.method")
link("@lsp.type.macro",     "@function.macro")
link("@lsp.type.keyword",   "@keyword")
link("@lsp.type.comment",   "@comment")
link("@lsp.type.decorator", "@attribute")
link("@lsp.typemod.function.defaultLibrary", "@function.builtin")
link("@lsp.typemod.variable.defaultLibrary", "@variable.builtin")

-- LSP UI: references, inlay hints, code lens, signature
h("LspReferenceText",  nil, c.bg2)
h("LspReferenceRead",  nil, c.bg2)
h("LspReferenceWrite", nil, c.bg2)
link("LspReferenceTarget", "LspReferenceText")
h("LspInlayHint", c.comment, c.bg1, "italic")
h("LspCodeLens",  c.comment, nil,   "italic")
h("LspSignatureActiveParameter", c.yellow, c.bg3, "bold")
h("LspInfoBorder", c.bg4, c.bg_1)

-- Diagnostics
h("DiagnosticError", c.red)
h("DiagnosticWarn",  c.yellow)
h("DiagnosticInfo",  c.purple2)
h("DiagnosticHint",  c.cyan)
h("DiagnosticOk",    c.green)
uc("DiagnosticUnderlineError", c.red)
uc("DiagnosticUnderlineWarn",  c.yellow)
uc("DiagnosticUnderlineInfo",  c.purple2)
uc("DiagnosticUnderlineHint",  c.cyan)
h("DiagnosticUnnecessary", c.comment)
h("DiagnosticDeprecated",  c.comment, nil, "strikethrough")
link("DiagnosticVirtualTextError", "DiagnosticError")
link("DiagnosticVirtualTextWarn",  "DiagnosticWarn")
link("DiagnosticVirtualTextInfo",  "DiagnosticInfo")
link("DiagnosticVirtualTextHint",  "DiagnosticHint")
link("DiagnosticFloatingError", "DiagnosticError")
link("DiagnosticFloatingWarn",  "DiagnosticWarn")
link("DiagnosticFloatingInfo",  "DiagnosticInfo")
link("DiagnosticFloatingHint",  "DiagnosticHint")
link("DiagnosticSignError", "DiagnosticError")
link("DiagnosticSignWarn",  "DiagnosticWarn")
link("DiagnosticSignInfo",  "DiagnosticInfo")
link("DiagnosticSignHint",  "DiagnosticHint")

-- Plugins: GitGutter / GitSigns
h("GitGutterAdd",          c.green2)
h("GitGutterDelete",       c.red)
h("GitGutterChange",       c.yellow)
h("GitGutterChangeDelete", c.red)
link("GitSignsAdd",    "GitGutterAdd")
link("GitSignsChange", "GitGutterChange")
link("GitSignsDelete", "GitGutterDelete")

-- Plugin: mini.diff
local mini_diff = {
    add    = { gui = "#6aa052", cterm = 71  },
    change = { gui = "#b59a55", cterm = 137 },
    delete = { gui = "#c06a78", cterm = 168 },
}
h("MiniDiffSignAdd",     mini_diff.add)
h("MiniDiffSignChange",  mini_diff.change)
h("MiniDiffSignDelete",  mini_diff.delete)
h("MiniDiffOverAdd",     nil, diff.add)
h("MiniDiffOverChange",  nil, diff.change)
h("MiniDiffOverContext", nil, diff.change)
h("MiniDiffOverDelete",  nil, diff.delete)

-- Plugin: vim-fugitive + builtin diff syntax
h("diffAdded",       c.green2)
h("diffRemoved",     c.red)
h("diffChanged",     c.yellow)
h("diffFile",        c.purple2)
h("diffNewFile",     c.green2)
h("diffOldFile",     c.red)
h("diffLine",        c.blue)
h("diffIndexLine",   c.blue)
h("fugitiveHeader",          c.yellow)
h("fugitiveHeading",         c.yellow, nil, "bold")
h("fugitiveHash",            c.orange)
h("fugitiveSymbolicRef",     c.purple2)
h("fugitiveStagedHeading",   c.green2, nil, "bold")
h("fugitiveStagedModifier",  c.green2)
h("fugitiveUnstagedHeading", c.yellow, nil, "bold")
h("fugitiveUnstagedModifier", c.red)
h("fugitiveUntrackedHeading", c.comment, nil, "bold")
h("fugitiveUntrackedModifier", c.comment)

-- Git commit buffer
h("gitcommitComment",       c.comment)
h("gitcommitUnmerged",      c.red)
h("gitcommitOnBranch",      c.fg)
h("gitcommitBranch",        c.purple2)
h("gitcommitDiscardedType", c.red)
h("gitcommitSelectedType",  c.green2)
h("gitcommitHeader",        c.fg)
h("gitcommitUntrackedFile", c.comment)
h("gitcommitDiscardedFile", c.red)
h("gitcommitSelectedFile",  c.green2)
h("gitcommitUnmergedFile",  c.yellow)
h("gitcommitFile",          c.fg)
link("gitcommitNoBranch",       "gitcommitBranch")
link("gitcommitUntracked",      "gitcommitComment")
link("gitcommitDiscarded",      "gitcommitComment")
link("gitcommitSelected",       "gitcommitComment")
link("gitcommitDiscardedArrow", "gitcommitDiscardedFile")
link("gitcommitSelectedArrow",  "gitcommitSelectedFile")
link("gitcommitUnmergedArrow",  "gitcommitUnmergedFile")

-- treesitter-context
h("TreesitterContext",                 c.fg,  c.bg1)
h("TreesitterContextLineNumber",       c.bg4, c.bg1)
h("TreesitterContextBottom",           nil,   nil, "underline")
h("TreesitterContextLineNumberBottom", nil,   nil, "underline")

-- Terminal colors
vim.g.terminal_color_0  = c.bg2.gui
vim.g.terminal_color_1  = c.red.gui
vim.g.terminal_color_2  = c.green.gui
vim.g.terminal_color_3  = c.yellow.gui
vim.g.terminal_color_4  = c.blue.gui
vim.g.terminal_color_5  = c.purple2.gui
vim.g.terminal_color_6  = c.cyan.gui
vim.g.terminal_color_7  = c.fg.gui
vim.g.terminal_color_8  = c.comment.gui
vim.g.terminal_color_9  = c.red.gui
vim.g.terminal_color_10 = c.green2.gui
vim.g.terminal_color_11 = c.yellow.gui
vim.g.terminal_color_12 = c.blue.gui
vim.g.terminal_color_13 = c.pink.gui
vim.g.terminal_color_14 = c.cyan.gui
vim.g.terminal_color_15 = c.white.gui
vim.g.terminal_color_background = c.bg.gui
vim.g.terminal_color_foreground = c.fg.gui
