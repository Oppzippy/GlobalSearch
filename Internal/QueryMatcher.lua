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
	local queryIndex = 1
	for i = 1, #text do
		local char = string.sub(text, i, i)
		local queryChar = string.sub(query, queryIndex, queryIndex)
		if char == queryChar then
			if range and range.to == i - 1 then
				-- extend previous range
				range.to = i
			else
				-- finalize the previous range and create a new one
				if range then
					matchRanges[#matchRanges + 1] = range
				end
				range = {
					from = i,
					to = i,
				}
			end


			if queryIndex == #query then
				-- finalize last range
				if range then
					matchRanges[#matchRanges + 1] = range
				end
				return true, matchRanges
			end
			queryIndex = queryIndex + 1
		end
	end
	return false, nil
end

local export = { MatchesQuery = MatchesQuery }
if ns then
	ns.QueryMatcher = export
end
return export
