# dirx: create, delete, rename, copy and move entries

- STATUS: CLOSED
- PRIORITY: 100
- TAGS: scope

The builtin `:h dir` listing is read-only ("dir.lua does not provide actions which modify
the filesystem"): every render resets `modifiable`/`readonly`, and lines must stay bare
entry names for `<CR>` to resolve. So file operations are keys on the listing (Dired/netrw
style), not oil-style edit-and-`:w`.

| Key | Mode | Action |
|---|---|---|
| `%` | n | create file; name ending in `/` creates a directory; parents created (`a/b/c.txt`) |
| `r` | n | rename/move, prompt pre-filled; target dir or trailing `/` receives the entry (mv) |
| `dd` | n | delete entry (file or dir) after confirm, to Trash |
| `d` | x | delete selection after one confirm |
| `yy` / `y` | n / x | yank paths for `p` (copy); also sets `v:register` |
| `x` | n / x | cut paths for `p` (move) |
| `p` | n | paste into this listing: copy or move per clipboard mode |

## Resolution (2026-10-07)

Added a "File operations" section to `nvim/plugin/dirx.lua` (`M.create`, `M.rename`,
`M.delete`, `M.yank`, `M.cut`, `M.paste`) and the mappings in the `FileType directory` autocmd.

- Delete: `/usr/bin/trash` via `vim.system`, fallback `vim.fs.rm(p, {recursive=true})`.
- Copy: `cp -R`. Move: `uv.fs_rename`, on `EXDEV` copy + `vim.fs.rm` (EXDEV path untested).
- Conflicts on `p`/`r`: confirm Yes/Skip/Cancel; the replaced target goes to Trash.
  Copy onto itself (`yy` then `p` in the same dir) prompts "Copy as:".
  Moving a dir into itself is refused. Case-only renames (`foo` -> `Foo`) are detected
  by inode so they aren't treated as "move into existing dir".
- Moving keeps buffers in sync: `nvim_buf_set_name` on file buffers and listings under the
  source, wipes the stale buffer set_name leaves under the old name, and `:edit!`s
  unmodified buffers so `:w` doesn't hit E13 (file exists). Modified buffers keep their
  changes and get a warning to save with `:w!`.
- Cut entries that weren't moved (skipped/cancelled) stay in the clipboard.
- After each op all listings of the affected dirs are reloaded and the cursor goes to the
  new/renamed/pasted entry.
- `collect_targets()` now takes `[count]` lines from the cursor (`2x`, `3dd`); this also
  applies to `!`/`&`, like Dired's prefix argument.
- Verified headless (`--clean`, `-n`, script run from VimEnter): %, nested %/, existing
  name, r with open buffer then `:w`, r into `sub/`, dd declined/accepted, `Vd` on a dir,
  `Vjy` + p of dir and file, p conflicts skip/overwrite, x + p across listings, empty p,
  copy-as next to source, `2x`, move into itself. With the full config no mapping conflicts.
