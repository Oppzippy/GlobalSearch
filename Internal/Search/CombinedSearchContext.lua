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
	local results = {}
	for i, context in ipairs(self.contexts) do
		results[i] = context:Search(query)
	end
	return self:FlattenAndDeduplicate(results)
end

---@param results SearchContextItem[][]
---@return SearchContextItem[]
function CombinedSearchContextPrototype:FlattenAndDeduplicate(results)
	local seen = {}
	local deduplicated = {}
	-- Outer loop runs very few times so ipairs is fine
	for _, contextResults in ipairs(results) do
		local numContextResults = #contextResults
		-- Standard for loop for performance
		for i = 1, numContextResults do
			local result = contextResults[i]
			local item = result.item
			if not seen[item] then
				seen[item] = true
				deduplicated[#deduplicated + 1] = result
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
