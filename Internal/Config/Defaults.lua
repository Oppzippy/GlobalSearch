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
			showMouseoverTooltip = true,
			disabledSearchProviders = {
				GlobalSearch_Achievements = true,
			},
			keybindings = {
				selectNextItem = "DOWN",
				selectPreviousItem = "UP",
				selectNextPage = "ALT-RIGHT",
				selectPreviousPage = "ALT-LEFT",
			},
			searchProviders = {
			},
		},
	},
}
