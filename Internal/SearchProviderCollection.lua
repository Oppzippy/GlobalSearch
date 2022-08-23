---@class ns
local ns = select(2, ...)

---@class SearchProviderCollection
---@field providers SearchProvider[]
local SearchProviderCollectionPrototype = {}

---@param providers SearchProvider[]
---@return SearchProviderCollection
local function CreateSearchProviderCollection(providers)
	local collection = setmetatable({
		providers = providers,
	}, { __index = SearchProviderCollectionPrototype })
	return collection
end

---@return SearchItem[]
function SearchProviderCollectionPrototype:Get()
	local items = {}
	for _, provider in ipairs(self.providers) do
		local success, itemGroup = xpcall(provider.Get, geterrorhandler and geterrorhandler() or print, provider)
		if success then
			for _, item in ipairs(itemGroup) do
				items[#items + 1] = item
			end
		end
	end
	return items
end

local export = { Create = CreateSearchProviderCollection }
if ns then
	ns.SearchProviderCollection = export
end
return export
