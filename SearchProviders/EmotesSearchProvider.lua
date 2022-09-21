---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class EmotesSearchProvider : SearchProvider
local EmotesSearchProvider = {
	localizedName = L.emotes,
	category = L.global_search,
}

---@return SearchItem[]
function EmotesSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end

	return self.cache
end

---@return SearchItem[]
function EmotesSearchProvider:Fetch()
	ChatFrame_ImportAllListsToHash()
	local items = {}
	for cmd, emote in next, hash_EmoteTokenList do
		local readableName = cmd:sub(2, 2) .. cmd:sub(3):lower()
		items[#items + 1] = {
			id = emote,
			name = readableName,
			texture = 1019848, -- Interface/GossipFrame/ChatBubbleGossipIcon
			action = function()
				DoEmote(emote)
			end,
		}
	end
	return items
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_Emotes", EmotesSearchProvider)
