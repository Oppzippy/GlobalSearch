---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class EmotesSearchProvider : SearchProvider
local EmotesSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.emotes)

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
