# PROMPT 
# %1~ -> \W        (cwd basename, ~ at home)
# %F{c}..%f        -> \[\e[..m\]..\[\e[0m\]
# %(?.a.b)         -> exit-status branch, computed in __prompt_command
# git segment      -> git-prompt.sh (__git_ps1), sourced below

__prompt_command() {
    local exit=$?   # MUST be the first statement

    history -a
    history -n

    local c_cyan='\[\e[36m\]'
    local c_red='\[\e[31m\]'
    local c_magenta='\[\e[35m\]'
    local c_yellow='\[\e[33m\]'
    local c_reset='\[\e[0m\]'

    local c_dim='\[\e[90m\]'

    # host:dir, always shown so panes from several machines can be
    # told apart; the host turns yellow over SSH
    local host="\h"
    if [ -n "${SSH_CONNECTION:-}" ]; then
        host="${c_yellow}\h"
    fi
    local ident="${c_dim}${host}${c_dim}:${c_cyan}\W${c_reset}"

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
    # venv and conda may wrap the name in parens; show it bare
    env_text="${env_text#(}"
    env_text="${env_text%)}"

    local env_segment=""
    if [ -n "$env_text" ]; then
        env_segment=" ${c_dim}env:${c_magenta}${env_text}${c_reset}"
    fi

    local pchar
    if [ "$exit" -eq 0 ]; then
        pchar="${c_cyan}❯${c_reset}"
    else
        pchar="${c_red}❯${c_reset}"
    fi

    # blank line between the previous output and the prompt, except on the
    # first prompt of the shell
    local gap="\n"
    if [ -z "${__prompt_started:-}" ]; then
        gap=""
        __prompt_started=1
    fi

    # line 1: host:dir env:name git:branch; line 2: the prompt char
    local ps1_pre="${gap}${ident}${env_segment}"
    local ps1_post="\n${pchar} "

    # git segment: in this 3-arg form __git_ps1 sets PS1 itself (needed for
    # color hints); outside a repo it just sets PS1="$pre$post"
    if declare -F __git_ps1 >/dev/null; then
        __git_ps1 "$ps1_pre" "$ps1_post" " ${c_dim}git:${c_reset}%s"
        # git-prompt hardcodes green for the branch; swap in our own color
        # (detached HEAD keeps git's red)
        local green_branch="${__git_SOH}${__git_ESC}[32m${__git_STX}\${__git_ps1_branch_name}"
        local my_branch="${__git_SOH}${__git_ESC}[${GIT_PROMPT_BRANCH_COLOR:-34}m${__git_STX}\${__git_ps1_branch_name}"
        PS1="${PS1/"$green_branch"/"$my_branch"}"
        # unstaged * is yellow in zsh; git-prompt makes it red
        local red_dirty="${__git_SOH}${__git_ESC}[31m${__git_STX}*"
        local yellow_dirty="${__git_SOH}${__git_ESC}[33m${__git_STX}*"
        PS1="${PS1/"$red_dirty"/"$yellow_dirty"}"
    else
        PS1="${ps1_pre}${ps1_post}"
    fi
}

# Git segment via git's contrib prompt script (location varies by distro)
for __git_prompt_file in \
    /usr/share/git/completion/git-prompt.sh \
    /usr/lib/git-core/git-sh-prompt \
    /usr/share/git-core/contrib/completion/git-prompt.sh \
    /opt/homebrew/etc/bash_completion.d/git-prompt.sh \
    /usr/local/etc/bash_completion.d/git-prompt.sh; do
    if [ -f "$__git_prompt_file" ]; then
        source "$__git_prompt_file"
        break
    fi
done
unset __git_prompt_file

# Markers after the branch name:
#   *  unstaged changes      +  staged changes
#   $  stash present         %  untracked files
# plus |MERGING, |REBASE 1/3, etc. during operations.
# Untracked scan can be slow in huge repos; disable per-repo with
#   git config bash.showUntrackedFiles false
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWCOLORHINTS=1
GIT_PS1_STATESEPARATOR=""

# after clearing the screen, the next prompt starts at the top with no gap
clear() {
    command clear "$@" && unset __prompt_started
}

PROMPT_COMMAND=__prompt_command
