-- Disable provider on classic
if C_MountJournal == nil then return end

---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale("GlobalSearch")
local addon = AceAddon:GetAddon("GlobalSearch")

---@class MountsSearchProvider : SearchProvider, AceEvent-3.0
local MountsSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.mounts)
MountsSearchProvider.description = L.mounts_search_provider_desc
AceEvent:Embed(MountsSearchProvider)

---@return fun(): SearchItem?
function MountsSearchProvider:Fetch()
	return coroutine.wrap(function()
		local mountIDs = C_MountJournal.GetMountIDs()
		for _, mountID in ipairs(mountIDs) do
			local tooltipStorage = addon:GetModule("TooltipStorage")
			---@cast tooltipStorage TooltipStorageModule
			local name, spellID, icon, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
			local _, description, source = C_MountJournal.GetMountInfoExtraByID(mountID)
			source = ns.Util.StripEscapeSequences(source)

			local tooltipText = tooltipStorage:GetMountBySpellID(spellID)

			if isUsable then
				coroutine.yield({
					id = mountID,
					name = name,
					extraSearchText = string.format("%s %s %s", description, source, tooltipText),
					texture = icon,
					---@param tooltip GameTooltip
					tooltip = function(tooltip)
						tooltip:SetMountBySpellID(spellID)
					end,
					action = function()
						C_MountJournal.SummonByID(mountID)
					end,
					pickup = function()
						PickupSpell(spellID)
					end,
					hyperlink = GetSpellLink(spellID),
				})
			end
		end
	end)
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
