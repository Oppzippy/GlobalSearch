---@class ns
local ns = select(2, ...)

local whitelist = {
	AddDoubleLine = true,
	AddLine = true,
	AddSpellByID = true,
	AddTexture = true,
	AdvanceSecondaryCompareItem = true,
	ResetSecondaryCompareItem = true,
	AppendText = true,
}

local frame = CreateFrame("Frame")
local allowedFunctionsCache
local function getAllowedFunctions()
	if not allowedFunctionsCache then
		local disallowedFunctions = {}
		for key in next, getmetatable(frame).__index do
			disallowedFunctions[key] = true
		end

		local allowedFunctions = {}
		for key, value in next, getmetatable(GameTooltip).__index do
			if type(key) == "string" and type(value) == "function" and not disallowedFunctions[key] then
				if key:find("^Set[A-Z]") or whitelist[key] then
					allowedFunctions[key] = true
				end
			end
		end
		allowedFunctionsCache = allowedFunctions
	end
	return allowedFunctionsCache
end

---@param tooltip GameTooltip
local function Limit(tooltip)
	local allowedFunctions = getAllowedFunctions()
	return setmetatable({}, {
		__index = function(_, key)
			if allowedFunctions[key] then
				return function(_, ...)
					tooltip[key](tooltip, ...)
				end
			end
		end,
		__newindex = function()
			error("LimitedTooltip is read only.")
		end,
	})
end

local export = { Limit = Limit }
if ns then
	ns.LimitedTooltip = export
end
return export
