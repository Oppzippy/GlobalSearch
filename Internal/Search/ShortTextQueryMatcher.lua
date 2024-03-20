---@class ns
local ns = select(2, ...)

--- Attempts to group together match ranges when the a match range could exist in multiple places
--- Example:
--- Crusader Strike
--- Search "Strike", result selects "Cru*s*ader S*trike*"
--- This could instead be "Crusader *Strike*"
---@param textCodePoints number[]
---@param matchRanges MatchRange[]
---@return MatchRange[]
local function CondenseMatchRanges(textCodePoints, matchRanges)
	local rangeStack = {}
	for i = #matchRanges, 1, -1 do
		rangeStack[#rangeStack + 1] = matchRanges[i]
	end

	local newRanges = {}
	while #rangeStack > 1 do
		local currentRange = rangeStack[#rangeStack]
		rangeStack[#rangeStack] = nil
		local nextRange = rangeStack[#rangeStack]

		local currentStringStart, currentStringEnd = currentRange.from, currentRange.to
		local currentStringLength = currentStringEnd - currentStringStart + 1
		local nextStringStart, nextStringEnd = nextRange.from - currentStringLength, nextRange.from - 1

		local areStringsEqual = currentStringLength == nextStringEnd - nextStringStart + 1
		if areStringsEqual then
			for i = 0, currentStringLength - 1 do
				if textCodePoints[currentStringStart + i] ~= textCodePoints[nextStringStart + i] then
					areStringsEqual = false
					break
				end
			end
		end

		if areStringsEqual then
			-- The new range is added to the stack so it can be merged with even more ranges
			rangeStack[#rangeStack] = {
				from = nextRange.from - currentStringLength,
				to = nextRange.to,
			}
		else
			newRanges[#newRanges + 1] = currentRange
		end
	end
	newRanges[#newRanges + 1] = rangeStack[1]

	return newRanges
end

---@param textCodePoints integer[]
---@param matchRanges MatchRange[]
---@return MatchRange[]
local function ShiftMatchRangesForUTF8(textCodePoints, matchRanges)
	local newMatchRanges = {}
	local offset = 0
	local matchIndex = 1
	for i = 1, #textCodePoints do
		if matchRanges[matchIndex].from == i then
			newMatchRanges[matchIndex] = { from = matchRanges[matchIndex].from + offset }
		end
		offset = offset + ns.UTF8.CodePointNumBytes(textCodePoints[i]) - 1
		if matchRanges[matchIndex].to == i then
			newMatchRanges[matchIndex].to = matchRanges[matchIndex].to + offset
			matchIndex = matchIndex + 1
			if matchIndex > #matchRanges then
				break
			end
		end
	end
	return newMatchRanges
end

---@alias ShortTextQueryMatcher fun(queryCodePoints: integer[], textCodePoints: integer[]): boolean, MatchRange[]?

local export = {}
---@param queryCodePoints integer[]
---@param textCodePoints integer[]
---@return boolean, MatchRange[]?
function export.MatchesQuery(queryCodePoints, textCodePoints)
	---@type MatchRange[]
	local matchRanges = {}
	---@type MatchRange
	local range
	local prevIndex = 0

	local hasMultibyteCharacters = false
	for i = 1, #queryCodePoints do
		local char = queryCodePoints[i]
		local index
		for j = prevIndex + 1, #textCodePoints do
			if ns.UTF8.CodePointNumBytes(textCodePoints[j]) > 1 then
				hasMultibyteCharacters = true
			end
			if textCodePoints[j] == char then
				index = j
				break
			end
		end
		if not index then return false, nil end

		if index == prevIndex + 1 and range then
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

	if #matchRanges > 1 then
		matchRanges = CondenseMatchRanges(textCodePoints, matchRanges)
	end
	if hasMultibyteCharacters then
		matchRanges = ShiftMatchRangesForUTF8(textCodePoints, matchRanges)
	end

	return true, matchRanges
end

if ns then
	ns.ShortTextQueryMatcher = export
end
return export
