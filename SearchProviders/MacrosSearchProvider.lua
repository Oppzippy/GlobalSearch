---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class MacrosSearchProvider : SearchProvider, AceEvent-3.0
local MacrosSearchProvider = {
	name = L.macros,
	category = L.global_search,
}
AceEvent:Embed(MacrosSearchProvider)

---@return SearchItem[]
function MacrosSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end
	return self.cache
end

function MacrosSearchProvider:ClearCache()
	self.cache = nil
end

---@return SearchItem[]
function MacrosSearchProvider:Fetch()
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
function MacrosSearchProvider:GetItemByMacroIndex(index)
	local name, icon, body = GetMacroInfo(index)
	return {
		id = name,
		name = name,
		texture = icon,
		macroText = body,
		pickup = function()
			PickupMacro(index)
		end
	}
end

MacrosSearchProvider:RegisterEvent("UPDATE_MACROS", "ClearCache")
GlobalSearchAPI:RegisterProvider("GlobalSearch_Macros", MacrosSearchProvider)
