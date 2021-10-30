## dotfiles
![dot-image](dotfiles.png)
Repository contains essential `config` and `rc` files for  terminal driven applications.

### Description
Installation file for bash, vim, tmux, etc..
(Optional)install Ag using `brew install the_silver_searcher`
(Optional)install oh-my-zsh
 <!-- tmux is configured using reattach-usernamespace (install using brew) -->

### Installation 
> asuming dotfiles are cloned/downloaded to home folder
- ln -sf ~/dotfiles/bash/bashrc ~/.bashrc
- ln -sf ~/dotfiles/bash/bash_profile ~/.bash_profile
- ln -sf ~/dotfiles/bash/lazy ~/.bash_it/themes/lazy

- ln -sf ~/dotfiles/bash/inputrc ~/.inputrc
- ln -sf ~/dotfiles/git/gitconfig ~/.gitconfig
- ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
- ln -sf ~/dotfiles/tmux/tmuxinator ~/.tmuxinator
- ln -sf ~/dotfiles/vim ~/.config/nvim
- ln -sf ~/dotfiles/vimrc ~/.vimrc