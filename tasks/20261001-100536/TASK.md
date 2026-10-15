# dirx: oil features (columns, ! command) for builtin dir explorer

- STATUS: CLOSED
- PRIORITY: 100
- TAGS: scope

Replace oil.nvim (my fork at ~/develop/oil.nvim) with the builtin `:h dir` listing
(nvim 0.13 nightly), keeping the two features I used:

1. permissions / size / mtime columns (oil `columns = { "permissions", "size", "mtime" }`)
2. Dired-style `!` / `&` / `<C-c>` shell commands on the entry or selection
   (fork commits efef2d1, 0bd387f, 34291cf; `lua/oil/shell_command.lua`)

## Resolution (2026-10-01)

New module `nvim/lua/dirx.lua`, loaded via `require("dirx")` in `nvim/init.lua`.

- Columns: inline extmarks placed from a `User DirReadPost` handler (fires on open,
  `R`, `:edit`), so buffer lines stay bare entry names and `<CR>`/`-`/`/`/`yy` work on
  names only. Formats copied from oil (9-char rwx with s/t bits, `%.1fk/M/G` sizes
  right-aligned, `%b %d %H:%M` or `%b %d  %Y`). Highlights `DirxPerm`/`DirxSize`/
  `DirxMtime` (default links, re-applied on ColorScheme). `gl` toggles, on by default.
- Gotcha: the `:h dir-decorate` approach (ephemeral marks from a decoration provider)
  does not work for `virt_text_pos = 'inline'` on this nightly (eol/overlay do draw),
  hence real extmarks. A later DirReadPost handler that rewrites lines with
  nvim_buf_set_lines would drop the marks.
- Shell commands: ported shell_command.lua. `!`/`&` in n and x mode, `<C-c>` stops,
  output in a reused bottom split (`DirxShellOutput`, `q` closes), focus stays in the
  listing, listing reloaded via `:edit` (the BufReadCmd path `R` uses) when the job exits.
  Visual mode now exits with `:normal! <Esc>` instead of feedkeys "x", which flushed
  pending typeahead.
- `filemarks` `dir_open_cmd` changed from `"Oil %s"` to `"edit %s"`.
- Verified: headless tests for Dired substitution (`*`, `?`, append), `!` on a name
  with spaces, visual range + `*`, `&` streaming + `<C-c>` -> `-- terminated --`,
  reload after `touch`; tmux render with the full config for columns, toggle, `-`, `<CR>`.
- `q` dismisses the output window from the listing (and inside it), stopping a running
  job so its exit doesn't reopen the window. In the listing it is an `<expr>` mapping
  that falls back to plain `q`, so macro recording works and the register stays clean.
