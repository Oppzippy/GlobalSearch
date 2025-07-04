---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class MinimapTrackingSearchProvider : SearchProvider
local MinimapTrackingSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.minimap_tracking)

---@return SearchItem[]
function MinimapTrackingSearchProvider:Fetch()
	---@type SearchItem[]
	local items = {}
	for i = 1, C_Minimap.GetNumTrackingTypes() do
		local trackingInfo = C_Minimap.GetTrackingInfo(i)
		if trackingInfo ~= nil then
			items[i] = {
				id = trackingInfo.name,
				name = trackingInfo.name,
				texture = trackingInfo.texture,
				action = function()
					local currentTrackingInfo = C_Minimap.GetTrackingInfo(i)
					if currentTrackingInfo then
						C_Minimap.SetTracking(i, not currentTrackingInfo.active)
					end
				end,
				-- The items are cached so tooltip needs to be a function in order to be updated when
				-- toggling tracking.
				---@param tooltip GameTooltip
				tooltip = function(tooltip)
					local currentTrackingInfo = C_Minimap.GetTrackingInfo(i)
					if currentTrackingInfo and currentTrackingInfo.active then
						tooltip:SetText(L.x_is_enabled:format(trackingInfo.name))
					else
						tooltip:SetText(L.x_is_disabled:format(trackingInfo.name))
					end
				end
			}
		end
	end
	return items
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_MinimapTracking", MinimapTrackingSearchProvider)
