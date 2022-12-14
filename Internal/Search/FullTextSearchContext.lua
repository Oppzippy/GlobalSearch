---@class ns
local ns = select(2, ...)

---@class FullTextSearchContext
---@field index FullTextWordIndex
local FullTextSearchContextPrototype = {}

local export = {}

---@param items SearchItem[]
---@return Task
function export.CreateAsync(items)
	return ns.Task.Create(coroutine.create(function()
		local context = setmetatable({}, { __index = FullTextSearchContextPrototype })
		local index = ns.FullTextWordIndex.Create()
		for _, item in next, items do
			index:AddString(item, item.name)
			index:AddString(item, item.category)
			if item.extraSearchText then
				index:AddString(item, item.extraSearchText)
			end
			coroutine.yield()
		end
		index:Index()
		coroutine.yield()
		context.index = index
		return context
	end))
end

---@param query string
---@return SearchContextItem[]
function FullTextSearchContextPrototype:Search(query)
	if query == "" then return {} end
	local weightedResults = self.index:Search(query)
	local results = self:ScoreWeightedResults(weightedResults)

	return results
end

---@param weightedResults table<SearchItem, number>
function FullTextSearchContextPrototype:ScoreWeightedResults(weightedResults)
	local results = {}
	for value, weight in next, weightedResults do
		results[#results + 1] = {
			item = value,
			score = weight - 50000, -- TODO configurable or something
		}
	end

	return results
end

if ns then
	ns.FullTextSearchContext = export
end
return export
