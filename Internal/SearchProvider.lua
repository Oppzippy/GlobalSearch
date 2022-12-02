---@meta

---@class SearchProvider
---@field name string
---@field description string
---@field category string
---@field optionsTable? AceConfigOptionsTable
---@field Fetch? fun(self: SearchProvider): SearchItem[] | fun(): SearchItem?
local SearchProvider = {}

---@return SearchItem[]
function SearchProvider:Get() end
