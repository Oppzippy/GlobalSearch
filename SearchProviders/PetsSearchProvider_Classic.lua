-- Disable if we do have the new pet API or we don't have the old pet ui
if C_PetJournal ~= nil or PetPaperDollFrame_SetCompanionPage == nil then return end

---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class PetsSearchProvider_Classic : SearchProvider
local PetsSearchProvider_Classic = GlobalSearchAPI:CreateProvider(L.global_search, L.pets)
AceEvent:Embed(PetsSearchProvider_Classic)

---@return SearchItem[]
function PetsSearchProvider_Classic:Fetch()
	---@type SearchItem[]
	local items = {}
	local numCritters = GetNumCompanions("CRITTER")
	for i = 1, numCritters do
		local _, name, spellID, texture = GetCompanionInfo("CRITTER", i)
		-- I'm not sure if the critter id can change when learning new critters, but if it can, it could cause
		-- the wrong critter to be summoned if the new critter is learned while the search bar is opened, meaning the items won't
		-- be refreshed. To get around this, we get the critter id when we need it by spell id since that won't change.
		items[#items + 1] = {
			id = spellID,
			name = name,
			texture = texture,
			pickup = function()
				local critterID = self:GetCritterIDBySpellID(spellID)
				PickupCompanion("CRITTER", critterID)
			end,
			action = function()
				local critterID = self:GetCritterIDBySpellID(spellID)
				CallCompanion("CRITTER", critterID)
			end,
			---@param tooltip GameTooltip
			tooltip = function(tooltip)
				tooltip:SetSpellByID(spellID)
			end,
		}
	end
	return items
end

function PetsSearchProvider_Classic:GetCritterIDBySpellID(critterSpellID)
	local numCritters = GetNumCompanions("CRITTER")
	for i = 1, numCritters do
		local _, _, spellID = GetCompanionInfo("CRITTER", i)
		if spellID == critterSpellID then
			return i
		end
	end
end

PetsSearchProvider_Classic:RegisterEvent("COMPANION_LEARNED", "ClearCache")

GlobalSearchAPI:RegisterProvider("GlobalSearch_Pets", PetsSearchProvider_Classic)
