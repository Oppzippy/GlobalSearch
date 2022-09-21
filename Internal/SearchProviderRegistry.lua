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

---@param name string
---@param provider SearchProvider
function SearchProviderRegistryPrototype:Register(name, provider)
	if self.providers[name] then
		error(string.format("A search provider named %s is already registered.", name))
	end
	self.providers[name] = provider
end

---@param name string
---@return boolean
function SearchProviderRegistryPrototype:Has(name)
	return self.providers[name] ~= nil
end

---@param disabledProviders table<string, true>
---@return SearchProviderCollection
function SearchProviderRegistryPrototype:GetProviderCollection(disabledProviders)
	local providers = {}
	for name, provider in next, self.providers do
		if not disabledProviders[name] then
			providers[name] = provider
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
