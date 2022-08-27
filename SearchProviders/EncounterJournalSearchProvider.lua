---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class EncounterJournalSearchProvider : SearchProvider
local EncounterJournalSearchProvider = {
	localizedName = L.encounter_journal,
}

---@return SearchItem[]
function EncounterJournalSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end

	return self.cache
end

---@return SearchItem[]
function EncounterJournalSearchProvider:Fetch()
	local items = {}
	local seenIds = {}
	for instanceInfo, encounterInfo in self:IterateInstancesAndEncounterInfo() do
		if not seenIds[encounterInfo.journalEncounterID] then
			seenIds[encounterInfo.journalEncounterID] = true

			local _, _, _, _, bossImage = EJ_GetCreatureInfo(1, encounterInfo.journalEncounterID)
			items[#items + 1] = {
				name = L.boss_from_instance:format(encounterInfo.name, instanceInfo.name),
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
				action = function()
					EncounterJournal_LoadUI()

					-- Nav bar buttons will be appended to what was there before if it's not reset
					NavBar_Reset(EncounterJournal.navBar)

					EncounterJournal_DisplayInstance(encounterInfo.journalInstanceID)
					EncounterJournal_DisplayEncounter(encounterInfo.journalEncounterID)
					ShowUIPanel(EncounterJournal)
				end,
			}
		end
	end

	return items
end

---@return fun(): EncounterJournalSearchProvider.InstanceInfo, EncounterJournalSearchProvider.EncounterInfo
function EncounterJournalSearchProvider:IterateInstancesAndEncounterInfo()
	return coroutine.wrap(function()
		for instanceInfo in self:IterateInstanceInfo() do
			for encounterInfo in self:IterateEncounterInfo(instanceInfo) do
				coroutine.yield(instanceInfo, encounterInfo)
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

---@return fun(): EncounterJournalSearchProvider.InstanceInfo
function EncounterJournalSearchProvider:IterateInstanceInfo()
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

			yieldInstances(false) -- Dungeons
			yieldInstances(true) -- Raids
		end
	end)
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_EncounterJournal", EncounterJournalSearchProvider)
