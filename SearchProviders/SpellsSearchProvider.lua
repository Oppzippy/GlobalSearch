---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

local providerName = "GlobalSearch_Spells"

---@class SpellsSearchProvider : SearchProvider, AceEvent-3.0
local SpellsSearchProvider = {
	localizedName = L.spells,
	description = L.spells_search_provider_desc,
	category = L.global_search,
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
				id = spellID,
				name = displayName,
				texture = icon,
				extraSearchText = description,
				---@param tooltip GameTooltip
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
	return coroutine.wrap(function()
		for _, offset, numEntries in self:IterateSpellTabs() do
			for i = 1, numEntries do
				local _, _, spellID = GetSpellBookItemName(offset + i, BOOKTYPE_SPELL)
				if spellID and IsSpellKnownOrOverridesKnown(spellID) then
					coroutine.yield(spellID)
				end
			end
		end
	end)
end

function SpellsSearchProvider:IterateSpellTabs()
	return coroutine.wrap(function()
		local numTabs = GetNumSpellTabs()
		for i = 1, numTabs do
			local _, _, offset, numEntries, _, offspecID = GetSpellTabInfo(i)
			if offspecID == 0 then
				coroutine.yield(i, offset, numEntries)
			end
		end
	end)
end

SpellsSearchProvider:RegisterEvent("SPELLS_CHANGED", "ClearCache")
GlobalSearchAPI:RegisterProvider(providerName, SpellsSearchProvider)
