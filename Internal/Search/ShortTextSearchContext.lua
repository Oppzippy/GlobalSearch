---@class ns
local ns = select(2, ...)

---@class ShortTextSearchContext
---@field prevQuery string
---@field items SearchItem[]
---@field queryMatcher QueryMatcher
---@field prevResults SearchContextItem[]
local ShortTextSearchContextPrototype = {}

---@param queryMatcher QueryMatcher
---@param items SearchItem[]
local function CreateSearchContext(queryMatcher, items)
	local searchContext = setmetatable({
		queryMatcher = queryMatcher,
		items = items,
	}, { __index = ShortTextSearchContextPrototype })
	return searchContext
end

---@param query string
---@return SearchContextItem[]
function ShortTextSearchContextPrototype:Search(query)
	local items
	-- If the old query matches the new query, the new query must be a subset, so we can reuse the results and filter them.
	if self.prevResults and self.prevQuery and self.prevQuery ~= "" and self.queryMatcher(self.prevQuery, query) then
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
function ShortTextSearchContextPrototype:SearchItems(query, items)
	if query == "" then return {} end
	query = query:lower()
	---@type SearchContextItem[]
	local matches = {}
	---@type table<SearchContextItem, number>
	local scores = {}
	for _, item in ipairs(items) do
		local isMatch, matchRanges = self.queryMatcher(query, item.name:lower())
		if isMatch then
			local match = {
				item = item,
				matchRanges = matchRanges,
			}
			matches[#matches + 1] = match
			scores[match] = self:GetMatchScore(match)
		end
	end

	table.sort(matches, function(a, b)
		local aScore, bScore = scores[a], scores[b]
		if aScore ~= bScore then
			return aScore > bScore
		end
		return a.item.name < b.item.name
	end)
	return matches
end

---@param match SearchContextItem
---@return number
function ShortTextSearchContextPrototype:GetMatchScore(match)
	local numMatchRanges = #match.matchRanges

	-- Prioritize shorter names
	local score = -(#match.item.name)

	-- Prioritize earlier first match
	score = score - match.matchRanges[1].from * 10

	-- Prioritize smaller distance between the first and last match
	score = score - (match.matchRanges[#match.matchRanges].to - match.matchRanges[1].from) * 10

	-- Prioritize fewer matches
	score = score - numMatchRanges * 100

	return score
end

local export = { Create = CreateSearchContext }
if ns then
	ns.ShortTextSearchContext = export
end
return export
