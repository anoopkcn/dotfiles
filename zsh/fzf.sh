# fzf env — palette matched to kitty/neovim.conf
# Sourced from zshrc and from non-shell scripts that spawn fzf
# (e.g. kitty overlay scripts), so the theme is consistent everywhere.

export FZF_DEFAULT_OPTS='--layout=reverse
--color=fg:#e0e2e9,bg:-1,hl:#f7e19e
--color=fg+:#e0e2e9,bg+:#292b33,hl+:#f7e19e
--color=gutter:#1d1f27,border:#505257,separator:#505257
--color=info:#b26cc7,prompt:#b1dafb,pointer:#f5c3bb
--color=marker:#c1f4c4,spinner:#b26cc7,header:#a6f5f6
--color=preview-fg:#e0e2e9,preview-bg:-1,preview-border:#505257
--color=query:#e0e2e9,disabled:#505257,label:#b2b5b9
--bind=alt-p:toggle-preview
--bind=ctrl-u:preview-half-page-up
--bind=ctrl-d:preview-half-page-down
--bind=ctrl-y:preview-up
--bind=ctrl-e:preview-down'

export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}' --preview-window=hidden"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200' --preview-window=hidden"
