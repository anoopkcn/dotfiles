# support libraries and links for zsh

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
if [ -f "/Users/akc/.config/zsh-plugins/znap/znap.zsh" ]; then
    source /Users/akc/.config/zsh-plugins/znap/znap.zsh
    znap source zdharma-continuum/fast-syntax-highlighting
    znap source zshzoo/macos
    znap source zsh-users/zsh-autosuggestions
    bindkey '^y' autosuggest-accept
fi

eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"
eval "$(thefuck --alias)"

source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f'

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'tree -C {} | head -200'   "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
  esac
}

export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#cad3f5,fg+:#d0d0d0,bg:#24273a,bg+:#393c55
  --color=hl:#ed8796,hl+:#5fd7ff,info:#c6a0f6,marker:#EAD5A5
  --color=prompt:#c6a0f6,spinner:#f4dbd6,pointer:#f4dbd6,header:#ed8796
  --color=gutter:#252739,border:#3A405A,preview-border:#3A405A,label:#aeaeae
  --color=query:#d9d9d9
  --height 40% --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="❯"
  --marker="+" --pointer="❯" --separator="─" --scrollbar=""
  --layout="reverse" --info="right"'
