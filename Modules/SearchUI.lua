---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local addon = AceAddon:GetAddon("GlobalSearch")
---@class SearchUI
local module = addon:NewModule("SearchUI")

---@type table<string, AceGUIWidget|AceGUIContainer>
module.widgets = {}
module.searchQuery = ""

function module:OnInitialize()
end

function module:Show()
	if self.widgets.container then return end

	local container = AceGUI:Create("SimpleGroup")
	container:SetLayout("List")
	container:SetPoint("TOP", 0, -20)
	container:SetWidth(350)
	container:SetAutoAdjustHeight(true)

	local searchBar = AceGUI:Create("GlobalSearch-SearchBar")
	searchBar:SetCallback("OnClose", function()
		self.searchQuery = ""
		self:Hide()
	end)
	searchBar:SetCallback("OnTextChanged", function()
		self:Search(searchBar:GetText())
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

	self.searchContext = ns.SearchContext.Create(ns.SearchItemProvider.GetItems())
	searchBar:SetText(self.searchQuery)
	self:Search(self.searchQuery)
end

function module:Hide()
	if self.widgets.container == nil then return end

	self.widgets.container:Release()
	self.widgets = {}
	self.searchContext = nil
end

function module:IsVisible()
	return self.widgets.container ~= nil
end

function module:Search(query)
	self.searchQuery = query
	local results = self.searchContext:Search(query)
	self.widgets.resultsContainer:ReleaseChildren()

	self.widgets.resultsContainer:PauseLayout()
	for i, result in ipairs(results) do
		local resultWidget = AceGUI:Create("GlobalSearch-SearchResult")
		resultWidget:SetText(self:HighlightRanges(result.item.name, result.matchRanges))
		resultWidget:SetTexture(result.item.texture)
		resultWidget:SetFullWidth(true)
		resultWidget:SetHeight(40)
		self.widgets.resultsContainer:AddChild(resultWidget)

		if i > 10 then break end
	end
	self.widgets.resultsContainer:ResumeLayout()
	self.widgets.resultsContainer:DoLayout()
end

do
	local color = CreateColor(0.75, 0.75, 0)

	---@param text string
	---@param ranges MatchRange[]
	function module:HighlightRanges(text, ranges)
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
