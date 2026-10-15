# surround: use a Lua operatorfunc and an augroup (0.13)

- STATUS: CLOSED
- PRIORITY: 100
- TAGS:

`nvim/plugin/surround.lua`.

- Nvim 0.13 accepts Lua functions for 'operatorfunc' (`:h option-value-function`), so the
  global `_G.__surround_op` and the `"v:lua.__surround_op"` string can go:
  `vim.o.operatorfunc = surround_op`. Verified on the nightly that `.` still repeats.
- The `ModeChanged` autocmd (line 142) has no augroup, so re-sourcing stacks duplicates.
- `noremap = true` in `expr_opts`/visual `S` is already the `vim.keymap.set` default.

Found in the Neovim 0.13 review on 2026-10-01.

## Resolution (2026-10-01)

`nvim/plugin/surround.lua`: `_G.__surround_op` is now a local `surround_op` assigned
directly to `vim.o.operatorfunc` (Nvim 0.13 Lua option values); the `ModeChanged` autocmd
is in a `surround` augroup; `noremap = true` dropped. Verified: no `_G.__surround_op`, one
autocmd in the group, `.` repeat of `ys` and `ds` works.
