---@class ns
local _, ns = ...

--[[
TODO:
- macros
- inventory items
- equipment (trinkets and such)
]]

---@class SearchItem
---@field name string
---@field category string
---@field texture number
---@field searchableText string
---@field spellId number
---@field action function
---@field macro string

---@return SearchItem[]
local function GetItems()
	local items = {}

	for _, provider in ipairs(ns.SearchItemProviders) do
		local itemGroup = provider:Get()
		for _, item in ipairs(itemGroup) do
			items[#items + 1] = item
		end
	end
	return items
end

if ns then
	ns.SearchItemProviders = {}
	ns.GetSearchItems = GetItems
end
