---@class ns
local ns = select(2, ...)

ns.dbDefaults = {
	global = {
		cache = {
			achievements = {},
		},
	},
	profile = {
		recentItemsV2 = {},
		options = {
			debugMode = false,
			doesShowKeybindToggle = false,
			showMouseoverTooltip = true,
			showHelp = true,
			maxRecentItems = 20,
			frameStrata = "DIALOG",
			resultsPerPage = 10,
			preloadCache = false,
			preloadCacheDelayInSeconds = 30,
			taskQueueTimeAllocationInMilliseconds = 1,
			position = {
				xOffset = 0,
				yOffset = -20,
			},
			size = {
				width = 350,
				height = 40,
			},
			font = {
				font = "Friz Quadrata TT",
				size = 12,
				outline = false,
				monochrome = false,
			},
			helpTextFont = {
				font = "Friz Quadrata TT",
				size = 12,
				outline = "OUTLINE",
				monochrome = false,
			},
			tooltipFont = {
				font = "Friz Quadrata TT",
				size = 12,
				outline = false,
				monochrome = false,
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
