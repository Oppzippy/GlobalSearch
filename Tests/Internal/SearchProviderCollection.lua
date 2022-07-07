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
