local luaunit = require("luaunit")
local SearchProviderCollection = require("Internal.SearchProviderCollection")

TestSearchProviderCollection = {}

local CreateMockSearchProvider = function(items)
	return {
		Get = function()
			return items
		end,
	}
end

function TestSearchProviderCollection:TestNoProviders()
	local collection = SearchProviderCollection.Create({})
	luaunit.assertEquals(#collection:Get(), 0)
end

function TestSearchProviderCollection:TestCombinesAllChildren()
	local collection = SearchProviderCollection.Create({
		CreateMockSearchProvider({
			{
				name = "1",
			},
		}),
		CreateMockSearchProvider({}),
		CreateMockSearchProvider({
			{
				name = "2",
			},
			{
				name = "3",
			},
		}),
	})

	luaunit.assertEquals(#collection:Get(), 3)
end

function TestSearchProviderCollection:TestNilID()
	local collection = SearchProviderCollection.Create({
		CreateMockSearchProvider({
			{
				id = nil,
				name = "1",
			},
		}),
	})
	luaunit.assertNil(collection:Get()[1].id)
end

function TestSearchProviderCollection:TestFalsyID()
	local collection = SearchProviderCollection.Create({
		CreateMockSearchProvider({
			{
				id = nil,
				name = "1",
			},
			{
				id = false,
				name = "2",
			},
		}),
	})
	local results = collection:Get()
	luaunit.assertNotEquals(results[1].id, results[2].id)
end
