# PROMPT 
# %~  -> \w        (cwd with ~ abbreviation)
# %F{c}..%f        -> \[\e[..m\]..\[\e[0m\]
# %(?.a.b)         -> exit-status branch, computed in __prompt_command
# vcs_info segment -> left commented out, mirroring the zsh version

__prompt_command() {
    local exit=$?   # MUST be the first statement

    history -a
    history -n

    local c_cyan='\[\e[36m\]'
    local c_red='\[\e[31m\]'
    local c_magenta='\[\e[35m\]'
    local c_reset='\[\e[0m\]'

    # environment segment: venv > conda > bare VIRTUAL_ENV
    local env_text=""
    if [ -n "${VIRTUAL_ENV_PROMPT:-}" ]; then
        env_text=$VIRTUAL_ENV_PROMPT
    elif [ -n "${CONDA_PROMPT_MODIFIER:-}" ]; then
        env_text=$CONDA_PROMPT_MODIFIER
    elif [ -n "${VIRTUAL_ENV:-}" ]; then
        env_text="(${VIRTUAL_ENV##*/})"
    fi

    # trim surrounding whitespace
    env_text="${env_text#"${env_text%%[![:space:]]*}"}"
    env_text="${env_text%"${env_text##*[![:space:]]}"}"

    local env_segment=""
    if [ -n "$env_text" ]; then
        env_segment=" env:${c_magenta}${env_text}${c_reset}"
    fi

    local pchar
    if [ "$exit" -eq 0 ]; then
        pchar="${c_cyan}\$${c_reset}"
    else
        pchar="${c_red}\$${c_reset}"
    fi

    PS1="[${c_cyan}\w${c_reset}${env_segment}]${pchar} "
}

PROMPT_COMMAND=__prompt_command

# Git segment (left disabled, as in the zsh original). Bash has no vcs_info;
# the closest drop-in is git's contrib prompt:
#   source /opt/homebrew/etc/bash_completion.d/git-prompt.sh  (if present)
#   GIT_PS1_SHOWDIRTYSTATE=1
# then add  $(__git_ps1 ' git:(%s)')  into the PS1 above.
