---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class AchievementsSearchProvider : SearchProvider
local AchievementsSearchProvider = {
	localizedName = L.achievements,
}

---@return SearchItem[]
function AchievementsSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end

	return self.cache
end

---@return SearchItem[]
function AchievementsSearchProvider:Fetch()
	local items = {}
	for id, name, _, _, _, _, _, _, _, icon in self:IterateAchievements() do
		items[#items + 1] = {
			name = name,
			category = L.achievements,
			texture = icon,
			action = function()
				AchievementFrame_LoadUI()
				ShowUIPanel(AchievementFrame)
				AchievementFrame_SelectSearchItem(id)
			end,
			tooltip = function(tooltip)
				tooltip:SetAchievementByID(id)
			end,
		}
	end
	return items
end

function AchievementsSearchProvider:IterateAchievements()
	local categoryIDs = GetCategoryList()

	local GetAchievementInfo, GetCategoryNumAchievements = GetAchievementInfo,
		GetCategoryNumAchievements

	return coroutine.wrap(function()
		for _, categoryID in next, categoryIDs do
			for i = 1, GetCategoryNumAchievements(categoryID, false) do
				coroutine.yield(GetAchievementInfo(categoryID, i))
				for sibling in self:IterateSiblingAchievements() do
					coroutine.yield(sibling)
				end
			end
		end
	end)
end

function AchievementsSearchProvider:IterateSiblingAchievements(achievementId)
	return coroutine.wrap(function()
		for achievement in self:IterateNextAchievements(achievementId) do
			coroutine.yield(achievement)
		end
		for achievement in self:IteratePreviousAchievements(achievementId) do
			coroutine.yield(achievement)
		end
	end)
end

function AchievementsSearchProvider:IteratePreviousAchievements(achievementId)
	return coroutine.wrap(function()
		while achievementId do
			coroutine.yield(GetPreviousAchievement(achievementId))
		end
	end)
end

function AchievementsSearchProvider:IterateNextAchievements(achievementId)
	return coroutine.wrap(function()
		while achievementId do
			coroutine.yield(GetNextAchievement(achievementId))
		end
	end)
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_Achievements", AchievementsSearchProvider)
