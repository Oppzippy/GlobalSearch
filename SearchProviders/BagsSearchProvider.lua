---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale("GlobalSearch")
local GlobalSearch = AceAddon:GetAddon("GlobalSearch")
---@cast GlobalSearch GlobalSearch

local GetContainerNumSlots = GetContainerNumSlots or C_Container.GetContainerNumSlots
local GetContainerItemID = GetContainerItemID or C_Container.GetContainerItemID

---@class BagsSearchProvider : SearchProvider, AceEvent-3.0
local BagsSearchProvider = GlobalSearchAPI:CreateProvider(L.bags, L.global_search)
BagsSearchProvider.description = L.bags_search_provider_desc
AceEvent:Embed(BagsSearchProvider)

---@return fun(): SearchItem?
function BagsSearchProvider:Fetch()
	local tooltipStorage = GlobalSearch:GetModule("TooltipStorage")
	---@cast tooltipStorage TooltipStorageModule

	return coroutine.wrap(function(...)
		for itemID in next, self:GetItemSet() do
			local itemName, itemLink, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
			local spellName = GetItemSpell(itemLink)
			if itemName and spellName then
				coroutine.yield({
					id = itemID,
					name = itemName,
					extraSearchText = tooltipStorage:GetItemByID(itemID),
					texture = icon,
					macroText = "/use " .. itemName,
					---@param tooltip GameTooltip
					tooltip = function(tooltip)
						tooltip:SetItemByID(itemID)
					end,
					pickup = function()
						PickupItem(itemLink)
					end,
					hyperlink = itemLink,
				})
			end
		end
	end)
end

function BagsSearchProvider:GetItemSet()
	local items = {}
	for itemID in self:IterateBagItems() do
		items[itemID] = true
	end
	return items
end

-- Skips empty slots
function BagsSearchProvider:IterateBagItems()
	return coroutine.wrap(function()
		for bagID = 0, NUM_BAG_SLOTS do
			for slot = 1, GetContainerNumSlots(bagID) do
				local itemID = GetContainerItemID(bagID, slot)
				if itemID then
					coroutine.yield(itemID)
				end
			end
		end
	end)
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_Bags", BagsSearchProvider)
BagsSearchProvider:RegisterEvent("BAG_UPDATE_DELAYED", "ClearCache")
