---@class ns
local ns = select(2, ...)

---@class UTF8
local UTF8 = {}
ns.UTF8 = UTF8

-- Function to convert UTF-8 string to a table of code points
---@param utf8String string
---@return integer[]
function UTF8.ToCodePoints(utf8String)
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
function UTF8.FromCodePoints(codepoints)
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

-- TODO see if I can find an existing table for case conversions. I only need to cover the languages WoW uses.
---@param codePoints integer[]
---@return integer[]
function UTF8.ToLower(codePoints)
	local newCodePoints = {}
	for i = 1, #codePoints do
		local codePoint = codePoints[i]
		local isEven = codePoint % 2 == 0
		if (codePoint >= 0x41 and codePoint <= 0x5A) or
			(codePoint >= 0xC0 and codePoint <= 0xDE and codePoint ~= 0xD7) then
			-- A-Z, À-Þ except for ×
			codePoint = codePoint + 0x20
		elseif (codePoint >= 0x100 and codePoint <= 0x12F) or
			(codePoint >= 0x132 and codePoint <= 0x137) or
			(codePoint >= 0x14A and codePoint <= 0x177) then
			-- Ā-į, Ĳ-ň, Ŋ-ž
			-- Uppercase letters are even, lower case are the following odd number
			if isEven then
				codePoint = codePoint + 1
			end
		elseif codePoint >= 0x139 and codePoint <= 0x148 then
			if not isEven then
				codePoint = codePoint + 1
			end
		elseif codePoint == 0x178 then
			-- Ÿ
			codePoint = 0xFF
		elseif codePoint >= 0x179 and codePoint <= 0x17E then
			if not isEven then
				codePoint = codePoint + 1
			end
		elseif codePoint >= 0x400 and codePoint <= 0x40F then
			-- Ѐ-Џ
			codePoint = codePoint + 0x50
		elseif codePoint >= 0x410 and codePoint <= 0x42F then
			-- А-Я
			codePoint = codePoint + 0x20
		elseif (codePoint >= 0x460 and codePoint <= 0x481) or
			(codePoint >= 0x48A and codePoint <= 0x4BF) or
			(codePoint >= 0x4D0 and codePoint <= 0x4FF) then
			-- Ѡ-ҁ, Ҋ-ҿ, Ӑ-ӿ
			-- Uppercase letters are even, lower case are the following odd number
			if isEven then
				codePoint = codePoint + 1
			end
		elseif codePoint >= 0x4C1 and codePoint <= 0x4CE then
			-- Ӂ-ӎ
			-- Uppercase letters are odd, lower case are the following even number
			if not isEven then
				codePoint = codePoint + 1
			end
		end
		newCodePoints[i] = codePoint
	end
	return newCodePoints
end
