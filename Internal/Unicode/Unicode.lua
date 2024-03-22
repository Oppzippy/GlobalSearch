---@class ns
local ns = select(2, ...)

---@class Unicode
local Unicode = ns.Unicode or {}
ns.Unicode = Unicode

do
	local function add(amount)
		return function(codePoint)
			return codePoint + amount
		end
	end

	local function exactly(codePoint)
		return function()
			return codePoint
		end
	end

	local add1 = add(1)
	local add32 = add(32)

	-- TODO see if I can find an existing table for case conversions. I only need to cover the languages WoW uses.
	local mapToLowercase, mapToUppercase = ns.Unicode.CreateBidirectionalMatcherTable({
		-- A-Z
		{ from = 0x41,  to = 0x5A,  map = add32 },
		-- À-Þ except for ×
		{ from = 0xC0,  to = 0xDE,  except = { 0xD7 },           map = add32 },
		-- Ā-į
		{ from = 0x100, to = 0x12F, evenOddFilter = "evensOnly", map = add1 },
		-- Ĳ-ň
		{ from = 0x132, to = 0x137, evenOddFilter = "evensOnly", map = add1 },
		-- Ŋ-ž
		{ from = 0x14A, to = 0x177, evenOddFilter = "evensOnly", map = add1 },
		-- Ĺ-ň
		{ from = 0x139, to = 0x148, evenOddFilter = "oddsOnly",  map = add1 },
		-- Ÿ
		{ from = 0x178, to = 0x178, map = exactly(0xFF) },
		-- Ź-ž
		{ from = 0x179, to = 0x17E, evenOddFilter = "oddsOnly",  map = add1 },
		-- Ѐ-Џ
		{ from = 0x400, to = 0x40F, map = add(0x50) },
		-- А-Я
		{ from = 0x410, to = 0x42F, map = add32 },
		-- Ѡ-ҁ
		{ from = 0x460, to = 0x481, evenOddFilter = "evensOnly", map = add1 },
		-- Ҋ-ҿ
		{ from = 0x48A, to = 0x4BF, evenOddFilter = "evensOnly", map = add1 },
		-- Ӑ-ӿ
		{ from = 0x4D0, to = 0x4FF, evenOddFilter = "evensOnly", map = add1 },
		-- Ӂ-ӎ
		{ from = 0x4C1, to = 0x4CE, evenOddFilter = "oddsOnly",  map = add1 },
	})

	---@param codePoints integer[]
	---@return integer[]
	function Unicode.ToLower(codePoints)
		local newCodePoints = {}
		for i = 1, #codePoints do
			local codePoint = codePoints[i]
			newCodePoints[i] = mapToLowercase(codePoint) or codePoint
		end
		return newCodePoints
	end

	--
	---@param codePoints integer[]
	---@return integer[]
	function Unicode.ToUpper(codePoints)
		local newCodePoints = {}
		for i = 1, #codePoints do
			local codePoint = codePoints[i]
			newCodePoints[i] = mapToUppercase(codePoint) or codePoint
		end
		return newCodePoints
	end

	---@param codePoint integer
	---@return integer
	function Unicode.CharToUpper(codePoint)
		return mapToUppercase(codePoint)
	end
end
