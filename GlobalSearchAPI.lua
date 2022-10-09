local AceAddon = LibStub("AceAddon-3.0")
---@class GlobalSearch
local GlobalSearch = AceAddon:GetAddon("GlobalSearch")

GlobalSearchAPI = {}

---@param providerID string
---@param provider SearchProvider
function GlobalSearchAPI:RegisterProvider(providerID, provider)
	assert(type(providerID) == "string", "providerID must be a string")
	assert(type(provider) == "table", "provider must be a table")
	-- Asserting that it's a table changes the type to table
	---@cast provider SearchProvider
	assert(type(provider.Get) == "function", "provider must have a Get function")
	assert(type(provider.name) == "string", "provider must have a name string")
	assert(provider.description == nil or type(provider.description) == "string",
		"provider description must be a string or nil")
	assert(provider.category == nil or type(provider.category) == "string", "provider category must be a string or nil")
	assert(provider.optionsTable == nil or type(provider.optionsTable) == "table",
		"provider optionsTable must be a table or nil")

	GlobalSearch:RegisterSearchProvider(providerID, provider)
end

---@param providerID string
function GlobalSearchAPI:HasProvider(providerID)
	return GlobalSearch:HasSearchProvider(providerID)
end

function GlobalSearchAPI:Show()
	GlobalSearch:GetModule("Search"):Show()
end
