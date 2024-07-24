---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

local providerID = "GlobalSearch_Spells"

-- The War Within compatibility
-- C_Spell
local IsPassiveSpell = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE and IsPassiveSpell or C_Spell.IsSpellPassive
local GetSpellInfo = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE and GetSpellInfo or function(spellID)
	local spellInfo = C_Spell.GetSpellInfo(spellID)
	return spellInfo.name, nil, spellInfo.iconID, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID,
		spellInfo.originalIconID
end
local GetSpellSubtext = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE and GetSpellSubtext or C_Spell.GetSpellSubtext
local GetSpellDescription = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE and GetSpellDescription or C_Spell
	.GetSpellDescription
local PickupSpell = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE and PickupSpell or C_Spell.PickupSpell
local GetSpellLink = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE and GetSpellLink or C_Spell.GetSpellLink
-- C_SpellBook
local GetSpellBookItemInfo = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE and GetSpellBookItemInfo or function(index, bookType)
	if bookType == BOOKTYPE_SPELL then
		bookType = 0
	else
		bookType = 1
	end
	local itemInfo = C_SpellBook.GetSpellBookItemInfo(index, bookType)
	local itemType
	if itemInfo.itemType == 1 then
		itemType = "SPELL"
	elseif itemInfo.itemType == 2 then
		itemType = "FUTURESPELL"
	elseif itemInfo.itemType == 3 then
		itemType = "PETACTION"
	elseif itemInfo.itemType == 4 then
		itemType = "FLYOUT"
	end
	return itemType, itemInfo.actionID
end
local GetSpellBookItemName = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE and GetSpellBookItemName or function(index, bookType)
	if bookType == BOOKTYPE_SPELL then
		bookType = 0
	else
		bookType = 1
	end
	local name, subName = C_SpellBook.GetSpellBookItemName(index, bookType)
	local itemInfo = C_SpellBook.GetSpellBookItemInfo(index, bookType)
	return name, subName, itemInfo.spellID
end

---@class SpellsSearchProvider : SearchProvider, AceEvent-3.0
local SpellsSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.spells)
SpellsSearchProvider.description = L.spells_search_provider_desc
AceEvent:Embed(SpellsSearchProvider)

---@return fun(): SearchItem
function SpellsSearchProvider:Fetch()
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
function SpellsSearchProvider:IterateKnownSpells()
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
function SpellsSearchProvider:IterateSpellTabs()
	return coroutine.wrap(function()
		local numTabs = GetNumSpellTabs()
		for i = 1, numTabs do
			local _, _, offset, numEntries, _, offspecID = GetSpellTabInfo(i)
			if not offspecID or offspecID == 0 then
				coroutine.yield(i, offset, numEntries)
			end
		end
	end)
end

---@param flyoutID number
---@return fun(): spellID: number
function SpellsSearchProvider:IterateFlyoutSpells(flyoutID)
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

SpellsSearchProvider:RegisterEvent("SPELLS_CHANGED", "ClearCache")
GlobalSearchAPI:RegisterProvider(providerID, SpellsSearchProvider)
