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

---@class SearchItem
---@field name string
---@field category string
---@field texture number
---@field searchableText string
---@field spellId number
---@field action function

---@return SearchItem[]
local function GetSpells()
	---@type SearchItem[]
	local items = {}

	for i = 1, GetNumSpellTabs() do
		local tabName, _, offset, numEntries = GetSpellTabInfo(i)
		for j = offset + 1, offset + numEntries do
			local spellName, spellSubName, spellId = GetSpellBookItemName(j, BOOKTYPE_SPELL)
			if spellId and not IsPassiveSpell(spellId) then
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

---@return SearchItem[]
local function GetItems()
	local itemGroups = {
		GetSpells(),
		ns.SearchItemProvider.GetDefaultUIPanels()
	}
	local items = {}
	for _, itemGroup in ipairs(itemGroups) do
		for _, item in ipairs(itemGroup) do
			items[#items + 1] = item
		end
	end
	return items
end

local export = { GetItems = GetItems }
if ns then
	ns.SearchItemProvider = export
end
return export
