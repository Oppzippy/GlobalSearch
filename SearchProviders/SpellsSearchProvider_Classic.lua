if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then return end

---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

local providerID = "GlobalSearch_Spells"

---@class SpellsSearchProvider_Classic : SearchProvider, AceEvent-3.0
local SpellsSearchProvider_Classic = GlobalSearchAPI:CreateProvider(L.global_search, L.spells)
SpellsSearchProvider_Classic.description = L.spells_search_provider_desc
AceEvent:Embed(SpellsSearchProvider_Classic)

---@return fun(): SearchItem
function SpellsSearchProvider_Classic:Fetch()
	return coroutine.wrap(function(...)
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

				coroutine.yield({
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
					hyperlink = function()
						return GetSpellLink(spellID)
					end,
				})
			end
		end
	end)
end

---@return fun(): spellID: number
function SpellsSearchProvider_Classic:IterateKnownSpells()
	return coroutine.wrap(function()
		local function yieldIndex(index)
			local spellType, id = GetSpellBookItemInfo(index, BOOKTYPE_SPELL)
			if spellType == "FLYOUT" then
				for spellID in self:IterateFlyoutSpells(id) do
					coroutine.yield(spellID)
				end
			else
				local _, _, spellID = GetSpellBookItemName(index, BOOKTYPE_SPELL)
				if spellID and IsSpellKnownOrOverridesKnown(spellID) then
					coroutine.yield(spellID)
				end
			end
		end

		-- Spells
		for _, offset, numEntries in self:IterateSpellTabs() do
			for index = offset + 1, offset + numEntries do
				yieldIndex(index)
			end
		end

		-- Professions (retail)
		-- Classic professions are in the general tab
		if GetProfessions then
			local professionTabIndexes = { GetProfessions() }
			for _, tabIndex in next, professionTabIndexes do
				local _, _, offset, numSlots = GetSpellTabInfo(tabIndex)
				for index = offset + 1, offset + numSlots do
					yieldIndex(index)
				end
			end
		end
	end)
end

---@return fun(): tabIndex: number, tabStartOffset: number, numEntries: number
function SpellsSearchProvider_Classic:IterateSpellTabs()
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

---@param flyoutID number
---@return fun(): spellID: number
function SpellsSearchProvider_Classic:IterateFlyoutSpells(flyoutID)
	return coroutine.wrap(function()
		local _, _, numSlots = GetFlyoutInfo(flyoutID)
		for i = 1, numSlots do
			local spellID = GetFlyoutSlotInfo(flyoutID, i)
			if spellID and IsSpellKnownOrOverridesKnown(spellID) then
				coroutine.yield(spellID)
			end
		end
	end)
end

SpellsSearchProvider_Classic:RegisterEvent("SPELLS_CHANGED", "ClearCache")
GlobalSearchAPI:RegisterProvider(providerID, SpellsSearchProvider_Classic)
