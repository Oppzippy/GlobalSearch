local luaunit = require("luaunit")
local SearchProviderCollection = require("Internal.SearchProviderCollection")

TestSearchProviderCollection = {}

local CreateMockSearchProvider = function(items, localizedName)
	return {
		localizedName = localizedName,
		Get = function()
			return items
		end,
	}
end

function TestSearchProviderCollection:TestNoProviders()
	local collection = SearchProviderCollection.Create({})
	luaunit.assertEquals(#collection:GetProviderItems("none"), 0)
end

function TestSearchProviderCollection:TestNilID()
	local collection = SearchProviderCollection.Create({
		MockProvider = CreateMockSearchProvider({
			{
				id = nil,
				name = "1",
			},
		}),
	})
	luaunit.assertNil(collection:GetProviderItems("MockProvider")[1].id)
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
	luaunit.assertNil(results[1].id)
	luaunit.assertFalse(results[2].id)
end

function TestSearchProviderCollection:TestItemCategory()
	local collection = SearchProviderCollection.Create({
		MockProvider = CreateMockSearchProvider({
			{
				name = "1",
			},
		}, "Mock Provider")
	})
	local results = collection:GetProviderItems("MockProvider")
	luaunit.assertEquals(results[1].category, "Mock Provider")
end

function TestSearchProviderCollection:TestSearchProviderID()
	local collection = SearchProviderCollection.Create({
		MockProvider = CreateMockSearchProvider({
			{
				name = "1",
			},
		}, "Mock Provider")
	})
	local results = collection:GetProviderItems("MockProvider")
	luaunit.assertEquals(results[1].providerID, "MockProvider")
end
