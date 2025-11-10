# NeoVim setup
- If it can't be explained, it needn't be used.

## Requirements

- [NeoVim](https://neovim.io) (>= 0.12)

## Plugins

- Managed with the built-in `vim.pack` module (see `lua/custom/pack.lua`).
- Upgrade plugins with `:lua vim.pack.update()`; their state lives in
  `~/.config/nvim/nvim-pack-lock.json`.
