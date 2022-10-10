---@type ns
local ns = select(2, ...)
local luaunit = require("luaunit")

TestUtil = {}

function TestUtil:TestStripColorCodes()
	local text = "|cFFFFFFFFTest|r color"
	local noColor = ns.Util.StripEscapeSequences(text)
	luaunit.assertEquals(noColor, "Test color")
end

function TestUtil:TestBinarySearch()
	local comparitor = function(value)
		if value < 2 then
			return -1
		elseif value > 4 then
			return 1
		else
			return 0
		end
	end
	local array = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
	local first = ns.Util.BinarySearch(array, comparitor, "first")
	local last = ns.Util.BinarySearch(array, comparitor, "last")
	luaunit.assertEquals(first, 2)
	luaunit.assertEquals(last, 4)
end
