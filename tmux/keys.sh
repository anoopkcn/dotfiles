unbind C-b
set -g prefix C-Space
bind Space send-prefix

bind-key a send-prefix

bind R source-file ~/.config/tmux/tmux.conf \; display "TMUX Reloaded"

bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# synchronize all panes in a window
bind y setw synchronize-panes

# pane movement shortcuts
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

bind -r C-h select-window -t :-
bind -r C-l select-window -t :+

# Resize pane shortcut
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# more settings to make copy-mode more vim-like
unbind [
bind Space copy-mode
set-window-option -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

# CUSTOM BINDINGS
bind-key -r f display-popup -E -w 80% -h 80% "source ~/.config/tmux/tmuxtools.sh && fzf_create_session"
bind-key -r g display-popup -E -w 80% -h 80% "source ~/.config/tmux/tmuxtools.sh && fzf_attach_session"
bind-key -r l display-popup -E -w 80% -h 80% "source ~/.config/tmux/tmuxtools.sh && fzf_list_sessions"
bind-key -r k display-popup -E -w 80% -h 80% "source ~/.config/tmux/tmuxtools.sh && fzf_kill_session"
