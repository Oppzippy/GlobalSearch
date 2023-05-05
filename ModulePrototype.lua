---@class ns
local ns = select(2, ...)

local export = {}

---@param addon GlobalSearch
---@return table
function export.Create(addon)
	---@class ModulePrototype
	local ModulePrototype = {}

	---@return AceDBObject-3.0
	function ModulePrototype:GetDB()
		return addon.db
	end

	---@return SearchProviderRegistry
	function ModulePrototype:GetSearchProviderRegistry()
		return addon.providerRegistry
	end

	---@return boolean
	function ModulePrototype:IsDebugMode()
		return addon:IsDebugMode()
	end

	---@param self ModulePrototype|AceConsole-3.0
	---@param message string
	---@param ... unknown
	function ModulePrototype.Debugf(self, message, ...)
		if self:IsDebugMode() then
			self:Printf(message, ...)
		end
	end

	return ModulePrototype
end

if ns then
	ns.ModulePrototype = export
end
return export
