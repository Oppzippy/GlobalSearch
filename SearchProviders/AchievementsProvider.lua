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
		---@type table<number, boolean>
		local seenAchievements = {}
		for _, categoryID in next, categoryIDs do
			for i = 1, GetCategoryNumAchievements(categoryID, false) do
				local achievement = { GetAchievementInfo(categoryID, i) }
				-- If the achievement was already seen through a sibling, it should be skipped
				if not seenAchievements[achievement[1]] then
					seenAchievements[achievement[1]] = true
					coroutine.yield(unpack(achievement))
					for siblingID in self:IterateSiblingAchievements(achievement[1]) do
						seenAchievements[siblingID] = true
						coroutine.yield(GetAchievementInfo(siblingID))
					end
				end
			end
		end
	end)
end

function AchievementsSearchProvider:IterateSiblingAchievements(achievementID)
	return coroutine.wrap(function()
		for achievement in self:IterateNextAchievements(achievementID) do
			coroutine.yield(achievement)
		end
		for achievement in self:IteratePreviousAchievements(achievementID) do
			coroutine.yield(achievement)
		end
	end)
end

function AchievementsSearchProvider:IteratePreviousAchievements(achievementID)
	return coroutine.wrap(function()
		while achievementID do
			achievementID = GetPreviousAchievement(achievementID)
			coroutine.yield(achievementID)
		end
	end)
end

function AchievementsSearchProvider:IterateNextAchievements(achievementID)
	return coroutine.wrap(function()
		while achievementID do
			achievementID = GetNextAchievement(achievementID)
			coroutine.yield(achievementID)
		end
	end)
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_Achievements", AchievementsSearchProvider)
