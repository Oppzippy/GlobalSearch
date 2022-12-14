---@class ns
local ns = select(2, ...)

-- Disable on retail
local optionGroups = ns.InterfaceOptionsPanels[GetClientDisplayExpansionLevel()] or ns.InterfaceOptionsPanels.default
if not optionGroups then return end

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GlobalSearch")
local GlobalSearch = AceAddon:GetAddon("GlobalSearch")
---@cast GlobalSearch GlobalSearch

---@class InterfaceOptionsSearchProvider : SearchProvider
local InterfaceOptionsSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.interface_options)
InterfaceOptionsSearchProvider.description = L.interface_options_search_provider_desc

---@return SearchItem[]
function InterfaceOptionsSearchProvider:Fetch()
	local items = {}
	for i, optionGroup in ipairs(optionGroups) do
		if optionGroup.frame and optionGroup.options then
			for _, option in next, optionGroup.options do
				if type(_G[option.text]) == "string" then
					local tooltip = _G["OPTION_TOOLTIP_" .. option.text:gsub("_TEXT$", "")]
					items[#items + 1] = {
						id = optionGroup.frame:GetName() .. ":" .. option.text,
						name = ns.Util.StripEscapeSequences(_G[option.text]),
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

GlobalSearchAPI:RegisterProvider("GlobalSearch_InterfaceOptions", InterfaceOptionsSearchProvider)
