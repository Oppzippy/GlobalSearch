---@class ns
local ns = select(2, ...)

---@class FullTextWordIndex
---@field rootNode FullTextWordIndex.Node
---@field wordResultCache table<string, unknown>
local FullTextWordIndexPrototype = {}

---@class FullTextWordIndex.Node
---@field children table<integer, FullTextWordIndex.Node>
---@field values? table<unknown, boolean>

local function CreateFullTextWordIndex()
	local InvertedIndex = setmetatable({
		rootNode = {
			children = {},
		},
		wordResultCache = {},
	}, { __index = FullTextWordIndexPrototype })
	return InvertedIndex
end

---@param value unknown
---@param string string
function FullTextWordIndexPrototype:AddString(value, string)
	self:AddWords(value, { strsplit(" ", self:Normalize(string)) })
end

---@param value unknown
---@param words string[]
function FullTextWordIndexPrototype:AddWords(value, words)
	local wordSet = ns.Util.ListToSet(words)
	for word in next, wordSet do
		self:AddWord(value, word)
	end
end

---@param value unknown
---@param word string
function FullTextWordIndexPrototype:AddWord(value, word)
	local node = self.rootNode
	for i = 1, #word do
		local byte = word:byte(i)
		if not node.children[byte] then
			node.children[byte] = {
				children = {},
			}
		end
		node = node.children[byte]
	end
	if not node.values then
		node.values = {}
	end
	node.values[value] = true
end

---@param query string
---@return unknown[]
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

	local results = {}
	for value in next, weightedResults do
		results[#results + 1] = value
	end

	table.sort(results, function(a, b)
		return weightedResults[a] > weightedResults[b]
	end)
	return results
end

function FullTextWordIndexPrototype:WeightWords(words)
	local weightedWords = {}
	for _, word in next, words do
		weightedWords[word] = (weightedWords[word] or 0) + 1
	end
	return weightedWords
end

---@param word string
---@return unknown[]
function FullTextWordIndexPrototype:SearchWord(word)
	if not self.wordResultCache[word] then
		local node = self.rootNode
		for i = 1, #word do
			local byte = word:byte(i)
			node = node.children[byte]
			if not node then
				break
			end
		end
		self.wordResultCache[word] = node and self:GetNodeValues(node) or {}
	end
	return self.wordResultCache[word]
end

---@param parentNode FullTextWordIndex.Node
---@return table<unknown, boolean>
function FullTextWordIndexPrototype:GetNodeValues(parentNode)
	local nodes = { parentNode }
	local values = {}
	repeat
		local childNodes = {}
		for _, node in next, nodes do
			for _, childNode in next, node.children do
				childNodes[#childNodes + 1] = childNode
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

---@param text string
---@return string
function FullTextWordIndexPrototype:Normalize(text)
	-- All punctuation should be removed except hyphens. Those should be replaced with spaces.
	text = text:gsub("-", " ")
	text = text:gsub("%p", "")
	text = text:lower()
	return text
end

local export = { Create = CreateFullTextWordIndex }
if ns then
	ns.FullTextWordIndex = export
end
return export
