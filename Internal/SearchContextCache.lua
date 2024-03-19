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

-- Task returns CombinedSearchContext
---@return Task
function SearchContextCachePrototype:GetCombinedContextAsync()
	return ns.Task.Create(coroutine.create(function()
		---@type SearchContext[]
		local contexts = {}

		for providerID in next, self.providerCollection:GetProviders() do
			self:GetContextsForProviderAsync(providerID):Then(ns.Task.Create(coroutine.create(function(providerContexts)
				---@cast providerContexts SearchContext[]
				for _, context in ipairs(providerContexts) do
					contexts[#contexts + 1] = context
				end
			end))):PollToCompletionAsync()
		end

		return ns.CombinedSearchContext.Create(contexts)
	end))
end

-- Task returns CombinedSearchContext
---@param providerIDs table<string, boolean>
---@return Task
function SearchContextCachePrototype:GetCombinedContextForProvidersAsync(providerIDs)
	return ns.Task.Create(coroutine.create(function()
		---@type SearchContext[]
		local contexts = {}

		for providerID in next, providerIDs do
			self:GetContextsForProviderAsync(providerID):Then(ns.Task.Create(coroutine.create(function(providerContexts)
				---@cast providerContexts SearchContext[]
				for _, context in ipairs(providerContexts) do
					contexts[#contexts + 1] = context
				end
			end))):PollToCompletionAsync()
		end

		return ns.CombinedSearchContext.Create(contexts)
	end))
end

-- Task returns SearchContext[]
---@param providerID string
---@return Task
function SearchContextCachePrototype:GetContextsForProviderAsync(providerID)
	return self.providerCollection:GetProviderItemsAsync(providerID):Then(ns.Task.Create(coroutine.create(function(items)
		if items then
			if self.items[providerID] ~= items then
				local contextGroup = {}
				contextGroup[#contextGroup + 1] = ns.ShortTextSearchContext.CreateAsync(
				ns.ShortTextQueryMatcher.MatchesQuery, items)
				-- Expensive to build index
				contextGroup[#contextGroup + 1] = ns.FullTextSearchContext.CreateAsync(items):PollToCompletionAsync()

				self.contexts[items] = contextGroup
				self.items[providerID] = items
			end
			return self.contexts[items]
		end
		return {}
	end)))
end

function SearchContextCachePrototype:GetProviders()
	return self.providerCollection:GetProviders()
end

local export = { Create = CreateSearchContextCache }
if ns then
	ns.SearchContextCache = export
end
return export
