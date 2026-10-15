# dirx: edit the listing and :w to apply, oil-style

- STATUS: CLOSED
- PRIORITY: 100
- TAGS: scope

Make the builtin `:h dir` listing an ordinary editable buffer, and have `:w` turn the edits
into file operations, like oil.nvim. Replaces the key-driven file operations of
20261007-095118 (`%`, `r`, `dd`, `yy`, `x`, `p`); `!`, `&`, `<C-c>`, `gl` and `q` stay.

## Resolution (2026-10-09)

"Editing" section of `nvim/plugin/dirx.lua` (replaces "File operations").

| Edit | On `:w` |
|---|---|
| change a name | rename; a path (`sub/x`, `../x`, `~/x`, `/abs`) moves it, creating parents |
| delete the line, or blank the name | delete, to Trash (`trash`, fallback `vim.fs.rm`) |
| new line | create a file; a trailing `/` creates a directory; parents created |
| `dd` then `p` elsewhere | nothing (delete + create of the same name cancel out) |

- Identity: `DirReadPost` puts an extmark on each entry (`dirx.entries`, `id` = line number
  in the render, `invalidate = true`) and snapshots the lines + lstat in `listings[buf]`.
  Marks follow their line through `cc`/`cw`/`I`/`o`/`O`; `dd` invalidates them and undo
  restores them. Lines are still bare names, so `<CR>` keeps working.
- Unlocking: dir.lua sets `nowrite`/`readonly`/`nomodifiable` right after `DirReadPost`, so
  dirx flips to `acwrite`/`modifiable` in a `vim.schedule`. `acwrite` routes `:w` to a
  buffer-local `BufWriteCmd` (`nested`, so the reload goes through `BufReadCmd`).
- Each render clears undo history (`undolevels=-1` trick), so `u` after `:w` can't bring
  back the old names.
- Validation before the confirm: a target named twice, a target that exists and isn't
  being deleted or moved away, moving a dir into itself, and two entries on one line
  (`J`). Errors abort the write and leave the buffer modified.
- Confirm lists delete/move/create; Enter confirms unless something is deleted.
- Order: deletes, then moves, then creates. A move waits until its target is free; a
  cycle (`x -> y`, `y -> x`) parks one source under `<src>.dirx-<hrtime>`. Moves keep
  file buffers in sync (`rename_buffers`, unchanged from before).
- Unsaved edits are kept: `nvim.dir.open` is wrapped to skip re-listing a modified
  listing (`-`/`<CR>` navigate with `:edit` + `open`), `reload_listing` skips modified
  listings (after `!`/`&` and after a `:w` elsewhere), `:e` stops at E37, and `R` is
  remapped to ask before dropping edits. `:e!` still discards.
- Columns are re-placed on `TextChanged`/`InsertLeave` from the entry marks, so they stay
  with their entry after `O`/`dd`; new lines get blank padding.

Tested headless on a scratch dir with a fake `trash`: rename, delete, move into a subdir,
create file/dir, the x/y swap, `dd`+`p` no-op, conflict and `J` errors, undo after `:w`,
edits surviving `-` + `<CR>`, `:e` E37, `R`, blanking a name.

Superseded below: moving or copying between listings by `dd`/`yy` in one and `p`
in another (that creates an empty file; rename the line to `../other/name` instead).

## Resolution: copy by putting a line (2026-10-09)

`mark_copies()` in `nvim/plugin/dirx.lua`, run on `TextChanged`/`InsertLeave`: a line with
no entry/copy mark whose text matches a line that is still an entry (or a copy) becomes a
copy of it. It is renamed in the buffer right away, and the rename is `undojoin`ed with the
put, so one `u` undoes both. It gets a mark in `dirx.copies` (source in `listing.copies`),
so renaming it before `:w` (e.g. to `sub/notes.txt`) still copies.

- Names (`copy_name`): `notes.txt` -> `notes_copy_1.txt`, then `_copy_2`, ... (first N free
  on disk and in the buffer); `src/` -> `src_copy_1/`; `.zshrc` -> `.zshrc_copy_1`;
  `a.tar.gz` -> `a.tar_copy_1.gz` (last extension only); a copy of a copy counts on.
- Only copies while the source line is still in the buffer, so `ddp` on an entry stays a
  no-op. A copy line that is cut and put back keeps its identity (matched by its last text).
- Typing a new line with an existing entry's name also turns it into a copy (shown in the
  confirm, so it can be refused).
- `:w` runs copies first (`cp -R`), before deletes/moves, so copying and deleting or
  renaming the source in one write works. A copy target must not exist before the write
  (a name freed by a delete in the same write is refused); copying a dir into itself is
  refused. A blanked copy line is dropped.

Tested headless: yyp/p/copy-of-copy numbering, single `u`, dir/dotfile/tar.gz names, `ddp`
on an entry and on a copy, renaming a copy into a subdir, copy + delete of the source in one
write, file contents copied.

## Keymaps for the editable listing (2026-10-09)

- Output window closes with `gq` in the listing (was `q`), so `q` records macros there.
  `q` still closes it from inside the output window.
- `a`/`o` are no longer dir.lua's split-open keys: dirx maps `<Plug>(dirx-vsplit)` and
  `<Plug>(dirx-split)` to `<Plug>(nvim-dir-vsplit)`/`<Plug>(nvim-dir-split)`, and dir.lua's
  `_map` skips a default key when `hasmapto(<Plug>)`. Deleting the maps wouldn't stick:
  `fs.init` re-maps them every time `-`/`<CR>` navigates into a listing.

## Resolution: one :w for all listings, cut/copy between listings (2026-10-09)

Before, each listing was its own buffer and `:w` applied only that one; edits in a listing
left with `-`/`<CR>` stayed pending until `:wa` (one confirm per listing, no checks across
listings).

- `write_listings()`: `:w` in any listing collects the edits of every listing with unsaved
  ones into one plan (`collect()` per listing, `build_plan(bufs)`), validates it as a whole
  (names twice, existing targets, targets inside a deleted dir), and shows one confirm with
  paths relative to the directory that holds everything.
- `apply()` runs copies, deletes, moves, deletes of dirs that moves take entries out of,
  then creates. Each move rebases the pending paths under it, so edits inside a dir that
  another listing renames land in the new place (`src -> lib` + `src/new` = `lib/new`).
- Cut/copy between listings: `TextYankPost` in a listing records, per register, the path
  each yanked line stands for (`yanks`; marks are still valid when it fires for `dd`).
  `mark_copies()` turns a put line into a copy of that path if the register still holds
  that yank (`getreg` + `getregtype == 'V'`), keeping its name unless it clashes
  (`_copy_N`). `build_plan` turns a copy whose source is deleted in the same write into a
  move. So `yy` there + `p` here = copy, `dd` there + `p` here = move. In one listing,
  `yyp` + `dd` of the original is now a move too.
- After applying, written listings are re-listed by buffer (a listing renamed along with
  its directory keeps working); a listing of a deleted dir is wiped unless a window shows it.
- Fixed `refresh()`: listing names end in `/` but `vim.fs.dirname` results don't, so other
  listings of affected dirs were never re-listed (bug since 20261007-095118).
- Fixed in passing: parking a move for a swap must set the parked `src` itself, not via
  the prefix rebase (an exact-match rebase would point `y -> x` at the temp name).

Tested headless (fake `trash`): edits in parent + child applied by one `:w`; child edits
following a parent rename; `dd`/`p` across listings = move, `yy`/`p` = copy; cut from a
child that the parent deletes (saved first, then the dir trashed); a clash renamed to
`_copy_1`; a put into a deleted dir refused; `yyp` + `dd` = move; a stale register =
plain create; earlier suites (swap, conflicts, `J`, undo, navigation, `R`, keymaps) still pass.

## Fix: columns jumped to the line opened by o/O (2026-10-09)

The column marks have left gravity (so text typed at col 0 by `cc`/`I` stays after them), but
that also leaves a mark at col 0 of the next line on a line that `o`/`O` inserts, so the
entry's columns showed on the new empty line and the entry had none until `<Esc>`
(`TextChanged`/`InsertLeave` re-placed them). Now `render_columns` also runs on every
`InsertEnter` (the opened line already exists then) and on `TextChangedI` when the line
count changed since the last render (`listing.rendered_lines`, e.g. `<C-r>` puts). Empty
lines get blank padding too, so the cursor typing a new name lines up with the others.
