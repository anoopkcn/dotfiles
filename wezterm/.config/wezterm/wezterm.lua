local wezterm = require 'wezterm';

local config = wezterm.config_builder()

config.font = wezterm.font("ZedMono Nerd Font")
config.font_size = 15
config.enable_tab_bar = false
config.window_decorations = "TITLE | RESIZE"
config.color_scheme = "Catppuccin Macchiato"
config.window_padding = {
  left = 5,
  right = 5,
  top = 10,
  bottom = 10,
}
config.initial_cols = 120
config.initial_rows = 38

return config
