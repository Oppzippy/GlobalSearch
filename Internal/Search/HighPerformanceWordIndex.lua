---@class ns
local ns = select(2, ...)

---@class HighPerformanceWordIndex
---@field words string[]
---@field wordValues table<string, unknown>
local HighPerformanceWordIndexPrototype = {}

---@class HighPerformanceWordIndex.Node
---@field children table<integer, HighPerformanceWordIndex.Node>
---@field values? table<unknown, boolean>

local function CreateHighPerformanceWordIndex()
	local InvertedIndex = setmetatable({
		words = {},
		wordValues = {},
	}, { __index = HighPerformanceWordIndexPrototype })
	return InvertedIndex
end

---@param value unknown
---@param text string
function HighPerformanceWordIndexPrototype:AddString(value, text)
	local normalized = self:Normalize(text)
	for word in normalized:gmatch("([^ ]+)") do
		if not self.wordValues[word] then
			self.wordValues[word] = {}
			local words = self.words
			words[#words + 1] = word
		end
		local values = self.wordValues[word]
		values[#values + 1] = value
	end
end

function HighPerformanceWordIndexPrototype:Index()
	table.sort(self.words)
end

---@param query string
---@return fun(): unknown
function HighPerformanceWordIndexPrototype:Search(query)
	local words = { strsplit(" ", self:Normalize(query)) }
	local weightedWords = self:WeightWords(words)

	local seen = {}
	return coroutine.wrap(function()
		for word, weight in next, weightedWords do
			local values = self:SearchWord(word)
			for value in values do
				if not seen[value] then
					seen[value] = true
					coroutine.yield(value)
				end
			end
		end
	end)
end

function HighPerformanceWordIndexPrototype:WeightWords(words)
	local weightedWords = {}
	for _, word in next, words do
		weightedWords[word] = (weightedWords[word] or 0) + 1
	end
	return weightedWords
end

---@param word string
---@return fun(): unknown
function HighPerformanceWordIndexPrototype:SearchWord(word)
	local function comparator(value)
		if value:find(word, nil, true) == 1 then
			return 0
		elseif value < word then
			return -1
		elseif value > word then
			return 1
		end
	end

	local first = ns.Util.BinarySearch(self.words, comparator, "first")
	local last = ns.Util.BinarySearch(self.words, comparator, "last")

	if not first or not last then
		return function() end
	end

	return coroutine.wrap(function()
		local seen = {}
		for i = first, last do
			local values = self.wordValues[self.words[i]]
			for j = 1, #values do
				if not seen[values[j]] then
					seen[values[j]] = true
					coroutine.yield(values[j])
				end
			end
		end
	end)
end

do
	-- Keep an eye on this as it could get big
	local cache = {}
	---@param text string
	---@return string
	function HighPerformanceWordIndexPrototype:Normalize(text)
		if cache[text] then return cache[text] end
		-- All punctuation should be removed except hyphens. Those should be replaced with spaces.
		local normalized = text
			:gsub("-", " ")
			:gsub("%p", "")
			:lower()
		cache[text] = normalized
		return normalized
	end
end

local export = { Create = CreateHighPerformanceWordIndex }
if ns then
	ns.HighPerformanceWordIndex = export
end
return export
