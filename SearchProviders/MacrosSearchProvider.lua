---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class MacrosSearchProvider : SearchProvider, AceEvent-3.0
local MacrosSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.macros)
AceEvent:Embed(MacrosSearchProvider)

---@return fun(): SearchItem?
function MacrosSearchProvider:Fetch()
	return coroutine.wrap(function(...)
		local numGlobalMacros, numCharacterMacros = GetNumMacros()
		for i = 1, numGlobalMacros do
			coroutine.yield(self:GetItemByMacroIndex(i))
		end
		for i = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + numCharacterMacros do
			coroutine.yield(self:GetItemByMacroIndex(i))
		end
	end)
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
