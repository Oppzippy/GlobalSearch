---@class ns
local ns = select(2, ...)

---@class MatchRange
---@field from integer
---@field to integer

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
	return true, matchRanges
end

local export = { MatchesQuery = MatchesQuery }
if ns then
	ns.QueryMatcher = export
end
return export
