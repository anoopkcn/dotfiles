# search_replace: escape ~ in the visual-selection replacement

- STATUS: CLOSED
- PRIORITY: 100
- TAGS:

`nvim/plugin/search_replace.lua:38`.

The replacement escapes `\ / &` but not `~`, which in `:s` means "previous replacement
string".

Repro (verified headless): after `:s/foo/QQ/`, replacing a selected `x~y` turns it into
`xQQy`.

Fix: `vim.fn.escape(text, [[\/&~]])`. While there: the file mixes 2-space indent and an
odd indent on line 56; the other Lua files in `nvim/` use 4 spaces.

Found in the Neovim 0.13 review on 2026-10-01.

## Resolution (2026-10-01)

`nvim/plugin/search_replace.lua`: replacement now escapes `\/&~`; file reindented to 4
spaces. Verified headless: after `:s/foo/QQ/`, `<leader>s` on a selected `x~y` builds
`%s/\Vx~y/x\~y/gI` and leaves `x~y` as `x~y` (was `xQQy`).
