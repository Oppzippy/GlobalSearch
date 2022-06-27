---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class EmotesItemProvider
---@field cache SearchItem[]
local EmotesItemProvider = {}

---@return SearchItem[]
function EmotesItemProvider:Get()
	if not self.cache then
		self.cache = self:CreateItems()
	end

	return self.cache
end

---@return SearchItem[]
function EmotesItemProvider:CreateItems()
	local items = {}
	for _, emote in ipairs(ns.emotes) do
		local emoteLowerCase = emote:lower()
		items[#items + 1] = {
			name = emoteLowerCase,
			category = L.emotes,
			texture = 1019848, -- Interface/GossipFrame/ChatBubbleGossipIcon
			searchableText = emoteLowerCase,
			action = function()
				DoEmote(emote)
			end,
		}
	end
	return items
end

ns.SearchItemProviders[#ns.SearchItemProviders + 1] = EmotesItemProvider
