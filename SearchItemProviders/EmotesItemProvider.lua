---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class EmotesItemProvider : SearchItemProvider
---@field cache SearchItem[]
local EmotesItemProvider = {
	localizedName = L.emotes,
}

---@return SearchItem[]
function EmotesItemProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end

	return self.cache
end

---@return SearchItem[]
function EmotesItemProvider:Fetch()
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

GlobalSearchAPI:RegisterProvider("emotes", EmotesItemProvider)
