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

	---@param t table
	---@param ignoreWrites? boolean
	---@return table
	function Util.ReadOnlyTable(t, ignoreWrites)
		local proxy = setmetatable({}, {
			__index = t,
			__newindex = ignoreWrites and doNothing or printError,
		})
		return proxy
	end
end

if ns then
	ns.Util = Util
end
return Util
