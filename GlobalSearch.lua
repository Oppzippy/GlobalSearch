---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

---@class GlobalSearch : AceAddon, AceEvent-3.0, AceConsole-3.0
local GlobalSearch = AceAddon:NewAddon("GlobalSearch", "AceEvent-3.0", "AceConsole-3.0")
GlobalSearch:SetDefaultModuleState(false)

GlobalSearch.providerRegistry = ns.SearchProviderRegistry.Create()

function GlobalSearch:OnInitialize()
	self.db = AceDB:New("GlobalSearchDB", ns.dbDefaults, true)
	self:RegisterChatCommand("globalsearchprofile", "ProfilingResults")
end

function GlobalSearch:OnEnable()
	-- These events are guaranteed to fire between initialize and enable
	self:SendMessage("GlobalSearch_OnDBAvailable", self.db)
	self:SendMessage("GlobalSearch_OnSearchProviderRegistryAvailable", self.providerRegistry)
	self:EnableModules()

	self:UpdateProviderCollection()
	self:RegisterMessage("GlobalSearch_OnProviderStatusChanged", "UpdateProviderCollection")

	AceConfig:RegisterOptionsTable("GlobalSearch", self:GetModule("Options").optionsTable)
	AceConfigDialog:AddToBlizOptions("GlobalSearch", L.global_search)
end

function GlobalSearch:EnableModules()
	for _, module in self:IterateModules() do
		module:Enable()
	end
end

---@param name string
---@param provider SearchProvider
function GlobalSearch:RegisterSearchProvider(name, provider)
	self.providerRegistry:Register(name, provider)
	self:SendMessage("GlobalSearch_OnProviderRegistered", name, provider)
end

---@return boolean
function GlobalSearch:HasSearchProvider(name)
	return self.providerRegistry:Has(name)
end

function GlobalSearch:UpdateProviderCollection()
	---@type SearchModule
	local searchModule = self:GetModule("Search")
	searchModule.providerCollection = self.providerRegistry:GetProviderCollection(self.db.profile.disabledSearchProviders)
end

function GlobalSearch:ProfilingResults()
	for name, provider in pairs(self.providerRegistry:GetProviders()) do
		local time, count = GetFunctionCPUUsage(provider.Get, true)
		self:Printf("%s: %d / %d", name, time, count)
	end
end
