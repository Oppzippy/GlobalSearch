---@class ns
local _, ns = ...

---@class ModulePrototype
---@field GetDB fun(): table
---@field GetSearchProviderRegistry fun(): SearchProviderRegistry

local ModulePrototype = {}

---@param addon GlobalSearch
---@return table
function ModulePrototype.Create(addon)
	return {
		GetDB = function()
			return addon.db
		end,
		GetSearchProviderRegistry = function()
			return addon.providerRegistry
		end,
	}
end

if ns then
	ns.ModulePrototype = ModulePrototype
end
return ModulePrototype
