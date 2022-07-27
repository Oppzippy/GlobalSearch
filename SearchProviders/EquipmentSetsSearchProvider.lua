-- Disable provider on classic
if C_EquipmentSet == nil then return end

---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class EquipmentSetsSearchProvider : SearchProvider, AceEvent-3.0
local EquipmentSetsSearchProvider = {
	localizedName = L.equipment_sets,
}
AceEvent:Embed(EquipmentSetsSearchProvider)

---@return SearchItem[]
function EquipmentSetsSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end

	return self.cache
end

function EquipmentSetsSearchProvider:ClearCache()
	self.cache = nil
end

---@return SearchItem[]
function EquipmentSetsSearchProvider:Fetch()
	local items = {}
	local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs()
	for _, setID in ipairs(equipmentSetIDs) do
		local setName, icon = C_EquipmentSet.GetEquipmentSetInfo(setID)
		items[#items + 1] = {
			name = setName,
			category = L.equipment_sets,
			texture = icon,
			tooltip = function(tooltip)
				tooltip:SetEquipmentSet(setName)
			end,
			action = function()
				C_EquipmentSet.UseEquipmentSet(setID)
			end,
		}
	end

	return items
end

EquipmentSetsSearchProvider:RegisterEvent("EQUIPMENT_SETS_CHANGED", "ClearCache")
GlobalSearchAPI:RegisterProvider("GlobalSearch_EquipmentSets", EquipmentSetsSearchProvider)
