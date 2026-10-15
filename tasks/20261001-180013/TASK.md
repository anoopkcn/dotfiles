# surround: ds on an unmatched closer deletes it and errors

- STATUS: CLOSED
- PRIORITY: 100
- TAGS:

`nvim/plugin/surround.lua:42-66` (`around_range`).

When `va<target>` finds no pair, the trim loops still run on the one-char selection:
the backward scan for the closer latches onto any closer before the cursor, and the
forward scan for the opener runs to the end of the line.

Repro (verified headless): line `foo) bar baz`, cursor on `bar`, `ds(` -> the stray `)`
is deleted (`foo bar baz`), then `nvim_buf_set_text` throws "out of range" for the opener.

Fix: return nil unless the selection really starts with the opener and ends with the
closer (and `ec > sc`), instead of scanning to whatever matches.

Found in the Neovim 0.13 review on 2026-10-01.

## Resolution (2026-10-01)

`nvim/plugin/surround.lua` `around_range`: the trim scans no longer bail out mid-way;
afterwards the range is rejected (view restored, nil returned) when no closer was found,
the opener scan ran off the line, or start >= end on a single line, i.e. when `va<char>`
found no pair and Visual mode just sat on the cursor char.
Verified headless with the full config: `ds(` on `foo) bar baz` (cursor on `bar`) leaves the
line untouched with no error; `ds(` on a lone `(` is a no-op; `ds(`, `ds"`, `ds"` on `""`,
`cs([`, `ysiw)`, `yss]`, visual `S'` and `.` repeat of `ys`/`ds` still work.
