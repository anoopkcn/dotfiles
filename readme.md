# dotfiles
![dot-image](dotfiles.png)
Repository contains essential `config` and `rc` files for  terminal driven applications.

## Description
Installation file for bash, vim, tmux, etc..

(optional) install `diff-so-fancy` for better diff with `git diff` command

(optional) install Ag using `brew install the_silver_searcher`

(optional) install oh-my-zsh

(optional) starship `brew install starship`. If conda python prompt is activated disable it with `conda config --set changeps1 False`, otherwise the python env will be shown twice upon activating one
<!-- tmux is configured using reattach-usernamespace (install using brew) -->

## Installation 
> asuming dotfiles are cloned/downloaded to home folder
```sh
# install.sh
#ln -sf ~/dotfiles/bash/bashrc ~/.bashrc
ln -sf ~/dotfiles/zsh/zshrc ~/.zshrc

ln -sf ~/dotfiles/bash/inputrc ~/.inputrc
ln -sf ~/dotfiles/git/gitconfig ~/.gitconfig
ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/tmux/tmuxinator ~/.tmuxinator
ln -sf ~/dotfiles/vim ~/.config/nvim # for nvim
# ln -sf ~/dotfiles/init.vim ~/.vimrc # For vim
```