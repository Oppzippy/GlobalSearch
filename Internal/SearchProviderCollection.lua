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

---@return table<string, SearchItem[]>
function SearchProviderCollectionPrototype:Get()
	local itemsBySearchProvider = {}
	for name, provider in next, self.providers do
		local success, itemGroup = xpcall(provider.Get, geterrorhandler and geterrorhandler() or print, provider)
		local decoratedItemGroup = {}
		for i, item in ipairs(itemGroup) do
			decoratedItemGroup[i] = setmetatable({
				provider = name,
				category = provider.localizedName,
			}, { __index = item })
		end
		if success then
			itemsBySearchProvider[name] = decoratedItemGroup
		end
	end
	return itemsBySearchProvider
end

local export = { Create = CreateSearchProviderCollection }
if ns then
	ns.SearchProviderCollection = export
end
return export
