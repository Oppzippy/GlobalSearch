---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")

local addon = AceAddon:GetAddon("GlobalSearch")
---@cast addon GlobalSearch

---@class TooltipStorageModule : AceModule, AceConsole-3.0, AceEvent-3.0, ModulePrototype
---@field RegisterEvent function
local module = addon:NewModule("TooltipStorage", "AceEvent-3.0", "AceConsole-3.0")

function module:OnEnable()
	self.tooltip = CreateFrame("GameTooltip", "GlobalSearchHiddenTooltip", nil, "GameTooltipTemplate")
	self.tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
end

-- This module is for internal use only, so we can add functions as needed

---@param itemID number
---@return string
function module:GetToyByItemID(itemID)
	return self:GetTooltip("ToyByItemID", itemID)
end

---@param itemID number
---@return string
function module:GetItemByID(itemID)
	return self:GetTooltip("ItemByID", itemID)
end

---@param spellID number
---@return string
function module:GetMountBySpellID(spellID)
	return self:GetTooltip("MountBySpellID", spellID)
end

---@param functionSuffix string
---@param ... unknown
---@return string
function module:GetTooltip(functionSuffix, ...)
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		return self:GetTooltipRetail("Get" .. functionSuffix, ...)
	else
		return self:GetTooltipClassic("Set" .. functionSuffix, ...)
	end
end

---@param functionName string
---@param ... unknown
---@return string
function module:GetTooltipRetail(functionName, ...)
	local tooltipData = C_TooltipInfo[functionName](...)
	---@cast tooltipData TooltipData
	if not tooltipData then
		addon:Debugf("C_TooltipInfo.%s returned nil with args: " .. ..., functionName)
		return ""
	end

	local lines = {}
	for _, line in ipairs(tooltipData.lines) do
		if line.leftText then
			lines[#lines + 1] = line.leftText
		end
		if line.rightText then
			lines[#lines + 1] = line.rightText
		end
	end
	return table.concat(lines, "\n")
end

---@param functionName string
---@param ... unknown
---@return string
function module:GetTooltipClassic(functionName, ...)
	self.tooltip:ClearLines()
	self.tooltip[functionName](self.tooltip, ...)

	local regions = { self.tooltip:GetRegions() }
	local lines = {}
	for _, region in ipairs(regions) do
		if region:GetObjectType() == "FontString" and region:GetText() then
			lines[#lines + 1] = region:GetText()
		end
	end
	return table.concat(lines, "\n")
end
