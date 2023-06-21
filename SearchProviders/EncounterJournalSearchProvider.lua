-- Disable on classic
if not EJ_GetEncounterInfoByIndex then return end

---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local GlobalSearch = AceAddon:GetAddon("GlobalSearch")
---@cast GlobalSearch GlobalSearch
local L = AceLocale:GetLocale("GlobalSearch")
local providerID = "GlobalSearch_EncounterJournal"

---@class EncounterJournalSearchProvider : SearchProvider
local EncounterJournalSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.encounter_journal)
EncounterJournalSearchProvider.description = L.encounter_journal_search_provider_desc
---@type AceConfig.OptionsTable
EncounterJournalSearchProvider.optionsTable = {
	type = "group",
	get = function(info)
		local db = GlobalSearch:GetProviderOptionsDB(providerID)
		return db[info[#info]]
	end,
	set = function(info, value)
		local db = GlobalSearch:GetProviderOptionsDB(providerID)
		db[info[#info]] = value
		EncounterJournalSearchProvider.cache = nil
	end,
	args = {
		instanceTypes = {
			type = "group",
			inline = true,
			name = L.instance_types,
			args = {
				enableDungeons = {
					type = "toggle",
					name = L.dungeons,
					order = 1,
				},
				enableRaids = {
					type = "toggle",
					name = L.raids,
					order = 2,
				},
			},
		},
		itemTypes = {
			type = "group",
			inline = true,
			name = L.item_types,
			args = {
				enableInstances = {
					type = "toggle",
					name = L.instances,
					order = 1,
				},
				enableBosses = {
					type = "toggle",
					name = L.bosses,
					order = 2,
				},
			},
		},
	},
}

---@param journalInstanceID number
---@param journalEncounterID? number
local function createDisplayInstanceEncounterAction(journalInstanceID, journalEncounterID)
	return function()
		EncounterJournal_LoadUI()
		-- Nav bar buttons will be appended to what was there before if it's not reset
		NavBar_Reset(EncounterJournal.navBar)

		EncounterJournal_DisplayInstance(journalInstanceID)
		if journalEncounterID then
			EncounterJournal_DisplayEncounter(journalEncounterID)
		end
		ShowUIPanel(EncounterJournal)
	end
end

---@return fun(): SearchItem?
function EncounterJournalSearchProvider:Fetch()
	local db = GlobalSearch:GetProviderOptionsDB(providerID)
	return coroutine.wrap(function(...)
		-- Dungeons that are used in more than one expansion are listed more than once
		-- For example, Deadmines is listed under Classic and Cataclysm
		local seenInstanceIDs = {}
		for instanceInfo in self:IterateInstanceInfo(db.enableDungeons, db.enableRaids) do
			if not seenInstanceIDs[instanceInfo.journalInstanceID] then
				seenInstanceIDs[instanceInfo.journalInstanceID] = true
				if db.enableInstances then
					coroutine.yield({
						name = instanceInfo.name,
						tooltip = instanceInfo.description,
						extraSearchText = instanceInfo.description,
						texture = instanceInfo.buttonImage2,
						action = createDisplayInstanceEncounterAction(instanceInfo.journalInstanceID),
					})
				end

				if db.enableBosses then
					for encounterInfo in self:IterateEncounterInfo(instanceInfo) do
						local _, _, _, _, bossImage = EJ_GetCreatureInfo(1, encounterInfo.journalEncounterID)
						coroutine.yield({
							id = encounterInfo.journalEncounterID,
							name = L.boss_from_instance:format(encounterInfo.name, instanceInfo.name),
							tooltip = encounterInfo.description,
							extraSearchText = encounterInfo.description,
							---@param texture Texture
							texture = function(texture)
								if bossImage then
									texture:SetTexture(bossImage)
									-- 2:1 aspect ratio
									texture:SetTexCoord(0.25, 0.75, 0, 1)
								else
									texture:SetTexture(instanceInfo.buttonImage2)
								end
							end,
							action = createDisplayInstanceEncounterAction(encounterInfo.journalInstanceID,
								encounterInfo.journalEncounterID),
						})
					end
				end
			end
		end
	end)
end

---@class EncounterJournalSearchProvider.EncounterInfo
---@field name string
---@field description string
---@field journalEncounterID number
---@field rootSectionID number
---@field link string
---@field journalInstanceID number
---@field dungeonEncounterID number
---@field instanceID number

---@param instanceInfo EncounterJournalSearchProvider.InstanceInfo
---@return fun(): EncounterJournalSearchProvider.EncounterInfo
function EncounterJournalSearchProvider:IterateEncounterInfo(instanceInfo)
	return coroutine.wrap(function()
		EJ_SelectInstance(instanceInfo.journalInstanceID)
		local encounterIndex = 1
		while true do
			local name,
			description,
			journalEncounterID,
			rootSectionID,
			link,
			journalInstanceID,
			dungeonEncounterID,
			instanceID = EJ_GetEncounterInfoByIndex(encounterIndex)
			if not name then
				break
			end
			encounterIndex = encounterIndex + 1
			coroutine.yield({
				name = name,
				description = description,
				journalEncounterID = journalEncounterID,
				rootSectionID = rootSectionID,
				link = link,
				journalInstanceID = journalInstanceID,
				dungeonEncounterID = dungeonEncounterID,
				instanceID = instanceID,
			})
		end
	end)
end

---@class EncounterJournalSearchProvider.InstanceInfo
---@field journalInstanceID number
---@field name string
---@field description string
---@field bgImage number
---@field buttonImage1 number
---@field loreImage number
---@field buttonImage2 number
---@field dungeonAreaMapID number
---@field link string
---@field shouldDisplayDifficulty boolean

---@param includeDungeons boolean
---@param includeRaids boolean
---@return fun(): EncounterJournalSearchProvider.InstanceInfo
function EncounterJournalSearchProvider:IterateInstanceInfo(includeDungeons, includeRaids)
	return coroutine.wrap(function()
		local numTiers = EJ_GetNumTiers()
		for tierIndex = 1, numTiers do
			local function yieldInstances(isRaid)
				EJ_SelectTier(tierIndex)
				local instanceIndex = 1
				-- Dungeons
				while true do
					local journalInstanceID,
					name,
					description,
					bgImage,
					buttonImage1,
					loreImage,
					buttonImage2,
					dungeonAreaMapID,
					link,
					shouldDisplayDifficulty = EJ_GetInstanceByIndex(instanceIndex, isRaid)

					if not journalInstanceID then
						break
					end
					instanceIndex = instanceIndex + 1
					coroutine.yield({
						journalInstanceID = journalInstanceID,
						name = name,
						description = description,
						bgImage = bgImage,
						buttonImage1 = buttonImage1,
						loreImage = loreImage,
						buttonImage2 = buttonImage2,
						dungeonAreaMapID = dungeonAreaMapID,
						link = link,
						shouldDisplayDifficulty = shouldDisplayDifficulty,
					})
				end
			end

			if includeDungeons then
				yieldInstances(false) -- Dungeons
			end
			if includeRaids then
				yieldInstances(true) -- Raids
			end
		end
	end)
end

GlobalSearchAPI:RegisterProvider(providerID, EncounterJournalSearchProvider)
