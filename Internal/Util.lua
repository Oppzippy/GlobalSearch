---@class ns
local ns = select(2, ...)

local Util = {}

---@param text string
function Util.StripEscapeSequences(text)
	-- Colors
	text = text:gsub("|cn[^:]+:", "")
	text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
	text = text:gsub("|r", "")

	-- Textures
	text = text:gsub("|T.*|t", "")
	text = text:gsub("|A.*|a", "")

	-- Newline
	text = text:gsub("|n", "\n")

	return text
end

do
	local function doNothing() end

	local function printError()
		error("attempt to update a read-only table")
	end

	---@generic T: table
	---@param t T
	---@param ignoreWrites? boolean
	---@return T
	function Util.ReadOnlyTable(t, ignoreWrites)
		local proxy = setmetatable({}, {
			__index = t,
			__newindex = ignoreWrites and doNothing or printError,
		})
		return proxy
	end
end

---@generic T
---@param list T[]
---@return table<T, boolean>
function Util.ListToSet(list)
	local set = {}
	for _, value in next, list do
		set[value] = true
	end
	return set
end

---@param array unknown[]
---@param comparator fun(value: unknown): number Returns less than 0 if the value is too low. Returns more than 0 of the value is too high. Returns 0 if it is a match.
---@param range "first"|"last"|"firstFound"
---@return integer? index of the result
function Util.BinarySearch(array, comparator, range)
	local startPoint = 1
	local endPoint = #array

	local result
	while startPoint <= endPoint do
		local midPoint = math.floor((endPoint - startPoint) / 2 + startPoint)
		local comparison = comparator(array[midPoint])
		if comparison > 0 then
			endPoint = midPoint - 1
		elseif comparison < 0 then
			startPoint = midPoint + 1
		else
			result = midPoint
			if range == "first" then
				endPoint = midPoint - 1
			elseif range == "last" then
				startPoint = midPoint + 1
			elseif range == "firstFound" then
				break
			end
		end
	end

	return result
end

function Util.ReverseTable(t)
	local reversed = {}
	for i = #t, 1, -1 do
		reversed[#reversed + 1] = t[i]
	end
	return reversed
end

---@param left unknown[]
---@param right unknown[]
---@return boolean
function Util.CompareTables(left, right)
	local minLength = math.min(#left, #right)
	for i = 1, minLength do
		local leftValue = left[i]
		local rightValue = right[i]
		if leftValue < rightValue then
			return true
		end
		if leftValue > rightValue then
			return false
		end
	end
	return #left < #right
end

---@param haystack unknown[]
---@param needle unknown[]
---@return boolean
function Util.TableStartsWith(haystack, needle)
	if #needle > #haystack then return false end

	for i = 1, #needle do
		if needle[i] ~= haystack[i] then
			return false
		end
	end
	return true
end

if ns then
	ns.Util = Util
end
return Util
