SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${bold_red}✸${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
SCM_GIT_CHAR="${bold_green}±${normal}"
SCM_SVN_CHAR="${bold_cyan}⑆${normal}"
SCM_HG_CHAR="${bold_red}☿${normal}"

case $TERM in
	xterm*)
	TITLEBAR="\[\033]0;\w\007\]"
	;;
	*)
	TITLEBAR=""
	;;
esac

PS3=">> "

is_vim_shell() {
	if [ ! -z "$VIMRUNTIME" ]
	then
		echo "[${cyan}vim shell${normal}]"
	fi
}

modern_scm_prompt() {
	CHAR=$(scm_char)
	if [ $CHAR = $SCM_NONE_CHAR ]
	then
		return
	else
		echo "[$(scm_prompt_info)]"
	fi
}

# is_task_exist(){
#   is_task_todo="$(type -p task)" 
#   if ! [ -z $is_task_todo ]; then
#     num_tasks=$(task +in +PENDING count) 
#     if [ "$num_tasks" != "0" ];then
#       echo "[${num_tasks}]"
#     fi
#   fi
# }

prompt() {
  if [ $? -ne 0 ];then
    PS1="${TITLEBAR}${bold_red}▪${reset_color}${normal}$(modern_scm_prompt)[${cyan}\W${normal}]$(is_vim_shell)${normal}"
	else
    PS1="${TITLEBAR}▪$(modern_scm_prompt)[${cyan}\W${normal}]$(is_vim_shell)"
	fi
}

PS2="▪ "

safe_append_prompt_command prompt
