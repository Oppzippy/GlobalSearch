local luaunit = require("luaunit")
local QueryMatcher = require("Internal/QueryMatcher")
TestQueryMatcher = {}

function TestQueryMatcher:TestSkippedCharacters()
	luaunit.assertTrue(QueryMatcher.MatchesQuery("bcf", "abcdefg"))
end

function TestQueryMatcher:TestPartialMatchAtStart()
	luaunit.assertFalse(QueryMatcher.MatchesQuery("abc", "abdefg"))
end

function TestQueryMatcher:TestPartialMatchAtEnd()
	luaunit.assertFalse(QueryMatcher.MatchesQuery("def", "abcef"))
end

function TestQueryMatcher:TestLongerQueryThanText()
	luaunit.assertFalse(QueryMatcher.MatchesQuery("abcdef", "abc"))
end

function TestQueryMatcher:TestShorterQueryThanText()
	luaunit.assertTrue(QueryMatcher.MatchesQuery("abc", "abcdef"))
end
