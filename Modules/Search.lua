---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")

local addon = AceAddon:GetAddon("GlobalSearch")
---@class SearchModule
local module = addon:NewModule("Search", "AceEvent-3.0")
local searchExecute = CreateFrame("Button", "GlobalSearchExecute", UIParent, "InsecureActionButtonTemplate")
searchExecute:RegisterForClicks("AnyDown")

function module:OnInitialize()
	self.searchQuery = ""
	self.selectedIndex = 1
	self.maxResults = 10
	self.searchUI = ns.SearchUI.Create()
	self.searchContext = ns.SearchContext.Create(ns.GetSearchItems())

	self.searchUI.RegisterCallback(self, "OnTextChanged")
	self.searchUI.RegisterCallback(self, "OnSelectionChanged")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "Hide")
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
	ClearOverrideBindings(searchExecute)
end

function module:IsVisible()
	return self.searchUI:IsVisible()
end

function module:OnTextChanged(_, text)
	self:Search(text)
end

---@param _ any
---@param item SearchItem
function module:OnSelectionChanged(_, item)
	ClearOverrideBindings(searchExecute)

	searchExecute:SetAttribute("type", "macro")
	local macro = {
		[[/run LibStub("AceAddon-3.0"):GetAddon("GlobalSearch"):GetModule("Search"):Hide()]],
	}
	if item.action then
		macro[#macro + 1] = [[/run LibStub("AceAddon-3.0"):GetAddon("GlobalSearch"):GetModule("Search").selectedAction()]]
		self.selectedAction = item.action
	elseif item.spellId then
		local name = GetSpellInfo(item.spellId)
		macro[#macro + 1] = "/cast " .. name
	else
		print("no action set")
		return
	end
	searchExecute:SetAttribute("macrotext", table.concat(macro, "\n"))

	SetOverrideBindingClick(searchExecute, true, "ENTER", "GlobalSearchExecute")
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
