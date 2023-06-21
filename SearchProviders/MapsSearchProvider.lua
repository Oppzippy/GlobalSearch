---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local GlobalSearch = AceAddon:GetAddon("GlobalSearch")
---@cast GlobalSearch GlobalSearch
local L = AceLocale:GetLocale("GlobalSearch")
local providerID = "GlobalSearch_Maps"

---@class MapsSearchProvider : SearchProvider
local MapsSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.maps)
---@type AceConfig.OptionsTable
MapsSearchProvider.optionsTable = {
	type = "group",
	get = function(info)
		local db = GlobalSearch:GetProviderOptionsDB(providerID)
		return db[info[#info]]
	end,
	set = function(info, value)
		local db = GlobalSearch:GetProviderOptionsDB(providerID)
		db[info[#info]] = value
		MapsSearchProvider.cache = nil
	end,
	args = {
		listFloorsSeparately = {
			type = "toggle",
			name = L.list_floors_separately,
			order = 1,
		},
		enabledMapTypes = {
			type = "group",
			inline = true,
			name = L.enabled_map_types,
			args = {},
			order = 2,
		},
	},
}

for name, mapTypeID in next, Enum.UIMapType do
	MapsSearchProvider.optionsTable.args.enabledMapTypes.args[name] = {
		name = name,
		type = "toggle",
		get = function()
			local db = GlobalSearch:GetProviderOptionsDB(providerID)
			return not db.disabledMapTypes[mapTypeID]
		end,
		set = function(_, value)
			local db = GlobalSearch:GetProviderOptionsDB(providerID)
			db.disabledMapTypes[mapTypeID] = not value
			MapsSearchProvider.cache = nil
		end,
	}
end

---@return fun(): SearchItem?
function MapsSearchProvider:Fetch()
	return coroutine.wrap(function(...)
		local db = GlobalSearch:GetProviderOptionsDB(providerID)
		---@type table<number, boolean>
		local mapGroupIDs = {}
		for _, mapTypeID in next, Enum.UIMapType do
			if not db.disabledMapTypes[mapTypeID] then
				-- Cosmic if available, otherwise Azeroth
				local uiMapDetails = C_Map.GetMapChildrenInfo(946, mapTypeID, true) or
				C_Map.GetMapChildrenInfo(947, mapTypeID, true)
				for _, details in next, uiMapDetails do
					local groupID = C_Map.GetMapGroupID(details.mapID)
					-- Separate individual maps from groups of maps (dungeons, raids, anything with floors)
					-- so that we can provide the option of only showing one floor per group
					if groupID then
						mapGroupIDs[groupID] = true
					else
						coroutine.yield(self:CreateItem(details.name, details.mapID))
					end
				end
			end
		end

		for groupID in next, mapGroupIDs do
			local mapGroupMemberInfo = C_Map.GetMapGroupMembersInfo(groupID)
			if db.listFloorsSeparately then
				for _, memberInfo in next, mapGroupMemberInfo do
					local mapInfo = C_Map.GetMapInfo(memberInfo.mapID)
					coroutine.yield(self:CreateItem(L.map_with_floor:format(mapInfo.name, memberInfo.name),
						memberInfo.mapID))
				end
			elseif #mapGroupMemberInfo >= 1 then
				local memberInfo = mapGroupMemberInfo[1]
				local mapInfo = C_Map.GetMapInfo(memberInfo.mapID)
				coroutine.yield(self:CreateItem(mapInfo.name, memberInfo.mapID))
			end
		end
	end)
end

function MapsSearchProvider:CreateItem(name, mapID)
	return {
		id = mapID,
		name = name,
		texture = 137176, -- Interface/WorldMap/UI-World-Icon
		action = function()
			local success = pcall(OpenWorldMap, mapID)
			if not success then
				ShowUIPanel(WorldMapFrame)
				MaximizeUIPanel(WorldMapFrame)
				WorldMapFrame:SetMapID(mapID)
			end
		end,
		---@param tooltip GameTooltip
		tooltip = function(tooltip)
			local reversedPath = {}
			local mapInfo = C_Map.GetMapInfo(mapID)
			while mapInfo.parentMapID ~= 0 do
				reversedPath[#reversedPath + 1] = mapInfo.name
				mapInfo = C_Map.GetMapInfo(mapInfo.parentMapID)
			end
			local path = ns.Util.ReverseTable(reversedPath)
			tooltip:SetText(table.concat(path, " > "), nil, nil, nil, nil, true)
		end,
	}
end

GlobalSearchAPI:RegisterProvider(providerID, MapsSearchProvider)
