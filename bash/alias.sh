#!/bin/bash
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias cd.='cd ..'
alias cd..='cd ..'
alias l='ls -alF'
alias ll='ls -l'
alias vi='vim -u NONE'

# tmux alias
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tsend='tmux send -t'
alias tkill='tmux kill-session -t'
alias ts='tmuxinator start'

#git
alias gs='git status'
alias gn='git next'
alias gp='git prev'

#other
alias duh="du -h -d 0 [^.]*"

