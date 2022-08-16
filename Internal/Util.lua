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

do
	local function heapify(array, heapSize, i, lessThan)
		local largest = i
		local left = i * 2 + 1
		local right = i * 2 + 2

		if left < heapSize and lessThan(array[largest], array[left]) then
			largest = left
		end
		if right < heapSize and lessThan(array[largest], array[right]) then
			largest = right
		end
		if largest ~= i then
			array[i], array[largest] = array[largest], array[i]
			heapify(array, heapSize, largest, lessThan)
		end
	end

	---@generic T
	---@param array T[]
	---@param lessThan fun(a: T, b: T): boolean
	function Util.HeapSort(array, lessThan)
		local heapSize = #array
		for i = math.floor(heapSize / 2), 1, -1 do
			heapify(array, heapSize, i, lessThan)
		end
		for i = heapSize, 2, -1 do
			array[i], array[0] = array[0], array[i]
			heapify(array, i, 0, lessThan)
		end
	end
end

if ns then
	ns.Util = Util
end
return Util
