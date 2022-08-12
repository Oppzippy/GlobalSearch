---@class ns
local ns = select(2, ...)

---@class CombinedSearchContext
---@field contexts SearchContext[]
local CombinedSearchContextPrototype = {}

---@param contexts SearchContext[]
local function CreateCombinedSearchContext(contexts)
	local context = setmetatable({
		contexts = contexts,
	}, {
		__index = CombinedSearchContextPrototype,
	})
	return context
end

---@param query string
---@return unknown[]
function CombinedSearchContextPrototype:Search(query)
	local results = {}
	for i, context in ipairs(self.contexts) do
		results[i] = context:Search(query)
	end
	return self:FlattenAndDeduplicate(results)
end

---@param results unknown[][]
---@return unknown[]
function CombinedSearchContextPrototype:FlattenAndDeduplicate(results)
	local seen = {}
	local deduplicated = {}
	local i = 1
	for _, contextResults in ipairs(results) do
		for _, result in ipairs(contextResults) do
			if not seen[result] then
				seen[result] = true
				deduplicated[i] = result
				i = i + 1
			end
		end
	end
	return deduplicated
end

local export = { Create = CreateCombinedSearchContext }
if ns then
	ns.CombinedSearchContext = export
end
return export
