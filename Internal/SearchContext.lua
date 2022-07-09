---@class ns
local _, ns = ...

---@class SearchContextPrototype
---@field prevQuery string
---@field items SearchItem[]
---@field queryMatcher fun(query: string, text: string): boolean, MatchRange[]
---@field prevResults SearchContextItem[]
local SearchContextPrototype = {}

---@class SearchContextItem
---@field item SearchItem
---@field matchRanges MatchRange[]

---@param queryMatcher fun(query: string, text: string): boolean, MatchRange[]
---@param items SearchItem[]
local function CreateSearchContext(queryMatcher, items)
	local searchContext = setmetatable({
		queryMatcher = queryMatcher,
		items = items,
	}, { __index = SearchContextPrototype })
	return searchContext
end

---@param query string
---@return SearchContextItem[]
function SearchContextPrototype:Search(query)
	local items
	-- If the new query starts with the previous one, we can re-use the results and filter them
	if self.prevResults and self.prevQuery and self.prevQuery ~= "" and string.find(query, self.prevQuery, nil, true) == 1 then
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
	if query == "" then return {} end

	---@type SearchContextItem[]
	local matches = {}
	for _, item in ipairs(items) do
		local isMatch, matchRanges = self.queryMatcher(query, item.name .. (item.extraSearchText or ""))
		if isMatch then
			matches[#matches + 1] = {
				item = item,
				matchRanges = matchRanges,
			}
		end
	end

	table.sort(matches, function(a, b)
		local aNumRanges, bNumRanges = #a.matchRanges, #b.matchRanges

		-- If one of the matches uses extraSearchText, it should come last
		local isAMatchEntirelyWithinName = a.matchRanges[aNumRanges].to <= #a.item.name
		local isBMatchEntirelyWithinName = b.matchRanges[bNumRanges].to <= #b.item.name
		if isAMatchEntirelyWithinName ~= isBMatchEntirelyWithinName then
			return isAMatchEntirelyWithinName
		end

		-- Fewest total matches
		if aNumRanges ~= bNumRanges then
			return aNumRanges < bNumRanges
		end
		-- Which starts first
		local aFirstRange, bFirstRange = a.matchRanges[1], b.matchRanges[1]
		if aFirstRange.from ~= bFirstRange.from then
			return aFirstRange.from < bFirstRange.from
		end
		-- Which ends later
		if aFirstRange.to ~= bFirstRange.to then
			return aFirstRange.to < bFirstRange.to
		end
		return #a.item.name < #b.item.name
	end)

	return matches
end

local export = { Create = CreateSearchContext }
if ns then
	ns.SearchContext = export
end
return export
