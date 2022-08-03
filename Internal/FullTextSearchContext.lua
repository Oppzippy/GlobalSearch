---@class ns
local ns = select(2, ...)

---@class FullTextSearchContext
---@field index FullTextWordIndex
local FullTextSearchContextPrototype = {}

---@param items SearchItem[]
local function CreateFullTextSearchContext(items)
	local context = setmetatable({}, { __index = FullTextSearchContextPrototype })
	local index = ns.FullTextWordIndex.Create()
	for _, item in next, items do
		index:AddString(item, item.name)
		index:AddString(item, item.category)
		if item.extraSearchText then
			index:AddString(item, item.extraSearchText)
		end
	end
	context.index = index
	return context
end

---@param query string
---@return unknown[]
function FullTextSearchContextPrototype:Search(query)
	return self.index:Search(query)
end

local export = { Create = CreateFullTextSearchContext }
if ns then
	ns.FullTextSearchContext = export
end
return export
