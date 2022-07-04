---@class ns
local AceAddon = LibStub("AceAddon-3.0")
---@class GlobalSearch
local GlobalSearch = AceAddon:GetAddon("GlobalSearch")

GlobalSearchAPI = {}

---@param name string
---@param provider SearchProvider
function GlobalSearchAPI:RegisterProvider(name, provider)
	GlobalSearch:RegisterSearchProvider(name, provider)
end

---@param name string
function GlobalSearchAPI:HasProvider(name)
	return GlobalSearch:HasSearchProvider(name)
end

function GlobalSearchAPI:Show()
	GlobalSearch:GetModule("Search"):Show()
end
