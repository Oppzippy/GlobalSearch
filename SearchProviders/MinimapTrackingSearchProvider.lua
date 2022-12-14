---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class MinimapTrackingSearchProvider : SearchProvider
local MinimapTrackingSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.minimap_tracking)

local SetTracking = SetTracking or C_Minimap.SetTracking
local GetTrackingInfo = GetTrackingInfo or C_Minimap.GetTrackingInfo
local GetNumTrackingTypes = GetNumTrackingTypes or C_Minimap.GetNumTrackingTypes

---@return SearchItem[]
function MinimapTrackingSearchProvider:Fetch()
	---@type SearchItem[]
	local items = {}
	for i = 1, GetNumTrackingTypes() do
		local name, texture = GetTrackingInfo(i)
		items[i] = {
			id = name,
			name = name,
			texture = texture,
			action = function()
				local _, _, active = GetTrackingInfo(i)
				SetTracking(i, not active)
			end,
			-- The items are cached so tooltip needs to be a function in order to be updated when
			-- toggling tracking.
			---@param tooltip GameTooltip
			tooltip = function(tooltip)
				local _, _, active = GetTrackingInfo(i)
				if active then
					tooltip:SetText(L.x_is_enabled:format(name))
				else
					tooltip:SetText(L.x_is_disabled:format(name))
				end
			end
		}
	end
	return items
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_MinimapTracking", MinimapTrackingSearchProvider)
