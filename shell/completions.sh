#/usr/bin/env bash
# BASH completions for custom functions

_sublp_completions()
{
    if [ "${#COMP_WORDS[@]}" != "2" ]; then
        return
    fi
    project=$(ls *.sublime-project)
    COMPREPLY=($(compgen -W "${project%.*}" "${COMP_WORDS[1]}"))
}

complete -F _sublp_completions sublp