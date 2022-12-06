---@type ns
local ns = select(2, ...)
local luaunit = require("luaunit")

TestSearchProviderCollection = {}

local CreateMockSearchProvider = function(items, name)
	return {
		name = name,
		Get = function()
			return items
		end,
	}
end

function TestSearchProviderCollection:TestNoProviders()
	local collection = ns.SearchProviderCollection.Create({})
	luaunit.assertEquals(#collection:GetProviderItemsAsync("none"):PollToCompletion(), 0)
end

function TestSearchProviderCollection:TestNilID()
	local collection = ns.SearchProviderCollection.Create({
		MockProvider = CreateMockSearchProvider({
			{
				id = nil,
				name = "1",
			},
		}),
	})
	luaunit.assertNil(collection:GetProviderItemsAsync("MockProvider"):PollToCompletion()[1].id)
end

function TestSearchProviderCollection:TestFalsyID()
	local collection = ns.SearchProviderCollection.Create({
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
	local results = collection:GetProviderItemsAsync("MockProvider"):PollToCompletion()
	luaunit.assertNotEquals(results[1].id, results[2].id)
	luaunit.assertNil(results[1].id)
	luaunit.assertFalse(results[2].id)
end

function TestSearchProviderCollection:TestItemCategory()
	local collection = ns.SearchProviderCollection.Create({
		MockProvider = CreateMockSearchProvider({
			{
				name = "1",
			},
		}, "Mock Provider")
	})
	local results = collection:GetProviderItemsAsync("MockProvider"):PollToCompletion()
	luaunit.assertEquals(results[1].category, "Mock Provider")
end

function TestSearchProviderCollection:TestSearchProviderID()
	local collection = ns.SearchProviderCollection.Create({
		MockProvider = CreateMockSearchProvider({
			{
				name = "1",
			},
		}, "Mock Provider")
	})
	local results = collection:GetProviderItemsAsync("MockProvider"):PollToCompletion()
	luaunit.assertEquals(results[1].providerID, "MockProvider")
end
