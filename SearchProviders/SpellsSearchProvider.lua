---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale("GlobalSearch")
local GlobalSearch = AceAddon:GetAddon("GlobalSearch")
---@cast GlobalSearch GlobalSearch

local providerName = "GlobalSearch_Spells"

---@class SpellsSearchProvider : SearchProvider, AceEvent-3.0
local SpellsSearchProvider = {
	localizedName = L.spells,
}
AceEvent:Embed(SpellsSearchProvider)

---@return SearchItem[]
function SpellsSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end
	return self.cache
end

function SpellsSearchProvider:ClearCache()
	self.cache = nil
end

---@return SearchItem[]
function SpellsSearchProvider:Fetch()
	local items = {}

	for spellID in self:IterateKnownSpells() do
		if not IsPassiveSpell(spellID) then
			local name, _, icon = GetSpellInfo(spellID)
			local subtext = GetSpellSubtext(spellID)
			local displayName, castName = name, name

			if subtext and subtext ~= "" then
				displayName = string.format("%s (%s)", name, subtext)
				castName = string.format("%s(%s)", name, subtext)
			end

			---@type string?
			local description = GetSpellDescription(spellID)
			if description and description ~= "" then
				description = ns.Util.StripEscapeSequences(description)
			else
				description = nil
			end

			items[#items + 1] = {
				name = displayName,
				category = L.spells,
				texture = icon,
				extraSearchText = description,
				tooltip = function(tooltip)
					tooltip:SetSpellByID(spellID)
				end,
				macroText = "/cast " .. castName,
				pickup = function()
					PickupSpell(spellID)
				end,
				hyperlink = GetSpellLink(spellID),
			}
		end
	end

	return items
end

function SpellsSearchProvider:IterateKnownSpells()
	local tabIterator = self:IterateSpellTabs()
	local _, offset, numEntries = tabIterator()
	local index = 1
	return function()
		while numEntries do
			local _, _, spellID = GetSpellBookItemName(offset + index, BOOKTYPE_SPELL)
			index = index + 1
			if index > numEntries then
				_, offset, numEntries = tabIterator()
				index = 1
			end

			if spellID and IsSpellKnownOrOverridesKnown(spellID) then
				return spellID
			end
		end
	end
end

function SpellsSearchProvider:IterateSpellTabs()
	local currentTab = 1
	local numTabs = GetNumSpellTabs()

	return function()
		-- offspecID 0 means the spells are not for an offspec
		local _, offset, numEntries, offspecID
		repeat
			_, _, offset, numEntries, _, offspecID = GetSpellTabInfo(currentTab)
			currentTab = currentTab + 1
			if currentTab > numTabs then return end
		until offspecID == 0
		return currentTab, offset, numEntries
	end
end

SpellsSearchProvider:RegisterEvent("SPELLS_CHANGED", "ClearCache")
GlobalSearchAPI:RegisterProvider(providerName, SpellsSearchProvider)
