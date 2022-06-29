---@class ns
local _, ns = ...

---@class SearchItemProviderRegistry
---@field providers table<string, SearchItemProvider>
local SearchItemProviderRegistryPrototype = {}

local function CreateSearchItemProviderRegistry()
	local registry = setmetatable({
		providers = {},
	}, { __index = SearchItemProviderRegistryPrototype })
	return registry
end

---@param name string
---@param provider SearchItemProvider
function SearchItemProviderRegistryPrototype:Register(name, provider)
	self.providers[name] = provider
end

---@param name string
---@return boolean
function SearchItemProviderRegistryPrototype:Has(name)
	return self.providers[name] ~= nil
end

---@param disabledProviders table<string, true>
---@return SearchItemProviderCollection
function SearchItemProviderRegistryPrototype:GetProviderCollection(disabledProviders)
	local providers = {}
	for name, provider in next, self.providers do
		if not disabledProviders[name] then
			providers[#providers + 1] = provider
		end
	end
	return ns.SearchItemProviderCollection.Create(providers)
end

---@return table<string, SearchItemProvider>
function SearchItemProviderRegistryPrototype:GetProviders()
	return self.providers
end

local export = { Create = CreateSearchItemProviderRegistry }
if ns then
	ns.SearchItemProviderRegistry = export
end
return export
