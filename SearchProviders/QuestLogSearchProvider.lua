---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class QuestLogSearchProvider : SearchProvider, AceEvent-3.0
local QuestLogSearchProvider = {
	name = L.quest_log,
	category = L.global_search,
}

---@return SearchItem[]
function QuestLogSearchProvider:Get()
	---@type SearchItem[]
	local items = {}
	for questInfo in self:IterateQuests() do
		if not questInfo.isHeader and not questInfo.isHidden then
			local _, objective = GetQuestLogQuestText(questInfo.questLogIndex)
			local hyperlink = GetQuestLink and GetQuestLink(questInfo.questID)
			items[#items + 1] = {
				id = questInfo.questID,
				name = questInfo.title,
				extraSearchText = objective,
				texture = 136797, -- Interface/QuestFrame/UI-QuestLog-BookIcon
				action = function()
					if QuestMapFrame_OpenToQuestDetails then
						-- Retail
						QuestMapFrame_OpenToQuestDetails(questInfo.questID)
					else
						-- Classic
						ShowUIPanel(QuestLogFrame)
						QuestLog_SetSelection(questInfo.questLogIndex)
						QuestLog_Update()
					end
				end,
				---@param tooltip GameTooltip
				tooltip = function(tooltip)
					if hyperlink then
						tooltip:SetHyperlink(hyperlink)
					else
						tooltip:SetText(objective, nil, nil, nil, nil, true)
					end
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
		return self:GetQuestInfo(i)
	end
end

function QuestLogSearchProvider:GetQuestInfo(index)
	if C_QuestLog.GetInfo then
		-- Retail
		return C_QuestLog.GetInfo(index)
	end
	-- Classic
	local title,
	level,
	suggestedGroup,
	isHeader,
	isCollapsed,
	isComplete,
	frequency,
	questID,
	startEvent,
	displayQuestID,
	isOnMap,
	hasLocalPOI,
	isTask,
	isBounty,
	isStory,
	isHidden,
	isScaling = GetQuestLogTitle(index)

	if title then
		return {
			title = title,
			questLogIndex = index,
			questID = questID,
			campaignID = nil,
			level = level,
			difficultyLevel = nil,
			suggestedGroup = suggestedGroup,
			frequency = frequency,
			isHeader = isHeader,
			isCollapsed = isCollapsed,
			startEvent = startEvent,
			isTask = isTask,
			isBounty = isBounty,
			isStory = isStory,
			isScaling = isScaling,
			isOnMap = isOnMap,
			hasLocalPOI = hasLocalPOI,
			isHidden = isHidden,
			isAutoComplete = nil,
			overridesSortOrder = nil,
			readyForTranslation = nil,
		}
	end
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_QuestLog", QuestLogSearchProvider)
