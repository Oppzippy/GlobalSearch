if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then return end

---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

local providerID = "GlobalSearch_Spells"

---@class SpellsSearchProvider : SearchProvider, AceEvent-3.0
local SpellsSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.spells)
SpellsSearchProvider.description = L.spells_search_provider_desc
AceEvent:Embed(SpellsSearchProvider)

---@return fun(): SearchItem
function SpellsSearchProvider:Fetch()
	return coroutine.wrap(function(...)
		for spellID in self:IterateKnownSpells() do
			if not C_Spell.IsSpellPassive(spellID) then
				local spellInfo = C_Spell.GetSpellInfo(spellID)
				local subtext = C_Spell.GetSpellSubtext(spellID)
				local displayName, castName = spellInfo.name, spellInfo.name

				if subtext and subtext ~= "" then
					displayName = string.format("%s (%s)", spellInfo.name, subtext)
					castName = string.format("%s(%s)", spellInfo.name, subtext)
				end

				---@type string?
				local description = C_Spell.GetSpellDescription(spellID)
				if description and description ~= "" then
					description = ns.Util.StripEscapeSequences(description)
				else
					description = nil
				end

				coroutine.yield({
					id = spellID,
					name = displayName,
					texture = spellInfo.iconID,
					extraSearchText = description,
					---@param tooltip GameTooltip
					tooltip = function(tooltip)
						tooltip:SetSpellByID(spellID)
					end,
					macroText = "/cast " .. castName,
					pickup = function()
						C_Spell.PickupSpell(spellID)
					end,
					hyperlink = function()
						return C_Spell.GetSpellLink(spellID)
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
			local info = C_SpellBook.GetSpellBookItemInfo(index, Enum.SpellBookSpellBank.Player)
			if info.itemType == Enum.SpellBookItemType.Flyout then
				for spellID in self:IterateFlyoutSpells(info.actionID) do
					coroutine.yield(spellID)
				end
			else
				if info.spellID and IsSpellKnownOrOverridesKnown(info.spellID) then
					coroutine.yield(info.spellID)
				end
			end
		end

		-- Spells
		for _, offset, numEntries in self:IterateSkillLines() do
			for index = offset + 1, offset + numEntries do
				yieldIndex(index)
			end
		end

		-- Professions (retail)
		-- Classic professions are in the general tab
		if GetProfessions then
			local professionSkillLines = { GetProfessions() }
			for _, skillLineIndex in next, professionSkillLines do
				local info = C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex)
				for index = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
					yieldIndex(index)
				end
			end
		end
	end)
end

---@return fun(): skillLineIndex: number, skillLineStartOffset: number, numEntries: number
function SpellsSearchProvider:IterateSkillLines()
	return coroutine.wrap(function()
		local numSkillLines = C_SpellBook.GetNumSpellBookSkillLines()
		for i = 1, numSkillLines do
			local info = C_SpellBook.GetSpellBookSkillLineInfo(i)
			if not info.offSpecID then
				coroutine.yield(i, info.itemIndexOffset, info.numSpellBookItems)
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
