local luaunit = require("luaunit")
local SearchContext = require("Internal.SearchContext")
local QueryMatcher = require("Internal.QueryMatcher")

TestSearchContext = {}

function TestSearchContext:TestResultCaching()
	local items = {
		{
			name = "abc",
		},
		{
			name = "abcd",
		},
	}
	local context = SearchContext.Create(QueryMatcher.MatchesQuery, items)
	local firstResults = context:Search("abc")
	local secondResults = context:Search("abcd")
	local thirdResults = context:Search("abc")
	luaunit.assertEquals(2, #firstResults)
	luaunit.assertEquals(1, #secondResults)
	luaunit.assertEquals(2, #thirdResults)
end

function TestSearchContext:TestExtraSearchText()
	local items = {
		{
			name = "abc",
			extraSearchText = "def",
		},
		{
			name = "abcdef",
		},
	}
	local context = SearchContext.Create(QueryMatcher.MatchesQuery, items)
	local results = context:Search("abcdef")
	luaunit.assertEquals(#results, 2)
	luaunit.assertEquals(results[1].item.name, "abcdef")
	luaunit.assertEquals(results[2].item.name, "abc")
end

function TestSearchContext:TestSortingByNumMatches()
	local items = {
		{
			name = "abc",
		},
		{
			name = "ac",
		},
	}
	local context = SearchContext.Create(QueryMatcher.MatchesQuery, items)
	local results = context:Search("ac")
	luaunit.assertEquals(results[1].item.name, "ac")
	luaunit.assertEquals(results[2].item.name, "abc")
end

function TestSearchContext:TestSortingByEarliestMatch()
	local items = {
		{
			-- first match starts later and ends earlier
			name = "_____abcde",
		},
		{
			name = "abcde",
		},
	}
	local context = SearchContext.Create(QueryMatcher.MatchesQuery, items)
	local results = context:Search("abcde")
	luaunit.assertEquals(results[1].item.name, "abcde")
	luaunit.assertEquals(results[2].item.name, "_____abcde")
end

function TestSearchContext:TestSortingByLongestFirstMatch()
	local items = {
		{
			name = "a_bc",
		},
		{
			name = "abc",
		},
	}
	local context = SearchContext.Create(QueryMatcher.MatchesQuery, items)
	local results = context:Search("abc")
	luaunit.assertEquals(results[1].item.name, "abc")
	luaunit.assertEquals(results[2].item.name, "a_bc")
end

function TestSearchContext:TestSortingByStringLength()
	local items = {
		{
			name = "abcdefg",
		},
		{
			name = "abcd",
		},
	}
	local context = SearchContext.Create(QueryMatcher.MatchesQuery, items)
	local results = context:Search("ab")
	luaunit.assertEquals(results[1].item.name, "abcd")
	luaunit.assertEquals(results[2].item.name, "abcdefg")
end

function TestSearchContext:TestSortingBySmallestRange()
	local items = {
		{
			-- larger distance between the start and end
			name = "abc_____de",
		},
		{
			name = "abc_de________",
		},
	}
	local context = SearchContext.Create(QueryMatcher.MatchesQuery, items)
	local results = context:Search("abcde")
	luaunit.assertEquals(results[1].item.name, "abc_de________")
	luaunit.assertEquals(results[2].item.name, "abc_____de")
end
