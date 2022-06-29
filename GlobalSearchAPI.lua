---@class ns
local AceAddon = LibStub("AceAddon-3.0")
---@class GlobalSearch
local GlobalSearch = AceAddon:GetAddon("GlobalSearch")

GlobalSearchAPI = {}

---@param name string
---@param provider SearchItemProvider
function GlobalSearchAPI:RegisterProvider(name, provider)
	GlobalSearch:RegisterSearchItemProvider(name, provider)
end

---@param name string
function GlobalSearchAPI:HasProvider(name)
	return GlobalSearch:HasSearchItemProvider(name)
end
