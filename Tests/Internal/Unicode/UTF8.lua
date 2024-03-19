---@type ns
local ns = select(2, ...)
local luaunit = require("luaunit")

TestUtf8 = {}

function TestUtf8:TestAsciiCharactersToCodePoints()
	local input = "Hello, World!"
	local expected = {
		0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x21
	}
	luaunit.assertEquals(ns.utf8ToCodePoints(input), expected)
end

function TestUtf8:TestMixedAsciiAndNonAsciiCharactersToCodePoints()
	local input = "Hello, 世界！"
	local expected = {
		0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x4e16, 0x754c, 0xff01
	}
	luaunit.assertEquals(ns.utf8ToCodePoints(input), expected)
end

function TestUtf8:TestToCodePointsAndBack()
	local expected = "Hello, 世界！"
	local actual = ns.codePointsToUtf8(ns.utf8ToCodePoints(expected))
	luaunit.assertEquals(actual, expected)
end

function TestUtf8:TestCyrillicToLowerCase()
	local input = ns.utf8ToCodePoints("АБВГЁ")
	local expected_output = ns.utf8ToCodePoints("абвгё")
	local output = ns.utf8ToLower(input)
	luaunit.assertItemsEquals(expected_output, output)
end

function TestUtf8:testSpanishCharactersToLower()
	local input = ns.utf8ToCodePoints("ÁÉÍÓÚÑ")
	local expected = ns.utf8ToCodePoints("áéíóúñ")
	local result = ns.utf8ToLower(input)
	luaunit.assertEquals(result, expected)
end

function TestUtf8:testFrenchCharactersToLower()
	local input = ns.utf8ToCodePoints("ÀÂÆÇÉÈÊËÎÏÔŒÙÛÜŸ")
	local expected = ns.utf8ToCodePoints("àâæçéèêëîïôœùûüÿ")
	local result = ns.utf8ToLower(input)
	luaunit.assertEquals(result, expected)
end

function TestUtf8:testGermanCharactersToLower()
	local input = ns.utf8ToCodePoints("ÄÖÜß")
	local expected = ns.utf8ToCodePoints("äöüß")
	local result = ns.utf8ToLower(input)
	luaunit.assertEquals(result, expected)
end

function TestUtf8:TestToLower()
	local testCases = {
		{
			name = "Latin-1 Supplement",
			input = "ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞß",
			expected = "àáâãäåæçèéêëìíîïðñòóôõö×øùúûüýþß"
		},
		{
			name = "Latin Extended A",
			input =
			"ĀĂĄĆĈĊČĎĐĒĔĖĘĚĜĞĠĢĤĦĨĪĬĮİĲĴĶĹĻĽĿŁŃŅŇŊŌŎŐŒŔŖŘŚŜŞŠŢŤŦŨŪŬŮŰŲŴŶŸŹŻŽ",
			expected =
			"āăąćĉċčďđēĕėęěĝğġģĥħĩīĭįİĳĵķĺļľŀłńņňŋōŏőœŕŗřśŝşšţťŧũūŭůűųŵŷÿźżž",
		}
	}
	for _, testCase in ipairs(testCases) do
		local input = ns.utf8ToCodePoints(testCase.input)
		local expected = ns.utf8ToCodePoints(testCase.expected)
		local actual = ns.utf8ToLower(input)
		luaunit.assertEquals(actual, expected, testCase.name)
	end
end
