-- Disable on classic
if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then return end

---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

-- Frequently used functions
local GetAchievementInfo, GetCategoryNumAchievements = GetAchievementInfo, GetCategoryNumAchievements
local GetNextAchievement, GetPreviousAchievement = GetNextAchievement, GetPreviousAchievement

local addon = AceAddon:GetAddon("GlobalSearch")
---@class AchievementStorageModule : AceModule, AceConsole-3.0, AceEvent-3.0, ModulePrototype
---@field RegisterEvent function
local module = addon:NewModule("AchievementStorage", "AceEvent-3.0", "AceConsole-3.0")

-- Update when cache structure changes
local cacheVersion = 3

function module:OnEnable()
	local cache = self:GetDB().global.cache.achievements
	local _, _, _, tocVersion = GetBuildInfo()
	if cache.data and cache.tocVersion == tocVersion and cache.version == cacheVersion then
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
	local task = self:FetchAchievementsAsync():Then(ns.Task.Create(coroutine.create(function(achievements)
		local cache = self:GetDB().global.cache.achievements
		local _, _, _, tocVersion = GetBuildInfo()
		cache.tocVersion = tocVersion
		cache.version = cacheVersion

		-- By not saving fields we don't need, SavedVariables file size can be reduced by around 50%
		cache.data = {}
		for i, achievement in ipairs(achievements) do
			cache.data[i] = {
				id = achievement[1],
				name = achievement[2],
				description = achievement[8],
				icon = achievement[10],
			}
		end
		self.achievements = cache.data

		self:Print(L.done)
		self.rebuildInProgress = false
	end)))

	self:SendMessage("GlobalSearch_QueueTask", task, "BuildAchievementCache")
end

---@return Task
function module:FetchAchievementsAsync()
	return ns.Task.Create(coroutine.create(function()
		local achievements = {}
		for achievement in self:IterateAchievements() do
			achievements[#achievements + 1] = achievement
			coroutine.yield()
		end
		return achievements
	end))
end

function module:IterateAchievements()
	return coroutine.wrap(function()
		---@type table<number, boolean>
		local seenIDs = {}
		local categoryIDs = GetCategoryList()
		for _, categoryID in next, categoryIDs do
			for i = 1, GetCategoryNumAchievements(categoryID, false) do
				local achievement = { GetAchievementInfo(categoryID, i) }
				if not seenIDs[achievement[1]] then
					seenIDs[achievement[1]] = true
					coroutine.yield(achievement)
					for siblingID in self:IterateSiblingAchievements(achievement[1]) do
						seenIDs[siblingID] = true
						coroutine.yield({ GetAchievementInfo(siblingID) })
					end
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
