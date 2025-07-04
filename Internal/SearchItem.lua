---@class ns
local ns = select(2, ...)

---@class SearchItem
---@field id? any
---@field providerID? string
---@field name string
---@field category? string
---@field texture number|string|fun(texture: Texture)
---@field extraSearchText? string
---@field action? function
---@field macroText? string
---@field pickup? function
---@field tooltip? fun(limitedTooltip: GameTooltip) | string
---@field hyperlink? string|fun(): string

---@param item SearchItem
---@return boolean, string?
function ns.ValidateSearchItem(item)
	if type(item) ~= "table" then
		return false, "item is not a table"
	end
	if type(item.name) ~= "string" then
		return false, "name is not a string"
	end
	local textureType = type(item.texture)
	if textureType ~= "nil" and textureType ~= "number" and textureType ~= "string" and textureType ~= "function" then
		return false, string.format("texture is not a number, string, or function")
	end
	if item.extraSearchText ~= nil and type(item.extraSearchText) ~= "string" then
		return false, "extraSearchText is not a string"
	end
	if item.action ~= nil and type(item.action) ~= "function" then
		return false, "action is not a function"
	end
	if item.macroText ~= nil and type(item.macroText) ~= "string" then
		return false, "macroText is not a string"
	end
	if item.pickup ~= nil and type(item.pickup) ~= "function" then
		return false, "pickup is not a function"
	end
	local tooltipType = type(item.tooltip)
	if item.tooltip ~= nil and tooltipType ~= "function" and tooltipType ~= "string" then
		return false, "tooltip is not a function or string"
	end
	local hyperlinkType = type(item.hyperlink)
	if item.hyperlink ~= nil and hyperlinkType ~= "function" and hyperlinkType ~= "string" then
		return false, "hyperlink is not a function or string"
	end
	return true
end
