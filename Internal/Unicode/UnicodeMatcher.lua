---@class ns
local ns = select(2, ...)

---@class Unicode
local Unicode = ns.Unicode or {}
ns.Unicode = Unicode

---@class UnicodeRangeInner
---@field from integer
---@field to integer
---@field evenOddFilter? "evensOnly"|"oddsOnly"
---@field map? fun(codePoint: integer): any

---@class UnicodeRange
---@field from integer
---@field to integer
---@field evenOddFilter? "evensOnly"|"oddsOnly"
---@field except? integer[]
---@field flipEvenOddFilterOnExcept? boolean
---@field map? fun(codePoint: integer): any

---@param ranges UnicodeRange[]
---@return fun(codePoint: integer): any
function Unicode.CreateMatcher(ranges)
	---@type UnicodeRangeInner[]
	local newRanges = {}
	for _, range in ipairs(ranges) do
		if not range.except then
			table.insert(newRanges, range)
		else
			table.sort(range.except)
			local from = range.from
			local evenOddFilter = range.evenOddFilter
			for _, exceptCodePoint in ipairs(range.except) do
				assert(exceptCodePoint >= range.from and exceptCodePoint <= range.to, "except code point out of range")
				if from < exceptCodePoint then
					newRanges[#newRanges + 1] = {
						from = from,
						to = exceptCodePoint - 1,
						evenOddFilter = evenOddFilter,
						map = range.map,
					}
				end
				if range.flipEvenOddFilterOnExcept then
					if evenOddFilter == "evensOnly" then
						evenOddFilter = "oddsOnly"
					elseif evenOddFilter == "oddsOnly" then
						evenOddFilter = "evensOnly"
					end
				end
				from = exceptCodePoint + 1
			end
			if from < range.to then
				newRanges[#newRanges + 1] = {
					from = from,
					to = range.to,
					evenOddFilter = evenOddFilter,
					map = range.map,
				}
			end
		end
	end
	return function(codePoint)
		for i = 1, #newRanges do
			local range = newRanges[i]
			if range.from <= codePoint and codePoint <= range.to then
				if range.evenOddFilter == nil then
					return range.map and range.map(codePoint) or codePoint
				else
					local wantedRemainder = range.evenOddFilter == "evensOnly" and 0 or 1
					if codePoint % 2 == wantedRemainder then
						return range.map and range.map(codePoint) or codePoint
					end
				end
			end
		end
		return nil
	end
end
