---@class ns
local _, ns = ...

--[[
TODO:
- spells
- macros
- slash commands
- inventory items
- equipment (trinkets and such)
- toys
- mounts
- default UI panels

]]

---@return SearchContextItem[]
local function GetSpells()
	---@type SearchContextItem[]
	local items = {}

	for i = 1, GetNumSpellTabs() do
		local tabName, _, offset, numEntries = GetSpellTabInfo(i)
		for j = offset + 1, offset + numEntries do
			local spellName, spellSubName, spellId = GetSpellBookItemName(j, BOOKTYPE_SPELL)
			if spellId ~= nil and not IsPassiveSpell(spellId) then
				local name = spellName
				if spellSubName ~= "" then
					name = string.format("%s (%s)", spellName, spellSubName)
				end

				items[#items + 1] = {
					name = name,
					category = tabName,
					texture = GetSpellTexture(spellId),
					searchableText = name,
					spellId = spellId,
				}
			end
		end
	end

	return items
end

local function GetMacros()

end

local function GetSlashCommands()

end

local function GetUsableItems()

end

local function GetToys()

end

local function GetMounts()

end

local function GetDefaultUIPanels()

end

---@return SearchContextItem[]
local function GetItems()
	return GetSpells()
end

local export = { GetItems = GetItems }
if ns ~= nil then
	ns.SearchItemProvider = export
end
return export
