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
---@return SearchContextItem[]
function CombinedSearchContextPrototype:Search(query)
	local resultGroups = {}
	for i, context in ipairs(self.contexts) do
		resultGroups[i] = context:Search(query)
	end

	local results = self:Flatten(resultGroups)
	table.sort(results, function(a, b)
		if a.score ~= b.score then
			return a.score > b.score
		end
		return a.item.name < b.item.name
	end)
	local deduplicated = self:Deduplicate(results)

	return deduplicated
end

---@param resultGroups SearchContextItem[][]
---@return SearchContextItem[]
function CombinedSearchContextPrototype:Flatten(resultGroups)
	local flattened = {}
	for _, contextResults in ipairs(resultGroups) do
		local numContextResults = #contextResults
		for i = 1, numContextResults do
			flattened[#flattened + 1] = contextResults[i]
		end
	end
	return flattened
end

---@param results SearchContextItem[]
---@return SearchContextItem[]
function CombinedSearchContextPrototype:Deduplicate(results)
	local deduplicated = {}
	local seen = {}
	for _, result in ipairs(results) do
		if not seen[result.item] then
			seen[result.item] = true
			deduplicated[#deduplicated + 1] = result
		end
	end
	return deduplicated
end

local export = { Create = CreateCombinedSearchContext }
if ns then
	ns.CombinedSearchContext = export
end
return export
