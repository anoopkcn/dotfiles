#!/usr/bin/env bash
# tmux related functions

function tm(){
# abort if we're already inside a TMUX session
if ( [ "$TMUX" == "" ] ) ;then
# startup a "default" session if non currently exists
# tmux has-session -t _default || tmux new-session -s _default -d

# present menu for user to choose which workspace to open
PS3="Please choose your session: "
options=($(tmux list-sessions -F "#S" 2>/dev/null) "New Session" "quit")
echo "Available sessions"
echo "------------------"
select opt in "${options[@]}"
do
	case $opt in
		"New Session")
			read -p "Enter new session name: " SESSION_NAME
			tmux new -s "$SESSION_NAME"
			break
			;;
		"quit")
			break;;
		*)
			tmux attach-session -t $opt
			break
			;;
	esac
done
fi
}

tls(){
    t_sessions=($(tmux ls | cut -d : -f 1));
    for i in ${!t_sessions[@]};do
        printf "\e[31m${t_sessions[i]}\e[0m\n"
        (tmux lsw -t ${t_sessions[i]} | gawk '{print $1,$2}');
    done
}

tkillall(){
    t_sessions=($(tmux ls | cut -d : -f 1));
    for i in ${!t_sessions[@]};do
        tmux kill-session -t  ${t_sessions[i]} ;
    done
}

