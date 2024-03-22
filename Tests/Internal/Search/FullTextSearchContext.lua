---@type ns
local ns = select(2, ...)
local luaunit = require("luaunit")

TestFullTextSearchContext = {}
--
---@param results SearchContextItem[]
---@param itemName string
---@return SearchContextItem
local function getResultByItemName(results, itemName)
	for _, result in next, results do
		if result.item.name == itemName then
			return result
		end
	end
	error("item not found")
end

function TestFullTextSearchContext:TestCaseInsensitivity()
	local items = {
		{
			name = "aB",
			category = "",
		},
	}
	local context = ns.FullTextSearchContext.CreateAsync(items):PollToCompletion()
	local results = context:Search("Ab")
	luaunit.assertEquals(#results, 1)
end

function TestFullTextSearchContext:TestStartsWith()
	local items = {
		{
			name = "a",
			category = "",
		},
		{
			name = "ab",
			category = "",
		},
		{
			name = "abc",
			category = "",
		},
	}
	local context = ns.FullTextSearchContext.CreateAsync(items):PollToCompletion()
	local results = context:Search("ab")
	luaunit.assertEquals(#results, 2)
	getResultByItemName(results, "ab")
	getResultByItemName(results, "abc")
end

function TestFullTextSearchContext:TestIncludesExtraText()
	local items = {
		{
			name = "abc",
			category = "",
			extraSearchText = "def",
		},
	}
	local context = ns.FullTextSearchContext.CreateAsync(items):PollToCompletion()
	local nameResults = context:Search("abc")
	luaunit.assertEquals(#nameResults, 1)
	local extraTextResults = context:Search("def")
	luaunit.assertEquals(#extraTextResults, 1)
end

function TestFullTextSearchContext:TestScoreIgnoresNumOccurrencesInExtraSearchText()
	local items = {
		{
			name = "abc",
			category = "",
			extraSearchText = "abc abc abc abc abc abc", -- should not count more
		},
		{
			name = "def", -- will score higher since def will count as a second match
			category = "",
			extraSearchText = "abc",
		}
	}
	local context = ns.FullTextSearchContext.CreateAsync(items):PollToCompletion()
	local results = context:Search("abc def")
	luaunit.assertTrue(getResultByItemName(results, "abc").score < getResultByItemName(results, "def").score)
end

function TestFullTextSearchContext:TestScoring()
	local items = {
		{
			name = "abc",
			category = "",
		},
		{
			name = "def", -- will score higher since def will count as a second match
			category = "",
		}
	}
	local context = ns.FullTextSearchContext.CreateAsync(items):PollToCompletion()
	local results = context:Search("abc def def")
	luaunit.assertTrue(getResultByItemName(results, "abc").score < getResultByItemName(results, "def").score)
end

function TestFullTextSearchContext:TestChineseCharacters()
	local items = {
		{
			name = "以下是中文的虚拟文本",
			category = "",
			extraSearchText = "春江花月夜，风软草微长。 青山朝野间，白鸟啼声响。 水流悠悠去，天高云影凉。 人生如梦境，岁月匆匆忙。k山水皆有情，世界何尽荒。 行者止思远，归来仍家乡。",
		},
	}
	local context = ns.FullTextSearchContext.CreateAsync(items):PollToCompletion()
	local results = context:Search("拟本是下的文中文虚以") -- messed around with the order, since it should not matter
	luaunit.assertEquals(#results, 1)
end
