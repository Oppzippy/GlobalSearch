-- Disable on retail
if not VideoOptionsFrame then return end

---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

---@class SystemOptionsSearchProvider : SearchProvider
local SystemOptionsSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.system_options)
SystemOptionsSearchProvider.description = L.system_options_search_provider_desc

---@return fun(): SearchItem?
function SystemOptionsSearchProvider:Fetch()
	return coroutine.wrap(function()
		for item in self:GetVideoOptions() do
			coroutine.yield(item)
		end
		for item in self:GetOtherOptions() do
			coroutine.yield(item)
		end
	end)
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
						id = name .. ":" .. option.name,
						name = option.name,
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
					id = categoryFrame:GetName() .. ":" .. option.text,
					name = ns.Util.StripEscapeSequences(_G[option.text]),
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
