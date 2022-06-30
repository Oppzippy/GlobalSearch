---@class ns
local _, ns = ...

local Util = {}

---@param text string
function Util.StripColorCodes(text)
	text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
	text = text:gsub("|r", "")
	return text
end

if ns then
	ns.Util = Util
end
return Util
