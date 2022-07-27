---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

BINDING_HEADER_GLOBALSEARCH = L.global_search
BINDING_NAME_GLOBALSEARCH_SHOW = L.show

local Bindings = {}

function Bindings.GetCurrentModifiers()
	local modifiers = ""
	if IsShiftKeyDown() then
		modifiers = "SHIFT-"
	end
	if IsControlKeyDown() then
		modifiers = "CTRL-" .. modifiers
	end
	if IsAltKeyDown() then
		modifiers = "ALT-" .. modifiers
	end
	return modifiers
end

do
	local cache = {}
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("UPDATE_BINDINGS")

	frame:SetScript("OnEvent", function()
		cache = {}
	end)

	---@param name string
	---@return string[]
	local function GetBindingsByName(name)
		for i = 1, GetNumBindings() do
			local binding = { GetBinding(i) }
			if binding[1] == name then
				return { select(3, unpack(binding)) }
			end
		end
		return {}
	end

	---@param name string
	---@return table<string, boolean>
	function Bindings.GetKeyBinding(name)
		if not cache[name] then
			local bindingsList = GetBindingsByName("GLOBALSEARCH_" .. name)
			local bindingsSet = ns.Util.ListToSet(bindingsList)
			cache[name] = bindingsSet
		end
		return cache[name]
	end
end

if ns then
	ns.Bindings = Bindings
end
return Bindings
