# DOTFILES

This repository contains my personal configuration files for development environment. It is **NOT** meant to be a turnkey solution but only meant as a matter of record and reference for people who are interested in my configuration.

Repository includes `config` and `rc` files for `zsh`, `tmux`, `nvim` and `ghostty`

## Dependencies

- (optional) [`rg`](https://github.com/BurntSushi/ripgrep) for faster parallel grep  Ex: `brew install ripgrep`
- (optional) [`fzf`](https://github.com/junegunn/fzf) for fuzzy search  Ex: `brew install fzf`
- (optional) [`zoxide`](https://github.com/ajeetdsouza/zoxide) for directory navigation  Ex: `brew install zoxide`
- (optional) [`bat`](https://github.com/sharkdp/bat) `cat` with syntax highlighting Ex: `brew install bat`
- (optional) [`fd`](https://github.com/sharkdp/fd) simpler, faster find Ex: `brew install fd`
- (optional) [`eza`](https://github.com/eza-community/eza) alternative `ls` Ex: `brew install eza`

## Installation

Set the `PATH_TO_DOTFILES` to the path inside the `setup.sh` file

```sh
sh setup.sh
```

## Extra

### `TMUX` SESSION MANAGEMENT TOOL (TS)

Set variables `TS_SEARCH_DIRS` to make use of `tmuxctl` tool functionalities. Use `tmuxctl -h` or check `tmux/tools.sh` for details
