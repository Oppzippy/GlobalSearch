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

---@return SearchItem[]
function SearchProviderCollectionPrototype:Get()
	local items = {}
	for name, provider in next, self.providers do
		local success, itemGroup = xpcall(provider.Get, geterrorhandler and geterrorhandler() or print, provider)
		if success then
			for _, item in ipairs(itemGroup) do
				items[#items + 1] = setmetatable({
					category = provider.localizedName,
					id = item.id and string.format("%s:%s", name, tostring(item.id)),
				}, {
					__index = item,
				})
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
