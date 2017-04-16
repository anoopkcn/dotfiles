#!/bin/bash

#Installation file for bash, vim, tmux, etc..
#(Optional)install Ag using `brew install the_silver_searcher`

ln -sf ~/.dotfiles/bash/bash_profile ~/.bash_profile
ln -sf ~/.dotfiles/bash/bashrc ~/.bashrc
ln -sf ~/.dotfiles/bash/inputrc ~/.inputrc

ln -sf ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -sf ~/.dotfiles/tmux/dottmux ~/.tmux

ln -sf ~/.dotfiles/pip ~/.pip
ln -sf ~/.dotfiles/gitconfig ~/.gitconfig

mkdir -p ~/.vim/colors
ln -sf ~/.dotfiles/vim/vimrc ~/.vimrc
ln -sf ~/.dotfiles/vim/lazy.vim ~/.vim/colors/lazy.vim

# ln -sf ~/.dotfiles/ssh/config ~/.ssh/config
