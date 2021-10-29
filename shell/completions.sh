# BASH/ZSH completions for custom functions

if ! [ $ZSH_VERSION ]; then
    _sublp_completions() {
        if [ "${#COMP_WORDS[@]}" != "2" ]; then
            return
        fi
        project=$(ls *.sublime-project)
        COMPREPLY=($(compgen -W "${project%.*}" "${COMP_WORDS[1]}"))
    }

    complete -F _sublp_completions sublp
else
    function _sublp_completions() {
        project=$(ls *.sublime-project)
        compadd ${project%.*}
    }

    compdef _sublp_completions sublp
fi
