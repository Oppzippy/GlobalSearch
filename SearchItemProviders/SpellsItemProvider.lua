---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class SpellsItemProvider
local SpellsItemProvider = {}

---@return SearchItem[]
function SpellsItemProvider:Get()
	-- TODO cache spells
	return self:GetSpells()
end

---@return SearchItem[]
function SpellsItemProvider:GetSpells()
	local items = {}

	for i = 1, GetNumSpellTabs() do
		local _, _, offset, numEntries = GetSpellTabInfo(i)
		for j = offset + 1, offset + numEntries do
			local spellName, spellSubName, spellId = GetSpellBookItemName(j, BOOKTYPE_SPELL)
			if spellId and not IsPassiveSpell(spellId) then
				local name = spellName
				if spellSubName ~= "" then
					name = string.format("%s (%s)", spellName, spellSubName)
				end

				items[#items + 1] = {
					name = name,
					category = L.spells,
					texture = GetSpellTexture(spellId),
					searchableText = name,
					macro = "/cast " .. spellName,
				}
			end
		end
	end

	return items
end

ns.SearchItemProviders[#ns.SearchItemProviders + 1] = SpellsItemProvider
