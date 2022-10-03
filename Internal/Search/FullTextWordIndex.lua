---@class ns
local ns = select(2, ...)

---@class FullTextWordIndex
---@field words string[]
---@field wordValues table<string, unknown>
local FullTextWordIndexPrototype = {}

---@class FullTextWordIndex.Node
---@field children table<integer, FullTextWordIndex.Node>
---@field values? table<unknown, boolean>

local function CreateFullTextWordIndex()
	local InvertedIndex = setmetatable({
		words = {},
		wordValues = {},
	}, { __index = FullTextWordIndexPrototype })
	return InvertedIndex
end

---@param value unknown
---@param text string
function FullTextWordIndexPrototype:AddString(value, text)
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

function FullTextWordIndexPrototype:Index()
	table.sort(self.words)
end

---@param query string
---@return table<unknown, number> weightedResults
function FullTextWordIndexPrototype:Search(query)
	local words = { strsplit(" ", self:Normalize(query)) }
	local weightedWords = self:WeightWords(words)

	local weightedResults = {}
	for word, weight in next, weightedWords do
		local values = self:SearchWord(word)
		for value in next, values do
			weightedResults[value] = (weightedResults[value] or 0) + weight
		end
	end

	return weightedResults
end

function FullTextWordIndexPrototype:WeightWords(words)
	local weightedWords = {}
	for _, word in next, words do
		weightedWords[word] = (weightedWords[word] or 0) + 1
	end
	return weightedWords
end

---@param word string
---@return table<unknown, boolean>
function FullTextWordIndexPrototype:SearchWord(word)
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
		return {}
	end

	local resultsSet = {}
	for i = first, last do
		local values = self.wordValues[self.words[i]]
		for j = 1, #values do
			resultsSet[values[j]] = true
		end
	end
	return resultsSet
end

do
	-- Keep an eye on this as it could get big
	local cache = {}
	---@param text string
	---@return string
	function FullTextWordIndexPrototype:Normalize(text)
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

local export = { Create = CreateFullTextWordIndex }
if ns then
	ns.FullTextWordIndex = export
end
return export
