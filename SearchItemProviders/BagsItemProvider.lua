---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class BagsItemProvider : SearchItemProvider
local BagsItemProvider = {
	localizedName = L.bags
}

---@return SearchItem[]
function BagsItemProvider:Get()
	-- TODO cache inventory
	return self:Fetch()
end

---@return SearchItem[]
function BagsItemProvider:Fetch()
	local items = {}
	for itemID in next, self:GetItemSet() do
		local itemName, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
		local spellName = GetItemSpell(itemID)
		if itemName ~= nil and spellName ~= nil then
			items[#items + 1] = {
				name = itemName,
				category = L.bags,
				texture = icon,
				searchableText = itemName,
				macroText = "/use " .. itemName,
			}
		end
	end
	return items
end

function BagsItemProvider:GetItemSet()
	local items = {}
	for itemID in self:IterateBagItems() do
		items[itemID] = true
	end
	return items
end

-- Skips empty slots
function BagsItemProvider:IterateBagItems()
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

GlobalSearchAPI:RegisterProvider("bags", BagsItemProvider)
