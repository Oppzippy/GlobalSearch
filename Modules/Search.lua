---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local LibSharedMedia = LibStub("LibSharedMedia-3.0")

local L = AceLocale:GetLocale("GlobalSearch")
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
	self.searchUI.RegisterCallback(self, "OnRender")
	self.searchUI.RegisterCallback(self, "OnHyperlink")

	self.searchUI.keybindingRegistry.RegisterCallback(self, "OnClose", "Hide")
	self.searchUI.keybindingRegistry.RegisterCallback(self, "OnSelectNextItem")
	self.searchUI.keybindingRegistry.RegisterCallback(self, "OnSelectPreviousItem")
	self.searchUI.keybindingRegistry.RegisterCallback(self, "OnToggle")
	self.searchUI.keybindingRegistry.RegisterCallback(self, "OnCreateHyperlink")
	self.searchUI.keybindingRegistry.RegisterCallback(self, "OnSelectNextPage")
	self.searchUI.keybindingRegistry.RegisterCallback(self, "OnSelectPreviousPage")

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "Hide")
	self:RegisterMessage("GlobalSearch_OnKeybindingModified", "RegisterKeybindings")
	self:RegisterMessage("GlobalSearch_OnProviderStatusChanged", "UpdateProviderCollection")
	self:RegisterMessage("GlobalSearch_OnDisplaySettingsChanged", "UpdateDisplaySettings")
end

function module:OnEnable()
	self:RegisterKeybindings()
end

function module:UpdateProviderCollection()
	local disabledProviders = self:GetDB().profile.options.disabledSearchProviders
	local providerCollection = self:GetSearchProviderRegistry():GetProviderCollection(disabledProviders)
	self.searchContextCache = ns.SearchContextCache.Create(providerCollection)
end

function module:Show()
	if self:IsVisible() or InCombatLockdown() then return end
	local options = self:GetDB().profile.options
	self.searchUI:SetShowMouseoverTooltip(options.showMouseoverTooltip)
	self.searchUI:SetHelpText(options.showHelp and self:GetHelpText() or nil)

	local itemsBySearchProvider = {}
	for id in next, self.providerCollection:GetProviderIDs() do
		itemsBySearchProvider[id] = self.providerCollection:GetProviderItems(id)
	end
	self.itemsBySearchProvider = itemsBySearchProvider
	self.searchContext = self.searchContextCache:GetCombinedContextForProviders(self.searchContextCache:GetProviderIDs())
	self.searchUI:Show()
	self:UpdateDisplaySettings()
end

function module:UpdateDisplaySettings()
	if self.searchUI:IsVisible() then
		local options = self:GetDB().profile.options
		self.searchUI:SetOffset(options.position.xOffset, options.position.yOffset)
		self.searchUI:SetSize(options.size.width, options.size.height)

		local fontPath = LibSharedMedia:Fetch("font", options.font.font)
		local fontFlags = {}
		if options.font.outline then
			fontFlags[#fontFlags + 1] = options.font.outline
		end
		if options.font.monochrome then
			fontFlags[#fontFlags + 1] = "MONOCHROME"
		end

		self.searchUI:SetFont(fontPath, options.font.size, table.concat(fontFlags, ","))
	end
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
	self.searchUI.keybindingRegistry:RegisterKeybinding(keybindings.selectNextPage, "OnSelectNextPage")
	self.searchUI.keybindingRegistry:RegisterKeybinding(keybindings.selectPreviousPage, "OnSelectPreviousPage")
	for key in next, ns.Bindings.GetKeyBinding("SHOW") do
		self.searchUI.keybindingRegistry:RegisterKeybinding(key, "OnToggle")
	end
	self.searchUI.keybindingRegistry:RegisterKeybinding("SHIFT-ENTER", "OnCreateHyperlink")
	self.searchUI.keybindingRegistry:RegisterKeybinding("ESCAPE", "OnClose")
end

function module:OnSelectNextItem()
	self.searchUI:SetSelection(self.searchUI:GetSelectedIndex() + 1)
end

function module:OnSelectPreviousItem()
	self.searchUI:SetSelection(self.searchUI:GetSelectedIndex() + -1)
end

function module:OnSelectNextPage()
	self.searchUI:SelectPage(self.searchUI:GetPage() + 1)
end

function module:OnSelectPreviousPage()
	self.searchUI:SelectPage(self.searchUI:GetPage() - 1)
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
	searchExecute:SetAttribute("macrotext",
		self:GetMacroText(self.searchUI:GetSelectedItem(), self.searchUI:GetSelectedIndex()))

	SetOverrideBindingClick(searchExecute, true, "ENTER", "GlobalSearchExecuteButton")
end

function module:OnRender(_, resultWidgets)
	self.resultActions = {}
	local leftBound = self.searchUI:GetPageBounds()
	for i, resultWidget in ipairs(resultWidgets) do
		local resultIndex = leftBound + i - 1
		resultWidget:SetMacroText(self:GetMacroText(self.results[resultIndex].item, resultIndex))
	end
end

---@param resultIndex integer
function module:ExecuteAction(resultIndex)
	local action = self.results[resultIndex].item.action
	if action then
		action()
	end
end

function module:OnMacroItemSelected(resultIndex)
	self:Hide()
	local db = self.GetDB().profile
	local item = self.results[resultIndex].item

	if db.options.maxRecentItems == 0 then
		db.recentItemsV2 = {}
		return
	end

	if item.id then
		local newRecentItems = {
			{
				provider = item.provider,
				id = item.id,
			},
		}
		local seenItems = {
			[item.provider] = { [item.id] = true },
		}
		-- Store more items than the limit since some items may be unavailable (bag items that were consumed, etc.)
		local recentItemStorageLimit = db.options.maxRecentItems * 2

		for _, recentItem in ipairs(db.recentItemsV2) do
			if not seenItems[recentItem.provider] then
				seenItems[recentItem.provider] = {}
			end
			if not seenItems[recentItem.provider][recentItem.id] then
				seenItems[recentItem.provider][recentItem.id] = true
				newRecentItems[#newRecentItems + 1] = recentItem
				if #newRecentItems >= recentItemStorageLimit then
					break
				end
			end
		end
		db.recentItemsV2 = newRecentItems
	end
end

---@param item SearchItem
---@param resultIndex integer
---@return string
function module:GetMacroText(item, resultIndex)
	local macroText = {
		[[/run LibStub("AceAddon-3.0"):GetAddon("GlobalSearch"):GetModule("Search"):OnMacroItemSelected(]] .. resultIndex ..
			")",
	}
	if item.action then
		macroText[#macroText + 1] = [[/run LibStub("AceAddon-3.0"):GetAddon("GlobalSearch"):GetModule("Search"):ExecuteAction(]]
			.. resultIndex .. ")"
	elseif item.macroText then
		macroText[#macroText + 1] = item.macroText
	else
		error(string.format("No action set for %s in %s", item.name, item.category))
	end
	return table.concat(macroText, "\n")
end

---@param query string
function module:Search(query)
	local prevSelection = self.results and self.results[self.selectedIndex] or nil

	self.searchQuery = query
	if query == "" then
		local results = self:GetRecentItemResults()

		-- We store more items than the max number of recent items to display, so remove the extras.
		for i = self:GetDB().profile.options.maxRecentItems + 1, #results do
			results[i] = nil
		end
		self.results = results
	else
		local specificProvider, specificProviderQuery = query:match("^#([^ ]+) (.*)$")
		if specificProvider then
			specificProvider = specificProvider:lower()

			---@type table<string, boolean>
			local matchingProviderIDs = {}
			for id, provider in next, self:GetSearchProviderRegistry():GetProviders() do
				local localizedName = provider.localizedName or id
				if localizedName:gsub(" ", ""):lower() == specificProvider then
					matchingProviderIDs[id] = true
				end
			end

			local context = self.searchContextCache:GetCombinedContextForProviders(matchingProviderIDs)
			self.results = context:Search(specificProviderQuery)
		else
			self.results = self.searchContext:Search(query)
		end
	end

	local newSelectedIndex = 1
	for i, result in ipairs(self.results) do
		if prevSelection and prevSelection.item == result.item then
			newSelectedIndex = i
			break
		end
		if i >= self.maxResults then break end
	end
	self.selectedIndex = newSelectedIndex

	self.searchUI:SetResults(self.results)
end

function module:GetRecentItemResults()
	---@type table<string, table<unknown, number>>
	local itemIDOrder = {}
	for i, recentItem in next, self:GetDB().profile.recentItemsV2 do
		if recentItem.provider then -- don't break on old format
			if not itemIDOrder[recentItem.provider] then
				itemIDOrder[recentItem.provider] = {}
			end
			itemIDOrder[recentItem.provider][recentItem.id] = i
		end
	end

	---@type SearchContextItem[]
	local results = {}
	---@type table<SearchContextItem, number>
	local resultOrder = {}
	for providerName, items in next, self.itemsBySearchProvider do
		for _, item in next, items do
			local order = itemIDOrder[providerName] and itemIDOrder[providerName][item.id]
			if order then
				local result = { item = item }
				results[#results + 1] = result
				resultOrder[result] = order
			end
		end
	end

	table.sort(results, function(a, b)
		return resultOrder[a] < resultOrder[b]
	end)
	return results
end

function module:OnHyperlink(_, item)
	self:Hyperlink(item)
end

function module:OnCreateHyperlink()
	self:Hyperlink(self.searchUI:GetSelectedItem())
end

function module:Hyperlink(item)
	if item then
		self:Hide()
		ChatEdit_ActivateChat(ChatFrame1EditBox)
		ChatFrame1EditBox:Insert(item.hyperlink or item.name)
	end
end

function module:GetHelpText()
	local keybinds = self.searchUI.keybindingRegistry:GetKeyBindingsByCallbackName()
	local function getKeybindText(callbackName)
		if not keybinds[callbackName] then
			return L.not_bound
		end
		return table.concat(keybinds[callbackName], ", ")
	end

	return L.keybinding_help:format(
		getKeybindText("OnClose"),
		getKeybindText("OnCreateHyperlink"),
		getKeybindText("OnSelectPreviousItem"),
		getKeybindText("OnSelectNextItem"),
		getKeybindText("OnSelectPreviousPage"),
		getKeybindText("OnSelectNextPage")
	)
end
