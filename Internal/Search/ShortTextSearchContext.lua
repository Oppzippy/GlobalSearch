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
	local numItems = #items
	for i = 1, numItems do
		local item = items[i]
		local isMatch, matchRanges = self.queryMatcher(query, item.name:lower())
		if isMatch then
			local match = {
				item = item,
				matchRanges = matchRanges,
				score = self:GetMatchScore(item, matchRanges),
			}
			matches[#matches + 1] = match
		end
	end

	return matches
end

---@param item SearchItem
---@param matchRanges MatchRange[]
---@return number
function ShortTextSearchContextPrototype:GetMatchScore(item, matchRanges)
	local numMatchRanges = #matchRanges

	-- Prioritize shorter names
	local score = -(#item.name)

	-- Prioritize earlier first match
	score = score - matchRanges[1].from * 10

	-- Prioritize smaller distance between the first and last match
	score = score - (matchRanges[#matchRanges].to - matchRanges[1].from) * 10

	-- Prioritize fewer matches
	score = score - numMatchRanges * 100

	return score
end

local export = { Create = CreateSearchContext }
if ns then
	ns.ShortTextSearchContext = export
end
return export
