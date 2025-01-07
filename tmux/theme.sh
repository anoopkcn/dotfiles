# COLOUR
color_gray="#626262"
color_green="#a6da95"
color_blue="#8aadf4"
color_selection="#387EA2"
color_default=default
date_time="#[fg=$color_gray]%d/%m/%Y #[fg=$color_gray]%H:%M"
session_name="#[fg=$color_blue]@#S "
active_pane="#[fg=$color_green]#I:#W#{?window_zoomed_flag,#[fg=blue][Z],}" #F
inactive_pane="#I:#W#{?window_zoomed_flag,[Z],}"

set-window-option -g window-status-style fg=$color_gray,bg=$color_default
set-window-option -g window-status-current-style fg=$color_blue,bg=$color_default
set-window-option -g window-status-current-format $active_pane
set-window-option -g window-status-format $inactive_pane
set-window-option -g clock-mode-colour $color_green

set-option -g status-style fg=$color_blue,bg=$color_default
set-option -g pane-border-style fg=$color_gray
set-option -g pane-active-border-style fg=$color_green
set-option -g message-style fg=$color_blue,bg=$color_default
set-option -g display-panes-active-colour $color_blue
set-option -g display-panes-colour $color_gray
# set-option -g status-left-length "100"
# set-option -g status-right-length "100"
set-option -g status-interval 2
set-option -g mode-style bg=$color_selection
set-option -g status-right $date_time
set-option -g status-left $session_name
