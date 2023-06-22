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
ToysSearchProvider.toysUpdatedCount = nil
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
	self.numConsecutiveToysUpdatedCalls = 0

	self.prevSettings = GetToyBoxSettings()
	if not self.toysUpdatedCount then
		SetToyBoxSettings(toyBoxSettings)
		-- Start with the currently available toys, update later if it's wrong
		self.items = self:GetToyItems()
		self.toysUpdatedCount = 0
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
	-- Sometimes TOYS_UPDATED fires twice, and toys are only available for the second one.
	-- To work around this, we clear the cache for every event fired shortly after the first.
	if self.toysUpdatedCount then
		self.toysUpdatedCount = self.toysUpdatedCount + 1
		if self.toysUpdatedCount == 1 then
			C_Timer.After(0.5, function()
				self.toysUpdatedCount = nil
				SetToyBoxSettings(self.prevSettings)
			end)
		end

		local newItems = self:GetToyItems()
		-- Save time if the lists are the same by not having to reindex everything
		if not areItemListsEqual(self.items, newItems) then
			self.items = newItems
			self:ClearCache()
			self:SendMessage("GlobalSearch_ProviderItemsUpdated", "GlobalSearch_Toys")
		end
	end
end

---@return SearchItem[]
function ToysSearchProvider:GetToyItems()
	local tooltipStorage = GlobalSearch:GetModule("TooltipStorage")
	---@cast tooltipStorage TooltipStorageModule
	local items = {}
	for i = 1, C_ToyBox.GetNumFilteredToys() do
		local itemID = C_ToyBox.GetToyFromIndex(i)
		local _, name, icon = C_ToyBox.GetToyInfo(itemID)
		items[#items + 1] = {
			id = itemID,
			name = name,
			extraSearchText = tooltipStorage:GetToyByItemID(itemID),
			texture = icon,
			---@param tooltip GameTooltip
			tooltip = function(tooltip)
				tooltip:SetToyByItemID(itemID)
			end,
			macroText = "/use " .. name,
			pickup = function()
				C_ToyBox.PickupToyBoxItem(itemID)
			end,
			hyperlink = C_ToyBox.GetToyLink(itemID),
		}
	end
	return items
end

ToysSearchProvider:RegisterEvent("NEW_TOY_ADDED", "ClearCache")
ToysSearchProvider:RegisterEvent("TOYS_UPDATED")
GlobalSearchAPI:RegisterProvider("GlobalSearch_Toys", ToysSearchProvider)
