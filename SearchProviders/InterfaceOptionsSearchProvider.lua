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

local optionGroups = {
	{
		panel = InterfaceOptionsControlsPanel,
		options = ControlsPanelOptions,
	},
	{
		panel = InterfaceOptionsCombatPanel,
		options = CombatPanelOptions,
	},
	{
		panel = InterfaceOptionsDisplayPanel,
		options = DisplayPanelOptions,
	},
	{
		panel = InterfaceOptionsSocialPanel,
		options = SocialPanelOptions,
	},
	{
		panel = InterfaceOptionsActionBarsPanel,
		options = ActionBarsPanelOptions,
	},
	{
		panel = InterfaceOptionsNamesPanel,
		options = NamePanelOptions,
	},
	{
		panel = InterfaceOptionsCameraPanel,
		options = CameraPanelOptions,
	},
	{
		panel = InterfaceOptionsMousePanel,
		options = MousePanelOptions,
	},
	{
		panel = InterfaceOptionsAccessibilityPanel,
		options = AccessibilityPanelOptions,
	},
	{
		panel = InterfaceOptionsColorblindPanel,
		options = ColorblindPanelOptions,
	},
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
	for i, optionGroup in ipairs(optionGroups) do
		if optionGroup.panel and optionGroup.options then
			for _, option in next, optionGroup.options do
				if type(_G[option.text]) == "string" then
					local tooltip = _G["OPTION_TOOLTIP_" .. option.text:gsub("_TEXT$", "")]
					items[#items + 1] = {
						name = ns.Util.StripEscapeSequences(_G[option.text]),
						category = L.interface_options,
						texture = 136243, -- Interface/Icons/Trade_Engineering
						tooltip = type(tooltip) == "string" and tooltip,
						action = function()
							InterfaceOptionsFrame_OpenToCategory(optionGroup.panel)
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

GlobalSearchAPI:RegisterProvider("GlobalSearch_DefaultUIPanels", InterfaceOptionsSearchProvider)
