---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class MountsSearchProvider : SearchProvider
local MountsSearchProvider = {
	localizedName = L.mounts,
}

---@return SearchItem[]
function MountsSearchProvider:Get()
	-- TODO cache mounts
	return self:Fetch()
end

---@return SearchItem[]
function MountsSearchProvider:Fetch()
	local items = {}
	local mountIDs = C_MountJournal.GetMountIDs()
	for _, mountID in ipairs(mountIDs) do
		local name, spellID, icon, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if isUsable then
			items[#items + 1] = {
				name = name,
				category = L.mounts,
				texture = icon,
				action = function()
					C_MountJournal.SummonByID(mountID)
				end,
				pickup = function()
					PickupSpell(spellID)
				end
			}
		end
	end
	return items
end

GlobalSearchAPI:RegisterProvider("mounts", MountsSearchProvider)
