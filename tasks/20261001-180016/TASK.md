# brackets: drop mappings that duplicate Nvim defaults

- STATUS: CLOSED
- PRIORITY: 100
- TAGS:

`nvim/plugin/brackets.lua`.

Nvim (since 0.11) ships unimpaired-style defaults in `vim/_core/defaults.lua`:
- `]b`/`[b`: identical to the built-in -> remove.
- `]<Space>`/`[<Space>`: built-in goes through `g@l`, so it is `.`-repeatable; ours is not -> remove.
- `]x`/`[x`: same as built-in `]d`/`[d` -> remove unless the `x` muscle memory matters.

Keep:
- `]q`/`[q`: ours wraps around (cfirst/clast) and runs `zv`; the built-in does neither.
- `]e`/`[e`: not built in.

Also `noremap = true` in `opts` is the default.

Found in the Neovim 0.13 review on 2026-10-01.

## Resolution (2026-10-01)

`nvim/plugin/brackets.lua` now only keeps `]q`/`[q` (wrap + `zv`) and `]e`/`[e`.
Removed `]b`/`[b` and `]<Space>`/`[<Space>` (builtin defaults take over) and, by choice,
`]x`/`[x` (use builtin `]d`/`[d`). `noremap` dropped; header comment points at the
builtin help tags. Verified with maparg that `]b`/`]<Space>` resolve to the builtins.
