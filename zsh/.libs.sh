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

# source <(fzf --zsh)
# export FZF_DEFAULT_COMMAND='fd --type f'
# export FZF_DEFAULT_OPTS=" \
# --height 40% --layout reverse --info inline --border \
# --preview 'bat --color=always {}' --preview-window '~3' \
# --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
# --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
# --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"
#
# _fzf_compgen_path() {
#   fd --hidden --follow --exclude ".git" . "$1"
# }
#
# _fzf_compgen_dir() {
#   fd --type d --hidden --follow --exclude ".git" . "$1"
# }
