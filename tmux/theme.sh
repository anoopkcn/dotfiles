# COLOUR
tm_color_active=colour37
tm_color_inactive=colour241
tm_color_feature=colour37
tm_color_session=colour32
tm_color_selection=colour32
tm_color_datetime=color239
# separators
tm_separator_left_bold=""
tm_separator_left_thin=""
tm_separator_right_bold=""
tm_symbol="▣ "

set -g status-left-length 32
set -g status-right-length 150
set -g status-interval 2


# default statusbar colors
set-option -g status-style fg=$tm_color_active,bg=default,default

# default window title colors
set-window-option -g window-status-style fg=$tm_color_inactive,bg=default
set -g window-status-format "#I#W"

# active window title colors
set-window-option -g window-status-current-style fg=$tm_color_active,bg=default
set-window-option -g  window-status-current-format "#[fg=$tm_color_feature]#I#W"  #[#I,#W#F]

# pane border
set-option -g pane-border-style fg=$tm_color_inactive
set-option -g pane-active-border-style fg=$tm_color_active

# message text
set-option -g message-style fg=$tm_color_active,bg=default
#set-option -g message-fg $tm_color_active

# pane number display
set-option -g display-panes-active-colour $tm_color_active
set-option -g display-panes-colour $tm_color_inactive

# clock
set-window-option -g clock-mode-colour $tm_color_active

tm_date="#[fg=colour239]%d/%m/%Y #[fg=colour239]%H:%M"
tm_pwd="#[fg=colour239,bold]#{pane_current_path}"
tm_host="#[fg=$tm_color_feature,bold]#H"
tm_session_name="#[fg=$tm_color_session]$tm_separator_left_thin#S"
tm_session_symbol="#[fg=$tm_color_session,bold]$tm_symbol"

#settings status bar
set -g status-right $tm_date #$tm_separator_right_thin
set -g status-left $tm_session_symbol$tm_session_name" "

set -wg mode-style bg=$tm_color_selection #,fg=black
