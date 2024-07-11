# COLOUR
thm_bg="#24273a"
tm_fg="#cad3f5"
tm_cyan="#91d7e3"
tm_black="#1e2030"
tm_gray="#626262"
tm_magenta="#c6a0f6"
tm_pink="#f5bde6"
tm_red="#ed8796"
tm_green="#a6da95"
tm_yellow="#eed49f"
tm_blue="#8aadf4"
tm_orange="#f5a97f"
tm_black4="#5b6078"
tm_selection="#387EA2"

# set -g status 1
set -g status-left-length "100"
set -g status-right-length "100"
set -g status-interval 2
set -wg mode-style bg=$tm_selection

# default statusbar colors
set-option -g status-style fg=$tm_blue,bg=default,default

# default window title colors
set-window-option -g window-status-style fg=$tm_gray,bg=default
set -g window-status-format "#W" ##I

# active window title colors
set-window-option -g window-status-current-style fg=$tm_blue,bg=default
set-window-option -g  window-status-current-format "#[fg=$tm_green]#W"  #[#I,#W#F]

# pane border
set-option -g pane-border-style fg=$tm_gray
set-option -g pane-active-border-style fg=$tm_green

# message text
set-option -g message-style fg=$tm_green,bg=default
#set-option -g message-fg $tm_color_active

# pane number display
set-option -g display-panes-active-colour $tm_green
set-option -g display-panes-colour $tm_gray

# clock
set-window-option -g clock-mode-colour $tm_green

tm_date="#[fg=$tm_gray]%d/%m/%Y #[fg=$tm_gray]%H:%M"
# tm_pwd="#[fg=$tm_gray,bold]#{pane_current_path}"
tm_host="#[fg=$tm_green,bold]#H"
tm_session_name="#[fg=$tm_blue]#S"

#settings status bar
set -g status-right  $tm_session_name" "$tm_date 
set -g status-left ""
