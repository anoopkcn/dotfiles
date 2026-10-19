# PROMPT
setopt prompt_subst
autoload -Uz vcs_info add-zsh-hook
zmodload zsh/datetime

# Git segment: branch, then * for unstaged and + for staged changes.
# `enable git` keeps vcs_info from probing every VCS backend on each prompt.
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats 'git:%F{blue}(%b%F{yellow}%u%F{green}%c%F{blue})%f'
zstyle ':vcs_info:git:*' actionformats 'git:%F{blue}(%b|%a%F{yellow}%u%F{green}%c%F{blue})%f'

# Command duration: shown on the info line when the last command took >= 5s
_prompt_timer_start() { _PROMPT_CMD_START=$EPOCHREALTIME }
add-zsh-hook preexec _prompt_timer_start

precmd() {
    # Blank line between commands, but not above the first prompt of a shell
    (( ${+_PROMPT_DRAWN} )) && print
    typeset -g _PROMPT_DRAWN=1

    vcs_info

    PROMPT_DURATION_SEGMENT=""
    if (( ${+_PROMPT_CMD_START} )); then
        local -i elapsed=$(( EPOCHREALTIME - _PROMPT_CMD_START ))
        unset _PROMPT_CMD_START
        if (( elapsed >= 5 )); then
            local -i h=$(( elapsed / 3600 )) m=$(( elapsed % 3600 / 60 )) s=$(( elapsed % 60 ))
            local duration="${s}s"
            (( h || m )) && duration="${m}m${duration}"
            (( h )) && duration="${h}h${duration}"
            PROMPT_DURATION_SEGMENT="%F{yellow}${duration}%f"
        fi
    fi

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

PROMPT='%F{cyan}%~%f${PROMPT_ENV_SEGMENT:+ env:${PROMPT_ENV_SEGMENT}}${vcs_info_msg_0_:+ ${vcs_info_msg_0_}}${PROMPT_DURATION_SEGMENT:+ ${PROMPT_DURATION_SEGMENT}}
%(?.%F{cyan}❯%f.%F{red}❯%f) '
