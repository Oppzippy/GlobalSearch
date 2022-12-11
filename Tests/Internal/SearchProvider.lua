---@type ns
local ns = select(2, ...)
local luaunit = require("luaunit")

TestSearchProvider = {}

---@param fetchType "iterator" | "table"
---@return SearchProvider
local function createProvider(fetchType)
	local provider = ns.SearchProvider:Create("test")
	---@type SearchItem[]
	local items = {
		{
			id = "1",
			name = "test 1",
		},
		{
			id = "2",
			name = "test 2",
		},
		{
			id = "3",
			name = "test 3",
		},
		{
			id = "4",
			name = "test 4",
		},
		{
			id = "5",
			name = "test 5",
		},
		{
			id = "6",
			name = "test 6",
		},
	}

	---@return SearchItem[] | fun(): SearchItem?
	---@diagnostic disable-next-line: duplicate-set-field
	function provider:Fetch()
		if fetchType == "iterator" then
			local i = 0
			return function()
				i = i + 1
				return items[i]
			end
		else
			return items
		end
	end

	return provider
end

function TestSearchProvider:TestExpectedNumberOfSteps()
	local provider = createProvider("iterator")
	local co = coroutine.create(function()
		provider:RefreshCacheAsync()
	end)
	local steps = 0
	while coroutine.resume(co) do
		steps = steps + 1
	end
	luaunit.assertEquals(steps, 7)
	luaunit.assertEquals(coroutine.status(co), "dead")
end

function TestSearchProvider:TestRefreshCacheCancelsRefreshCacheAsync()
	local provider = createProvider("iterator")
	local co = coroutine.create(function()
		provider:RefreshCacheAsync()
	end)
	coroutine.resume(co)
	provider:RefreshCache()
	luaunit.assertEquals(coroutine.status(co), "suspended")
	coroutine.resume(co)
	luaunit.assertEquals(coroutine.status(co), "dead")
end

function TestSearchProvider:TestGetCancelsRefreshCacheAsync()
	local provider = createProvider("iterator")
	local co = coroutine.create(function()
		provider:RefreshCacheAsync()
	end)
	coroutine.resume(co)
	provider:Get()
	luaunit.assertEquals(coroutine.status(co), "suspended")
	coroutine.resume(co)
	luaunit.assertEquals(coroutine.status(co), "dead")
end

function TestSearchProvider:TestOnlyOneRefreshCacheAsyncCanRunAtOnce()
	local provider = createProvider("iterator")
	local co = coroutine.create(function()
		provider:RefreshCacheAsync()
	end)
	local co2 = coroutine.create(function()
		provider:RefreshCacheAsync()
	end)
	coroutine.resume(co)
	coroutine.resume(co2)
	luaunit.assertEquals(coroutine.status(co), "suspended")
	luaunit.assertEquals(coroutine.status(co2), "dead")
end

function TestSearchProvider:TestRefreshCacheAsyncWithTableOnlyTakesOneStep()
	local provider = createProvider("table")
	local co = coroutine.create(function()
		provider:RefreshCacheAsync()
	end)
	coroutine.resume(co)
	luaunit.assertEquals(coroutine.status(co), "dead")
end

function TestSearchProvider:TestGetWithTableCachesItems()
	local provider = createProvider("table")
	local items = provider:Get()
	local items2 = provider:Get()
	luaunit.assertTrue(items == items2)
end

function TestSearchProvider:TestGetWithIteratorCachesItems()
	local provider = createProvider("iterator")
	local items = provider:Get()
	local items2 = provider:Get()
	luaunit.assertTrue(items == items2)
end
