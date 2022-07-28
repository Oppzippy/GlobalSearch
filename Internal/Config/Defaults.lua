---@class ns
local ns = select(2, ...)

ns.dbDefaults = {
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
				GlobalSearch_Spells = {
					useSpellDescriptions = false,
				},
			},
		},
	},
}
