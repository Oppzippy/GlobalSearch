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

	local searchBar = AceGUI:Create("GlobalSearch-SearchBar")
	searchBar:SetText(self.searchQuery)
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
	resultsContainer:SetHeight(40)

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

function module:Hide()
	if self.widgets.container == nil then return end

	self.widgets.container:Release()
	self.widgets = {}
end

function module:IsVisible()
	return self.widgets.container ~= nil
end

function module:Search(query)
	self.searchQuery = query
end
