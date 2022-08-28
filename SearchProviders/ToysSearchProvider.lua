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
local ToysSearchProvider = {
	localizedName = L.toys,
	description = L.toys_search_provider_desc,
}
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
function ToysSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end
	return self.cache
end

function ToysSearchProvider:ClearCache()
	self.cache = nil
end

---@return SearchItem[]
function ToysSearchProvider:Fetch()
	local tooltipStorage = GlobalSearch:GetModule("TooltipStorage")
	local items = {}
	local prevSettings = GetToyBoxSettings()
	SetToyBoxSettings(toyBoxSettings)
	for i = 1, C_ToyBox.GetNumFilteredToys() do
		local itemID = C_ToyBox.GetToyFromIndex(i)
		local _, name, icon = C_ToyBox.GetToyInfo(itemID)
		items[#items + 1] = {
			name = name,
			extraSearchText = tooltipStorage:GetTooltip(function(tooltip)
				---@cast tooltip GameTooltip
				tooltip:SetToyByItemID(itemID)
			end),
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
	SetToyBoxSettings(prevSettings)
	return items
end

ToysSearchProvider:RegisterEvent("NEW_TOY_ADDED", "ClearCache")
GlobalSearchAPI:RegisterProvider("GlobalSearch_Toys", ToysSearchProvider)
