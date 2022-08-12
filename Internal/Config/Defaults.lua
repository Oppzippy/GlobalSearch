---@class ns
local ns = select(2, ...)

ns.dbDefaults = {
	global = {
		cache = {
			achievements = {},
		},
	},
	profile = {
		options = {
			doesShowKeybindToggle = false,
			disabledSearchProviders = {
				GlobalSearch_Achievements = true,
			},
			keybindings = {
				selectNextItem = "DOWN",
				selectPreviousItem = "UP",
			},
			providers = {
			},
		},
	},
}
