local luaunit = require("luaunit")
local ShortTextQueryMatcher = require("Internal.Search.ShortTextQueryMatcher")
TestShortTextQueryMatcher = {}

function TestShortTextQueryMatcher:TestSkippedCharacters()
	local isMatch, ranges = ShortTextQueryMatcher.MatchesQuery("bcf", "abcdefg")
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

function TestShortTextQueryMatcher:TestPartialMatchAtStart()
	local isMatch = ShortTextQueryMatcher.MatchesQuery("abc", "abdefg")
	luaunit.assertFalse(isMatch)
end

function TestShortTextQueryMatcher:TestPartialMatchAtEnd()
	local isMatch = ShortTextQueryMatcher.MatchesQuery("def", "abcef")
	luaunit.assertFalse(isMatch)
end

function TestShortTextQueryMatcher:TestLongerQueryThanText()
	local isMatch = ShortTextQueryMatcher.MatchesQuery("abcdef", "abc")
	luaunit.assertFalse(isMatch)
end

function TestShortTextQueryMatcher:TestShorterQueryThanText()
	local isMatch, ranges = ShortTextQueryMatcher.MatchesQuery("abc", "abcdef")
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

function TestShortTextQueryMatcher:TestFullMatch()
	local isMatch, ranges = ShortTextQueryMatcher.MatchesQuery("abc", "abc")
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
