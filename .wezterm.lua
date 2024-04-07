local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then 
    config = wezterm.config_builder()
end

config.color_scheme = 'Gruvbox dark, medium (base16)'
config.font = wezterm.font 'FiraCode Nerd Font'
config.font_size = 11.0
config.window_background_opacity = 0.9
config.window_decorations = 'RESIZE'
config.front_end = 'WebGpu'
config.hide_tab_bar_if_only_one_tab = true;
config.initial_cols = 120
config.initial_rows = 40
config.scrollback_lines = 5000
config.tab_and_split_indices_are_zero_based = true

return config
