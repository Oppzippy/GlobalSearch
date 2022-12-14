-- Disable provider on classic
if C_EquipmentSet == nil then return end

---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class EquipmentSetsSearchProvider : SearchProvider, AceEvent-3.0
local EquipmentSetsSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.equipment_sets)
AceEvent:Embed(EquipmentSetsSearchProvider)

---@return fun(): SearchItem?
function EquipmentSetsSearchProvider:Fetch()
	local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs()
	return coroutine.wrap(function(...)
		for _, setID in ipairs(equipmentSetIDs) do
			local setName, icon = C_EquipmentSet.GetEquipmentSetInfo(setID)
			coroutine.yield({
				id = setName,
				name = setName,
				texture = icon,
				---@param tooltip GameTooltip
				tooltip = function(tooltip)
					tooltip:SetEquipmentSet(setID)
				end,
				action = function()
					C_EquipmentSet.UseEquipmentSet(setID)
				end,
			})
		end
	end)
end

EquipmentSetsSearchProvider:RegisterEvent("EQUIPMENT_SETS_CHANGED", "ClearCache")
GlobalSearchAPI:RegisterProvider("GlobalSearch_EquipmentSets", EquipmentSetsSearchProvider)
