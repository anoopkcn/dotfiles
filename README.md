# dotfiles

Repository contains essential `config` and `rc` files for `zsh`, `tmux`, `nvim` and `ghostty`

## Dependencies

- (optional) [`rg`](https://github.com/BurntSushi/ripgrep)  Ex: `brew install ripgrep`
  - for faster parallel grep
- (optional) [`fzf`](https://github.com/junegunn/fzf)  Ex: `brew install fzf`
  - for fuzzy search
- (optional) [`zoxide`](https://github.com/ajeetdsouza/zoxide)  Ex: `brew install zoxide`
  - for directory navigation
- (optional) [`bat`](https://github.com/sharkdp/bat) Ex: `brew install bat`
  - `cat` with syntax highlighting
- (optional) [`fd`](https://github.com/sharkdp/fd) Ex: `brew install fd`
  - simpler, faster find
- (optional) [`eza`](https://github.com/eza-community/eza) Ex: `brew install eza`
  - better `ls` 

## Installation
Set the `PATH_TO_DOTFILES` to the path inside the `setup.sh` file

```sh
sh setup.sh
```

## Extra
### TMUX SESSION MANAGEMENT TOOL (TS)
Set variables `TS_SEARCH_DIRS` to make use of `ts` tool functionalities. Use `ts -h` or check `tmux/tools.sh` for details
