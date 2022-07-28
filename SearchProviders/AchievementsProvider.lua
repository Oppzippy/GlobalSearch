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

			end,
		}
	end

	return items
end

function AchievementsSearchProvider:IterateAchievements()
	local categoryIDs = GetCategoryList()
	local categoryIndex = 1
	local achievementIndex = 0
	local achievementId
	return function()
		if achievementId then
			local previousAchievementID = GetPreviousAchievement(achievementId)
			if previousAchievementID then
				local achievement = { GetAchievementInfo(previousAchievementID) }
				achievementId = previousAchievementID
				return achievement
			end
		end

		achievementIndex = achievementIndex + 1
		if achievementIndex > GetCategoryNumAchievements(categoryIDs[categoryIndex], false) then
			achievementIndex = 1
			repeat
				categoryIndex = categoryIndex + 1
			until categoryIndex > #categoryIDs or GetCategoryNumAchievements(categoryIDs[categoryIndex], false) ~= 0
			if categoryIndex > #categoryIDs then
				return
			end
		end
		local achievement = { GetAchievementInfo(categoryIDs[categoryIndex], achievementIndex) }
		achievementId = achievement[1]
		return achievement
	end
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_Achievements", AchievementsSearchProvider)
