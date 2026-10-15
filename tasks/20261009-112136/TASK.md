# dirx: drop the metadata columns

- STATUS: CLOSED
- PRIORITY: 100
- TAGS: scope

Listings show bare file names, like the native dir listing, instead of the ls -l style
permissions/size/mtime columns. Follows 20261009-111329.

## Resolution (2026-10-09)

`nvim/plugin/dirx.lua`: 1187 -> 1065 lines (-122). Removed the `dirx.columns` namespace,
`set_hl` + the `DirxPerm`/`DirxSize`/`DirxMtime` groups and the `ColorScheme` hook,
`format_size`, `format_mtime`, `render_columns`, the stat/`getfperm` loop in
`DirReadPost`, `listing.cols`/`size_width`/`rendered_lines`, `M.toggle_columns` and `gl`.

The `o`/`O` handling (left-gravity column marks, `InsertEnter`/`TextChangedI` re-placing,
blank padding on new lines) only existed for the columns and went with them. Entry identity
marks (`dirx.entries`) are default (right) gravity and follow their line under `o`/`O`/`cc`/`dd`
(checked in the very first extmark test of 20261009-102036). `InsertLeave` next to
`TextChanged` stays: it is for put/typed copy detection (`mark_copies`), not columns.

Tested headless: new `o`/`O` test (`O` above and `o` below an entry, `cc` rename of it ->
`move b -> b2`, `create above`, `create below`, identity marks on a/b2/c), plus edit basics
and swap, conflicts/`J`/navigation/`R`, copies and copy names, keymaps (`gl` gone), nine
cross-listing cases, `&` split lines, `!` output, error mid-write. Real config smoke test.
