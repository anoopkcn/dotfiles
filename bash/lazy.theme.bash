#color definitions
normal="\e[0m"
bold_red="\e[1;31m"
bold_green="\e[1;32m"
bold_cyan="\e[1;96m"
red="\e[31m"
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

lazy_git_status() {
  # Get the current git branch name (if available)
  local ref=$(git symbolic-ref HEAD 2>/dev/null | cut -d'/' -f3)
  if [[ "$ref" != "" ]];then
  (
    IFS='\n';
    git_status=$(git status -s 2>/dev/null | cut -c1-2)
    git_staged=$(echo ${git_status} | grep -c "^[M|A|D|R|C]")
    [[ $git_staged = 0 ]] && git_staged="" || git_staged=" "${git_staged}${yellow}ᴹ${normal}
    git_modified=$(echo ${git_status} | grep -c "^[M|A|D|R|C|[:space:]][M|A|R|C]")
    [[ $git_modified = 0 ]] && git_modified="" || git_modified=" "${git_modified}${green}ᴹ${normal}
    git_deleted=$(echo ${git_status} | grep -c "^[[:space:]]D")
    [[ $git_deleted = 0 ]] && git_deleted="" || git_deleted=" "${git_deleted}${red}ᴰ${normal}
    git_untracked=$(echo ${git_status} | grep -c "??")
    [[ $git_untracked = 0 ]] && git_untracked="" || git_untracked=" "${git_untracked}${cyan}ˀ${normal}
    printf "(${gray}${ref}${normal}${git_staged}${git_modified}${git_deleted}${git_untracked})"
  )
  fi
}

# lazy_git_staged() {
# # Get number of files added to the index (but uncommitted)
#   local git_staged=$(git status --porcelain 2>/dev/null| grep -c "^[M|A|D|R|C]")
#   if [ "${git_staged}" != "0" ]
#   then
#     printf "${git_staged}${yellow}ᴬ${normal} "
#   fi
# }

# lazy_git_not_staged() {
# # Get number of files that are uncommitted and not added 
#   local git_not_staged=$(git status --porcelain 2>/dev/null| grep -c "^[M|A|D|R|C|[:space:]][M|A|D|R|C]")
#   if [ "${git_not_staged}" != "0" ]
#   then
#     printf "${git_not_staged}${green}ᴹ${normal} "
#   fi
# }
# lazy_git_deleted() {
# # Get number of files that are deleted
#   local git_deleted=$(git status --porcelain 2>/dev/null| grep -c "^[[:space:]]D")
#   if [ "${git_deleted}" != "0" ]
#   then
#     printf "${git_deleted}${red}ᴰ${normal} "
#   fi
# }

# lazy_git_untracked(){
# # Get number of total uncommited files …
#   local git_untracked=$(git status --porcelain 2>/dev/null| grep -c "^??")
#   if [ "${git_untracked}" != "0" ]
#   then
#     printf "${git_untracked}${cyan}ˀ${normal} "
#   fi
# }

# lazy_git_prompt() {
# # Get the current git branch name (if available)
#   local ref=$(git symbolic-ref HEAD 2>/dev/null | cut -d'/' -f3)
#   if [ "$ref" != "" ]
#   then
#     printf "(${lazy_git_staged}${lazy_git_added}${lazy_git_deleted}${lazy_git_untracked}${gray}${ref}${normal})"
#   fi
# }

PS2="▪ "

# PS1="▪"'$(__git_ps1 "(%s)")'"[${cyan}\W${normal}]"
# PS1="▪$(lazy_git_prompt)[${cyan}\W${normal}]"
export PS1="▪\$(lazy_git_status)[${cyan}\W${normal}]"
