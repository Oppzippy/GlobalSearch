---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class MountsItemProvider : SearchItemProvider
local MountsItemProvider = {
	localizedName = L.mounts,
}

---@return SearchItem[]
function MountsItemProvider:Get()
	-- TODO cache mounts
	return self:Fetch()
end

---@return SearchItem[]
function MountsItemProvider:Fetch()
	local items = {}
	local mountIDs = C_MountJournal.GetMountIDs()
	for _, mountID in ipairs(mountIDs) do
		local name, _, icon, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if isUsable then
			items[#items + 1] = {
				name = name,
				category = L.mounts,
				texture = icon,
				searchableText = name,
				action = function()
					C_MountJournal.SummonByID(mountID)
				end,
			}
		end
	end
	return items
end

GlobalSearchAPI:RegisterProvider("mounts", MountsItemProvider)
