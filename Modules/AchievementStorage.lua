---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

-- Frequently used functions
local GetAchievementInfo, GetCategoryNumAchievements = GetAchievementInfo, GetCategoryNumAchievements
local GetNextAchievement, GetPreviousAchievement = GetNextAchievement, GetPreviousAchievement
local GetTimePreciseSec = GetTimePreciseSec

local addon = AceAddon:GetAddon("GlobalSearch")
---@class AchievementStorageModule : AceConsole-3.0, AceEvent-3.0, ModulePrototype
---@field RegisterEvent function
local module = addon:NewModule("AchievementStorage", "AceEvent-3.0", "AceConsole-3.0")

function module:OnEnable()
	local cache = self:GetDB().global.cache.achievements
	local _, _, _, tocVersion = GetBuildInfo()
	if cache.data and cache.tocVersion == tocVersion then
		self.achievements = cache.data
	else
		self:RebuildCache()
	end
end

function module:GetAchievements()
	return self.achievements
end

function module:RebuildCache()
	if self.rebuildInProgress then return end
	self.rebuildInProgress = true
	self:Print(L.building_achievement_cache)
	self:FetchAchievementsAsync(function(achievements)
		self.achievements = achievements

		local cache = self:GetDB().global.cache.achievements
		local _, _, _, tocVersion = GetBuildInfo()
		cache.data = achievements
		cache.tocVersion = tocVersion

		self:Print(L.done)
		self.rebuildInProgress = false
	end)
end

function module:FetchAchievementsAsync(callback)
	local achievements = {}
	local iterator = self:IterateAchievements()
	---@type Ticker
	local ticker
	local numAchievements = 1
	ticker = C_Timer.NewTicker(0, function()
		local time = GetTimePreciseSec()
		repeat
			local achievement = iterator()
			if achievement then
				achievements[numAchievements] = achievement
				numAchievements = numAchievements + 1
			else
				ticker:Cancel()
				callback(achievements)
				break
			end
		until GetTimePreciseSec() - time > 0.01 -- Time limit per frame
	end)
end

function module:IterateAchievements()
	return coroutine.wrap(function()
		local categoryIDs = GetCategoryList()
		for _, categoryID in next, categoryIDs do
			for i = 1, GetCategoryNumAchievements(categoryID, false) do
				local achievement = { GetAchievementInfo(categoryID, i) }
				coroutine.yield(achievement)
				for sibling in self:IterateSiblingAchievements(achievement[1]) do
					coroutine.yield({ GetAchievementInfo(sibling) })
				end
			end
		end
	end)
end

function module:IterateSiblingAchievements(achievementID)
	return coroutine.wrap(function()
		for achievement in self:IterateNextAchievements(achievementID) do
			coroutine.yield(achievement)
		end
		for achievement in self:IteratePreviousAchievements(achievementID) do
			coroutine.yield(achievement)
		end
	end)
end

function module:IteratePreviousAchievements(achievementID)
	return coroutine.wrap(function()
		while achievementID do
			achievementID = GetPreviousAchievement(achievementID)
			coroutine.yield(achievementID)
		end
	end)
end

function module:IterateNextAchievements(achievementID)
	return coroutine.wrap(function()
		while achievementID do
			achievementID = GetNextAchievement(achievementID)
			coroutine.yield(achievementID)
		end
	end)
end
