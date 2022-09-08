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
			showHelp = true,
			position = {
				xOffset = 0,
				yOffset = -20,
			},
			size = {
				width = 350,
			},
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
				GlobalSearch_Maps = {
					disabledMapTypes = {
						[0] = true, -- Cosmic
						[1] = true, -- World
						[4] = true, -- Dungeon
						[5] = true, -- Micro
						[6] = true, -- Orphan
					},
					listFloorsSeparately = false,
				},
				GlobalSearch_EncounterJournal = {
					enableDungeons = true,
					enableRaids = true,
					enableInstances = false,
					enableBosses = true,
				},
			},
		},
	},
}
