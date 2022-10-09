---@class ns
local ns = select(2, ...)

---@class SearchProviderCollection
---@field providers table<string, SearchProvider>
local SearchProviderCollectionPrototype = {}

---@param providers table<string, SearchProvider>
---@return SearchProviderCollection
local function CreateSearchProviderCollection(providers)
	local collection = setmetatable({
		providers = providers,
	}, { __index = SearchProviderCollectionPrototype })
	return collection
end

-- We only want to cache decorated item groups as long as the provider itself is caching the
-- original item group
local decoratedItemGroupCache = setmetatable({}, {
	__mode = "k", -- weak key references (https://www.lua.org/pil/17.html)
})

---@return table<string, SearchProvider>
function SearchProviderCollectionPrototype:GetProviders()
	return self.providers
end

---@param providerID string
---@return SearchItem[]
function SearchProviderCollectionPrototype:GetProviderItems(providerID)
	local provider = self.providers[providerID]
	local success, itemGroup = xpcall(provider.Get, geterrorhandler and geterrorhandler() or print, provider)

	if success then
		local decoratedItemGroup = decoratedItemGroupCache[itemGroup]
		if not decoratedItemGroup then
			decoratedItemGroup = {}
			for i, item in ipairs(itemGroup) do
				decoratedItemGroup[i] = setmetatable({
					provider = providerID,
					category = provider.localizedName,
				}, { __index = item })
			end
			decoratedItemGroupCache[itemGroup] = decoratedItemGroup
		end

		return decoratedItemGroup
	end
	return {}
end

local export = { Create = CreateSearchProviderCollection }
if ns then
	ns.SearchProviderCollection = export
end
return export
