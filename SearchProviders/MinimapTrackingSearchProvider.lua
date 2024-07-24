---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class MinimapTrackingSearchProvider : SearchProvider
local MinimapTrackingSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.minimap_tracking)

local GetTrackingInfo = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE and C_Minimap.GetTrackingInfo or function(index)
	local info = C_Minimap.GetTrackingInfo(index)
	return info.name, info.texture, info.active, info.type, info.subType, info.spellID
end

---@return SearchItem[]
function MinimapTrackingSearchProvider:Fetch()
	---@type SearchItem[]
	local items = {}
	for i = 1, C_Minimap.GetNumTrackingTypes() do
		local name, texture = GetTrackingInfo(i)
		items[i] = {
			id = name,
			name = name,
			texture = texture,
			action = function()
				local _, _, active = GetTrackingInfo(i)
				C_Minimap.SetTracking(i, not active)
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
