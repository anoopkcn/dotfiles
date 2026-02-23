# PROMPT
autoload -Uz vcs_info
setopt prompt_subst

# Git segment: no leading/trailing spaces in formats
zstyle ':vcs_info:git:*' formats 'git:%F{blue}(%b%F{yellow}%u%f%F{green}%c%f%F{blue})%f'
zstyle ':vcs_info:git:*' actionformats 'git:%F{blue}(%b|%a%F{yellow}%u%f%F{green}%c%f%F{blue})%f'
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true

# Icons carry their own leading space
zstyle ':vcs_info:*' unstagedstr ' 󱐌'
zstyle ':vcs_info:*' stagedstr  ' '

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

    # Trim leading/trailing whitespace from env_text
    env_text="${env_text##[[:space:]]##}"
    env_text="${env_text%%[[:space:]]##}"

    if [[ -n "$env_text" ]]; then
        PROMPT_ENV_SEGMENT="%F{magenta}${env_text//\%/%%}%f"
    fi
}

# Single-line prompt: [cwd env git]$ with exactly one space between segments
PROMPT='%F{cyan}%~%f${PROMPT_ENV_SEGMENT:+ env:${PROMPT_ENV_SEGMENT}}${vcs_info_msg_0_:+ ${vcs_info_msg_0_}} %(?.%F{cyan}❯%f.%F{red}❯%f) '
