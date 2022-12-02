---@meta

---@class SearchContextItem
---@field item SearchItem
---@field score number
---@field matchRanges? MatchRange[]

---@class SearchContext
local SearchContext = {}

---@param query string
---@return SearchContextItem[]
function SearchContext:Search(query) end
