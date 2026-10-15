# check if official oil plugin changed something in their API

- STATUS: CLOSED
- PRIORITY: 100
- TAGS: scope

Since I use a modified version of the official oil plugin. I need to check if there are any official changes

## Resolution (2026-10-01)

No longer needed: oil.nvim was dropped in favour of the builtin `:h dir` listing.
The fork's features I used (permissions/size/mtime columns, Dired-style `!`/`&`/`<C-c>`)
were ported to `nvim/lua/dirx.lua`; see 20261001-100536.
