local luaunit = require("luaunit")
local QueryMatcher = require("Internal.QueryMatcher")
TestQueryMatcher = {}

function TestQueryMatcher:TestSkippedCharacters()
	local isMatch, ranges = QueryMatcher.MatchesQuery("bcf", "abcdefg")
	luaunit.assertTrue(isMatch)
	luaunit.assertEquals(ranges,
		{
			{
				from = 2,
				to = 3,
			},
			{
				from = 6,
				to = 6,
			},
		}
	)
end

function TestQueryMatcher:TestPartialMatchAtStart()
	local isMatch = QueryMatcher.MatchesQuery("abc", "abdefg")
	luaunit.assertFalse(isMatch)
end

function TestQueryMatcher:TestPartialMatchAtEnd()
	local isMatch = QueryMatcher.MatchesQuery("def", "abcef")
	luaunit.assertFalse(isMatch)
end

function TestQueryMatcher:TestLongerQueryThanText()
	local isMatch = QueryMatcher.MatchesQuery("abcdef", "abc")
	luaunit.assertFalse(isMatch)
end

function TestQueryMatcher:TestShorterQueryThanText()
	local isMatch, ranges = QueryMatcher.MatchesQuery("abc", "abcdef")
	luaunit.assertTrue(isMatch)
	luaunit.assertEquals(ranges,
		{
			{
				from = 1,
				to = 3,
			},
		}
	)
end

function TestQueryMatcher:TestFullMatch()
	local isMatch, ranges = QueryMatcher.MatchesQuery("abc", "abc")
	luaunit.assertTrue(isMatch)
	luaunit.assertEquals(ranges,
		{
			{
				from = 1,
				to = 3,
			},
		}
	)
end
