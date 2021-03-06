---@class ns
local _, ns = ...

local Util = {}

---@param text string
function Util.StripColorCodes(text)
	text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
	text = text:gsub("|r", "")
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

if ns then
	ns.Util = Util
end
return Util
