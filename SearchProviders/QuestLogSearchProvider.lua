if not C_QuestLog.GetInfo then return end

---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class QuestLogSearchProvider : SearchProvider, AceEvent-3.0
local QuestLogSearchProvider = {
	localizedName = L.quest_log,
	category = L.global_search,
}

---@return SearchItem[]
function QuestLogSearchProvider:Get()
	---@type SearchItem[]
	local items = {}
	for questInfo in self:IterateQuests() do
		if not questInfo.isHeader and not questInfo.isHidden then
			local _, objective = GetQuestLogQuestText(questInfo.questLogIndex)
			local hyperlink = GetQuestLink(questInfo.questID)
			items[#items + 1] = {
				name = questInfo.title,
				extraSearchText = objective,
				texture = 136797, -- Interface/QuestFrame/UI-QuestLog-BookIcon
				action = function()
					QuestMapFrame_OpenToQuestDetails(questInfo.questID)
				end,
				---@param tooltip GameTooltip
				tooltip = function(tooltip)
					tooltip:SetHyperlink(hyperlink)
				end,
				hyperlink = hyperlink,
			}
		end
	end
	return items
end

function QuestLogSearchProvider:IterateQuests()
	local i = 0
	return function()
		i = i + 1
		return C_QuestLog.GetInfo(i)
	end
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_QuestLog", QuestLogSearchProvider)
