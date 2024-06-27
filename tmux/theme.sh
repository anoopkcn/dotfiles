# COLOUR
tm_color_active=colour2
tm_color_inactive=colour241
tm_color_feature=colour2
tm_color_session=colour181
tm_color_sysinfo=colour110
tm_color_selection=colour32
tm_color_datetime=color239
# separators
tm_separator_left_bold=""
tm_separator_left_thin=""
tm_separator_right_bold=""
# tm_separator_right_thin=" ▣"

set -g status-left-length 32
set -g status-right-length 150
set -g status-interval 2


# default statusbar colors
set-option -g status-style fg=$tm_color_active,bg=default,default

# default window title colors
set-window-option -g window-status-style fg=$tm_color_inactive,bg=default
set -g window-status-format "#I▣ #W"

# active window title colors
set-window-option -g window-status-current-style fg=$tm_color_active,bg=default
set-window-option -g  window-status-current-format "#[fg=$tm_color_feature]#I▣ #W"  #[#I,#W#F]

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

tm_date="#[fg=colour239]%d-%b#[fg=colour239] %l:%M"
tm_pwd="#[fg=colour239,bold]#{pane_current_path}"
tm_host="#[fg=$tm_color_feature,bold]#H"
tm_session_name="#[fg=$tm_color_session,bold,italics]$tm_separator_left_thin#S"
tm_cpu_info="#[fg=$tm_color_sysinfo]#(tmux-mem-cpu-load --interval 3)#[default]"
# tm_separator_right_thin=" ▣"


#settings status bar
set -g status-right $tm_session_name #' '$tm_date #$tm_separator_right_thin
set -g status-left ''

# set-option -g status-position top
set -wg mode-style bg=$tm_color_selection #,fg=black
