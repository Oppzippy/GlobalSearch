---@class ns
local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")
local CallbackHandler = LibStub("CallbackHandler-1.0")

---@class SearchUI
---@field callbacks table
local SearchUIPrototype = {
	maxResults = 10,
}

local function CreateSearchUI()
	local searchUI = setmetatable({
		widgets = { results = {} },
		selectedIndex = 1,
	}, { __index = SearchUIPrototype })
	searchUI.callbacks = CallbackHandler:New(searchUI)
	return searchUI
end

function SearchUIPrototype:Show()
	if self.widgets.container then return end

	self.selectedIndex = 1

	local container = AceGUI:Create("SimpleGroup")
	container:SetLayout("List")
	container:SetPoint("TOP", 0, -20)
	container:SetWidth(350)
	container:SetAutoAdjustHeight(true)

	local searchBar = AceGUI:Create("GlobalSearch-SearchBar")
	searchBar:SetCallback("OnClose", function()
		self:Hide()
	end)
	searchBar:SetCallback("OnTextChanged", function()
		self.callbacks:Fire("OnTextChanged", searchBar:GetText())
	end)
	searchBar:SetCallback("OnSelectNextItem", function()
		local newSelectedIndex = self.selectedIndex + 1
		if newSelectedIndex > math.min(#self.widgets.results, self.maxResults) then
			newSelectedIndex = 1
		end
		self:SetSelection(newSelectedIndex)
	end)
	searchBar:SetCallback("OnSelectPreviousItem", function()
		local newSelectedIndex = self.selectedIndex - 1
		if newSelectedIndex < 1 then
			newSelectedIndex = math.min(#self.widgets.results, self.maxResults)
		end
		self:SetSelection(newSelectedIndex)
	end)
	searchBar:SetFullWidth(true)
	searchBar:SetHeight(40)

	local resultsContainer = AceGUI:Create("SimpleGroup")
	resultsContainer:SetLayout("List")
	resultsContainer:SetFullWidth(true)
	resultsContainer:SetAutoAdjustHeight(true)

	container:AddChild(searchBar)
	container:AddChild(resultsContainer)

	-- This container doesn't show itself when acquired,
	-- probably since it's usually used as a child of another container
	---@diagnostic disable-next-line: undefined-field
	container.frame:Show()

	self.widgets.container = container
	self.widgets.searchBar = searchBar
	self.widgets.resultsContainer = resultsContainer
end

function SearchUIPrototype:Hide()
	if self.widgets.container == nil then return end

	self.widgets.container:Release()
	self.widgets = { results = {} }
end

function SearchUIPrototype:IsVisible()
	return self.widgets.container ~= nil
end

function SearchUIPrototype:SetSelection(index)
	local prevSelection = self.widgets.results[self.selectedIndex]
	if prevSelection then
		prevSelection:SetIsSelected(false)
	end

	local newSelection = self.widgets.results[index]
	newSelection:SetIsSelected(true)
	self.selectedIndex = index
	self:FireSelectionChange()
end

function SearchUIPrototype:FireSelectionChange()
	local widget = self.widgets.results[self.selectedIndex]
	local item = widget:GetUserData("item")
	self.callbacks:Fire("OnSelectionChanged", item)
end

function SearchUIPrototype:SetSearchQuery(query)
	self.widgets.searchBar:SetText(query)
end

function SearchUIPrototype:RenderResults(results)
	self.widgets.resultsContainer:ReleaseChildren()
	self.selectedIndex = 1

	self.widgets.results = {}
	self.widgets.resultsContainer:PauseLayout()
	for i, result in ipairs(results) do
		local resultWidget = AceGUI:Create("GlobalSearch-SearchResult")
		resultWidget:SetText(self:HighlightRanges(result.item.name, result.matchRanges))
		resultWidget:SetTexture(result.item.texture)
		resultWidget:SetFullWidth(true)
		resultWidget:SetHeight(40)
		resultWidget:SetUserData("item", result.item)

		if i == self.selectedIndex then
			resultWidget:SetIsSelected(true)
		end

		self.widgets.resultsContainer:AddChild(resultWidget)
		self.widgets.results[i] = resultWidget

		if i >= self.maxResults then break end
	end
	self.widgets.resultsContainer:ResumeLayout()
	self.widgets.resultsContainer:DoLayout()

	self:FireSelectionChange()
end

do
	local color = CreateColor(0.75, 0.75, 0)

	---@param text string
	---@param ranges MatchRange[]
	function SearchUIPrototype:HighlightRanges(text, ranges)
		if #ranges == 0 then
			return text
		end

		---@type string[]
		local newStringTable = {}
		for i, range in ipairs(ranges) do
			if range.from ~= 1 then
				-- add everything between the previous range and this one
				local prevTo = i == 1 and 1 or (ranges[i - 1].to + 1)
				newStringTable[#newStringTable + 1] = text:sub(prevTo, range.from - 1)
			end
			local substring = text:sub(range.from, range.to)
			newStringTable[#newStringTable + 1] = color:WrapTextInColorCode(substring)
		end

		-- the rest outside the last range
		newStringTable[#newStringTable + 1] = text:sub(ranges[#ranges].to + 1, #text)

		return table.concat(newStringTable)
	end
end

local export = { Create = CreateSearchUI }
if ns then
	ns.SearchUI = export
end
return export
