---@class ns
local ns = select(2, ...)

---@class FullTextWordIndex
---@field rootNode FullTextWordIndex.Node
local FullTextWordIndexPrototype = {}

---@class FullTextWordIndex.Node
---@field children table<integer, FullTextWordIndex.Node>
---@field values? table<unknown, boolean>

local function CreateFullTextWordIndex()
	local InvertedIndex = setmetatable({
		rootNode = {
			children = {},
		},
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
	for _, word in next, words do
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

	local weightedResults = {}
	for _, word in ipairs(words) do
		local values = self:SearchWord(word)
		local seenValues = {}
		for _, value in next, values do
			if not seenValues[value] then
				seenValues[value] = true
				weightedResults[value] = (weightedResults[value] or 0) + 1
			end
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

---@param word string
---@return unknown[]
function FullTextWordIndexPrototype:SearchWord(word)
	local node = self.rootNode
	for i = 1, #word do
		local byte = word:byte(i)
		node = node.children[byte]
		if not node then
			break
		end
	end
	return node and self:GetNodeValues(node) or {}
end

---@param parentNode FullTextWordIndex.Node
---@return unknown[]
function FullTextWordIndexPrototype:GetNodeValues(parentNode)
	local nodes = { parentNode }
	local valueTable = {}
	repeat
		local childNodes = {}
		for _, node in next, nodes do
			for _, childNode in next, node.children do
				childNodes[#childNodes + 1] = childNode
			end
			if node.values then
				for value in next, node.values do
					valueTable[#valueTable + 1] = value
				end
			end
		end
		nodes = childNodes
	until childNodes[1] == nil
	return valueTable
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
