-- Disable if we do have the new mount API or we don't have the old mount ui
if C_MountJournal ~= nil or PetPaperDollFrame_SetCompanionPage == nil then return end

---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class MountsSearchProvider_Classic : SearchProvider
local MountsSearchProvider_Classic = GlobalSearchAPI:CreateProvider(L.global_search, L.mounts)
AceEvent:Embed(MountsSearchProvider_Classic)

---@return SearchItem[]
function MountsSearchProvider_Classic:Fetch()
	---@type SearchItem[]
	local items = {}
	local numMounts = GetNumCompanions("MOUNT")
	for i = 1, numMounts do
		-- GetCompanionInfo returns the texture, but it will return a different texture if the mount is currently in use
		-- Since we cache the items, we don't want that information persisted. GetSpellInfo will return the actual texture.
		local _, name, spellID = GetCompanionInfo("MOUNT", i)
		local _, _, texture = GetSpellInfo(spellID)
		-- I'm not sure if the mount id can change when learning new mounts, but if it can, it could cause
		-- the wrong mount to be summoned if the new mount is learned while the search bar is opened, meaning the items won't
		-- be refreshed. To get around this, we get the mount id when we need it by spell id since that won't change.
		items[#items + 1] = {
			id = spellID,
			name = name,
			texture = texture,
			pickup = function()
				local mountID = self:GetMountIDBySpellID(spellID)
				PickupCompanion("MOUNT", mountID)
			end,
			action = function()
				local mountID = self:GetMountIDBySpellID(spellID)
				CallCompanion("MOUNT", mountID)
			end,
			---@param tooltip GameTooltip
			tooltip = function(tooltip)
				tooltip:SetSpellByID(spellID)
			end,
		}
	end
	return items
end

function MountsSearchProvider_Classic:GetMountIDBySpellID(mountSpellID)
	local numMounts = GetNumCompanions("MOUNT")
	for i = 1, numMounts do
		local _, _, spellID = GetCompanionInfo("MOUNT", i)
		if spellID == mountSpellID then
			return i
		end
	end
end

-- Since mounts aren't account wide, leveling up and learning higher riding shouldn't unlock any new mounts.
MountsSearchProvider_Classic:RegisterEvent("COMPANION_LEARNED", "ClearCache")

GlobalSearchAPI:RegisterProvider("GlobalSearch_Mounts", MountsSearchProvider_Classic)
