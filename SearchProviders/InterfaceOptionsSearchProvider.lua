---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GlobalSearch")
local GlobalSearch = AceAddon:GetAddon("GlobalSearch")
---@cast GlobalSearch GlobalSearch

---@class InterfaceOptionsSearchProvider : SearchProvider
local InterfaceOptionsSearchProvider = {
	localizedName = L.interface_options,
}

---@return SearchItem[]
function InterfaceOptionsSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end

	return self.cache
end

---@return SearchItem[]
function InterfaceOptionsSearchProvider:Fetch()
	local items = {}
	for i, optionGroup in ipairs(self:GetInterfaceOptionsPanels()) do
		if optionGroup.frame and optionGroup.options then
			for _, option in next, optionGroup.options do
				if type(_G[option.text]) == "string" then
					local tooltip = _G["OPTION_TOOLTIP_" .. option.text:gsub("_TEXT$", "")]
					items[#items + 1] = {
						name = ns.Util.StripEscapeSequences(_G[option.text]),
						category = L.interface_options,
						texture = 136243, -- Interface/Icons/Trade_Engineering
						tooltip = type(tooltip) == "string" and tooltip,
						action = function()
							InterfaceOptionsFrame_OpenToCategory(optionGroup.frame)
						end,
					}
				end
			end
		else
			GlobalSearch:Printf("InterfaceOptionsSearchProvider: Option group #%d doesn't exist. Please report this issue.", i)
		end
	end
	return items
end

function InterfaceOptionsSearchProvider:GetInterfaceOptionsPanels()
	local expansion = GetClientDisplayExpansionLevel()
	return ns.InterfaceOptionsPanels[expansion] or ns.InterfaceOptionsPanels.default
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_DefaultUIPanels", InterfaceOptionsSearchProvider)
