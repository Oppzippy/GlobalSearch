---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class SpellsSearchProvider : SearchProvider
local SpellsSearchProvider = {
	localizedName = L.spells,
}

---@return SearchItem[]
function SpellsSearchProvider:Get()
	-- TODO cache spells
	return self:Fetch()
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
				searchableText = name,
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

			if spellID and IsSpellKnown(spellID) then
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

GlobalSearchAPI:RegisterProvider("spells", SpellsSearchProvider)
