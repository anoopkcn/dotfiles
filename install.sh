#!/bin/bash

#Installation file for bash, vim, tmux, etc..
# (Optional)install Ag using `brew install the_silver_searcher`
# tmux is configured using reattach-usernamespace (install using brew)

ln -sf ~/.dotfiles/bash/bash_profile ~/.bash_profile
ln -sf ~/.dotfiles/bash/bashrc ~/.bashrc
ln -sf ~/.dotfiles/bash/inputrc ~/.inputrc

ln -sf ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf

ln -sf ~/.dotfiles/python/pip ~/.pip
ln -sf ~/.dotfiles/git/gitconfig ~/.gitconfig

ln -sf ~/.dotfiles/vim/init.vim ~/.vimrc
ln -sf ~/.dotfiles/vim ~/.vim
