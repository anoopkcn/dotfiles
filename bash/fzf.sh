# fzf env — palette matched to kitty/neovim.conf
# Sourced from bashrc and from non-shell scripts that spawn fzf
# (e.g. kitty overlay scripts), so the theme is consistent everywhere.

export FZF_DEFAULT_OPTS='--layout=reverse
--info=right
--bind=alt-p:toggle-preview
--bind=ctrl-u:preview-half-page-up
--bind=ctrl-d:preview-half-page-down
--bind=ctrl-y:preview-up
--bind=ctrl-e:preview-down
--color=fg:-1,bg:-1,bg+:#32373f,pointer:#8ED6FE,hl:#dc6a74,hl+:#dc6a74,gutter:#292d33
--prompt="❯ "
'

export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}' --preview-window=hidden"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200' --preview-window=hidden"
