---@class ns
local ns = select(2, ...)

---@generic T
---@param iterOrTable T[] | fun(): T?
---@return fun(): T?
local function toIteratorIfTable(iterOrTable)
	if type(iterOrTable) == "table" then
		local i = 0
		return function()
			i = i + 1
			return iterOrTable[i]
		end
	end
	return iterOrTable
end

---@param category string
---@param name string
---@return SearchProvider
local function Create(category, name)
	---@class SearchProvider
	---@field name string
	---@field category string
	---@field description? string
	---@field optionsTable? AceConfig.OptionsTable
	local SearchProvider = {
		category = category,
		name = name,
	}

	---@type SearchItem[]?
	local cache = nil
	-- Abort async cache refresh when it is refreshed synchronously
	local asyncCacheRefreshInProgress = false


	---@return SearchItem[]
	function SearchProvider:Get()
		if not cache then
			self:RefreshCache()
		end
		return cache or {}
	end

	function SearchProvider:RefreshCache()
		-- Ensure the cache is left as it was if an error is thrown in Fetch
		local iterOrTable = self:Fetch()
		if type(iterOrTable) == "table" then
			cache = iterOrTable
		else
			---@type SearchItem[]
			local items = {}
			for item in toIteratorIfTable(self:Fetch()) do
				items[#items + 1] = item
			end
			cache = items
		end
		asyncCacheRefreshInProgress = false
	end

	function SearchProvider:RefreshCacheAsync()
		if not self.Fetch or asyncCacheRefreshInProgress then return end
		asyncCacheRefreshInProgress = true

		local iterOrTable = self:Fetch()
		if type(iterOrTable) == "table" then
			cache = iterOrTable
		else
			---@type SearchItem[]
			local newCache = {}
			for item in toIteratorIfTable(self:Fetch()) do
				newCache[#newCache + 1] = item
				coroutine.yield()
				if not asyncCacheRefreshInProgress then
					return
				end
			end
			cache = newCache
		end
		asyncCacheRefreshInProgress = false
	end

	---@return SearchItem[] | fun(): SearchItem?
	function SearchProvider:Fetch()
		return {}
	end

	function SearchProvider:ClearCache()
		asyncCacheRefreshInProgress = false
		cache = nil
	end

	return SearchProvider
end

ns.SearchProvider = {
	Create = Create,
}
