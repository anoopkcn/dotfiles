# print available colors and their numbers
function colours() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}m colour${i}"
        if (($i % 5 == 0)); then
            printf "\n"
        else
            printf "\t"
        fi
    done
}

# Extract archives - use: extract <file>
function extract() {
    if [ -f $1 ]; then
        case $1 in
        *.tar.bz2) tar xjf $1 -C $2 ;;
        *.tar.gz) tar xzf $1 -C $2 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) rar x $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xf $1 -C $2 ;;
        *.tbz2) tar xjf $1 -C $2 ;;
        *.tgz) tar xzf $1 -C $2 ;;
        *.zip) unzip $1 -d $2 ;;
        *.Z) uncompress $1 ;;
        *.7z) 7z x $1 ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

function kill_port() {
    lsof -ti:$1 | xargs kill -9
}

# GIT functions
function _is_in_git_repo() {
    git rev-parse HEAD >/dev/null 2>&1
}

function git_log() {
    _is_in_git_repo || return
    if [ $# -eq 0 ]; then
        git log --oneline --decorate --all --graph
    elif [ $1 = "-b" ]; then
        git log --oneline
    else
        git log --oneline --decorate --max-count=$1 --all --graph
    fi
}
function join_by { local IFS="$1"; shift; echo "$*"; }

function git_get(){
    if [ $# -eq 0 ]; then
        echo "Usage: git_get_file <owner/repo> [<folder/file>]"
        return 1
    elif [ $# -eq 1 ]; then
        file_url="$1"
        file_arr=($(echo ${file_url//\//\ }))
        owner=${file_arr[3]}
        repo=${file_arr[4]}
        filename=$(join_by "/" ${file_arr[@]:6})
        echo "${owner} ${repo} ${filename}"
        curl -H "Accept: application/vnd.github.raw" \
            "https://api.github.com/repos/${owner}/${repo}/contents/${filename}" >> ${file_arr[-1]}
    else
        curl -H "Accept: application/vnd.github.raw" \
        https://api.github.com/repos/$1/contents/$2 >> $2
    fi
}

# TMUX functions
function tkill() {
    if [ $# -eq 1 ]; then
        case $1 in
        -a)
            t_sessions=($(tmux ls | cut -d : -f 1))
            for i in "${t_sessions[@]}"; do
                tmux kill-session -t $i
            done
            ;;
        *)
            tmux kill-session -t $1
            ;;
        esac
    else
        echo "Provide a TMUX session to kill"
    fi
}
