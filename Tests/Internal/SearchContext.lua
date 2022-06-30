local luaunit = require("luaunit")
local SearchContext = require("Internal.SearchContext")
local QueryMatcher = require("Internal.QueryMatcher")

TestSearchContext = {}

function TestSearchContext:TestResultCaching()
	local items = {
		{
			name = "abc",
			searchableText = "abc",
		},
		{
			name = "abcd",
			searchableText = "abcd",
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
			searchableText = "abc",
		},
		{
			searchableText = "ac",
		},
	}
	local context = SearchContext.Create(QueryMatcher.MatchesQuery, items)
	local results = context:Search("ac")
	luaunit.assertEquals(results[1].item.searchableText, "ac")
	luaunit.assertEquals(results[2].item.searchableText, "abc")
end

function TestSearchContext:TestSortingByEarliestMatch()
	local items = {
		{
			-- first match starts later and ends earlier
			searchableText = "_ab_cde",
		},
		{
			searchableText = "abcd___e",
		},
	}
	local context = SearchContext.Create(QueryMatcher.MatchesQuery, items)
	local results = context:Search("abcde")
	luaunit.assertEquals(results[1].item.searchableText, "abcd___e")
	luaunit.assertEquals(results[2].item.searchableText, "_ab_cde")
end

function TestSearchContext:TestSortingByLongestFirstMatch()
	local items = {
		{
			searchableText = "a_bc",
		},
		{
			searchableText = "abc",
		},
	}
	local context = SearchContext.Create(QueryMatcher.MatchesQuery, items)
	local results = context:Search("abc")
	luaunit.assertEquals(results[1].item.searchableText, "abc")
	luaunit.assertEquals(results[2].item.searchableText, "a_bc")
end

function TestSearchContext:TestSortingByStringLength()
	local items = {
		{
			name = "abcdefg",
			searchableText = "abcdefg",
		},
		{
			name = "abcd",
			searchableText = "abcd",
		},
	}
	local context = SearchContext.Create(QueryMatcher.MatchesQuery, items)
	local results = context:Search("ab")
	luaunit.assertEquals(results[1].item.searchableText, "abcd")
	luaunit.assertEquals(results[2].item.searchableText, "abcdefg")
end
