---@class ns
local _, ns = ...

---@class SearchContextPrototype
---@field prevQuery string
---@field items SearchItem[]
---@field prevResults SearchContextItem[]
local SearchContextPrototype = {}

---@class SearchContextItem
---@field item SearchItem
---@field matchRanges MatchRange[]

---@param items SearchItem[]
local function CreateSearchContext(items)
	local searchContext = setmetatable({}, { __index = SearchContextPrototype })
	searchContext.items = items
	return searchContext
end

---@param query string
---@return SearchContextItem[]
function SearchContextPrototype:Search(query)
	local items
	if self.prevResults and self.prevQuery and string.find(query, self.prevQuery, nil, true) == 1 then
		items = {}
		for i, result in ipairs(self.prevResults) do
			items[i] = result.item
		end
	else
		items = self.items
	end
	self.prevQuery = query


	local results = self:SearchItems(query, items)
	self.prevResults = results

	return results
end

---@param query string
---@param items SearchItem[]
---@return SearchContextItem[]
function SearchContextPrototype:SearchItems(query, items)
	---@type SearchContextItem[]
	local matches = {}
	for _, item in ipairs(items) do
		local isMatch, matchRanges = ns.QueryMatcher.MatchesQuery(query, item.searchableText)
		if isMatch then
			matches[#matches + 1] = {
				item = item,
				matchRanges = matchRanges,
			}
		end
	end

	table.sort(matches, function(a, b)
		local aMatchRange, bMatchRange = a.matchRanges[1], b.matchRanges[1]
		if not aMatchRange or not bMatchRange then
			-- Fallback to alphabetical order if there are no match ranges
			return a.item.name < b.item.name
		end

		-- Sort by which match range starts first
		-- if they start at the same place, go by which ends later
		if aMatchRange.from == bMatchRange.from then
			return aMatchRange.to > bMatchRange.to
		end
		return a.matchRanges[1].from < b.matchRanges[1].from
	end)

	return matches
end

local export = { Create = CreateSearchContext }
if ns then
	ns.SearchContext = export
end
return export
