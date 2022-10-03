---@class ns
local ns = select(2, ...)

---@class HighPerformanceSearchContext
---@field index HighPerformanceWordIndex
local HighPerformanceSearchContextPrototype = {}

---@param items SearchItem[]
local function CreateHighPerformanceSearchContext(items)
	local context = setmetatable({}, { __index = HighPerformanceSearchContextPrototype })
	local index = ns.HighPerformanceWordIndex.Create()
	for _, item in next, items do
		index:AddString(item, item.name)
		index:AddString(item, item.category)
		if item.extraSearchText then
			index:AddString(item, item.extraSearchText)
		end
	end
	index:Index()
	context.index = index
	return context
end

---@param query string
---@return fun(): SearchContextItem
function HighPerformanceSearchContextPrototype:Search(query)
	if query == "" then return function() end end
	local iterator = self.index:Search(query)
	local results = self:ScoreWeightedResults(iterator)

	return results
end

---@param weightedResults fun(): SearchItem
---@return fun(): SearchContextItem
function HighPerformanceSearchContextPrototype:ScoreWeightedResults(weightedResults)
	return coroutine.wrap(function()
		for item in weightedResults do
			coroutine.yield({
				item = item,
				score = 0,
			})
		end
	end)
end

local export = { Create = CreateHighPerformanceSearchContext }
if ns then
	ns.HighPerformanceSearchContext = export
end
return export
