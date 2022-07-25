---@class ns
local _, ns = ...

---@class SearchItem
---@field name string
---@field category string
---@field texture number
---@field extraSearchText string
---@field action function
---@field macroText string
---@field pickup function

---@class SearchProviderCollection
---@field providers SearchProvider[]
local SearchProviderCollectionPrototype = {}

---@class SearchProvider
---@field localizedName string
---@field Get fun(): SearchItem[]
---@field optionsTable AceConfigOptionsTable

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
		local itemGroup = provider:Get()
		for _, item in ipairs(itemGroup) do
			items[#items + 1] = item
		end
	end
	return items
end

local export = { Create = CreateSearchProviderCollection }
if ns then
	ns.SearchProviderCollection = export
end
return export
