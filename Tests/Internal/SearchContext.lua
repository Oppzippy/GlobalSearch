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
			name = "_ab_cde",
		},
		{
			name = "abcd___e",
		},
	}
	local context = SearchContext.Create(QueryMatcher.MatchesQuery, items)
	local results = context:Search("abcde")
	luaunit.assertEquals(results[1].item.name, "abcd___e")
	luaunit.assertEquals(results[2].item.name, "_ab_cde")
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
