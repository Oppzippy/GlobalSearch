---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class PetsSearchProvider : SearchProvider
local PetsSearchProvider = {
	localizedName = L.pets,
}

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
function PetsSearchProvider:Get()
	-- TODO cache pets
	return self:Fetch()
end

---@return SearchItem[]
function PetsSearchProvider:Fetch()
	local items = {}
	local prevSettings = GetPetJournalSettings()
	SetPetJournalBoxSettings(petJournalSettings)
	local numPets = C_PetJournal.GetNumPets()
	for i = 1, numPets do
		local petID, _, isOwned, customName, _, _, _, speciesName, icon = C_PetJournal.GetPetInfoByIndex(i)
		if isOwned then
			local name = speciesName
			if customName then
				name = string.format("%s (%s)", customName, speciesName)
			end
			items[#items + 1] = {
				name = name,
				category = L.pets,
				texture = icon,
				action = function()
					C_PetJournal.SummonPetByGUID(petID)
				end,
				pickup = function()
					C_PetJournal.PickupPet(petID)
				end,
			}
		end
	end
	SetPetJournalBoxSettings(prevSettings)
	return items
end

GlobalSearchAPI:RegisterProvider("pets", PetsSearchProvider)
