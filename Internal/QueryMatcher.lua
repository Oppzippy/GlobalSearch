---@class ns
local ns = select(2, ...)

---@class MatchRange
---@field from integer
---@field to integer

--- Attempts to group together match ranges when the a match range could exist in multiple places
--- Example:
--- Crusader Strike
--- Search "Strike", result selects "Cru*s*ader S*trike*"
--- This could instead be "Crusader *Strike*"
---@param text string
---@param matchRanges MatchRange[]
---@return MatchRange[]
local function CondenseMatchRanges(text, matchRanges)
	local rangeStack = {}
	for i = #matchRanges, 1, -1 do
		rangeStack[#rangeStack + 1] = matchRanges[i]
	end

	local newRanges = {}
	while #rangeStack > 1 do
		local currentRange = rangeStack[#rangeStack]
		rangeStack[#rangeStack] = nil
		local nextRange = rangeStack[#rangeStack]

		local currentString = text:sub(currentRange.from, currentRange.to)
		local stringLength = #currentString
		local nextStringPrefix = text:sub(nextRange.from - stringLength, nextRange.from - 1)
		if currentString == nextStringPrefix then
			-- The new range is added to the stack so it can be merged with even more ranges
			rangeStack[#rangeStack] = {
				from = nextRange.from - stringLength,
				to = nextRange.to,
			}
		else
			newRanges[#newRanges + 1] = currentRange
		end
	end
	newRanges[#newRanges + 1] = rangeStack[1]

	return newRanges
end

---@param query string
---@param text string
---@return boolean, MatchRange[]?
local function MatchesQuery(query, text)
	if query == "" then
		return true, {}
	end
	query = query:lower()
	text = text:lower()

	---@type MatchRange[]
	local matchRanges = {}
	---@type MatchRange
	local range
	local prevIndex = -1
	for i = 1, #query do
		local char = query:sub(i, i)
		local index = text:find(char, prevIndex + 1, true)
		if not index then return false, nil end

		if index == prevIndex + 1 then
			range.to = index
		else
			range = {
				from = index,
				to = index,
			}
			matchRanges[#matchRanges + 1] = range
		end
		prevIndex = index
	end

	matchRanges = CondenseMatchRanges(text, matchRanges)

	return true, matchRanges
end

local export = { MatchesQuery = MatchesQuery }
if ns then
	ns.QueryMatcher = export
end
return export
