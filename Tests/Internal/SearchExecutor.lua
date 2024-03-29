---@type ns
local ns = select(2, ...)
local luaunit = require("luaunit")

TestSearchExecutor = {}

---@return AceDBObject-3.0
local function createMockDB()
	return {
		profile = {
			recentItemsV2 = {},
			options = {
				maxRecentItems = 20,
			},
		},
	}
end

---@return SearchProviderCollection
local function createPrepopulatedProviderCollection()
	---@param name string
	---@param items SearchItem[]
	---@return SearchProvider
	local function createProvider(name, items)
		return {
			name = name,
			Get = function()
				return items
			end,
		}
	end

	local providerCollection = ns.SearchProviderCollection.Create({
		FirstProvider = createProvider("First Provider", {
			{
				id = 1,
				name = "First Item",
			},
			{
				id = 2,
				name = "Second Item",
			},
			{
				id = 3,
				name = "Third Item",
			},
		}),
		SecondProvider = createProvider("Second Provider", {
			{
				id = 1,
				name = "Fourth Item",
			},
			{
				id = 2,
				name = "Fifth Item",
			},
			{
				id = 3,
				name = "Sixth Item",
			},
			{
				id = 4,
				name = "????????",
			}
		})
	})

	return providerCollection
end

function TestSearchExecutor:TestShortTextAndFullTextOrdering()
	local providerCollection = createPrepopulatedProviderCollection()
	local contextCache = ns.SearchContextCache.Create(providerCollection)
	local executor = ns.SearchExecutor.Create(createMockDB(), providerCollection, contextCache)

	local results = executor:Search("Third Item")

	luaunit.assertEquals(results[1].item.name, "Third Item")
	luaunit.assertEquals(#results, 6)
end

function TestSearchExecutor:TestRecentItems()
	local db = createMockDB()
	db.profile.recentItemsV2 = {
		{
			providerID = "SecondProvider",
			id = 1,
		},
		{
			providerID = "FirstProvider",
			id = 2,
		},
	}

	local providerCollection = createPrepopulatedProviderCollection()
	local contextCache = ns.SearchContextCache.Create(providerCollection)
	local executor = ns.SearchExecutor.Create(db, providerCollection, contextCache);

	local results = executor:GetRecentItemResults()
	luaunit.assertEquals(results[1].item.name, "Fourth Item")
	luaunit.assertEquals(results[2].item.name, "Second Item")
end

function TestSearchExecutor:TestEmptyRecentItems()
	local db = createMockDB()

	local providerCollection = createPrepopulatedProviderCollection()
	local contextCache = ns.SearchContextCache.Create(providerCollection)
	local executor = ns.SearchExecutor.Create(db, providerCollection, contextCache);

	local results = executor:GetRecentItemResults()
	luaunit.assertEquals(#results, 0)
end
