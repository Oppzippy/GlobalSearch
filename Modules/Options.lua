---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local L = AceLocale:GetLocale("GlobalSearch")

local addon = AceAddon:GetAddon("GlobalSearch")
---@class OptionsModule : AceConsole-3.0, AceEvent-3.0, ModulePrototype
---@field RegisterEvent function
local module = addon:NewModule("Options", "AceEvent-3.0", "AceConsole-3.0")
module.numProviders = 0
module.numGroups = 0
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
					width = 1.6,
					order = 1,
				},
				showMouseoverTooltip = {
					type = "toggle",
					name = L.show_mouseover_tooltip,
					desc = L.show_mouseover_tooltip_desc,
					width = 1.6,
					order = 2,
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
					order = 1,
				},
				selectPreviousItem = {
					type = "keybinding",
					name = L.select_previous_item,
					order = 2,
				},
				selectNextPage = {
					type = "keybinding",
					name = L.select_next_page,
					order = 3,
				},
				selectPreviousPage = {
					type = "keybinding",
					name = L.select_previous_page,
					order = 4,
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
		providerOptions = {
			type = "group",
			name = L.provider_options,
			get = function() end,
			set = function() end,
			handler = {},
			order = 4,
			args = {},
		},
	},
}


function module:OnInitialize()
	module:RegisterMessage("GlobalSearch_OnProviderRegistered", "OnProviderRegistered")
end

function module:OnProviderRegistered(_, name, provider)
	self.numProviders = self.numProviders + 1
	self:AddProviderEnableOption(name, provider)
	self.optionsTable.args.providerOptions.args[name] = self:RenderProviderOptions(name, provider)
end

function module:AddProviderEnableOption(name, provider)
	local groupsOptionTable = self.optionsTable.args.enabledProviders
	local groupKey = provider.category or ""
	if not groupsOptionTable.args[groupKey] then
		self.numGroups = self.numGroups + 1
		groupsOptionTable.args[groupKey] = {
			type = "group",
			inline = true,
			name = groupKey == "" and L.uncategorized or groupKey,
			order = groupKey == "" and 999999 or self.numGroups,
			args = {}
		}
	end
	groupsOptionTable.args[groupKey].args[name] = self:RenderProviderEnableOption(name, provider)
end

function module:RenderProviderEnableOption(name, provider)
	return {
		type = "toggle",
		name = provider.localizedName or name,
		desc = provider.description,
		order = self.numProviders,
	}
end

function module:RenderProviderOptions(name, provider)
	local optionsTable = provider.optionsTable
	if optionsTable then
		local options = {
			type = "group",
			name = provider.localizedName or name,
			order = self.numProviders,
			set = optionsTable.set,
			get = optionsTable.get,
			handler = optionsTable.handler,
			args = optionsTable.args,
			plugins = optionsTable.plugins,
		}
		local success, error = pcall(function()
			AceConfigRegistry:ValidateOptionsTable(options, name)
		end)
		if success then
			return options
		else
			geterrorhandler()(error)
		end
	end
end

function module:Get(info, val)
	return self:GetOptions()[info[#info]]
end

function module:Set(info, val)
	self:GetOptions()[info[#info]] = val
end

function module:GetKeybinding(info)
	return self:GetOptions().keybindings[info[#info]]
end

function module:SetKeybinding(info, val)
	self:GetOptions().keybindings[info[#info]] = val
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

	for existingName, existingKey in next, self:GetOptions().keybindings do
		if key == existingKey and name ~= existingName then
			return true
		end
	end
	return false
end

function module:IsProviderEnabled(info)
	return not self:GetOptions().disabledSearchProviders[info[#info]]
end

function module:SetProviderEnabled(info, val)
	local providerName = info[#info]
	self:GetOptions().disabledSearchProviders[providerName] = not val
	module:SendMessage("GlobalSearch_OnProviderStatusChanged", providerName, val)
end

function module:GetOptions()
	return self:GetDB().profile.options
end
