---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

local addon = AceAddon:GetAddon("GlobalSearch")
---@class OptionsModule : AceConsole-3.0, AceEvent-3.0
---@field RegisterEvent function
---@field db table
local module = addon:NewModule("Options", "AceEvent-3.0", "AceConsole-3.0")
module.optionsTable = {
	type = "group",
	args = {
		enabledSearchItemProviders = {
			type = "group",
			name = L.enabled_modules,
			get = function(info)
				return not module.db.profile.disabledSearchItemProviders[ info[#info] ]
			end,
			set = function(info, val)
				local providerName = info[#info]
				module.db.profile.disabledSearchItemProviders[providerName] = not val
				module:SendMessage("GlobalSearch_OnProviderEnabledOrDisabled", providerName, val)
			end,
			order = 1,
			args = {},
		}
	},
}

function module:OnInitialize()
end

function module:OnEnable()
	self:RenderEnabledProviders()
	self:RegisterMessage("GlobalSearch_OnProviderRegistered", "RenderEnabledProviders")
end

function module:OnProviderRegistered(_, name, provider)
	self.numProviders = self.numProviders + 1
	self.optionsTable.args.enabledModules.args[name] = self:RenderProvider(name, provider)
end

function module:RenderEnabledProviders()
	self.numProviders = 0
	local providers = self.providerRegistry:GetProviders()
	local options = {}
	for name, provider in next, providers do
		self.numProviders = self.numProviders + 1
		options[name] = self:RenderProvider(name, provider)
	end
	self.optionsTable.args.enabledSearchItemProviders.args = options
end

function module:RenderProvider(name, provider)
	return {
		type = "toggle",
		name = provider.localizedName or name,
		order = self.numProviders,
	}
end
