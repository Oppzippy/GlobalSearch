---@class ns
local _, ns = ...

---@class SearchContextPrototype
---@field prevQuery string
---@field items SearchContextItem[]
local SearchContextPrototype = {}

---@class SearchContextItem
---@field name string
---@field category string
---@field texture number
---@field searchableText string
---@field spellId number
---@field action function

---@param items SearchContextItem[]
local function CreateSearchContext(items)
	local searchContext = setmetatable({}, { __index = SearchContextPrototype })
	searchContext.items = items
	return searchContext
end

---@param query string
---@return SearchContextItem[]
function SearchContextPrototype:Search(query)
	local items
	if self.prevQuery ~= nil and string.find(query, self.prevQuery, nil, true) == 1 then
		items = self.results
	else
		items = self.items
	end
	self.prevQuery = query

	local results = self:SearchItems(query, items)
	self.results = results
	return results
end

---@param query string
---@param items SearchContextItem[]
function SearchContextPrototype:SearchItems(query, items)
	local matches = {}
	for _, item in ipairs(items) do
		if ns.QueryMatcher.MatchesQuery(query, item.searchableText) then
			matches[#matches + 1] = item
		end
	end
	return matches
end

local export = { Create = CreateSearchContext }
if ns ~= nil then
	ns.SearchContext = export
end
return export
