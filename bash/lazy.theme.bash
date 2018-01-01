#color definitions
normal="\e[0m"
bold_red="\e[1;31m"
bold_green="\e[1;32m"
bold_cyan="\e[1;96m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
gray="\e[37m"
cyan="\e[96m"
SCM_THEME_PROMPT_DIRTY="${bold_red}✸${normal}"
SCM_THEME_PROMPT_CLEAN="${bold_green}✓${normal}"
SCM_GIT_CHAR="${bold_green}±${normal}"
SCM_SVN_CHAR="${bold_cyan}⑆${normal}"
SCM_HG_CHAR="${bold_red}☿${normal}"

PS3=">> "

lazy_git_staged() {
# Get number of files added to the index (but uncommitted)
  local git_staged=$(git status --porcelain 2>/dev/null| grep -c "^[M|A|D|R|C]")
  if [ "${git_staged}" != "0" ]
  then
    printf "${yellow}✚${normal}${git_staged} "
  fi
}

lazy_git_not_staged() {
# Get number of files that are uncommitted and not added ●
  local git_not_staged=$(git status --porcelain 2>/dev/null| grep -c "^[M|A|D|R|C|[:space:]][M|A|D|R|C]")
  if [ "${git_not_staged}" != "0" ]
  then
    printf "${green}●${normal}${git_not_staged} "
  fi
}

lazy_git_untracked(){
# Get number of total uncommited files …
  local git_untracked=$(git status --porcelain 2>/dev/null| grep -c "^??")
  if [ "${git_untracked}" != "0" ]
  then
    printf "${cyan}…${normal}${git_untracked} "
  fi
}

lazy_git_prompt() {
# Get the current git branch name (if available)
  local ref=$(git symbolic-ref HEAD 2>/dev/null | cut -d'/' -f3)
  if [ "$ref" != "" ]
  then
    printf "($(lazy_git_staged)$(lazy_git_not_staged)$(lazy_git_untracked)${gray}${ref}${normal})"
  fi
}

PS2="▪ "

# PS1="▪"'$(__git_ps1 "(%s)")'"[${cyan}\W${normal}]"
# PS1="▪$(lazy_git_prompt)[${cyan}\W${normal}]"
export PS1="▪\$(lazy_git_prompt)[${cyan}\W${normal}]"
