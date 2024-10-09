---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local LibSharedMedia = LibStub("LibSharedMedia-3.0")

local L = AceLocale:GetLocale("GlobalSearch")
local addon = AceAddon:GetAddon("GlobalSearch")
---@class SearchModule : AceModule, AceConsole-3.0, AceEvent-3.0, ModulePrototype
---@field RegisterEvent function
---@field searchExecutor? SearchExecutor
local module = addon:NewModule("Search", "AceEvent-3.0", "AceConsole-3.0")
local searchExecute = CreateFrame("Button", "GlobalSearchExecuteButton", nil, "InsecureActionButtonTemplate")
searchExecute:RegisterForClicks("AnyDown", "AnyUp")
searchExecute:HookScript("OnClick", function()
	module:OnClick(nil, module.searchUI:GetSelectedItem())
end)

function module:OnInitialize()
	self.searchQuery = ""

	self:UpdateProviderCollection()

	self.searchUI = ns.SearchUI.Create()

	self.searchUI.RegisterCallback(self, "OnTextChanged")
	self.searchUI.RegisterCallback(self, "OnSelectionChanged")
	self.searchUI.RegisterCallback(self, "OnRender")
	self.searchUI.RegisterCallback(self, "OnHyperlink")
	self.searchUI.RegisterCallback(self, "OnRightClick")
	self.searchUI.RegisterCallback(self, "OnSelectNextPage")
	self.searchUI.RegisterCallback(self, "OnSelectPreviousPage")
	self.searchUI.RegisterCallback(self, "OnClick")

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
	self:RegisterMessage("GlobalSearch_ProviderItemsUpdated", "RefreshItems")
end

function module:OnEnable()
	self:RegisterKeybindings()

	local options = self:GetDB().profile.options
	if options.preloadCache then
		self.preloadCacheTimer = C_Timer.NewTimer(options.preloadCacheDelayInSeconds, function()
			self.preloadCacheTimer = nil
			local task = ns.Task.Create(coroutine.create(function()
				-- Prefill caches
				for _, provider in next, self.providerCollection:GetProviders() do
					if provider.RefreshCacheAsync then
						provider:RefreshCacheAsync()
					end
				end
				-- Prebuild indexes
				for providerID in next, self.searchContextCache:GetProviders() do
					self.searchContextCache:GetContextsForProviderAsync(providerID):PollToCompletionAsync()
				end
			end))

			self:SendMessage("GlobalSearch_QueueTask", task, "PreloadCache")
		end)
	end
end

function module:UpdateProviderCollection()
	local disabledProviders = self:GetDB().profile.options.disabledSearchProviders
	self.providerCollection = self:GetSearchProviderRegistry():GetProviderCollection(disabledProviders)
	self.searchContextCache = ns.SearchContextCache.Create(self.providerCollection)
end

function module:Show()
	if self:IsVisible() or InCombatLockdown() then return end
	local options = self:GetDB().profile.options
	self.searchUI:SetShowMouseoverTooltip(options.showMouseoverTooltip)
	self.searchUI:SetHelpText(options.showHelp and self:GetHelpText() or nil)

	self:SendMessage("GlobalSearch_RunTaskToCompletion", "PreloadCache")
	-- If we haven't started preloading yet, GlobalSearch_RunTaskToCompletion will not finish the not yet started
	-- task. Since are about to fill all of the caches now, we don't need the task anymore.
	if self.preloadCacheTimer then
		self.preloadCacheTimer:Cancel()
		self.preloadCacheTimer = nil
	end

	self.searchExecutor = ns.SearchExecutor.CreateAsync(
		self:GetDB(),
		self.providerCollection,
		self.searchContextCache
	):PollToCompletion()
	self.searchUI:Show()
	self:UpdateDisplaySettings()
end

function module:RefreshItems(_, providerId)
	if self:IsVisible() then
		self:Debugf("Search provider %s fired refresh items", providerId)
		---@type SearchExecutor
		local newSearchExecutor = ns.SearchExecutor.CreateAsync(
			self:GetDB(),
			self.providerCollection,
			self.searchContextCache
		):PollToCompletion()
		self.results = newSearchExecutor:Search(self.searchExecutor.searchQuery)
		self.searchExecutor = newSearchExecutor
		self.searchUI:SetResults(self.results)
	end
end

do
	local function getFontFromFontOptions(fontOptions)
		local fontPath = LibSharedMedia:Fetch("font", fontOptions.font)
		local fontFlags = {}
		if fontOptions.outline then
			fontFlags[#fontFlags + 1] = fontOptions.outline
		end
		if fontOptions.monochrome then
			fontFlags[#fontFlags + 1] = "MONOCHROME"
		end

		return fontPath, fontOptions.size, table.concat(fontFlags, ",")
	end

	function module:UpdateDisplaySettings()
		if self.searchUI:IsVisible() then
			local options = self:GetDB().profile.options
			self.searchUI:SetOffset(options.position.xOffset, options.position.yOffset)
			self.searchUI:SetSize(options.size.width, options.size.height)
			self.searchUI:SetNumResultsPerPage(options.resultsPerPage)

			self.searchUI:SetFont(getFontFromFontOptions(options.font))
			self.searchUI:SetTooltipFont(getFontFromFontOptions(options.tooltipFont))
			self.searchUI:SetHelpTextFont(getFontFromFontOptions(options.helpTextFont))
			self.searchUI:SetFrameStrata(options.frameStrata)
		end
	end
end

function module:Hide()
	if not self:IsVisible() then return end

	self.searchExecutor = nil
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
	searchExecute:SetAttribute("macrotext", self.searchUI:GetSelectedItem().macroText)

	SetOverrideBindingClick(searchExecute, true, "ENTER", "GlobalSearchExecuteButton")
end

function module:OnRender(_, resultWidgets)
	self.resultActions = {}
	local leftBound = self.searchUI:GetPageBounds()
	for i, resultWidget in ipairs(resultWidgets) do
		local resultIndex = leftBound + i - 1
		resultWidget:SetMacroText(self.results[resultIndex].item.macroText)
	end
end

---@param resultIndex integer
function module:ExecuteAction(resultIndex)
	local action = self.results[resultIndex].item.action
	if action then
		action()
	end
end

---@param _ unknown
---@param item SearchItem
function module:OnClick(_, item)
	if item.action then
		xpcall(item.action, geterrorhandler())
	end

	self:Hide()
	local db = self:GetDB().profile

	if db.options.maxRecentItems == 0 then
		db.recentItemsV2 = {}
		return
	end

	if item.id then
		local newRecentItems = {
			{
				providerID = item.providerID,
				id = item.id,
			},
		}
		local seenItems = {
			[item.providerID] = { [item.id] = true },
		}
		-- Store more items than the limit since some items may be unavailable (bag items that were consumed, etc.)
		local recentItemStorageLimit = db.options.maxRecentItems * 2

		for _, recentItem in ipairs(db.recentItemsV2) do
			if recentItem.provider then
				-- Migration for renamed field
				recentItem.providerID = recentItem.provider
				recentItem.provider = nil
			end
			if not seenItems[recentItem.providerID] then
				seenItems[recentItem.providerID] = {}
			end
			if not seenItems[recentItem.providerID][recentItem.id] then
				seenItems[recentItem.providerID][recentItem.id] = true
				newRecentItems[#newRecentItems + 1] = recentItem
				if #newRecentItems >= recentItemStorageLimit then
					break
				end
			end
		end
		db.recentItemsV2 = newRecentItems
	end
end

---@param query string
function module:Search(query)
	self.searchQuery = query
	self.results = self.searchExecutor:Search(query)
	self.searchUI:SetResults(self.results)
end

---@param item SearchItem
function module:OnHyperlink(_, item)
	self:Hyperlink(item)
end

function module:OnCreateHyperlink()
	self:Hyperlink(self.searchUI:GetSelectedItem())
end

---@param item SearchItem
function module:Hyperlink(item)
	if item then
		local text
		local hyperlinkType = type(item.hyperlink)
		if hyperlinkType == "string" then
			text = item.hyperlink
		elseif hyperlinkType == "function" then
			text = item.hyperlink()
		else
			text = item.name
		end
		self:Hide()
		ChatEdit_ActivateChat(ChatFrame1EditBox)
		ChatFrame1EditBox:Insert(text)
	end
end

---@param item SearchItem
function module:OnRightClick(_, item)
	local menu = {
		{
			text = item.name,
			isTitle = true,
			notCheckable = true,
		},
		{
			text = L.hyperlink,
			notCheckable = true,
			func = function()
				self:Hyperlink(item)
			end,
		},
	}
	if self:IsItemInRecentItems(item) then
		menu[#menu + 1] = {
			text = L.remove_from_recent_items,
			notCheckable = true,
			func = function()
				self:RemoveItemFromRecentItems(item)
				-- Refresh results so the removed item is no longer displayed
				self:Search(self.searchQuery)
			end,
		}
	end
	self.searchUI:ShowContextMenu(menu)
end

---@param item SearchItem
---@return boolean
function module:IsItemInRecentItems(item)
	local recentItems = self:GetDB().profile.recentItemsV2
	for _, recentItem in next, recentItems do
		if recentItem.providerID == item.providerID and recentItem.id == item.id then
			return true
		end
	end
	return false
end

---@param item SearchItem
function module:RemoveItemFromRecentItems(item)
	local recentItems = self:GetDB().profile.recentItemsV2
	local i = 1
	local recentItem = recentItems[i]
	while recentItem do
		if recentItem.providerID == item.providerID and recentItem.id == item.id then
			table.remove(recentItems, i)
			i = i - 1
		end
		i = i + 1
		recentItem = recentItems[i]
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
