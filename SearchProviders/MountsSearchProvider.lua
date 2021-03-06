-- Disable provider on classic
if C_MountJournal == nil then return end

---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class MountsSearchProvider : SearchProvider, AceEvent-3.0
local MountsSearchProvider = {
	localizedName = L.mounts,
}
AceEvent:Embed(MountsSearchProvider)

---@return SearchItem[]
function MountsSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end
	return self.cache
end

function MountsSearchProvider:ClearCache()
	self.cache = nil
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
				tooltip = function(tooltip)
					tooltip:SetMountBySpellID(spellID)
				end,
				action = function()
					C_MountJournal.SummonByID(mountID)
				end,
				pickup = function()
					PickupSpell(spellID)
				end,
			}
		end
	end
	return items
end

do
	local ridingSpellIDs = {
		[33388] = true, -- Apprentice Riding
		[33391] = true, -- Journeyman Riding
		[34090] = true, -- Expert Riding
		[90265] = true, -- Master Riding
	}
	function MountsSearchProvider:LEARNED_SPELL_IN_TAB(_, spellID)
		if ridingSpellIDs[spellID] then
			self:ClearCache()
		end
	end
end

MountsSearchProvider:RegisterEvent("NEW_MOUNT_ADDED", "ClearCache")
MountsSearchProvider:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED", "ClearCache")
MountsSearchProvider:RegisterEvent("LEARNED_SPELL_IN_TAB")

GlobalSearchAPI:RegisterProvider("GlobalSearch_Mounts", MountsSearchProvider)
