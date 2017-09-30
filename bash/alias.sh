#!/bin/bash
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias cd.='cd ..'
alias cd..='cd ..'
alias l='ls -ltr'
alias ll='ls -l'
alias c='clear'
alias p="pwd"

#application links
alias vi='nvim -u NONE'
alias vim='nvim'
alias chrome='open -a Google\ Chrome'

# tmux alias
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tsend='tmux send -t'
alias tkill='tmux kill-session -t'
alias ts='tmuxinator start'

#git
alias gs='git status'

#other
alias duh="du -h -d 0 [^.]*"
alias js="bundle exec jekyll serve"
