---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")

local addon = AceAddon:GetAddon("GlobalSearch")
---@class SearchModule : AceConsole-3.0
---@field RegisterEvent function
local module = addon:NewModule("Search", "AceEvent-3.0", "AceConsole-3.0")
local searchExecute = CreateFrame("Button", "GlobalSearchExecuteButton", nil, "InsecureActionButtonTemplate")
searchExecute:RegisterForClicks("AnyDown")

function module:OnInitialize()
	-- Start with an empty provider collection
	self.providerCollection = ns.SearchProviderCollection.Create({})

	self.searchQuery = ""
	self.selectedIndex = 1
	self.maxResults = 10
	self.searchUI = ns.SearchUI.Create()

	self.searchUI.RegisterCallback(self, "OnTextChanged")
	self.searchUI.RegisterCallback(self, "OnSelectionChanged")
	self.searchUI.RegisterCallback(self, "OnClose")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "Hide")
end

function module:Show()
	if self:IsVisible() then return end

	self.searchContext = ns.SearchContext.Create(self.providerCollection:Get())
	self.searchUI:Show()
end

function module:Hide()
	if not self:IsVisible() then return end

	self.searchContext = nil
	self.searchUI:SetSearchQuery("")
	self.searchUI:Hide()
	ClearOverrideBindings(searchExecute)
end

---@return boolean
function module:IsVisible()
	return self.searchUI:IsVisible()
end

---@param _ any
---@param text string
function module:OnTextChanged(_, text)
	self:Search(text)
end

function module:OnClose()
	self:Hide()
end

---@param _ any
---@param item SearchItem
function module:OnSelectionChanged(_, item)
	ClearOverrideBindings(searchExecute)
	if not item then return end

	searchExecute:SetAttribute("type", "macro")
	local macroText = {
		[[/run LibStub("AceAddon-3.0"):GetAddon("GlobalSearch"):GetModule("Search"):Hide()]],
	}
	if item.action then
		macroText[#macroText + 1] = [[/run LibStub("AceAddon-3.0"):GetAddon("GlobalSearch"):GetModule("Search").selectedAction()]]
		self.selectedAction = item.action
	elseif item.macroText then
		macroText[#macroText + 1] = item.macroText
	else
		self:Printf("No action set for %s in %s", item.name, item.category)
		return
	end
	searchExecute:SetAttribute("macrotext", table.concat(macroText, "\n"))

	SetOverrideBindingClick(searchExecute, true, "ENTER", "GlobalSearchExecuteButton")
end

---@param query string
function module:Search(query)
	local prevSelection = self.results and self.results[self.selectedIndex] or nil

	self.searchQuery = query
	local results = self.searchContext:Search(query)
	self.results = results

	local newSelectedIndex = 1
	for i, result in ipairs(results) do
		if prevSelection and prevSelection.item == result.item then
			newSelectedIndex = i
			break
		end
		if i >= self.maxResults then break end
	end
	self.selectedIndex = newSelectedIndex

	self.searchUI:Show()
	self.searchUI:RenderResults(results)
end
