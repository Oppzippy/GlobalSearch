---@class ns
local ns = select(2, ...)

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
GlobalSearch.queuedMessages = {}

function GlobalSearch:OnInitialize()
	self.db = AceDB:New("GlobalSearchDB", ns.dbDefaults, true)

	self:RegisterChatCommand("globalsearchprofile", "ProfilingResults")

	AceConfig:RegisterOptionsTable("GlobalSearch", self:GetModule("Options").optionsTable)
	AceConfigDialog:AddToBlizOptions("GlobalSearch", L.global_search)
end

function GlobalSearch:OnEnable()
	for _, message in ipairs(self.queuedMessages) do
		self:SendMessage(unpack(message))
	end
	self.queuedMessages = nil
end

---@param name string
---@param provider SearchProvider
function GlobalSearch:RegisterSearchProvider(name, provider)
	self.providerRegistry:Register(name, provider)
	-- If providers are registered before OnInitialize, modules won't be ready to receive these events.
	-- In that case, we can queue up the messages and send them after OnInitialize has run for all modules.
	if self.queuedMessages then
		self.queuedMessages[#self.queuedMessages + 1] = { "GlobalSearch_OnProviderRegistered", name, provider }
	else
		self:SendMessage("GlobalSearch_OnProviderRegistered", name, provider)
	end
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

function GlobalSearch:GetProviderOptionsDB(name)
	local providerOptions = self.db.profile.options.searchProviders
	if not providerOptions[name] then
		providerOptions[name] = {}
	end
	return providerOptions[name]
end
