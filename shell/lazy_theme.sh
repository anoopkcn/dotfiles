## Colors are wraped using \[ and \] for linux and mac...
## ... because otherwise in limited width terminal windows ...
## ... lines seem to overwrite themselves ( a visual effect : commands will still run).
bold="\[\e[1m\]"
regular="\[\e[21m\]"
normal="\[\e[39m\]"
cyan="\[\e[36m\]"
yellow="\[\e[33m\]"
green="\[\e[32m\]"
gray_light="\[\e[37m\]"
gray_dark="\[\e[90m\]"

# functions for PS1
# MYPOS strips the directory names, except first and the last...
#... according to the legth of the term
export MYPS='$(echo -n "${PWD/#$HOME/~}" | awk -F "/" '"'"'{
if (length($0) > 14) { if (NF>4) print $1 "/" $2 "/.../" $(NF-1) "/" $NF;
else if (NF>3) print $1 "/" $2 "/.../" $NF;
else print $1 "/.../" $NF; }
else print $0;}'"'"')'

#PS* status
PS3=">> "
PS2="${gray_light}↳ ${normal}"
# export PS1="▪ \u@${green}\h${normal}:\$(lazy_git_status)[${cyan}\W${normal}] "
# export PS1="▪ \u@${green}\h${normal}:"'$(__git_ps1 "(%s)")'"[${cyan}\W${normal}] "
# export PS1="\u@${green}\h${normal}:[${cyan}$(eval 'echo ${MYPS}')${normal}] "
export PS1="${green}\h${normal}[${cyan}\W${normal}]${gray_dark}"'$(__git_ps1)'"${normal} "
