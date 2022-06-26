---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")

local addon = AceAddon:GetAddon("GlobalSearch")
---@class SearchModule
local module = addon:NewModule("Search")

function module:OnInitialize()
	self.searchQuery = ""
	self.selectedIndex = 1
	self.maxResults = 10
	self.searchUI = ns.SearchUI.Create()
	self.searchContext = ns.SearchContext.Create(ns.GetSearchItems())

	self.searchUI.RegisterCallback(self, "OnTextChanged")
	self.searchUI.RegisterCallback(self, "OnItemChosen")
end

function module:Show()
	if self:IsVisible() then return end

	self.searchContext = ns.SearchContext.Create(ns.GetSearchItems())
	self.searchUI:Show()
end

function module:Hide()
	if not self:IsVisible() then return end

	self.searchContext = nil
	self.searchUI:SetSearchQuery("")
	self.searchUI:Hide()
end

function module:IsVisible()
	return self.searchUI:IsVisible()
end

function module:OnTextChanged(_, text)
	self:Search(text)
end

---@param _ any
---@param item SearchItem
function module:OnItemChosen(_, item)
	if item.action then
		item.action()
	end
end

function module:Search(query)
	local prevSelection = self.results and self.results[self.selectedIndex] or nil

	self.searchQuery = query
	local results = self.searchContext:Search(query)
	self.results = results

	local newSelectedIndex = 1
	for i, result in ipairs(results) do
		if prevSelection ~= nil and result.item == prevSelection.item then
			newSelectedIndex = i
			break
		end
		if i >= self.maxResults then break end
	end
	self.selectedIndex = newSelectedIndex

	self.searchUI:Show()
	self.searchUI:RenderResults(results)
end
