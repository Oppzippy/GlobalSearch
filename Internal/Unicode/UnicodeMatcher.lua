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
---@return UnicodeRangeInner[]
local function compileRanges(ranges)
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
	return newRanges
end

--- Good default
---@param ranges UnicodeRange[]
---@return fun(codePoint: integer): any
local function CreateMatcherIteration(ranges)
	local compiledRanges = compileRanges(ranges)
	return function(codePoint)
		for i = 1, #compiledRanges do
			local range = compiledRanges[i]
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

--- A little faster than CreateMatcherIter it seems, but benchmark to be sure
---@param ranges UnicodeRange[]
---@return fun(codePoint: integer): any
local function CreateMatcherCodeGeneration(ranges)
	local compiledRanges = compileRanges(ranges)

	local code = {
		"local codePoint, ranges = ...",
		"local isEven = codePoint % 2 == 0",
	}
	for i = 1, #compiledRanges do
		local range = compiledRanges[i]
		if i == 1 then
			code[#code + 1] = string.format("if %d <= codePoint and codePoint <= %d then", range.from, range.to)
		else
			code[#code + 1] = string.format("elseif %d <= codePoint and codePoint <= %d then", range.from, range.to)
		end
		if range.evenOddFilter == "evensOnly" then
			code[#code + 1] = "if isEven then"
		elseif range.evenOddFilter == "oddsOnly" then
			code[#code + 1] = "if not isEven then"
		end
		code[#code + 1] = string.format("local map = ranges[%d].map", i)
		code[#code + 1] = "return map and map(codePoint) or codePoint"
		if range.evenOddFilter then
			code[#code + 1] = "end"
		end
	end
	code[#code + 1] = "end"

	local concatenatedCode = table.concat(code, "\n")
	local matcher, error = loadstring(concatenatedCode)
	assert(error == nil and matcher ~= nil, error)
	return function(codePoint)
		return matcher(codePoint, compiledRanges)
	end
end

--- Good when the total number of selectable characters isn't too big
---@param ranges UnicodeRange[]
---@return fun(codePoint: integer): any
local function CreateMatcherTable(ranges)
	local compiledRanges = compileRanges(ranges)

	local t = {}
	for _, range in ipairs(compiledRanges) do
		for i = range.from, range.to do
			if range.evenOddFilter then
				local targetRemainder = range.evenOddFilter == "evensOnly" and 0 or 1
				if i % 2 == targetRemainder then
					if range.map then
						t[i] = range.map(i)
					else
						t[i] = true
					end
				end
			else
				if range.map then
					t[i] = range.map(i)
				else
					t[i] = true
				end
			end
		end
	end

	return function(codePoint)
		return t[codePoint]
	end
end

---@param ranges UnicodeRange[]
---@param impl? "iteration"|"codeGeneration"|"table"
function Unicode.CreateMatcher(ranges, impl)
	if impl == nil or impl == "iteration" then
		return CreateMatcherIteration(ranges)
	elseif impl == "codeGeneration" then
		return CreateMatcherCodeGeneration(ranges)
	elseif impl == "table" then
		return CreateMatcherTable(ranges)
	end
	error("invalid impl " .. impl)
end
