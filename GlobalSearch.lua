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
GlobalSearch:SetDefaultModulePrototype(ns.ModulePrototype.Create(GlobalSearch))
GlobalSearch.providerRegistry = ns.SearchProviderRegistry.Create()

function GlobalSearch:OnInitialize()
	GlobalSearch.db = AceDB:New("GlobalSearchDB", ns.dbDefaults, true)

	self:RegisterChatCommand("globalsearchprofile", "ProfilingResults")

	AceConfig:RegisterOptionsTable("GlobalSearch", self:GetModule("Options").optionsTable)
	AceConfigDialog:AddToBlizOptions("GlobalSearch", L.global_search)
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

function GlobalSearch:ProfilingResults()
	for name, provider in pairs(self.providerRegistry:GetProviders()) do
		local time, count = GetFunctionCPUUsage(provider.Get, true)
		self:Printf("%s: %d / %d", name, time, count)
	end
end
