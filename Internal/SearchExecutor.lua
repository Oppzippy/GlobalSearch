---@class ns
local ns = select(2, ...)

---@class SearchExecutor
---@field db AceDBObject-3.0
---@field searchContextCache SearchContextCache
---@field searchProviderCollection SearchProviderCollection
---@field combinedSearchContext CombinedSearchContext
local SearchExecutorPrototype = {}

---@param db AceDBObject-3.0
---@param searchProviderCollection SearchProviderCollection
---@param searchContextCache SearchContextCache
---@return SearchExecutor
local function CreateSearchExecutor(db, searchProviderCollection, searchContextCache)
	local searchExecutor = setmetatable({
		db = db,
		searchProviderCollection = searchProviderCollection,
		searchContextCache = searchContextCache,
	}, {
		__index = SearchExecutorPrototype,
	})
	searchExecutor.combinedSearchContext = searchExecutor.searchContextCache:GetCombinedContext()
	return searchExecutor
end

---@param query string
---@return SearchContextItem[]
function SearchExecutorPrototype:Search(query)
	self.searchQuery = query
	local results
	if query == "" then
		results = self:GetRecentItemResults()

		-- We store more items than the max number of recent items to display, so remove the extras.
		for i = self.db.profile.options.maxRecentItems + 1, #results do
			results[i] = nil
		end
	else
		local specificProvider, specificProviderQuery = query:match("^#([^ ]+) (.*)$")
		if specificProvider then
			specificProvider = specificProvider:lower()

			---@type table<string, boolean>
			local matchingProviderIDs = {}
			for id, provider in next, self.searchProviderCollection:GetProviders() do
				local name = provider.name or id
				if name:gsub(" ", ""):lower() == specificProvider then
					matchingProviderIDs[id] = true
				end
			end

			local context = self.searchContextCache:GetCombinedContextForProviders(matchingProviderIDs)
			results = context:Search(specificProviderQuery)
		else
			results = self.combinedSearchContext:Search(query)
		end
	end

	return results
end

function SearchExecutorPrototype:GetRecentItemResults()
	---@type table<string, table<unknown, number>>
	local itemIDOrder = {}
	for i, recentItem in next, self.db.profile.recentItemsV2 do
		if recentItem.provider then -- don't break on old format
			if not itemIDOrder[recentItem.provider] then
				itemIDOrder[recentItem.provider] = {}
			end
			itemIDOrder[recentItem.provider][recentItem.id] = i
		end
	end

	---@type SearchContextItem[]
	local results = {}
	---@type table<SearchContextItem, number>
	local resultOrder = {}
	for providerID in next, self.searchProviderCollection:GetProviders() do
		for _, item in next, self.searchProviderCollection:GetProviderItems(providerID) do
			local order = itemIDOrder[item.providerID] and itemIDOrder[item.providerID][item.id]
			if order then
				local result = { item = item }
				results[#results + 1] = result
				resultOrder[result] = order
			end
		end
	end

	table.sort(results, function(a, b)
		return resultOrder[a] < resultOrder[b]
	end)
	return results
end

local export = { Create = CreateSearchExecutor }
if ns then
	ns.SearchExecutor = export
end
return export
