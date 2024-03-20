---@class ns
local ns = select(2, ...)

---@class ShortTextSearchContext
---@field prevQueryCodePoints integer[]
---@field items SearchItem[]
---@field itemNameCodePoints table<SearchItem, integer[]>
---@field queryMatcher ShortTextQueryMatcher
---@field prevResults SearchContextItem[]
local ShortTextSearchContextPrototype = {}

---@param queryMatcher QueryMatcher
---@param items SearchItem[]
local function CreateSearchContextAsync(queryMatcher, items)
	local itemNameCodePoints = {}
	for i = 1, #items do
		local item = items[i]
		itemNameCodePoints[item] = ns.Unicode.ToLower(ns.UTF8.ToCodePoints(item.name))
		if i % 16 == 0 then
			coroutine.yield()
		end
	end

	local searchContext = setmetatable({
		queryMatcher = queryMatcher,
		items = items,
		itemNameCodePoints = itemNameCodePoints,
	}, { __index = ShortTextSearchContextPrototype })
	return searchContext
end

---@param query string
---@return SearchContextItem[]
function ShortTextSearchContextPrototype:Search(query)
	local items
	local queryCodePoints = ns.Unicode.ToLower(ns.UTF8.ToCodePoints(query))
	-- If the old query matches the new query, the new query must be a subset, so we can reuse the results and filter them.
	if self.prevResults and self.prevQueryCodePoints and #self.prevQueryCodePoints > 0 and self.queryMatcher(self.prevQueryCodePoints, queryCodePoints) then
		items = {}
		for i, result in ipairs(self.prevResults) do
			items[i] = result.item
		end
	else
		items = self.items
	end
	self.prevQueryCodePoints = queryCodePoints


	local results = self:SearchItems(queryCodePoints, items)
	self.prevResults = results

	return results
end

---@param queryCodePoints integer[] Should already be converted to lowercase
---@param items SearchItem[]
---@return SearchContextItem[]
function ShortTextSearchContextPrototype:SearchItems(queryCodePoints, items)
	if #queryCodePoints == 0 then return {} end
	---@type SearchContextItem[]
	local matches = {}
	local numItems = #items
	for i = 1, numItems do
		local item = items[i]
		local isMatch, matchRanges = self.queryMatcher(queryCodePoints, self.itemNameCodePoints[item])
		if isMatch then
			assert(matchRanges ~= nil)
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

local export = { CreateAsync = CreateSearchContextAsync }
if ns then
	ns.ShortTextSearchContext = export
end
return export
