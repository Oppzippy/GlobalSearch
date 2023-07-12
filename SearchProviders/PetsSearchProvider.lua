-- Disable provider on classic
if C_PetJournal == nil then return end

---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class PetsSearchProvider : SearchProvider, AceEvent-3.0
local PetsSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.pets)
PetsSearchProvider.description = L.pets_search_provider_desc
AceEvent:Embed(PetsSearchProvider)

local petJournalSettings
do
	local trueTable = setmetatable({}, {
		__index = function()
			return true
		end
	})
	petJournalSettings = {
		search = "",
		type = trueTable,
		source = trueTable,
		collected = true,
		uncollected = false,
	}
end

local function GetPetJournalSettings()
	local settings = {
		search = PetJournalSearchBox and PetJournalSearchBox:GetText() or "",
		collected = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED),
		uncollected = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED),
		type = {},
		source = {},
	}
	for i = 1, C_PetJournal.GetNumPetTypes() do
		settings.type[i] = C_PetJournal.IsPetTypeChecked(i)
	end
	for i = 1, C_PetJournal.GetNumPetSources() do
		settings.source[i] = C_PetJournal.IsPetSourceChecked(i)
	end
	return settings
end

local function SetPetJournalBoxSettings(settings)
	C_PetJournal.SetSearchFilter(settings.search)
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, settings.collected)
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, settings.uncollected)
	for i = 1, C_PetJournal.GetNumPetTypes() do
		C_PetJournal.SetPetTypeFilter(i, settings.type[i])
	end
	for i = 1, C_PetJournal.GetNumPetSources() do
		C_PetJournal.SetPetSourceChecked(i, settings.source[i])
	end
end

---@return SearchItem[]
function PetsSearchProvider:Fetch()
	local items = {}
	local prevSettings = GetPetJournalSettings()
	SetPetJournalBoxSettings(petJournalSettings)
	local numPets = C_PetJournal.GetNumPets()
	for i = 1, numPets do
		local petID, _, isOwned, customName, _, _, _, speciesName, icon, _, _, source, description = C_PetJournal
			.GetPetInfoByIndex(i)

		if isOwned then
			source = ns.Util.StripEscapeSequences(source)
			---@type string?
			local name = speciesName
			if customName then
				name = string.format("%s (%s)", customName, speciesName)
			end
			items[#items + 1] = {
				id = petID,
				name = name,
				extraSearchText = string.format("%s %s", source, description),
				texture = icon,
				---@param tooltip GameTooltip
				tooltip = function(tooltip)
					tooltip:SetCompanionPet(petID)
				end,
				action = function()
					C_PetJournal.SummonPetByGUID(petID)
				end,
				pickup = function()
					C_PetJournal.PickupPet(petID)
				end,
				hyperlink = function()
					return C_PetJournal.GetBattlePetLink(petID)
				end,
			}
		end
	end
	SetPetJournalBoxSettings(prevSettings)
	return items
end

-- PET_JOURNAL_LIST_UPDATE is the only event that fires when a pet is released, but that event triggers whenever
-- any of the search filters are changed as well. This is a slow provider, so we don't want to clear the cache unless
-- absolutely necessary.
-- Releasing a pet is a rare enough event that we'll ignore it.
PetsSearchProvider:RegisterEvent("NEW_PET_ADDED", "ClearCache")
PetsSearchProvider:RegisterEvent("PET_JOURNAL_PET_DELETED", "ClearCache")

GlobalSearchAPI:RegisterProvider("GlobalSearch_Pets", PetsSearchProvider)
