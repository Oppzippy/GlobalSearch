---@class ns
local ns = select(2, ...)

local isPunctuationTable = ns.Unicode.isPunctuationTable
local toLowerTable = ns.Unicode.toLowerTable
local stringByte = string.byte
local band, rshift, bor = bit.band, bit.rshift, bit.bor

---@class FullTextWordIndex
---@field rootNode FullTextWordIndex.Node
local FullTextWordIndexPrototype = {}

---@class FullTextWordIndex.Node
---@field children table<integer, FullTextWordIndex.Node>
---@field values? table<unknown, boolean>

local function CreateFullTextWordIndex()
	local InvertedIndex = setmetatable({
		rootNode = {
		},
	}, { __index = FullTextWordIndexPrototype })
	return InvertedIndex
end

function FullTextWordIndexPrototype:Index() end

---@param wordCodePoints integer[]
---@return unknown[]
function FullTextWordIndexPrototype:SearchWord(wordCodePoints)
	local node = self.rootNode
	for i = 1, #wordCodePoints do
		local codePoint = wordCodePoints[i]
		node = node[codePoint]
		if not node then
			break
		end
	end
	return self:GetNodeValues(node) or {}
end

---@param parentNode FullTextWordIndex.Node
---@return table<unknown, boolean>
function FullTextWordIndexPrototype:GetNodeValues(parentNode)
	local nodes = { parentNode }
	local values = {}
	repeat
		local childNodes = {}
		for _, node in next, nodes do
			for key, childNode in next, node do
				if key ~= "values" then
					childNodes[#childNodes + 1] = childNode
				end
			end
			if node.values then
				for value in next, node.values do
					values[value] = true
				end
			end
		end
		nodes = childNodes
	until childNodes[1] == nil
	return values
end

-- Pre-compute the number of bytes in the character based on the character's first byte
local precomputedNumBytes = {}
for byte = 0, 255 do
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
	precomputedNumBytes[byte] = numBytes
end


-- Pre-compute initial value of codePoint for every possible first byte/number of bytes combination
local precomputedCodePointsForFirstByte = {}
for numBytes = 1, 4 do
	for byte = 0, 255 do
		precomputedCodePointsForFirstByte[byte + (256 * numBytes)] = band(byte, rshift(0xFF, numBytes))
	end
end

--- This function is a hot spot, so it must be very optimized. For this reason, it calls no other functions
--- (they were all inlined), and data is precomputed when practical.
---@param value unknown
---@param text string
function FullTextWordIndexPrototype:AddString(value, text)
	local i = 1
	local stringLength = #text
	local rootNode = self.rootNode
	local node = rootNode

	while i <= stringLength do
		local byte = stringByte(text, i)

		-- Check for multi-byte characters
		local numBytes = precomputedNumBytes[byte]

		-- A table lookup a lot faster than calculating the value here using bit.band and bit.rshift
		local codePoint = precomputedCodePointsForFirstByte[byte + (256 * numBytes)]
		for j = 2, numBytes do
			-- Multiply by 64 since it's faster than lshift(..., 6)
			-- subtract 0x80 to remove the leading 1 bit (0b10xxxxxx) since it's faster than bit.band(..., 0x3F)
			codePoint = bor(codePoint * 64, stringByte(text, i + j - 1) - 0x80)
		end

		if codePoint >= 0x4E00 and codePoint <= 0x9FFF then -- chinese characters are treated as words
			-- add current word
			if node ~= rootNode then
				node.values = node.values or {}
				node.values[value] = true
				node = rootNode
			end
			-- add chinese character
			if not rootNode[codePoint] then
				rootNode[codePoint] = { values = {} }
			end
			rootNode[codePoint].values[value] = true
		elseif codePoint ~= 0x2D and codePoint ~= 0x20 then -- Not a word boundary (hyphen/space)
			if not isPunctuationTable[codePoint] then -- ignore punctuation
				codePoint = toLowerTable[codePoint] or codePoint

				if not node[codePoint] then
					node[codePoint] = {}
				end
				node = node[codePoint]
			end
		elseif node ~= rootNode then -- we hit a word boundary, make sure the current word is not empty
			node.values = node.values or {}
			node.values[value] = true
			node = rootNode
		end
		i = i + numBytes
	end
	if node ~= rootNode then
		-- node does not have a chlidren table to avoid the extra allocation. children go directly in node, which means
		-- the keys of node are a bunch of integers, plus one string key, "values"
		node.values = node.values or {}
		node.values[value] = true
	end
end

---@param query string
---@return table<unknown, number> weightedResults
function FullTextWordIndexPrototype:Search(query)
	local queryCodePoints = ns.UTF8.ToCodePoints(query)
	local weightedWords = self:WeightWords(queryCodePoints)

	local weightedResults = {}
	for word, weight in next, weightedWords do
		local values = self:SearchWord(word)
		for value in next, values do
			weightedResults[value] = (weightedResults[value] or 0) + weight
		end
	end

	return weightedResults
end

---@param queryCodePoints integer[]
---@return table<table, number>
function FullTextWordIndexPrototype:WeightWords(queryCodePoints)
	-- TODO optimize?
	local weightedWords = {}
	for wordCodePoints in self:IterateWords(queryCodePoints) do
		local word = ns.UTF8.FromCodePoints(wordCodePoints)
		-- to string for uniqueness
		weightedWords[word] = (weightedWords[word] or 0) + 1
	end

	local t = {}
	for k, v in next, weightedWords do
		t[ns.UTF8.ToCodePoints(k)] = v
	end

	return t
end

do
	---@param codePoints integer[]
	---@return fun(): integer[]
	function FullTextWordIndexPrototype:IterateWords(codePoints)
		return coroutine.wrap(function()
			local word = {}
			for i = 1, #codePoints do
				local codePoint = ns.Unicode.CharToLower(codePoints[i])
				if ns.Unicode.IsCJKIdeograph(codePoint) then
					if #word ~= 0 then
						coroutine.yield(word)
						word = {}
					end
					coroutine.yield({ codePoint })
				elseif codePoint == 0x2D or ns.Unicode.IsBlankSpace(codePoint) then -- hyphen or space
					if #word ~= 0 then
						coroutine.yield(word)
						word = {}
					end
				elseif not ns.Unicode.IsPunctuation(codePoint) then
					word[#word + 1] = codePoint
				end
			end
			if #word ~= 0 then
				coroutine.yield(word)
			end
		end)
	end
end

local export = { Create = CreateFullTextWordIndex }
if ns then
	ns.FullTextWordIndex = export
end
return export
