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

	for achievement in self:IterateAchievements() do
		items[#items + 1] = {
			name = achievement[2],
			category = L.achievements,
			texture = achievement[10],
			action = function()
				AchievementFrame_LoadUI()
				ShowUIPanel(AchievementFrame)
				AchievementFrame_SelectSearchItem(achievement[1])
			end,
		}
	end

	return items
end

function AchievementsSearchProvider:IterateAchievements()
	local categoryIDs = GetCategoryList()
	local numCategories = #categoryIDs
	local categoryIndex = 1
	local achievementIndex = 0

	local siblingAchievementIterator

	local GetAchievementInfo, GetCategoryNumAchievements = GetAchievementInfo,
		GetCategoryNumAchievements
	return function()
		if siblingAchievementIterator then
			local achievement = siblingAchievementIterator()
			if achievement then
				return achievement
			end
			siblingAchievementIterator = nil
		end

		achievementIndex = achievementIndex + 1
		if achievementIndex > GetCategoryNumAchievements(categoryIDs[categoryIndex], false) then
			achievementIndex = 1
			repeat
				categoryIndex = categoryIndex + 1
			until categoryIndex > numCategories or GetCategoryNumAchievements(categoryIDs[categoryIndex], false) ~= 0
			if categoryIndex > numCategories then
				return
			end
		end
		local achievement = { GetAchievementInfo(categoryIDs[categoryIndex], achievementIndex) }
		siblingAchievementIterator = self:IterateSiblingAchievements(achievement[1])
		return achievement
	end
end

function AchievementsSearchProvider:IterateSiblingAchievements(achievementId)
	local iterator = self:IterateNextAchievements(achievementId)
	local stage = 1
	return function()
		local achievement = iterator()
		if not achievement then
			if stage == 1 then
				iterator = self:IteratePreviousAchievements(achievementId)
				stage = 2
				return iterator()
			else
				return
			end
		end
		return achievement
	end
end

function AchievementsSearchProvider:IteratePreviousAchievements(achievementId)
	return function()
		achievementId = GetPreviousAchievement(achievementId)
		if achievementId then
			return { GetAchievementInfo(achievementId) }
		end
	end
end

function AchievementsSearchProvider:IterateNextAchievements(achievementId)
	return function()
		achievementId = GetNextAchievement(achievementId)
		if achievementId then
			return { GetAchievementInfo(achievementId) }
		end
	end
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_Achievements", AchievementsSearchProvider)
