# fzf env — onehalfdark theme
# Sourced from zshrc and from non-shell scripts that spawn fzf
# (e.g. kitty overlay scripts), so the theme is consistent everywhere.

export FZF_DEFAULT_OPTS='--layout=reverse
--color=fg:#dcdfe4,bg:-1,hl:#e5c07b
--color=fg+:#dcdfe4,bg+:#313640,hl+:#e5c07b
--color=gutter:#282c34,border:#313640,separator:#5c6370
--color=info:#c678dd,prompt:#61afef,pointer:#e06c75
--color=marker:#98c379,spinner:#c678dd,header:#56b6c2
--color=preview-fg:#dcdfe4,preview-bg:-1,preview-border:#5c6370
--color=query:#dcdfe4,disabled:#5c6370,label:#919baa
--bind=alt-p:toggle-preview
--bind=ctrl-u:preview-half-page-up
--bind=ctrl-d:preview-half-page-down
--bind=ctrl-y:preview-up
--bind=ctrl-e:preview-down'

export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}' --preview-window=hidden"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200' --preview-window=hidden"
