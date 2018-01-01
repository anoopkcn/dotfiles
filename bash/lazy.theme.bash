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
        local git_status_array=$(git status -s 2>/dev/null | awk '{print $1}')
        if [[ ${#git_status_array[@]} > 0 ]];then
            git_modified=$(echo ${git_status_array} | tr ' ' '\n'| grep -c "[M|R|D|C]")
            if [[ $git_modified != 0 ]]; then 
              git_modified=${git_modified}${yellow}ᴹ${normal}" "
            else
              git_modified=""
            fi
            git_untracked=$(echo ${git_status_array} | tr ' ' '\n'| grep -c "??")
            if [[ $git_untracked != 0 ]]; then 
              git_untracked=${git_untracked}${cyan}ˀ${normal}" "
            else
              git_untracked=""
            fi
            printf "(${git_modified}${git_untracked}${gray}${ref}${normal})"
        fi
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
