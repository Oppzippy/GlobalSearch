---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

---@class SystemOptionsSearchProvider : SearchProvider
local SystemOptionsSearchProvider = {
	localizedName = L.interface_options,
}

---@return SearchItem[]
function SystemOptionsSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end

	return self.cache
end

---@return SearchItem[]
function SystemOptionsSearchProvider:Fetch()
	local items = {}
	for item in self:GetVideoOptions() do
		items[#items + 1] = item
	end
	for item in self:GetOtherOptions() do
		items[#items + 1] = item
	end
	return items
end

do
	local prefixToPanelName = {
		Display = GRAPHICS_LABEL,
		Graphics = GRAPHICS_LABEL,
		RaidGraphics = GRAPHICS_LABEL,
		Advanced = ADVANCED_LABEL,
	}

	function SystemOptionsSearchProvider:GetVideoOptions()
		-- Avoid duplicates such as Graphics and RaidGraphics versions of the same option
		local seenNames = {}
		return coroutine.wrap(function()
			for name, option in next, VideoData do
				if not seenNames[option.name] then
					seenNames[option.name] = true
					local prefix = name:match("^([^_]+)")
					local panelName = prefixToPanelName[prefix]
					coroutine.yield({
						name = option.name,
						category = L.system_options,
						texture = 136243, -- Interface/Icons/Trade_Engineering
						tooltip = option.tooltip or option.description,
						action = function()
							OptionsFrame_OpenToCategory(VideoOptionsFrame, panelName)
						end,
					})
				end
			end
		end)
	end
end

function SystemOptionsSearchProvider:GetOtherOptions()
	return coroutine.wrap(function()
		for _, categoryFrame in ipairs(VideoOptionsFrame.categoryList) do
			if categoryFrame.options then
				for i in self:GetOptionsFromCategoryFrame(categoryFrame) do
					coroutine.yield(i)
				end
			end
		end
	end)
end

function SystemOptionsSearchProvider:GetOptionsFromCategoryFrame(categoryFrame)
	return coroutine.wrap(function()
		for _, option in next, categoryFrame.options do
			if type(_G[option.text]) == "string" then
				local tooltip = _G["OPTION_TOOLTIP_" .. option.text:gsub("_TEXT$", "")]
				coroutine.yield({
					name = ns.Util.StripEscapeSequences(_G[option.text]),
					category = L.system_options,
					texture = 136243, -- Interface/Icons/Trade_Engineering
					tooltip = type(tooltip) == "string" and tooltip,
					action = function()
						OptionsFrame_OpenToCategory(VideoOptionsFrame, categoryFrame.name)
					end,
				})
			end
		end
	end)
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_SystemOptions", SystemOptionsSearchProvider)
