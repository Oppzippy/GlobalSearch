---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class BagsSearchProvider : SearchProvider, AceEvent-3.0
local BagsSearchProvider = {
	localizedName = L.bags
}
AceEvent:Embed(BagsSearchProvider)

---@return SearchItem[]
function BagsSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end
	return self.cache
end

function BagsSearchProvider:ClearCache()
	self.cache = nil
end

---@return SearchItem[]
function BagsSearchProvider:Fetch()
	local items = {}
	for itemID in next, self:GetItemSet() do
		local itemName, itemString, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
		local spellName = GetItemSpell(itemString)
		if itemName ~= nil and spellName ~= nil then
			items[#items + 1] = {
				name = itemName,
				category = L.bags,
				texture = icon,
				macroText = "/use " .. itemName,
				tooltip = function(tooltip)
					tooltip:SetItemByID(itemID)
				end,
				pickup = function()
					PickupItem(itemString)
				end
			}
		end
	end
	return items
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
	local bagID = 0
	local slot = 1
	local numContainerSlots = GetContainerNumSlots(bagID)
	return function()
		local itemID
		while not itemID do
			if slot > numContainerSlots then
				bagID = bagID + 1
				if bagID > NUM_BAG_SLOTS then
					return
				end
				slot = 1
				numContainerSlots = GetContainerNumSlots(bagID)
			end

			itemID = GetContainerItemID(bagID, slot)
			slot = slot + 1
		end
		return itemID
	end
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_Bags", BagsSearchProvider)
BagsSearchProvider:RegisterEvent("BAG_UPDATE_DELAYED", "ClearCache")
