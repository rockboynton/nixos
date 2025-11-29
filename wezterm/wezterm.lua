local wezterm = require('wezterm')

local config = wezterm.config_builder()

config.color_scheme = 'GruvboxDark'
config.font = wezterm.font('FiraCode Nerd Font')
config.font_size = 11.0
-- config.window_background_opacity = 0.8
-- config.kde_window_background_blur = true
config.background = {
    {
        source = {
            File = '/home/rockboynton/Downloads/honeycomb-modified (1).png',
        },
    },
}
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 5000
config.tab_and_split_indices_are_zero_based = true
config.enable_kitty_keyboard = true
-- Since we are always in a zellij session, we can never lose our layout/scrollback
config.window_close_confirmation = 'NeverPrompt'
config.window_padding = {
    left = '0.5cell',
    right = '0.5cell',
    top = '0.25cell',
    bottom = '0cell',
}

return config
