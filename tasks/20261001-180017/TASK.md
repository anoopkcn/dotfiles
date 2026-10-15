# qfbuffers: % marker for the current buffer is lost after dd

- STATUS: CLOSED
- PRIORITY: 100
- TAGS:

`nvim/lua/qfbuffers.lua:8`.

`buffer_items()` takes `nvim_get_current_buf()` as the current buffer. When `dd`
(`delete_under_cursor`) rebuilds the list, the current buffer is the quickfix buffer
itself, so no entry gets `%` and `^` (alternate) marks the wrong one.

Fix: capture the current/alternate buffer of the previous window (`wincmd p` /
`vim.fn.win_getid(vim.fn.winnr('#'))`) when rebuilding, or store them in `M.open()`.

Found in the Neovim 0.13 review on 2026-10-01.

## Resolution (2026-10-01)

`nvim/lua/qfbuffers.lua`: `buffer_items(win)` takes the window whose current/alternate
buffers are flagged (uses `nvim_win_call` returning two values, Nvim 0.13). `M.open()`
passes the current window, `dd` passes the previous window (`winnr('#')`).
Verified headless: with q1..q3 open (q3 current, q2 alternate), `dd` on q1 gives
`^ q2.txt`, `% q3.txt` (flags kept).
