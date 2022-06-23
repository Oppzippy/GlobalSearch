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
	if self.widgets.container ~= nil then return end

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
		resultWidget:SetText(result.name)
		resultWidget:SetTexture(result.texture)
		resultWidget:SetFullWidth(true)
		resultWidget:SetHeight(40)
		self.widgets.resultsContainer:AddChild(resultWidget)

		if i > 10 then break end
	end
	self.widgets.resultsContainer:ResumeLayout()
	self.widgets.resultsContainer:DoLayout()
end
