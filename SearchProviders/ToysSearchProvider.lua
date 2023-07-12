-- Disable provider on classic
if C_ToyBox == nil then return end

---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale("GlobalSearch")
local GlobalSearch = AceAddon:GetAddon("GlobalSearch")
---@cast GlobalSearch GlobalSearch

---@class ToysSearchProvider : SearchProvider, AceEvent-3.0
local ToysSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.toys)
ToysSearchProvider.description = L.toys_search_provider_desc
ToysSearchProvider.items = {}
ToysSearchProvider.waitingForToysUpdated = false
AceEvent:Embed(ToysSearchProvider)

local toyBoxSettings
do
	local trueTable = setmetatable({}, {
		__index = function()
			return true
		end,
	})
	toyBoxSettings = {
		search = "",
		expansion = trueTable,
		source = trueTable,
		collected = true,
		uncollected = false,
		unusable = false,
	}
end

local function GetToyBoxSettings()
	local settings = {
		search = (ToyBox and ToyBox.searchBox and ToyBox.searchBox:GetText()) or "",
		collected = C_ToyBox.GetCollectedShown(),
		uncollected = C_ToyBox.GetUncollectedShown(),
		unusable = C_ToyBox.GetUnusableShown(),
		expansion = {},
		source = {},
	}
	for i = 1, GetNumExpansions() do
		settings.expansion[i] = C_ToyBox.IsExpansionTypeFilterChecked(i)
	end
	for i = 1, C_PetJournal.GetNumPetSources() do -- Blizzard uses the pet journal to get num sources in Blizzard_ToyBox.lua
		settings.source[i] = C_ToyBox.IsSourceTypeFilterChecked(i)
	end
	return settings
end

local function SetToyBoxSettings(settings)
	C_ToyBox.SetFilterString(settings.search)
	C_ToyBox.SetCollectedShown(settings.collected)
	C_ToyBox.SetUncollectedShown(settings.uncollected)
	C_ToyBox.SetUnusableShown(settings.unusable)
	for i = 1, GetNumExpansions() do
		C_ToyBox.SetExpansionTypeFilter(i, settings.expansion[i])
	end
	for i = 1, C_PetJournal.GetNumPetSources() do -- Blizzard uses the pet journal to get num sources in Blizzard_ToyBox.lua
		C_ToyBox.SetSourceTypeFilter(i, settings.source[i])
	end
end

---@return SearchItem[]
function ToysSearchProvider:Fetch()
	if not self.waitingForToysUpdated then
		self.prevSettings = GetToyBoxSettings()
		SetToyBoxSettings(toyBoxSettings)
		-- Start with the currently available toys, update later if it's wrong
		self.items = self:GetToyItems()
		GlobalSearch:Debugf("ToysSearchProvider: Found %d toys initially", #self.items)
		self.waitingForToysUpdated = true
	end

	return self.items
end

---@param left SearchItem[]
---@param right SearchItem[]
---@return boolean
local function areItemListsEqual(left, right)
	if #left ~= #right then return false end
	-- We shouldn't have to worry about the order since the game doesn't have sorting options for toys,
	-- so the default sorting will be applied to both lists of toys.
	for i, leftItem in ipairs(left) do
		local rightItem = right[i]
		if leftItem.id ~= rightItem.id then
			return false
		end
	end
	return true
end

function ToysSearchProvider:TOYS_UPDATED()
	-- TOYS_UPDATED will continue to fire in quick succession until all toys are loaded in.
	if self.waitingForToysUpdated then
		-- We need to collect the items now rather than after the debounce, since we know the names are not nil now,
		-- that won't necessarily be the case in a second from now.
		self.newItems = self:GetToyItems()

		-- We need the number of frames passed condition as well rather than just C_Timer.NewTimer for if the frame
		-- rate drops below 1. If it does, a NewTimer would fire too soon before it could be canceled on the next frame.
		self.framesSinceLastToysUpdated = 0
		self.lastToysUpdatedTime = GetTime()

		if not self.updateToysTimer then
			self.updateToysTimer = C_Timer.NewTicker(0, function(ticker)
				self.framesSinceLastToysUpdated = self.framesSinceLastToysUpdated + 1
				if GetTime() - self.lastToysUpdatedTime > 1 and self.framesSinceLastToysUpdated > 5 then
					ticker:Cancel()
					self.updateToysTimer = nil

					local newItems = self.newItems
					self.newItems = nil
					GlobalSearch:Debugf("ToysSearchProvider: TOYS_UPDATED stopped firing. Found %d toys.", #newItems)

					-- Save time if the lists are the same by not having to reindex
					if not areItemListsEqual(self.items, newItems) then
						self.items = newItems
						self:ClearCache()
						self:SendMessage("GlobalSearch_ProviderItemsUpdated", "GlobalSearch_Toys")
					end
					SetToyBoxSettings(self.prevSettings)
					-- waitingForToysUpdated must be set to false AFTER GlobalSearch_ProviderItemsUpdated to ensure we
					-- don't trigger a loop of fetching toys.
					self.waitingForToysUpdated = false
				end
			end)
		end
	end
end

-- Toys never get unlearned, so never clearing the cache is okay
local tooltipCache = setmetatable({}, {
	__index = function(t, itemID)
		local tooltipStorage = GlobalSearch:GetModule("TooltipStorage")
		---@cast tooltipStorage TooltipStorageModule
		local tooltip = tooltipStorage:GetToyByItemID(itemID)
		t[itemID] = tooltip
		return tooltip
	end
})

---@return SearchItem[]
function ToysSearchProvider:GetToyItems()
	local items = {}
	for i = 1, C_ToyBox.GetNumFilteredToys() do
		local itemID = C_ToyBox.GetToyFromIndex(i)
		local _, name, icon = C_ToyBox.GetToyInfo(itemID)
		-- If toys aren't fully loaded in, name can be nil. In that case, return what we have.
		-- The full list of toys will be retrieved later.
		-- By continuing to iterate through despite having at least one missing toy name,
		-- the game receives our requests for toy names, allowing us to get all of the results
		-- in one TOYS_UPDATED rather than needing a TOYS_UPDATED per toy name.
		if name then
			items[#items + 1] = {
				id = itemID,
				name = name,
				extraSearchText = tooltipCache[itemID],
				texture = icon,
				---@param tooltip GameTooltip
				tooltip = function(tooltip)
					tooltip:SetToyByItemID(itemID)
				end,
				macroText = "/use " .. name,
				pickup = function()
					C_ToyBox.PickupToyBoxItem(itemID)
				end,
				hyperlink = function()
					return C_ToyBox.GetToyLink(itemID)
				end,
			}
		end
	end
	return items
end

ToysSearchProvider:RegisterEvent("NEW_TOY_ADDED", "ClearCache")
ToysSearchProvider:RegisterEvent("TOYS_UPDATED")
GlobalSearchAPI:RegisterProvider("GlobalSearch_Toys", ToysSearchProvider)
