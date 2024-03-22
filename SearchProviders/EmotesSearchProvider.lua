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
		local codePoints = ns.UTF8.ToCodePoints(cmd)
		table.remove(codePoints, 1) -- strip preceeding slash
		codePoints[1] = ns.Unicode.CharToUpper(codePoints[1])
		local name = ns.UTF8.FromCodePoints(codePoints)
		items[#items + 1] = {
			id = emote,
			name = name,
			texture = 1019848, -- Interface/GossipFrame/ChatBubbleGossipIcon
			action = function()
				DoEmote(emote)
			end,
		}
	end
	return items
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_Emotes", EmotesSearchProvider)
