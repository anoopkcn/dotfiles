#!/usr/bin/env bash
alias ..='cd ..'
alias l='ls -lhF'
alias c='clear'
alias p='pwd'
alias hls='h5ls'

#application links
alias vi='nvim -u NONE'
alias vim='nvim'

# tmux alias
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tsend='tmux send -t'
alias ts='tmuxinator start'

#other
alias duh="du -h -d 0 [^.]*"
alias js="bundle exec jekyll serve"

#jupyter
alias jn='jupyter-notebook'

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi
