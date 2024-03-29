---@type ns
local ns = select(2, ...)
local luaunit = require("luaunit")

TestShortTextSearchContext = {}

---@param results SearchContextItem[]
---@param itemName string
---@return SearchContextItem
local function getResultByItemName(results, itemName)
	for _, result in next, results do
		if result.item.name == itemName then
			return result
		end
	end
	error("item not found")
end

function TestShortTextSearchContext:TestResultCaching()
	local items = {
		{
			name = "abc",
		},
		{
			name = "abcd",
		},
	}
	local context = ns.Task.Create(coroutine.create(function()
		return ns.ShortTextSearchContext.CreateAsync(ns.ShortTextQueryMatcher.MatchesQuery, items)
	end)):PollToCompletion()
	local firstResults = context:Search("abc")
	local secondResults = context:Search("abcd")
	local thirdResults = context:Search("abc")
	luaunit.assertEquals(2, #firstResults)
	luaunit.assertEquals(1, #secondResults)
	luaunit.assertEquals(2, #thirdResults)
end

function TestShortTextSearchContext:TestDoesNotIncludeExtraText()
	local items = {
		{
			name = "abc",
			extraSearchText = "def",
		},
		{
			name = "abcdef",
		},
	}
	local context = ns.Task.Create(coroutine.create(function()
		return ns.ShortTextSearchContext.CreateAsync(ns.ShortTextQueryMatcher.MatchesQuery, items)
	end)):PollToCompletion()
	local results = context:Search("abcdef")
	luaunit.assertEquals(#results, 1)
end

function TestShortTextSearchContext:TestSortingByNumMatches()
	local items = {
		{
			name = "abc",
		},
		{
			name = "ac",
		},
	}
	local context = ns.Task.Create(coroutine.create(function()
		return ns.ShortTextSearchContext.CreateAsync(ns.ShortTextQueryMatcher.MatchesQuery, items)
	end)):PollToCompletion()
	local results = context:Search("ac")
	luaunit.assertTrue(getResultByItemName(results, "abc").score < getResultByItemName(results, "ac").score)
end

function TestShortTextSearchContext:TestSortingByEarliestMatch()
	local items = {
		{
			-- first match starts later and ends earlier
			name = "_____abcde",
		},
		{
			name = "abcde",
		},
	}
	local context = ns.Task.Create(coroutine.create(function()
		return ns.ShortTextSearchContext.CreateAsync(ns.ShortTextQueryMatcher.MatchesQuery, items)
	end)):PollToCompletion()
	local results = context:Search("abcde")
	luaunit.assertTrue(getResultByItemName(results, "_____abcde").score < getResultByItemName(results, "abcde").score)
end

function TestShortTextSearchContext:TestSortingByLongestFirstMatch()
	local items = {
		{
			name = "a_bc",
		},
		{
			name = "abc",
		},
	}
	local context = ns.Task.Create(coroutine.create(function()
		return ns.ShortTextSearchContext.CreateAsync(ns.ShortTextQueryMatcher.MatchesQuery, items)
	end)):PollToCompletion()
	local results = context:Search("abc")
	luaunit.assertTrue(getResultByItemName(results, "a_bc").score < getResultByItemName(results, "abc").score)
end

function TestShortTextSearchContext:TestSortingByStringLength()
	local items = {
		{
			name = "abcdefg",
		},
		{
			name = "abcd",
		},
	}
	local context = ns.Task.Create(coroutine.create(function()
		return ns.ShortTextSearchContext.CreateAsync(ns.ShortTextQueryMatcher.MatchesQuery, items)
	end)):PollToCompletion()
	local results = context:Search("ab")
	luaunit.assertTrue(getResultByItemName(results, "abcdefg").score < getResultByItemName(results, "abcd").score)
end

function TestShortTextSearchContext:TestSortingBySmallestRange()
	local items = {
		{
			-- larger distance between the start and end
			name = "abc_____de",
		},
		{
			name = "abc_de________",
		},
	}
	local context = ns.Task.Create(coroutine.create(function()
		return ns.ShortTextSearchContext.CreateAsync(ns.ShortTextQueryMatcher.MatchesQuery, items)
	end)):PollToCompletion()
	local results = context:Search("abcde")
	luaunit.assertTrue(getResultByItemName(results, "abc_____de").score <
		getResultByItemName(results, "abc_de________").score)
end

function TestShortTextSearchContext:TestCaseInsensitivity()
	---@diagnostic disable-next-line: missing-fields
	local items = { { name = "AbC" } }
	local context = ns.Task.Create(coroutine.create(function()
		return ns.ShortTextSearchContext.CreateAsync(ns.ShortTextQueryMatcher.MatchesQuery, items)
	end)):PollToCompletion()
	local results = context:Search("aBc")
	luaunit.assertEquals(#results, 1)
end
