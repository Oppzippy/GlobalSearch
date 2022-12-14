---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class InstanceOptionsSearchProvider : SearchProvider
local InstanceOptionsSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.instance_options)
InstanceOptionsSearchProvider.description = L.instance_options_search_provider_desc

local dungeonDifficulties = {
	[1] = PLAYER_DIFFICULTY1, -- Normal
	[2] = PLAYER_DIFFICULTY2, -- Heroic
	[23] = PLAYER_DIFFICULTY6, -- Mythic
}

local raidDifficulties = {
	[14] = PLAYER_DIFFICULTY1, -- Normal
	[15] = PLAYER_DIFFICULTY2, -- Heroic
	[16] = PLAYER_DIFFICULTY6, -- Mythic
}

---@return SearchItem[]
function InstanceOptionsSearchProvider:Fetch()
	---@type SearchItem[]
	local items = {
		{
			id = "resetAllInstances",
			name = L.reset_all_instances,
			texture = 337500, -- Interface/LFGFrame/UI-LFG-PORTRAIT
			action = function()
				StaticPopup_Show("CONFIRM_RESET_INSTANCES")
			end,
		},
		{
			id = "legacyRaidDifficulty:3",
			name = L.legacy_raid_difficulty_x:format(RAID_DIFFICULTY1),
			texture = 341547, -- Interface/LFGFrame/UI-LFR-PORTRAIT
			action = function()
				SetLegacyRaidDifficultyID(3)
			end,
		},
		{
			id = "legacyRaidDifficulty:4",
			name = L.legacy_raid_difficulty_x:format(RAID_DIFFICULTY2),
			texture = 341547, -- Interface/LFGFrame/UI-LFR-PORTRAIT
			action = function()
				SetLegacyRaidDifficultyID(4)
			end,
		},
	}
	for difficultyID, localizedName in next, dungeonDifficulties do
		items[#items + 1] = {
			id = "dungeonDifficulty:" .. difficultyID,
			name = L.dungeon_difficulty_x:format(localizedName),
			texture = 133076, -- Interface/Icons/INV_Helmet_08 (Dungeon Finder icon)
			action = function()
				SetDungeonDifficultyID(difficultyID)
			end,
		}
	end
	for difficultyID, localizedName in next, raidDifficulties do
		items[#items + 1] = {
			id = "raidDifficulty:" .. difficultyID,
			name = L.raid_difficulty_x:format(localizedName),
			texture = 341547, -- Interface/LFGFrame/UI-LFR-PORTRAIT
			action = function()
				SetRaidDifficultyID(difficultyID)
			end,
		}
	end
	return items
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_InstanceOptions", InstanceOptionsSearchProvider)
