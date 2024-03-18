---@class ns
local ns = select(2, ...)

-- Function to convert UTF-8 string to a table of code points
---@param utf8String string
---@return integer[]
function ns.utf8ToCodePoints(utf8String)
	local codepoints = {}
	local i = 1

	while i <= #utf8String do
		local byte = string.byte(utf8String, i)

		-- Check for multi-byte characters
		local num_bytes = 1
		if byte >= 0xC0 and byte <= 0xFD then
			local mask = 0x40
			local count = 1
			while bit.band(byte, mask) ~= 0 do
				mask = bit.rshift(mask, 1)
				count = count + 1
			end
			num_bytes = count
		end

		-- Extract code point from multi-byte character
		local code_point = bit.band(byte, bit.rshift(0xFF, num_bytes))
		for j = 2, num_bytes do
			code_point = bit.bor(bit.lshift(code_point, 6), bit.band(string.byte(utf8String, i + j - 1), 0x3F))
		end

		table.insert(codepoints, code_point)
		i = i + num_bytes
	end

	return codepoints
end

---@param codepoints integer[]
---@return string
function ns.codePointsToUtf8(codepoints)
	local utf8_chars = {}

	for _, code_point in ipairs(codepoints) do
		if code_point < 0x80 then
			table.insert(utf8_chars, string.char(code_point))
		elseif code_point < 0x800 then
			table.insert(utf8_chars, string.char(0xC0 + bit.rshift(code_point, 6)))
			table.insert(utf8_chars, string.char(0x80 + bit.band(code_point, 0x3F)))
		elseif code_point < 0x10000 then
			table.insert(utf8_chars, string.char(0xE0 + bit.rshift(code_point, 12)))
			table.insert(utf8_chars, string.char(0x80 + bit.band(bit.rshift(code_point, 6), 0x3F)))
			table.insert(utf8_chars, string.char(0x80 + bit.band(code_point, 0x3F)))
		elseif code_point < 0x200000 then
			table.insert(utf8_chars, string.char(0xF0 + bit.rshift(code_point, 18)))
			table.insert(utf8_chars, string.char(0x80 + bit.band(bit.rshift(code_point, 12), 0x3F)))
			table.insert(utf8_chars, string.char(0x80 + bit.band(bit.rshift(code_point, 6), 0x3F)))
			table.insert(utf8_chars, string.char(0x80 + bit.band(code_point, 0x3F)))
		else
			-- Invalid Unicode code point, skip it
		end
	end

	return table.concat(utf8_chars)
end
