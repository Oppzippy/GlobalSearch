---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class MacrosItemProvider : SearchItemProvider
local MacrosItemProvider = {
	localizedName = L.macros,
}

---@return SearchItem[]
function MacrosItemProvider:Get()
	return self:Fetch()
end

---@return SearchItem[]
function MacrosItemProvider:Fetch()
	local items = {}

	local numGlobalMacros, numCharacterMacros = GetNumMacros()
	for i = 1, numGlobalMacros do
		items[#items + 1] = self:GetItemByMacroIndex(i)
	end
	for i = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + numCharacterMacros do
		items[#items + 1] = self:GetItemByMacroIndex(i)
	end

	return items
end

---@param index number
---@return SearchItem
function MacrosItemProvider:GetItemByMacroIndex(index)
	local name, icon, body = GetMacroInfo(index)
	return {
		name = name,
		category = L.macros,
		texture = icon,
		searchableText = name,
		macroText = body,
	}
end

GlobalSearchAPI:RegisterProvider("macros", MacrosItemProvider)
