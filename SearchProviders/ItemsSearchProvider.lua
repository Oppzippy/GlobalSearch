---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local GlobalSearch = AceAddon:GetAddon("GlobalSearch")
local L = AceLocale:GetLocale("GlobalSearch")

---@class ItemsSearchProvider : SearchProvider
local ItemsSearchProvider = {
	localizedName = L.items,
	category = L.global_search,
}

---@return SearchItem[]
function ItemsSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end
	return self.cache
end

---@return SearchItem[]
function ItemsSearchProvider:Fetch()
	---@type ItemStorageModule
	local itemStorage = GlobalSearch:GetModule("ItemStorage")

	---@type SearchItem[]
	local items = {}
	for itemID, itemName in next, itemStorage:GetItems() do
		items[#items + 1] = {
			id = itemID,
			name = itemName,
			---@param texture Texture
			texture = function(texture)
				local _, _, _, _, _, _, _, _, _, textureID = GetItemInfo(itemID)
				texture:SetTexture(textureID)
			end,
			---@param tooltip GameTooltip
			tooltip = function(tooltip)
				tooltip:SetItemByID(itemID)
			end,
			action = function()

			end,
		}
	end

	return items
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_Items", ItemsSearchProvider)
