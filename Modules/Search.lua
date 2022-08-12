---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")

local addon = AceAddon:GetAddon("GlobalSearch")
---@class SearchModule : AceConsole-3.0, AceEvent-3.0, ModulePrototype
---@field RegisterEvent function
local module = addon:NewModule("Search", "AceEvent-3.0", "AceConsole-3.0")
local searchExecute = CreateFrame("Button", "GlobalSearchExecuteButton", nil, "InsecureActionButtonTemplate")
searchExecute:RegisterForClicks("AnyDown")

function module:OnInitialize()
	self.searchQuery = ""
	self.selectedIndex = 1
	self.maxResults = 10

	self.providerCollection = ns.SearchProviderCollection.Create({})
	self:UpdateProviderCollection()

	self.searchUI = ns.SearchUI.Create()

	self.searchUI.RegisterCallback(self, "OnTextChanged")
	self.searchUI.RegisterCallback(self, "OnSelectionChanged")

	self.searchUI.keybindingRegistry.RegisterCallback(self, "OnClose", "Hide")
	self.searchUI.keybindingRegistry.RegisterCallback(self, "OnSelectNextItem")
	self.searchUI.keybindingRegistry.RegisterCallback(self, "OnSelectPreviousItem")
	self.searchUI.keybindingRegistry.RegisterCallback(self, "OnToggle")
	self.searchUI.keybindingRegistry.RegisterCallback(self, "OnCreateHyperlink")

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "Hide")
	self:RegisterMessage("GlobalSearch_OnKeybindingModified", "RegisterKeybindings")
	self:RegisterMessage("GlobalSearch_OnProviderStatusChanged", "UpdateProviderCollection")
end

function module:OnEnable()
	self:RegisterKeybindings()
end

function module:UpdateProviderCollection()
	local disabledProviders = self:GetDB().profile.options.disabledSearchProviders
	self.providerCollection = self:GetSearchProviderRegistry():GetProviderCollection(disabledProviders)
end

function module:Show()
	if self:IsVisible() or InCombatLockdown() then return end

	local items = self.providerCollection:Get()
	self.searchContext = ns.CombinedSearchContext.Create({
		ns.ShortTextSearchContext.Create(ns.ShortTextQueryMatcher.MatchesQuery, items),
		ns.FullTextSearchContext.Create(items),
	})
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

function module:RegisterKeybindings()
	self.searchUI.keybindingRegistry:ClearAllKeybindings()
	local keybindings = self:GetDB().profile.options.keybindings

	self.searchUI.keybindingRegistry:RegisterKeybinding(keybindings.selectNextItem, "OnSelectNextItem")
	self.searchUI.keybindingRegistry:RegisterKeybinding(keybindings.selectPreviousItem, "OnSelectPreviousItem")
	for key in next, ns.Bindings.GetKeyBinding("SHOW") do
		self.searchUI.keybindingRegistry:RegisterKeybinding(key, "OnToggle")
	end
	self.searchUI.keybindingRegistry:RegisterKeybinding("SHIFT-ENTER", "OnCreateHyperlink")
	self.searchUI.keybindingRegistry:RegisterKeybinding("ESCAPE", "OnClose")
end

function module:OnSelectNextItem()
	self.searchUI:SelectNextItem()
end

function module:OnSelectPreviousItem()
	self.searchUI:SelectPreviousItem()
end

function module:OnToggle()
	if self:GetDB().profile.options.doesShowKeybindToggle then
		self:Hide()
	end
end

---@param _ any
---@param text string
function module:OnTextChanged(_, text)
	self:Search(text)
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

function module:OnCreateHyperlink()
	local item = self.searchUI:GetSelection()
	if item then
		self:Hide()
		ChatEdit_ActivateChat(ChatFrame1EditBox)
		ChatFrame1EditBox:Insert(item.hyperlink or item.name)
	end
end
