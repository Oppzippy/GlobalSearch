---@type ns
local ns = select(2, ...)
local luaunit = require("luaunit")

TestShortTextQueryMatcher = {}

function TestShortTextQueryMatcher:TestSkippedCharacters()
	local isMatch, ranges = ns.ShortTextQueryMatcher.MatchesQuery("bcf", "abcdefg")
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
	local isMatch = ns.ShortTextQueryMatcher.MatchesQuery("abc", "abdefg")
	luaunit.assertFalse(isMatch)
end

function TestShortTextQueryMatcher:TestPartialMatchAtEnd()
	local isMatch = ns.ShortTextQueryMatcher.MatchesQuery("def", "abcef")
	luaunit.assertFalse(isMatch)
end

function TestShortTextQueryMatcher:TestLongerQueryThanText()
	local isMatch = ns.ShortTextQueryMatcher.MatchesQuery("abcdef", "abc")
	luaunit.assertFalse(isMatch)
end

function TestShortTextQueryMatcher:TestShorterQueryThanText()
	local isMatch, ranges = ns.ShortTextQueryMatcher.MatchesQuery("abc", "abcdef")
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
	local isMatch, ranges = ns.ShortTextQueryMatcher.MatchesQuery("abc", "abc")
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

function TestShortTextQueryMatcher:TestChineseCharacters()
	local isMatch, ranges = ns.ShortTextQueryMatcher.MatchesQuery("你好世", "你好，世界！")
	luaunit.assertTrue(isMatch)
	luaunit.assertEquals(ranges, {
		{
			from = 1, to = 6,
		},
		{
			from = 10, to = 12,
		}
	})
end
