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
		local hyperlink = GetAchievementLink(achievement.id)
		items[#items + 1] = {
			id = achievement.id,
			name = achievement.name,
			texture = achievement.icon,
			extraSearchText = achievement.description,
			action = function()
				AchievementFrame_LoadUI()
				ShowUIPanel(AchievementFrame)
				AchievementFrame_SelectAchievement(achievement.id)
			end,
			---@param tooltip GameTooltip
			tooltip = function(tooltip)
				-- We can't use SetAchievementByID because it doesn't exist on wotlk classic
				tooltip:SetHyperlink(hyperlink)
			end,
			hyperlink = hyperlink,
		}
	end
	return items
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_Achievements", AchievementsSearchProvider)
