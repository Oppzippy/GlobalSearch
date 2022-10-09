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
	luaunit.assertEquals(#collection:GetProviderItems("none"), 0)
end

function TestSearchProviderCollection:TestCombinesAllChildren()
	local collection = SearchProviderCollection.Create({
		Provider1 = CreateMockSearchProvider({
			{
				name = "1",
			},
		}),
		Provider2 = CreateMockSearchProvider({}),
		Provider3 = CreateMockSearchProvider({
			{
				name = "2",
			},
			{
				name = "3",
			},
		}),
	})

	luaunit.assertEquals(#collection:GetProviderItems("Provider1"), 1)
	luaunit.assertEquals(#collection:GetProviderItems("Provider2"), 0)
	luaunit.assertEquals(#collection:GetProviderItems("Provider3"), 2)
end

function TestSearchProviderCollection:TestNilID()
	local collection = SearchProviderCollection.Create({
		Provider1 = CreateMockSearchProvider({
			{
				id = nil,
				name = "1",
			},
		}),
	})
	luaunit.assertNil(collection:GetProviderItems("Provider1")[1].id)
end

function TestSearchProviderCollection:TestFalsyID()
	local collection = SearchProviderCollection.Create({
		MockProvider = CreateMockSearchProvider({
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
	local results = collection:GetProviderItems("MockProvider")
	luaunit.assertNotEquals(results[1].id, results[2].id)
end
