local AceAddon = LibStub("AceAddon-3.0")
---@class GlobalSearch
local GlobalSearch = AceAddon:GetAddon("GlobalSearch")

GlobalSearchAPI = {}

---@param name string
---@param provider SearchProvider
function GlobalSearchAPI:RegisterProvider(name, provider)
	assert(type(name) == "string", "name must be a string")
	assert(type(provider) == "table", "provider must be a table")
	-- Asserting that it's a table changes the type to table
	---@cast provider SearchProvider
	assert(type(provider.Get) == "function", "provider must have a Get function")
	assert(type(provider.localizedName) == "string", "provider must have a localizedName string")
	assert(provider.description == nil or type(provider.description) == "string",
		"provider description must be a string or nil")
	assert(provider.category == nil or type(provider.category) == "string", "provider category must be a string or nil")
	assert(provider.optionsTable == nil or type(provider.optionsTable) == "table",
		"provider optionsTable must be a table or nil")

	GlobalSearch:RegisterSearchProvider(name, provider)
end

---@param name string
function GlobalSearchAPI:HasProvider(name)
	return GlobalSearch:HasSearchProvider(name)
end

function GlobalSearchAPI:Show()
	GlobalSearch:GetModule("Search"):Show()
end
