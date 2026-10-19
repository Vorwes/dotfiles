-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

config.front_end = "OpenGL"
config.max_fps = 165
config.default_cursor_style = "BlinkingBlock"
config.animation_fps = 1
config.cursor_blink_rate = 500
config.term = "xterm-256color"
config.audible_bell = "Disabled"

config.cell_width = 0.9
config.font = wezterm.font("ABC Areal Mono")
config.window_background_opacity = 0.7
config.prefer_egl = true
config.font_size = 13.0

-- tabs
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

-- keymaps
config.keys = {
	{
		key = "h",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 50 },
		}),
	},
	{
		key = "v",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 50 },
		}),
	},
	{
		key = "U",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "I",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Down", 5 }),
	},
	{
		key = "O",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "P",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Right", 5 }),
	},
	{ key = "9", mods = "CTRL", action = act.PaneSelect },
	{ key = "L", mods = "CTRL", action = act.ShowDebugOverlay },
	{
		key = "x",
		mods = "CTRL|SHIFT",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "C",
		mods = "CTRL|SHIFT",
		action = act.ActivateCopyMode,
	},
	{
		key = "O",
		mods = "CTRL|ALT",
		action = wezterm.action_callback(function(window, _)
			local overrides = window:get_config_overrides() or {}
			if overrides.window_background_opacity == 1.0 then
				overrides.window_background_opacity = 0.9
			else
				overrides.window_background_opacity = 1.0
			end
			window:set_config_overrides(overrides)
		end),
	},
	{
		key = "UpArrow",
		mods = "SHIFT",
		action = wezterm.action.ScrollByLine(-1),
	},
	{
		key = "DownArrow",
		mods = "SHIFT",
		action = wezterm.action.ScrollByLine(1),
	},
}

-- Custom Colorscheme
config.colors = {
	foreground = "#ffffff",
	background = "#101010",

	cursor_bg = "#b0b0b0",
	cursor_fg = "#101010",
	cursor_border = "#b0b0b0",

	selection_bg = "#272727",
	selection_fg = "#b0b0b0",

	split = "#ffffff",
	compose_cursor = "#d9ba73",
	scrollbar_thumb = "#b0b0b0",

	ansi = {
		"#101010",
		"#ff7676",
		"#a3d6a3",
		"#ffffff",
		"#b3b3b3",
		"#f4b8e4",
		"#fafafa",
		"#a5adce",
	},

	brights = {
		"#50585d",
		"#ff5733",
		"#86cd82",
		"#d9ba73",
		"#ffffff",
		"#f2a4db",
		"#5abfb5",
		"#b5bfe2",
	},

	tab_bar = {
		inactive_tab_edge = "#101010",
		background = "#101010",

		active_tab = {
			fg_color = "#ffffff",
			bg_color = "#101010",
		},

		inactive_tab = {
			fg_color = "#777777",
			bg_color = "#101010",
		},

		inactive_tab_hover = {
			fg_color = "#ebebeb",
			bg_color = "#101010",
		},

		new_tab = {
			fg_color = "#b0b0b0",
			bg_color = "#101010",
		},

		new_tab_hover = {
			fg_color = "#ebebeb",
			bg_color = "#000000",
			intensity = "Bold",
		},
	},
}

config.window_frame = {
	font = wezterm.font({ family = "Iosevka Custom", weight = "Regular" }),
	active_titlebar_bg = "#0c0b0f",
}

config.window_decorations = "RESIZE"
config.default_prog = { "nu.exe" }

config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 0,
}

return config
