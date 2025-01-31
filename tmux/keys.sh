unbind C-b
set -g prefix C-Space
bind Space send-prefix

bind-key a send-prefix

bind R source-file ~/.config/tmux/tmux.conf \; display "TMUX Reloaded"

bind \\ split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# synchronize all panes in a window
bind y setw synchronize-panes

# CUSTOM BINDING
bind-key -n C-S-Left swap-window -t -1\; select-window -t -1
bind-key -n C-S-Right swap-window -t +1\; select-window -t +1

tm_source="source ~/.config/tmux/tools.sh"
tm_new="TM_SEARCH_DIRS='$TM_SEARCH_DIRS' $tm_source"

bind-key -r f display-popup -E -w 70% "$tm_new && fzf_create_session --height=100%"
bind-key -r l display-popup -E -w 70% "$tm_source && fzf_attach_session --height=100%"
bind-key -r r display-popup -E -w 70% "$tm_source && fzf_rename_session --height=100%"
bind-key -r k display-popup -E -w 70% "$tm_source && fzf_kill_session --height=100%"
# bind-key -r l display-popup -E -w 80% "$tmctl && fzf_list_sessions --height=100%"

# Smart pane switching with awareness of Vim splits.
# Updated version from https://github.com/christoomey/vim-tmux-navigator
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?|fzf)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'
bind-key -n 'C-\' if-shell "$is_vim" 'send-keys C-\\' 'select-pane -l'

bind-key -T copy-mode-vi 'C-h' select-pane -L
bind-key -T copy-mode-vi 'C-j' select-pane -D
bind-key -T copy-mode-vi 'C-k' select-pane -U
bind-key -T copy-mode-vi 'C-l' select-pane -R
bind-key -T copy-mode-vi 'C-\' select-pane -l

# more settings to make copy-mode more vim-like
unbind [
bind Space copy-mode
set-window-option -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
