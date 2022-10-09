---@class ns
local ns = select(2, ...)

---@class SearchProviderRegistry
---@field providers table<string, SearchProvider>
local SearchProviderRegistryPrototype = {}

local function CreateSearchProviderRegistry()
	local registry = setmetatable({
		providers = {},
	}, { __index = SearchProviderRegistryPrototype })
	return registry
end

---@param providerID string
---@param provider SearchProvider
function SearchProviderRegistryPrototype:Register(providerID, provider)
	if self.providers[providerID] then
		error(string.format("A search provider with id %s is already registered.", providerID))
	end
	self.providers[providerID] = provider
end

---@param providerID string
---@return boolean
function SearchProviderRegistryPrototype:Has(providerID)
	return self.providers[providerID] ~= nil
end

---@param disabledProviders table<string, true>
---@return SearchProviderCollection
function SearchProviderRegistryPrototype:GetProviderCollection(disabledProviders)
	local providers = {}
	for providerID, provider in next, self.providers do
		if not disabledProviders[providerID] then
			providers[providerID] = provider
		end
	end
	return ns.SearchProviderCollection.Create(providers)
end

---@return table<string, SearchProvider>
function SearchProviderRegistryPrototype:GetProviders()
	return self.providers
end

local export = { Create = CreateSearchProviderRegistry }
if ns then
	ns.SearchProviderRegistry = export
end
return export
