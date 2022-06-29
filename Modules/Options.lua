---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

local addon = AceAddon:GetAddon("GlobalSearch")
---@class OptionsModule : AceConsole-3.0, AceEvent-3.0
---@field RegisterEvent function
---@field db AceDBObject-3.0
---@field searchProviderRegistry SearchProviderRegistry
local module = addon:NewModule("Options", "AceEvent-3.0", "AceConsole-3.0")
module.optionsTable = {
	type = "group",
	args = {
		enabledSearchProviders = {
			type = "group",
			name = L.enabled_modules,
			get = function(info)
				return not module.db.profile.disabledSearchProviders[ info[#info] ]
			end,
			set = function(info, val)
				local providerName = info[#info]
				module.db.profile.disabledSearchProviders[providerName] = not val
				module:SendMessage("GlobalSearch_OnProviderStatusChanged", providerName, val)
			end,
			order = 1,
			args = {},
		}
	},
}

function module:OnInitialize()
	self:RegisterMessage("GlobalSearch_OnDBAvailable", "OnDBAvailable")
	self:RegisterMessage("GlobalSearch_OnSearchProviderRegistryAvailable", "OnSearchProviderRegistryAvailable")
end

function module:OnEnable()
	self:RenderEnabledProviders()
	self:RegisterMessage("GlobalSearch_OnProviderRegistered", "RenderEnabledProviders")
end

function module:OnSearchProviderRegistryAvailable(_, searchProviderRegistry)
	self.searchProviderRegistry = searchProviderRegistry
end

function module:OnDBAvailable(_, db)
	self.db = db
end

function module:OnProviderRegistered(_, name, provider)
	self.numProviders = self.numProviders + 1
	self.optionsTable.args.enabledModules.args[name] = self:RenderProvider(name, provider)
end

function module:RenderEnabledProviders()
	self.numProviders = 0
	local providers = self.searchProviderRegistry:GetProviders()
	local options = {}
	for name, provider in next, providers do
		self.numProviders = self.numProviders + 1
		options[name] = self:RenderProvider(name, provider)
	end
	self.optionsTable.args.enabledSearchProviders.args = options
end

function module:RenderProvider(name, provider)
	return {
		type = "toggle",
		name = provider.localizedName or name,
		order = self.numProviders,
	}
end
