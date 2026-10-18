# PROMPT
setopt prompt_subst
autoload -Uz vcs_info

# Git segment: branch only (no check-for-changes, so large repos stay fast).
# `enable git` keeps vcs_info from probing every VCS backend on each prompt.
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats 'git:%F{blue}(%b)%f'
zstyle ':vcs_info:git:*' actionformats 'git:%F{blue}(%b|%a)%f'

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

    env_text="${env_text##[[:space:]]##}"
    env_text="${env_text%%[[:space:]]##}"

    if [[ -n "$env_text" ]]; then
        PROMPT_ENV_SEGMENT="%F{magenta}${env_text//\%/%%}%f"
    fi
}

PROMPT='%F{cyan}%~%f${PROMPT_ENV_SEGMENT:+ env:${PROMPT_ENV_SEGMENT}}${vcs_info_msg_0_:+ ${vcs_info_msg_0_}} %(?.%F{cyan}❯%f.%F{red}❯%f) '
