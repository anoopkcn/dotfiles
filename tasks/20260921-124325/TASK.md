# check for neovim update to see to check if ui2 is natively supported

- STATUS: OPEN
- PRIORITY: 100
- TAGS: scope

UI2 is introduced as an experimental feature in neovim 0.12.0. If it is natively supported then remove the lines where it is enabled by hand

## Findings (checked 2026-10-01)

On `NVIM v0.13.0-dev-1755+geddadd7ab3`, ui2 is still experimental. `:h ui2` still says
"WARNING: This is an experimental feature" and documents `require('vim._core.ui2').enable()`
as the way to turn it on, so keep the line in `nvim/init.lua`. `fillchars` `msgsep` is still
read by ui2 (`runtime/lua/vim/_core/ui2/messages.lua`), so keep that line too.
0.13 news: the ui2 pager no longer uses `<CR>` by default (use `g<` or `messagesopt+=pager:<CR>`),
and `cfg.pager_char` / `cfg.msg.msg.timeout` moved into 'messagesopt'.
