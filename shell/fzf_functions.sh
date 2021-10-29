#!/bin/bash
# Interactive cd
function fzfCd() {
  if [[ "$#" != 0 ]]; then
    builtin cd "$@"
    return
  fi
  while true; do
    local lsd=$(echo ".." && ls -p | grep '/$' | sed 's;/$;;')
    local dir="$(printf '%s\n' "${lsd[@]}" |
      fzf --reverse --preview '
                __cd_nxt="$(echo {})";
                __cd_path="$(echo $(pwd)/${__cd_nxt} | sed "s;//;/;")";
                echo $__cd_path;
                echo;
                ls -p --color=always "${__cd_path}";
        ')"
    [[ ${#dir} != 0 ]] || return 0
    builtin cd "$dir" &>/dev/null
  done
}

#----- FZF powerd git functions -------
function __gi() {
  curl -L -s https://www.gitignore.io/api/"$@"
}

function GitIgnore() {
  if [ "$#" -eq 0 ]; then
    IFS+=","
    for item in $(__gi list); do
      echo $item
    done | fzf --multi --ansi | paste -s -d "," - |
      { read result && __gi "$result"; }
  else
    __gi "$@"
  fi
}
#
function GitBranch() {
  # checkout git branch
  is_in_git_repo || return
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" |
      fzf -d $((2 + $(wc -l <<<"$branches"))) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# checkout git commit with previews
function GitCommit() {
  is_in_git_repo || return
  alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
  _gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
  _viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"
  local commit
  commit=$(glNoGraph |
    fzf --no-sort --reverse --tiebreak=index --no-multi \
      --ansi --preview="$_viewGitLogLine") &&
    git checkout $(echo "$commit" | sed "s/ .*//")
}
# gitstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
function GitStash() {
  is_in_git_repo || return
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
      fzf --ansi --no-sort --query="$q" --print-query \
        --expect=ctrl-d,ctrl-b
  ); do
    mapfile -t out <<<"$out"
    q="${out[0]}"
    k="${out[1]}"
    sha="${out[-1]}"
    sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff $sha
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" $sha
      break
    else
      git stash show -p $sha
    fi
  done
}

#------------ FZF powerd Tmux functions------
#
# tm - create new tmux session, or switch to existing one. Works from within tmux too. (@bag-man)
# `tm` will allow you to select your tmux session via fzf.
# `tm irc` will attach to the irc session (if it exists), else it will create it.

function tm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1")
    return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) && tmux $change -t "$session" || echo "No sessions found."
}
