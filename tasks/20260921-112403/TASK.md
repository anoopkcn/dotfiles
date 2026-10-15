# Cleanup the jj plugin even from the lock file

- STATUS: CLOSED
- PRIORITY: 100
- TAGS: scope

Eventhogth jj is commented out when I update it still recives updates. cleanup the jj plugin for neovim properly

## Resolution (2026-10-01)

Already done before this check: jj.nvim was removed from `vim.pack.add` and its
`require("jj").setup` in cbe8bee, and the jj keymaps are gone from `nvim/init.lua`.
Nothing is left: no entry in `nvim/nvim-pack-lock.json`, no `jj` directory under
`~/.local/share/nvim/site/pack/core/opt/`, and `vim.pack.get()` lists only the 8 plugins
in `vim.pack.add`.
