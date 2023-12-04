---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GlobalSearch")
local GlobalSearch = AceAddon:GetAddon("GlobalSearch")
---@cast GlobalSearch GlobalSearch
local AchievementStorage = GlobalSearch:GetModule("AchievementStorage", true)

-- Disable if client does not support achievements (classic)
if not AchievementStorage then return end
---@cast AchievementStorage AchievementStorageModule

---@class AchievementsSearchProvider : SearchProvider
local AchievementsSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.achievements)
AchievementsSearchProvider.description = L.achievements_search_provider_desc
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

---@return fun(): SearchItem?
function AchievementsSearchProvider:Fetch()
	return coroutine.wrap(function()
		local achievements = AchievementStorage:GetAchievements()
		if not achievements then return end

		for _, achievement in next, achievements do
			coroutine.yield({
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
					local hyperlink = GetAchievementLink(achievement.id)
					tooltip:SetHyperlink(hyperlink)
				end,
				hyperlink = function()
					return GetAchievementLink(achievement.id)
				end,
			})
		end
	end)
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_Achievements", AchievementsSearchProvider)
