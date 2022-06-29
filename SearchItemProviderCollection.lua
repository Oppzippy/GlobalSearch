---@class ns
local _, ns = ...

---@class SearchItem
---@field name string
---@field category string
---@field texture number
---@field searchableText string
---@field action function
---@field macroText string

---@class SearchItemProviderCollection
---@field providers SearchItemProvider[]
local SearchItemProviderCollectionPrototype = {}

---@class SearchItemProvider
---@field localizedName string
---@field Get fun(): SearchItem[]

---@param providers SearchItemProvider[]
---@return SearchItemProviderCollection
local function CreateSearchItemProviderCollection(providers)
	local collection = setmetatable({
		providers = providers,
	}, { __index = SearchItemProviderCollectionPrototype })
	return collection
end

---@return SearchItem[]
function SearchItemProviderCollectionPrototype:Get()
	local items = {}
	for _, provider in ipairs(self.providers) do
		local itemGroup = provider:Get()
		for _, item in ipairs(itemGroup) do
			items[#items + 1] = item
		end
	end
	return items
end

local export = { Create = CreateSearchItemProviderCollection }
if ns then
	ns.SearchItemProviderCollection = export
end
return export
