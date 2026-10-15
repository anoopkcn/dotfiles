# Clenaup the unused keybindings

- STATUS: CLOSED
- PRIORITY: 100
- TAGS: scope

There are some keymaps that are not used in the current configuration. We need to identify and remove them to clean up the keybindings.

## Resolution (2026-10-01)

`nvim/init.lua` and `nvim/plugin/brackets.lua`:
- `<leader>d` was mapped twice in normal mode; the diagnostics->quickfix mapping silently
  overrode the `"_d` delete. Diagnostics->quickfix moved to `<leader>D`, so `<leader>d` is
  `"_d` in normal and visual mode again.
- Removed `<M-j>`/`<M-k>` (same as `]q`/`[q`) and `]x`/`[x` (same as builtin `]d`/`[d`).
- Kept `<leader>x` and `<leader>on` (duplicate builtin `<C-w>d` / `<C-w>o`, kept by choice).
- Also see 20261001-180016 for the brackets.lua defaults cleanup.
Note: `<C-l>` (focus right window) shadows the builtin CTRL-L, which in Nvim 0.13 also
clears multicursors (`:h multicursor`).
