#color definitions
PS3=">> "
PS2="▪ "
# PS1="▪"'$(__git_ps1 "(%s)")'"[${cyan}\W${normal}]"
# PS1="▪$(lazy_git_prompt)[${cyan}\W${normal}]"
# export PS1="▪\$(lazy_git_status)[${cyan}\W${normal}]"
#for oh-my-zsh
# PROMPT="▪\$(lazy_git_status)[${cyan}\W${normal}]"
local ret_status="%(?:%{$fg_bold[green]%}▪%{$reset_color%}:%{$fg_bold[red]%}▪%{$reset_color%})"
PROMPT='${ret_status}$(lazy_git_status)[%{$fg[cyan]%}%c%{$reset_color%}]'
# PROMPT='${ret_status}$(git_prompt_info)[%{$fg[cyan]%}%c%{$reset_color%}]'

function lazy_git_status() {
  # Get the current git branch name (if available)
  local ref
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
  # IFS='\n';
  git_status=$(git status -s 2>/dev/null | cut -c1-2) # NOTE: ${git_status:0:2} cant be used since multi lined
  if [[ -z "$git_status" ]]; then
    echo "(%{$fg[blue]%}${ref#refs/heads/}%{$reset_color%} %{$fg_bold[green]%}✓%{$reset_color%})"
  else
    git_staged=$(echo ${git_status} | grep -c "^[M|A|D|R|C]")
    [[ $git_staged = 0 ]] && git_staged="" || git_staged=" ${git_staged}%{$fg_bold[yellow]%}ᴹ%{$reset_color%}"
    git_modified=$(echo ${git_status} | grep -c "^[M|A|D|R|C|[:space:]][M|A|R|C]")
    [[ $git_modified = 0 ]] && git_modified="" || git_modified=" ${git_modified}%{$fg_bold[green]%}ᴹ%{$reset_color%}"
    git_deleted=$(echo ${git_status} | grep -c "^[[:space:]]D")
    [[ $git_deleted = 0 ]] && git_deleted="" || git_deleted=" ${git_deleted}%{$fg_bold[red]%}ᴰ%{$reset_color%}"
    git_untracked=$(echo ${git_status} | grep -c "??")
    [[ $git_untracked = 0 ]] && git_untracked="" || git_untracked=" ${git_untracked}%{$fg_bold[cyan]%}ˀ%{$reset_color%}"
    echo "(%{$fg[blue]%}${ref#refs/heads/}%{$reset_color%}${git_staged}${git_modified}${git_deleted}${git_untracked})"
  fi
}

# TODO SSH COONECTION FUNCTION