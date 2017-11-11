#!/bin/bash
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias cd.='cd ..'
alias cd..='cd ..'
alias l='ls -al'
alias ll='ls -l'
alias c='clear'
alias p="pwd"

#application links
alias vi='vim -u NONE'
alias chrome='open -a Google\ Chrome'

# tmux alias
#alias tmux="TERM=screen-256color-bce tmux"
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tsend='tmux send -t'
alias ts='tmuxinator start'

#git
alias gs='git status'

#other
alias duh="du -h -d 0 [^.]*"
alias js="bundle exec jekyll serve"
