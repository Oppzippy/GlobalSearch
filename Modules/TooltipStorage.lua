---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")

local addon = AceAddon:GetAddon("GlobalSearch")
---@class TooltipStorageModule : AceConsole-3.0, AceEvent-3.0, ModulePrototype
---@field RegisterEvent function
local module = addon:NewModule("TooltipStorage", "AceEvent-3.0", "AceConsole-3.0")

function module:OnEnable()
	self.tooltip = CreateFrame("GameTooltip", "GlobalSearchHiddenTooltip")
	self.tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	self.tooltip:AddFontStrings(
		self.tooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
		self.tooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
	)
	self.limitedTooltip = ns.LimitedTooltip.Limit(self.tooltip)
end

---@param hyperlink string|fun(limitedTooltip: any)
---@return string
function module:GetTooltip(hyperlink)
	-- TODO implement caching

	self.tooltip:ClearLines()
	if type(hyperlink) == "function" then
		hyperlink(self.limitedTooltip)
	else
		self.tooltip:SetHyperlink(hyperlink)
	end
	local regions = { self.tooltip:GetRegions() }
	local lines = {}
	for _, region in ipairs(regions) do
		if region:GetObjectType() == "FontString" and region:GetText() then
			lines[#lines + 1] = region:GetText()
		end
	end
	return table.concat(lines, "\n")
end
