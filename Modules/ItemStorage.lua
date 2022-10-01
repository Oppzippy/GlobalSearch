---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

local addon = AceAddon:GetAddon("GlobalSearch")
---@class ItemStorageModule : AceConsole-3.0, AceEvent-3.0, ModulePrototype
---@field RegisterEvent function
local module = addon:NewModule("ItemStorage", "AceEvent-3.0", "AceConsole-3.0")

-- Update when cache structure changes
local cacheVersion = 1

function module:OnEnable()
	local cache = self:GetDB().global.cache.items
	local _, _, _, tocVersion = GetBuildInfo()
	if cache.data and cache.tocVersion == tocVersion and cache.version == cacheVersion then
		self.items = cache.data
	else
		self:RebuildCache()
	end
end

function module:GetItems()
	return self.items
end

function module:RebuildCache()
	if self.rebuildInProgress then return end
	self.rebuildInProgress = true
	self:Print(L.building_item_cache)
	self:FetchItemsAsync(function(items)
		self.items = items

		local cache = self:GetDB().global.cache.items
		local _, _, _, tocVersion = GetBuildInfo()
		cache.tocVersion = tocVersion
		cache.version = cacheVersion

		cache.data = items

		self:Print(L.done)
		self.rebuildInProgress = false
	end)
end

---@param callback fun(items: table<number, string>)
function module:FetchItemsAsync(callback)
	local items = {}
	local waitGroup = ns.WaitGroup.Create()

	local co = coroutine.create(function()
		for itemID = 1, 300000 do
			local item = Item:CreateFromItemID(itemID)

			if not item:IsItemEmpty() then
				waitGroup:Add()
				item:ContinueOnItemLoad(function()
					items[itemID] = item:GetItemName()
					waitGroup:Done()
				end)
			end

			coroutine.yield()
		end

		waitGroup:Subscribe(function()
			callback(items)
		end)
	end)
	self:SendMessage("GlobalSearch_QueueTask", co)
end
