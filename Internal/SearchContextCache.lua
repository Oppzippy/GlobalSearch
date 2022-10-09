---@class ns
local ns = select(2, ...)

---@class SearchContextCache
---@field contexts table<SearchItem[], SearchContext[]>
---@field items table<string, SearchItem[]>
---@field providerCollection SearchProviderCollection
local SearchContextCachePrototype = {}

---@param providerCollection SearchProviderCollection
local function CreateSearchContextCache(providerCollection)
	local collection = setmetatable({
		-- If nobody else has a reference to the search item arrays in the cache, it is impossible for the value to ever be
		-- includedin the table passed as a parameter. We can use a weak reference to prevent the key value pairs from being
		-- kept around longer than necessary.
		contexts = setmetatable({}, {
			__mode = "k",
		}),
		items = setmetatable({}, {
			__mode = "v",
		}),

		providerCollection = providerCollection,
	}, {
		__index = SearchContextCachePrototype,
	})
	return collection
end

---@return CombinedSearchContext
function SearchContextCachePrototype:GetCombinedContext()
	---@type SearchContext[]
	local contexts = {}


	for providerID in next, self.providerCollection:GetProviders() do
		for context in self:IterateContextsForProvider(providerID) do
			contexts[#contexts + 1] = context
		end
	end

	return ns.CombinedSearchContext.Create(contexts)
end

---@param providerIDs table<string, boolean>
---@return CombinedSearchContext
function SearchContextCachePrototype:GetCombinedContextForProviders(providerIDs)
	---@type SearchContext[]
	local contexts = {}

	for providerID in next, providerIDs do
		for context in self:IterateContextsForProvider(providerID) do
			contexts[#contexts + 1] = context
		end
	end

	return ns.CombinedSearchContext.Create(contexts)
end

---@param providerID string
---@return fun(): SearchContext
function SearchContextCachePrototype:IterateContextsForProvider(providerID)
	return coroutine.wrap(function()
		local items = self.providerCollection:GetProviderItems(providerID)
		if items then
			if self.items[providerID] ~= items then
				local contextGroup = {}
				contextGroup[#contextGroup + 1] = ns.ShortTextSearchContext.Create(ns.ShortTextQueryMatcher.MatchesQuery, items)
				contextGroup[#contextGroup + 1] = ns.FullTextSearchContext.Create(items)
				self.contexts[items] = contextGroup
				self.items[providerID] = items
			end

			for _, context in next, self.contexts[items] do
				coroutine.yield(context)
			end
		end
	end)
end

function SearchContextCachePrototype:GetProviders()
	return self.providerCollection:GetProviders()
end

local export = { Create = CreateSearchContextCache }
if ns then
	ns.SearchContextCache = export
end
return export
