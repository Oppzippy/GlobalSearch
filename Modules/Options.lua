---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

local addon = AceAddon:GetAddon("GlobalSearch")
---@class OptionsModule : AceConsole-3.0, AceEvent-3.0
---@field RegisterEvent function
---@field db AceDBObject-3.0
---@field searchProviderRegistry SearchProviderRegistry
local module = addon:NewModule("Options", "AceEvent-3.0", "AceConsole-3.0")
module.optionsTable = {
	type = "group",
	childGroups = "tab",
	handler = module,
	get = "Get",
	set = "Set",
	args = {
		general = {
			type = "group",
			name = L.general,
			order = 1,
			args = {
				doesShowKeybindToggle = {
					type = "toggle",
					name = L.does_show_keybind_toggle,
					desc = L.does_show_keybind_toggle_desc,
					width = "full",
					order = 1,
				},
			},
		},
		keybindings = {
			type = "group",
			name = L.key_bindings,
			order = 2,
			get = "GetKeybinding",
			set = "SetKeybinding",
			validate = "ValidateKeybinding",
			args = {
				selectNextItem = {
					type = "keybinding",
					name = L.select_next_item,
				},
				selectPreviousItem = {
					type = "keybinding",
					name = L.select_previous_item,
				},
			},
		},
		enabledProviders = {
			type = "group",
			name = L.enabled_providers,
			get = "IsProviderEnabled",
			set = "SetProviderEnabled",
			order = 3,
			args = {},
		},
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
	self.optionsTable.args.enabledProviders.args[name] = self:RenderProvider(name, provider)
end

function module:RenderEnabledProviders()
	self.numProviders = 0
	local providers = self.searchProviderRegistry:GetProviders()
	local options = {}
	for name, provider in next, providers do
		self.numProviders = self.numProviders + 1
		options[name] = self:RenderProvider(name, provider)
	end
	self.optionsTable.args.enabledProviders.args = options
end

function module:RenderProvider(name, provider)
	return {
		type = "toggle",
		name = provider.localizedName or name,
		order = self.numProviders,
	}
end

function module:Get(info, val)
	return self.db.profile[info[#info]]
end

function module:Set(info, val)
	self.db.profile[info[#info]] = val
end

function module:GetKeybinding(info)
	return self.db.profile.keybindings[info[#info]]
end

function module:SetKeybinding(info, val)
	self.db.profile.keybindings[info[#info]] = val
	self:SendMessage("GlobalSearch_OnKeybindingModified", info[#info], val)
end

function module:ValidateKeybinding(info, val)
	-- Don't allow duplicate keybindings
	if self:DoesKeybindingExist(info[#info], val) then
		-- Workaround for AceConfigDialog not reverting the displayed keybind when validation fails.
		AceConfigDialog:SelectGroup("GlobalSearch", "keybindings")
		return string.format(L.keybinding_in_use, val)
	end
	return true
end

---@param name string Name of the keybinding. It will not be checked against itself.
---@param key string
---@return boolean
function module:DoesKeybindingExist(name, key)
	if ns.Bindings.GetKeyBinding("SHOW")[key] then
		return true
	end

	for existingName, existingKey in next, module.db.profile.keybindings do
		if key == existingKey and name ~= existingName then
			return true
		end
	end
	return false
end

function module:IsProviderEnabled(info)
	return not module.db.profile.disabledSearchProviders[info[#info]]
end

function module:SetProviderEnabled(info, val)
	local providerName = info[#info]
	module.db.profile.disabledSearchProviders[providerName] = not val
	module:SendMessage("GlobalSearch_OnProviderStatusChanged", providerName, val)
end
