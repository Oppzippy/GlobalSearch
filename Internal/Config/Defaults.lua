---@class ns
local ns = select(2, ...)

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
