local luaunit = require("luaunit")
local Util = require("Internal.Util")

TestUtil = {}

function TestUtil:TestStripColorCodes()
	local text = "|cFFFFFFFFTest|r color"
	local noColor = Util.StripColorCodes(text)
	luaunit.assertEquals(noColor, "Test color")
end
