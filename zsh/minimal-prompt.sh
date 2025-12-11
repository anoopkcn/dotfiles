# PROMPT
autoload -Uz vcs_info
setopt prompt_subst

# Git segment
zstyle ':vcs_info:git:*' formats ' git:%F{blue}(%b)%f%F{yellow}%u%f%F{green}%c%f'
zstyle ':vcs_info:git:*' actionformats ' git:%F{blue}(%b|%a)%f%F{yellow}%u%f%F{green}%c%f'
zstyle ':vcs_info:*' check-for-changes true

# Put the space *inside* the markers, so it only appears when they do
zstyle ':vcs_info:*' unstagedstr ' 󱐌'  # leading space before icon
zstyle ':vcs_info:*' stagedstr  ' '   # leading space before icon

precmd() {
    vcs_info

    PROMPT_ENV_SEGMENT=""

    local env_text=""
    if [[ -n ${VIRTUAL_ENV_PROMPT:-} ]]; then
        env_text=$VIRTUAL_ENV_PROMPT
    elif [[ -n ${CONDA_PROMPT_MODIFIER:-} ]]; then
        env_text=$CONDA_PROMPT_MODIFIER
    elif [[ -n ${VIRTUAL_ENV:-} ]]; then
        env_text="(${VIRTUAL_ENV:t})"
    fi

    if [[ -n "$env_text" ]]; then
        PROMPT_ENV_SEGMENT=" env:%F{magenta}${env_text//\%/%%}%f"
    fi
}

# Single-line prompt: [cwd env git]$ with colored status
PROMPT='[%F{cyan}%~%f${PROMPT_ENV_SEGMENT}${vcs_info_msg_0_}]%(?.%F{cyan}$%f.%F{red}$%f) '
