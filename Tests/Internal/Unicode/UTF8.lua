---@type ns
local ns = select(2, ...)
local luaunit = require("luaunit")
local UTF8 = ns.UTF8

TestUTF8 = {}

function TestUTF8:TestAsciiCharactersToCodePoints()
	local input = "Hello, World!"
	local expected = {
		0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x21
	}
	luaunit.assertEquals(UTF8.ToCodePoints(input), expected)
end

function TestUTF8:TestMixedAsciiAndNonAsciiCharactersToCodePoints()
	local input = "Hello, 世界！"
	local expected = {
		0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x4e16, 0x754c, 0xff01
	}
	luaunit.assertEquals(UTF8.ToCodePoints(input), expected)
end

function TestUTF8:TestToCodePointsAndBack()
	local expected = "Hello, 世界！"
	local actual = UTF8.FromCodePoints(UTF8.ToCodePoints(expected))
	luaunit.assertEquals(actual, expected)
end

function TestUTF8:TestCyrillicToLowerCase()
	local input = UTF8.ToCodePoints("АБВГЁ")
	local expected_output = UTF8.ToCodePoints("абвгё")
	local output = UTF8.ToLower(input)
	luaunit.assertItemsEquals(expected_output, output)
end

function TestUTF8:testSpanishCharactersToLower()
	local input = UTF8.ToCodePoints("ÁÉÍÓÚÑ")
	local expected = UTF8.ToCodePoints("áéíóúñ")
	local result = UTF8.ToLower(input)
	luaunit.assertEquals(result, expected)
end

function TestUTF8:testFrenchCharactersToLower()
	local input = UTF8.ToCodePoints("ÀÂÆÇÉÈÊËÎÏÔŒÙÛÜŸ")
	local expected = UTF8.ToCodePoints("àâæçéèêëîïôœùûüÿ")
	local result = UTF8.ToLower(input)
	luaunit.assertEquals(result, expected)
end

function TestUTF8:testGermanCharactersToLower()
	local input = UTF8.ToCodePoints("ÄÖÜß")
	local expected = UTF8.ToCodePoints("äöüß")
	local result = UTF8.ToLower(input)
	luaunit.assertEquals(result, expected)
end

function TestUTF8:TestToLower()
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
		local input = UTF8.ToCodePoints(testCase.input)
		local expected = UTF8.ToCodePoints(testCase.expected)
		local actual = UTF8.ToLower(input)
		luaunit.assertEquals(actual, expected, testCase.name)
	end
end
