---@class ns
local _, ns

---@param query string
---@param text string
local function MatchesQuery(query, text)
	local queryIndex = 1
	for i = 1, #text do
		local char = string.sub(text, i, i)
		local queryChar = string.sub(query, queryIndex, queryIndex)
		if char == queryChar then
			if queryIndex == #query then
				return true
			end
			queryIndex = queryIndex + 1
		end
	end
	return false
end

local export = { MatchesQuery = MatchesQuery }
if ns ~= nil then
	ns.QueryMatcher = export
end
return export
