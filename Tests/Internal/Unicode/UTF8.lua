---@type ns
local ns = select(2, ...)
local luaunit = require("luaunit")

TestUtf8 = {}

function TestUtf8:testAsciiCharactersToCodePoints()
	local input = "Hello, World!"
	local expected = {
		0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x21
	}
	luaunit.assertEquals(ns.utf8ToCodePoints(input), expected)
end

function TestUtf8:testMixedAsciiAndNonAsciiCharactersToCodePoints()
	local input = "Hello, 世界！"
	local expected = {
		0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x4e16, 0x754c, 0xff01
	}
	luaunit.assertEquals(ns.utf8ToCodePoints(input), expected)
end

function TestUtf8:testToCodePointsAndBack()
	local expected = "Hello, 世界！"
	local actual = ns.codePointsToUtf8(ns.utf8ToCodePoints(expected))
	luaunit.assertEquals(actual, expected)
end
