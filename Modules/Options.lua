---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local LibSharedMedia = LibStub("LibSharedMedia-3.0")

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
					width = 1.5,
					order = 1,
				},
				showMouseoverTooltip = {
					type = "toggle",
					name = L.show_mouseover_tooltip,
					desc = L.show_mouseover_tooltip_desc,
					width = 1.5,
					order = 2,
				},
				showHelp = {
					type = "toggle",
					name = L.show_help,
					desc = L.show_help_desc,
					width = 1.5,
					order = 3,
				},
				maxRecentItems = {
					type = "range",
					name = L.number_of_recent_items,
					softMin = 0,
					softMax = 100,
					min = 0,
					max = 1000,
					step = 1,
					width = 1.5,
					order = 3.1,
				},
				position = {
					type = "group",
					inline = true,
					name = L.position,
					order = 4,
					get = "GetPosition",
					set = "SetPosition",
					args = {
						xOffset = {
							type = "range",
							name = L.x_offset_from_center,
							softMin = -1000,
							softMax = 1000,
							step = 0.01,
							order = 1,
							width = 1.5,
						},
						yOffset = {
							type = "range",
							name = L.y_offset_from_top,
							softMin = -1000,
							softMax = 0,
							max = 0,
							step = 0.01,
							order = 2,
							width = 1.5,
						},
					},
				},
				size = {
					type = "group",
					inline = true,
					name = L.size,
					order = 5,
					get = "GetSize",
					set = "SetSize",
					args = {
						width = {
							type = "range",
							name = L.width,
							min = 100,
							softMin = 200,
							softMax = 1000,
							width = 1.5,
							order = 1,
						},
						height = {
							type = "range",
							name = L.height,
							softMin = 20,
							softMax = 80,
							width = 1.5,
							order = 2,
						},
					},
				},
				font = {
					type = "group",
					inline = true,
					name = L.font,
					get = "GetFont",
					set = "SetFont",
					args = {
						font = {
							type = "select",
							dialogControl = "LSM30_Font",
							name = L.font,
							values = LibSharedMedia:HashTable("font"),
							width = 1.5,
							order = 1,
						},
						size = {
							type = "range",
							name = L.size,
							min = 1,
							softMin = 8,
							softMax = 32,
							width = 1.5,
							order = 2,
						},
						outline = {
							type = "select",
							name = L.outline,
							values = {
								[false] = L.none,
								OUTLINE = L.thin,
								THICKOUTLINE = L.thick,
							},
							sorting = { false, "OUTLINE", "THICKOUTLINE" },
							width = 1.5,
							order = 3,
						},
						monochrome = {
							type = "toggle",
							name = L.monochrome,
							width = 1.5,
							order = 4,
						},
					},
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

function module:OnProviderRegistered(_, providerID, provider)
	self.numProviders = self.numProviders + 1
	self:AddProviderEnableOption(providerID, provider)
	self.optionsTable.args.providerOptions.args[providerID] = self:RenderProviderOptions(providerID, provider)
end

function module:AddProviderEnableOption(providerID, provider)
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
	groupsOptionTable.args[groupKey].args[providerID] = self:RenderProviderEnableOption(providerID, provider)
end

function module:RenderProviderEnableOption(providerID, provider)
	return {
		type = "toggle",
		name = provider.localizedName or providerID,
		desc = provider.description,
		order = self.numProviders,
	}
end

function module:RenderProviderOptions(providerID, provider)
	local optionsTable = provider.optionsTable
	if optionsTable then
		local options = {
			type = "group",
			name = provider.localizedName or providerID,
			order = self.numProviders,
			set = optionsTable.set,
			get = optionsTable.get,
			handler = optionsTable.handler,
			args = optionsTable.args,
			plugins = optionsTable.plugins,
		}
		local success, error = pcall(function()
			AceConfigRegistry:ValidateOptionsTable(options, providerID)
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
	local providerID = info[#info]
	self:GetOptions().disabledSearchProviders[providerID] = not val
	module:SendMessage("GlobalSearch_OnProviderStatusChanged", providerID, val)
end

function module:GetPosition(info)
	return self:GetOptions().position[info[#info]]
end

function module:SetPosition(info, val)
	self:GetOptions().position[info[#info]] = val
	self:SendMessage("GlobalSearch_OnDisplaySettingsChanged")
end

function module:GetSize(info)
	return self:GetOptions().size[info[#info]]
end

function module:SetSize(info, val)
	self:GetOptions().size[info[#info]] = val
	self:SendMessage("GlobalSearch_OnDisplaySettingsChanged")
end

function module:GetFont(info)
	return self:GetOptions().font[info[#info]]
end

function module:SetFont(info, val)
	self:GetOptions().font[info[#info]] = val
	self:SendMessage("GlobalSearch_OnDisplaySettingsChanged")
end

function module:GetOptions()
	return self:GetDB().profile.options
end
