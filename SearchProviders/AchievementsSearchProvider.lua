---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GlobalSearch")
local GlobalSearch = AceAddon:GetAddon("GlobalSearch")
---@cast GlobalSearch GlobalSearch
local AchievementStorage = GlobalSearch:GetModule("AchievementStorage", true)
if not AchievementStorage then return end
---@cast AchievementStorage AchievementStorageModule

---@class AchievementsSearchProvider : SearchProvider
local AchievementsSearchProvider = {
	localizedName = L.achievements,
	description = L.achievements_search_provider_desc,
	category = L.global_search,
}
AchievementsSearchProvider.optionsTable = {
	type = "group",
	args = {
		rebuildCache = {
			name = L.rebuild_cache,
			type = "execute",
			func = function()
				AchievementsSearchProvider.cache = nil
				AchievementStorage:RebuildCache()
			end,
		},
	},
}

---@return SearchItem[]
function AchievementsSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end

	return self.cache or {}
end

---@return SearchItem[]?
function AchievementsSearchProvider:Fetch()
	local achievements = AchievementStorage:GetAchievements()
	if not achievements then return end

	local items = {}
	for _, achievement in next, achievements do
		items[#items + 1] = {
			name = achievement[2],
			texture = achievement[10],
			extraSearchText = achievement[8],
			action = function()
				AchievementFrame_LoadUI()
				ShowUIPanel(AchievementFrame)
				AchievementFrame_SelectSearchItem(achievement[1])
			end,
			---@param tooltip GameTooltip
			tooltip = function(tooltip)
				tooltip:SetAchievementByID(achievement[1])
			end,
			hyperlink = GetAchievementLink(achievement[1]),
		}
	end
	return items
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_Achievements", AchievementsSearchProvider)
