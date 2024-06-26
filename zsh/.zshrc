export LANG=en_US.UTF-8
export LC_ALL=en_GB.UTF-8

# General shellrc file
source ${HOME}/.utils.sh

export GREP_OPTIONS='--color=auto'
export TERM="xterm-256color"
export EDITOR='vim'

if ! [ $ZSH_VERSION ]; then
  bind TAB:menu-complete
  bind '"\er": redraw-current-line'
  bind '"\C-g\C-f": "$(gf)\e\C-e\er"'
  bind '"\C-g\C-b": "$(gb)\e\C-e\er"'
  bind '"\C-g\C-t": "$(gt)\e\C-e\er"'
  bind '"\C-g\C-h": "$(gh)\e\C-e\er"'
  bind '"\C-g\C-r": "$(gr)\e\C-e\er"'
fi

alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tsend='tmux send -t'
alias ts='tmuxinator start'

#other
alias vim='nvim'
alias duh="du -h -d 0 [^.]*"
# usage sync <source> <destination> (source or destination could be -e ssh://user@host:/path)
alias sync = "rsync -airzvc --exclude-from=${HOME}/.rsync-local-ignore --prune-empty-dirs"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
autoload -U compinit; compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
# Variables
bindkey '^[^M' self-insert-unmeta

NODE_PATH="$HOME/.node/lib/node_modules:$NODE_PATH"
MANPATH="/usr/local/man:$HOME/.node/share/man:$MANPATH"
export PATH="/Library/TeX/texbin/:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/akc/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/akc/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/akc/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/akc/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# ZSH plugins
source /Users/akc/.config/zsh-plugins/znap/znap.zsh
znap source zdharma-continuum/fast-syntax-highlighting
znap source zshzoo/macos
znap source zsh-users/zsh-autosuggestions
bindkey '^y' autosuggest-accept
