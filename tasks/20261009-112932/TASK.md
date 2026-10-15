# dirx: tilde and dollar names, copies from yanks only, drop M

- STATUS: CLOSED
- PRIORITY: 100
- TAGS: scope

Follow-up review of `nvim/plugin/dirx.lua` after 20261009-112136: fix `~`/`$` in names,
detect copies from yanks only, drop the `M` table, one helper for entry names.

## Resolution (2026-10-09)

1066 -> 1064 lines (+124 / -126). The simplifications removed about 40 lines; the bug fixes
and the two small features that fell out of them added most of that back.

### Bugs fixed

- `~` and `$` in typed names. `resolve` used `vim.fs.abspath` + `vim.fs.normalize` with
  defaults, so `~foo` became `/Users/akcfoo` (sibling of home), `~` became home, `$HOME` and
  `x$USER` were expanded. Now only `~/` expands (`abspath(..., { plain = not ~/ })`) and
  `normalize(..., { expand_env = false })`. The old hand-written resolve had the same bug.
- Same expansion in the confirm text (`vim.fs.relpath` normalizes and expands internally:
  `$HOME` showed as `Users/akc`) and in matching listing names in `refresh` and
  `write_listings`. Display now strips the root prefix; both `normalize` calls pass
  `expand_env = false`.
- Which register a put came from is only known by its text; with several registers holding
  the same text for different entries the winner depended on `pairs()` order. Now the
  registers are checked sorted, so the unnamed one wins: `p` of a name just deleted is
  always "put it back".

### Simplified

- Copy detection: one rule instead of three (text of an entry in the same listing, yank from
  another listing, cut copy line by its last text). A put line from a live yank (this
  listing or another) is a copy of that entry; it keeps its name unless another line has
  it, or a file has it whose line wasn't deleted here (then `copy_name`). Removed `sources`,
  `cut`, `valid`, the `.line` tracking in `listing.copies` (now id -> src path) and the
  `buf` field of yanks. `build_plan` drops a copy put back under its own source name.
- Dropped `M` and `return M`: a `plugin/` file can't be `require`d. `run_command`,
  `run_command_async`, `stop_command` became keymap callbacks; `close_output` and `reload`
  are locals (`close_output` moved above `ensure_output_window`, which maps `q` to it).
- `entry_name(line)` for strip-`/` + decode-NUL; used by `line_path`, `collect_targets`,
  `mark_copies` and `copy_name` (its `taken` now holds entry names).

### Behaviour changes

- `:t` and typing an existing name no longer make a copy (no register involved): they are
  plain creates and `:w` stops with "already exists". `yy`/`p` copies as before.
- New: a put can replace an entry whose line was deleted in the same listing. Copy (`yy` in
  A, `"_dd` foo in B, `p`): `copy foo -> B/foo` + `delete B/foo`, apply trashes B/foo right
  before the copy. Cut (`dd` in A, `"_dd` in B, `p`): `delete B/foo` + `move foo -> B/foo`.
- New: an unnamed yank is also recorded for `"0`, a delete for `"1`, as Vim fills them; so
  `yy` foo, `dd` bar, `"0p` copies foo. With the same name in both (`dd` foo, `"0p` foo) the
  text can't tell them apart and the unnamed register wins (put back); use `"_dd` there.

Tested headless: all earlier suites (edit basics and swap, conflicts/`J`/navigation/`R`,
copies incl. `ddp`/`ddP`/rename/`yyp`+`dd`, copy names via `yy`+`p`, keymaps and `gq`, nine
cross-listing cases, `o`/`O`, `&` split lines, `!`, error mid-write) plus new: `~foo` and
`$HOME` created and shown literally, `:t` and typed name clash, replace by `"_dd`+`p` (copy)
and by cut, `dd`+`p`+`p` (kept + one copy), `"0p` with different names. Real config smoke test.
