---@class ns
local ns = select(2, ...)

---@class UTF8
local UTF8 = {}
ns.UTF8 = UTF8

local stringByte = string.byte
local band, rshift, lshift, bor = bit.band, bit.rshift, bit.lshift, bit.bor
-- Function to convert UTF-8 string to a table of code points
---@param utf8String string
---@return integer[]
function UTF8.ToCodePoints(utf8String)
	local codePoints = {}
	local i = 1
	local stringLength = #utf8String

	while i <= stringLength do
		local byte = stringByte(utf8String, i)

		-- Check for multi-byte characters
		local numBytes = 1
		if byte >= 0xC0 and byte <= 0xFD then
			local mask = 0x40
			local count = 1
			while band(byte, mask) ~= 0 do
				mask = rshift(mask, 1)
				count = count + 1
			end
			numBytes = count
		end

		-- Extract code point from multi-byte character
		local codePoint = band(byte, rshift(0xFF, numBytes))
		for j = 2, numBytes do
			codePoint = bor(codePoint * 64, stringByte(utf8String, i + j - 1) - 0x80)
		end

		codePoints[#codePoints + 1] = codePoint
		i = i + numBytes
	end

	return codePoints
end

---@param codePoints integer[]
---@return string
function UTF8.FromCodePoints(codePoints)
	local utf8Chars = {}

	for _, codePoint in ipairs(codePoints) do
		if codePoint < 0x80 then
			table.insert(utf8Chars, string.char(codePoint))
		elseif codePoint < 0x800 then
			table.insert(utf8Chars, string.char(0xC0 + bit.rshift(codePoint, 6)))
			table.insert(utf8Chars, string.char(0x80 + bit.band(codePoint, 0x3F)))
		elseif codePoint < 0x10000 then
			table.insert(utf8Chars, string.char(0xE0 + bit.rshift(codePoint, 12)))
			table.insert(utf8Chars, string.char(0x80 + bit.band(bit.rshift(codePoint, 6), 0x3F)))
			table.insert(utf8Chars, string.char(0x80 + bit.band(codePoint, 0x3F)))
		elseif codePoint < 0x200000 then
			table.insert(utf8Chars, string.char(0xF0 + bit.rshift(codePoint, 18)))
			table.insert(utf8Chars, string.char(0x80 + bit.band(bit.rshift(codePoint, 12), 0x3F)))
			table.insert(utf8Chars, string.char(0x80 + bit.band(bit.rshift(codePoint, 6), 0x3F)))
			table.insert(utf8Chars, string.char(0x80 + bit.band(codePoint, 0x3F)))
		else
			-- Invalid Unicode code point, skip it
		end
	end

	return table.concat(utf8Chars)
end

---@param codePoint integer
---@return integer
function UTF8.CodePointNumBytes(codePoint)
	if codePoint < 0x80 then
		return 1
	elseif codePoint < 0x800 then
		return 2
	elseif codePoint < 0x10000 then
		return 3
	elseif codePoint < 0x200000 then
		return 4
	end
	error("code point is too big: " .. codePoint)
end
