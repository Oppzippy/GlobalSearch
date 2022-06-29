---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

---@class GlobalSearch : AceAddon, AceEvent-3.0
local GlobalSearch = AceAddon:NewAddon("GlobalSearch", "AceEvent-3.0")
GlobalSearch.providerRegistry = ns.SearchItemProviderRegistry.Create()

function GlobalSearch:OnInitialize()
	self.db = AceDB:New("GlobalSearchDB", ns.dbDefaults, true)

	self:RegisterMessage("GlobalSearch_OnProviderEnabledOrDisabled", nil)

	local optionsModule = self:GetModule("Options")
	optionsModule.db = self.db -- TODO move this to an event or something
	optionsModule.providerRegistry = self.providerRegistry
	AceConfig:RegisterOptionsTable("GlobalSearch", optionsModule.optionsTable)
	AceConfigDialog:AddToBlizOptions("GlobalSearch", L.global_search)
end

---@param name string
---@param provider SearchItemProvider
function GlobalSearch:RegisterSearchItemProvider(name, provider)
	self.providerRegistry:Register(name, provider)
	self:SendMessage("GlobalSearch_OnProviderRegistered", name, provider)
end

---@return boolean
function GlobalSearch:HasSearchItemProvider(name)
	return self.providerRegistry:Has(name)
end

function GlobalSearch:GlobalSearch_OnProviderEnabledOrDisabled()
	---@type SearchModule
	local searchModule = self:GetModule("Search")
	searchModule.providerCollection = self.providerRegistry:GetProviderCollection(self.db.profile.disabledSearchItemProviders)
end
