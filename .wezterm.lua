local wezterm = require("wezterm")
return {
  adjust_window_size_when_changing_font_size = false,
  color_scheme = "Catppuccin Mocha",
  enable_tab_bar = false,
  font_size = 18,
  font = wezterm.font("JetBrainsMono Nerd Font"),
  macos_window_background_blur = 20,
  window_background_opacity = 0.96,
  window_decorations = "RESIZE",
  keys = {
    {
      key = "'",
      mods = "CTRL",
      action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
    },
    {
      key = "F",
      mods = "CMD", -- CMD = ⌘
      action = wezterm.action.ToggleFullScreen,
    },
  },
  mouse_bindings = {
    -- Ctrl-click will open the link under the mouse cursor
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = wezterm.action.OpenLinkAtMouseCursor,
    },
  },
}
