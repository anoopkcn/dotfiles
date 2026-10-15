# dirx: native APIs, redundancy and bug pass

- STATUS: CLOSED
- PRIORITY: 100
- TAGS: scope

Full review of `nvim/plugin/dirx.lua`: prefer Neovim's own APIs over hand-written helpers,
remove redundant code, fix bugs, keep it minimal. Follows 20261009-102036.

## Resolution (2026-10-09)

1299 -> 1187 lines. Behaviour unchanged except the bugs and the permissions column noted below.

### Native APIs instead of own code

| Was | Now |
|---|---|
| `perm_to_str` + `format_perm` (bit ops on `stat.mode`, 17 lines) | `vim.fn.getfperm()` |
| `resolve`: `^[/~]` check + `joinpath` + `normalize` | `vim.fs.normalize(vim.fs.abspath(input, { cwd = dir }))` |
| `vim.fn.mkdir(p, 'p')` | `vim.fs.mkdir(p, { parents = true })` |
| `find_buf` loop | `vim.iter(api.nvim_list_bufs()):find(...)` |
| `is_standalone` + `has_token` + `replace_tokens` (char loops, 35 lines) | `sub_token`: one `gsub` with `%f[%s]` frontier and a function replacement (literal `%`). Identical output on 17 templates (`*`, `?`, `**`, tabs, `%` names, adjacent tokens) |
| `build_header`, `strip_trailing_newline` | `vim.tbl_map`, `vim.list_extend(dst, src, 1, n)` |

Permissions column: `getfperm()` follows symlinks and has no setuid/setgid/sticky letters
(`/usr/bin/sudo` shows `r-x--x--x`, not `r-s--x--x`). Size/mtime now also come from
`fs_stat` (follow links), with `fs_lstat` for a broken link (shown as `?????????`).

### Redundancy removed

- File helpers (`trash`, `copy`, `move`, `create`) raise instead of returning error strings;
  `write_listings` wraps `apply` in one `pcall`. Removes the `if err then return err end`
  chains (apply alone had 7).
- Columns formatted once per render (`listing.cols`: perm/size/mtime strings) instead of on
  every `TextChanged`; `render_columns` only builds chunks. Dead `if chunks then` gone.
- `write_output` opens the window itself (callers did `write_output(ensure_output_window(), ...)`);
  `ensure_output_window` reuses `output_win_open` instead of repeating its check.
- `reload_listing` also skips a directory that is gone and returns whether it reloaded, so
  `write_listings` no longer repeats the `isdirectory` check; `refresh` no longer repeats
  the listing check.
- `notify` helper used everywhere (shell section had its own `vim.notify('dirx: ' ..)`),
  `uv` local at the top (was defined mid-file, `vim.uv` used before it).
- `write_listings` collects listings in one `tbl_filter` (was a loop + a second filter).
- `copy` makes the parent dir (apply did it separately before each copy).
- Removed `M._build_commands` ("exposed for tests", no tests use it).
- Misplaced doc comment (close_output's text above `output_win_open`) fixed.

### Bugs fixed

- `&` streaming split lines: job handlers can get a line in pieces (`:h channel-lines`);
  each piece was printed as its own line. Now the unfinished last line per stream is kept
  and joined with the next chunk, and flushed before the footer. Test: `printf ab; sleep;
  printf "cd\nef\n"` shows `abcd`, `ef` (was `ab`, `cd`, `ef`).
- Year in mtime was computed once at load (`current_year`), so a session spanning New Year
  showed this year's files with the year format. Now compared per call.
- `reload_listing` after `!`/`&` raised ENOENT if the command removed the listed directory.
- `toggle_columns` walks `listings` (loaded buffers) instead of every buffer.
- Job callbacks no longer go through `vim.schedule`: they already run on the main loop.

### Kept on purpose

- `format_size`, `format_mtime`, `same_file`, `common_dir`, `rebase`: no native equivalent.
- `cp -R` (`uv.fs_copyfile` is files only), `trash` CLI (no trash API).
- `jobstart` over `vim.system`: it splits output into lines for us.
- `InsertLeave` next to `TextChanged`: Neovim's `TextChanged` doc only promises Normal-mode
  changes, so not relying on it to fire after Insert mode.
- `nvim.dir.open` wrapper and `<Plug>` claims: no public hook for either.

Tested headless: all earlier suites (edit basics, swap, conflicts, `J`, undo, navigation, `R`,
copies and copy names, keymaps and `gq`, nine cross-listing cases, columns during `o`/`O`/`cc`)
plus new ones: `&` split lines, `!` stdout+stderr, an error mid-write (reported, earlier
operations kept, listing re-listed), permissions column incl. broken symlink. Real config
smoke test.
