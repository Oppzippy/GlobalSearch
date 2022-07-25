---@class ns
local _, ns = ...

ns.dbDefaults = {
	profile = {
		options = {
			doesShowKeybindToggle = false,
			disabledSearchProviders = {},
			keybindings = {
				selectNextItem = "DOWN",
				selectPreviousItem = "UP",
			},
			providers = {
				GlobalSearch_Spells = {
					useSpellDescriptions = false,
				},
			},
		},
	},
}
