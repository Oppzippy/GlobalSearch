---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class MinimapTrackingSearchProvider : SearchProvider
local MinimapTrackingSearchProvider = {
	name = L.minimap_tracking,
	category = L.global_search,
}

---@return SearchItem[]
function MinimapTrackingSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end
	return self.cache
end

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
