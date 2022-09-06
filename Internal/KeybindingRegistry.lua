---@class ns
local ns = select(2, ...)

---@class KeybindingRegistry
---@field keybindings table<string, string>
---@field callbacks table
---@field RegisterCallback fun(self: table, eventName: string, method?: string, ...?)
---@field UnregisterCallback fun(self: table, eventName: string)
---@field UnregisterAllCallbacks fun(self: table)
local KeybindingRegistryPrototype = {}

---@param callbackHandler table
---@return KeybindingRegistry
local function CreateKeybindingRegistry(callbackHandler)
	local registry = setmetatable({
		keybindings = {},
	}, { __index = KeybindingRegistryPrototype })
	registry.callbacks = callbackHandler:New(registry)
	return registry
end

---@param key string
---@param callbackName string
function KeybindingRegistryPrototype:RegisterKeybinding(key, callbackName)
	self.keybindings[key] = callbackName
end

---@return table<string, string[]>
function KeybindingRegistryPrototype:GetKeyBindingsByCallbackName()
	local keybindingsByCallback = {}
	for key, callbackName in next, self.keybindings do
		if not keybindingsByCallback[callbackName] then
			keybindingsByCallback[callbackName] = {}
		end
		table.insert(keybindingsByCallback[callbackName], key)
	end
	return keybindingsByCallback
end

---@param eventToRemove string
function KeybindingRegistryPrototype:ClearKeybindingsByEvent(eventToRemove)
	for key, event in next, self.keybindings do
		if event == eventToRemove then
			self.keybindings[key] = nil
		end
	end
end

function KeybindingRegistryPrototype:ClearAllKeybindings()
	self.keybindings = {}
end

---@param key string
function KeybindingRegistryPrototype:OnKeyDown(key)
	local callbackName = self.keybindings[key]
	if callbackName then
		self.callbacks:Fire(callbackName, key)
	end
end

local export = { Create = CreateKeybindingRegistry }
if ns then
	ns.KeybindingRegistry = export
end
return export
