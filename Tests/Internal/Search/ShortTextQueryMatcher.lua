---@type ns
local ns = select(2, ...)
local luaunit = require("luaunit")

TestShortTextQueryMatcher = {}

---@param query string
---@param text string
local function matchesQuery(query, text)
	return ns.ShortTextQueryMatcher.MatchesQuery(
		ns.utf8ToCodePoints(query),
		ns.utf8ToCodePoints(text)
	)
end

function TestShortTextQueryMatcher:TestSkippedCharacters()
	local isMatch, ranges = matchesQuery("bcf", "abcdefg")
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
	local isMatch = matchesQuery("abc", "abdefg")
	luaunit.assertFalse(isMatch)
end

function TestShortTextQueryMatcher:TestPartialMatchAtEnd()
	local isMatch = matchesQuery("def", "abcef")
	luaunit.assertFalse(isMatch)
end

function TestShortTextQueryMatcher:TestLongerQueryThanText()
	local isMatch = matchesQuery("abcdef", "abc")
	luaunit.assertFalse(isMatch)
end

function TestShortTextQueryMatcher:TestShorterQueryThanText()
	local isMatch, ranges = matchesQuery("abc", "abcdef")
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
	local isMatch, ranges = matchesQuery("abc", "abc")
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
	local isMatch, ranges = matchesQuery("你好世", "你好，世界！")
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
