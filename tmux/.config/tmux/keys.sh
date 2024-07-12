# Key Bindings#
#--------------

unbind C-b
set -g prefix C-Space
bind Space send-prefix

bind-key a send-prefix # for nested tmux sessions

bind R source-file ~/.config/tmux/tmux.conf \; display "TMUX Reloaded" 

bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# pane movement
bind-key m command-prompt -p "join pane from:"  "join-pane -s '%%'"
bind-key M command-prompt -p "send pane to:"  "join-pane -t '%%'"

bind y setw synchronize-panes # synchronize all panes in a window

# pane movement shortcuts
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

bind -r C-h select-window -t :-
bind -r C-l select-window -t :+

# Resize pane shortcut
bind -r H resize-pane -L 10
bind -r J resize-pane -D 10
bind -r K resize-pane -U 10
bind -r L resize-pane -R 10

# more settings to make copy-mode more vim-like
unbind [
bind Space copy-mode
set-window-option -g mode-keys vi

# clipboard setting
unbind -T copy-mode-vi MouseDragEnd1Pane
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection
bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'pbcopy'

bind-key -r i run-shell "tmux neww ~/.config/zsh/cht.sh"

# search for prompt
# bind-key @ copy-mode\;\
#            send-keys -X start-of-line\;\
#            send-keys -X search-backward "chand@"
