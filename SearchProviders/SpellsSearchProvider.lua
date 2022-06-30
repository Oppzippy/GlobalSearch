---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class SpellsSearchProvider : SearchProvider, AceEvent-3.0
---@field cache SearchItem[]
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

			items[#items + 1] = {
				name = name,
				category = L.spells,
				texture = icon,
				macroText = "/cast " .. name,
				pickup = function()
					PickupSpell(spellID)
				end,
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
		while numEntries ~= nil do
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
GlobalSearchAPI:RegisterProvider("spells", SpellsSearchProvider)
