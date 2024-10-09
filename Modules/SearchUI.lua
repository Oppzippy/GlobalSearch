---@class ns
local ns = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local CallbackHandler = LibStub("CallbackHandler-1.0")

local L = AceLocale:GetLocale("GlobalSearch")

---@class SearchUI
---@field callbacks table
---@field keybindingRegistry KeybindingRegistry
---@field RegisterCallback function
---@field frameStrata FrameStrata
---@field font Font
---@field tooltipFont Font
---@field helpTextFont Font
local SearchUIPrototype = {
	resultsPerPage = 10,
	barHeight = 40,
}

---@return SearchUI
local function CreateSearchUI()
	local searchUI = setmetatable({
		widgets = { results = {} },
		selectedIndex = 1,
		page = 1,
		keybindingRegistry = ns.KeybindingRegistry.Create(CallbackHandler),
	}, { __index = SearchUIPrototype })
	searchUI.callbacks = CallbackHandler:New(searchUI)
	searchUI.frameStrata = "DIALOG"
	searchUI.font = CreateFont("GlobalSearch_SearchUIFont")
	searchUI.helpTextFont = CreateFont("GlobalSearch_SearchUIHelpTextFont")
	searchUI.tooltipFont = CreateFont("GlobalSearch_SearchUITooltipFont")
	return searchUI
end

function SearchUIPrototype:Show()
	if self.widgets.container then return end

	self.selectedIndex = 1

	local container = AceGUI:Create("GlobalSearch-Container")
	---@cast container AceGUISimpleGroup
	container:SetLayout("List")
	container:SetPoint("TOP", 0, -20)
	container:SetWidth(350)
	container:SetAutoAdjustHeight(true)

	local searchBar = AceGUI:Create("GlobalSearch-SearchBar")
	searchBar:SetCallback("OnTextChanged", function()
		local text = searchBar:GetText()
		text = strtrim(text)
		self.callbacks:Fire("OnTextChanged", text)
	end)
	searchBar:SetCallback("OnKeyDown", function(_, _, key)
		local keyWithModifiers = ns.Bindings.GetCurrentModifiers() .. key
		self.keybindingRegistry:OnKeyDown(keyWithModifiers)
	end)
	searchBar:SetFullWidth(true)
	searchBar:SetHeight(self.barHeight)
	searchBar:SetFontObject(self.font)

	local resultsContainer = AceGUI:Create("GlobalSearch-ResultsContainer")
	---@cast resultsContainer AceGUISimpleGroup
	resultsContainer:SetLayout("List")
	resultsContainer:SetFullWidth(true)
	resultsContainer:SetAutoAdjustHeight(true)
	resultsContainer:SetCallback("OnSelectNextPage", function()
		self.callbacks:Fire("OnSelectNextPage")
	end)
	resultsContainer:SetCallback("OnSelectPreviousPage", function()
		self.callbacks:Fire("OnSelectPreviousPage")
	end)

	container:AddChild(searchBar)
	container:AddChild(resultsContainer)

	-- This container doesn't show itself when acquired,
	-- probably since it's usually used as a child of another container
	---@diagnostic disable-next-line: undefined-field
	container.frame:Show()

	self.widgets.container = container
	self.widgets.searchBar = searchBar
	self.widgets.resultsContainer = resultsContainer

	self.results = {}

	-- The caller should be listening for this event and trigger a render
	self.callbacks:Fire("OnTextChanged", "")
end

function SearchUIPrototype:SetOffset(xOffset, yOffset)
	self.widgets.container:SetPoint("TOP", xOffset, yOffset)
end

function SearchUIPrototype:SetSize(width, height)
	self.widgets.container:SetWidth(width)
	-- Changing the search bar width triggers an OnTextChanged event for some reason, so we can just
	-- let that trigger the rerender rather than calling Render here.
	self.widgets.searchBar:SetHeight(height)
	self.barHeight = height
end

function SearchUIPrototype:SetFont(path, size, flags)
	self.font:SetFont(path, size, flags)
end

function SearchUIPrototype:SetTooltipFont(path, size, flags)
	self.tooltipFont:SetFont(path, size, flags)
end

function SearchUIPrototype:SetHelpTextFont(path, size, flags)
	self.helpTextFont:SetFont(path, size, flags)
end

---@param strata FrameStrata
function SearchUIPrototype:SetFrameStrata(strata)
	self.frameStrata = strata
	self.widgets.container:SetFrameStrata(strata)
end

---@param resultsPerPage number
function SearchUIPrototype:SetNumResultsPerPage(resultsPerPage)
	self.resultsPerPage = resultsPerPage
end

function SearchUIPrototype:SetHelpText(helpText)
	self.helpText = helpText
end

---@param item SearchItem
function SearchUIPrototype:SetTooltip(item)
	if item and item.tooltip then
		local tooltipSetter = item.tooltip
		local tooltipSetterType = type(tooltipSetter)
		if tooltipSetterType == "string" then
			self:ShowTooltip(function(tooltip)
				tooltip:SetText(tooltipSetter, nil, nil, nil, nil, true)
			end)
		elseif tooltipSetterType == "function" then
			self:ShowTooltip(tooltipSetter)
		else
			error("bad tooltip type: " .. tooltipSetterType)
		end
	else
		self:HideTooltip()
	end
end

---@param tooltipFunc fun(tooltip: GameTooltip)
function SearchUIPrototype:ShowTooltip(tooltipFunc)
	self:HideTooltip()

	local tooltip = AceGUI:Create("GlobalSearch-Tooltip")
	self.widgets.tooltip = tooltip

	tooltip:ClearAllPoints()
	tooltip:SetFontObject(self.tooltipFont)
	tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	tooltip:SetPoint("TOPLEFT", self.widgets.resultsContainer.frame, "TOPRIGHT", 4, 0)
	-- Since tooltip isn't a child of self.widgets.container, its frame strata will not be inherited
	tooltip:SetFrameStrata(self.frameStrata)

	local limitedTooltip = ns.LimitedTooltip.Limit(tooltip.frame)
	xpcall(function()
		tooltipFunc(limitedTooltip)
	end, function(err)
		geterrorhandler()(err)
		self:HideTooltip()
	end)
end

function SearchUIPrototype:HideTooltip()
	if self.widgets.tooltip then
		self.widgets.tooltip:Release()
		self.widgets.tooltip = nil
	end
end

function SearchUIPrototype:Hide()
	if not self.widgets.container then return end

	-- result widgets must be released first to prevent the results'
	-- OnLeave handler from showing another tooltip after HideTooltip
	-- is already called
	self.widgets.container:Release()
	self:HideTooltip()
	self.widgets = { results = {} }
end

---@return boolean
function SearchUIPrototype:IsVisible()
	return self.widgets.container ~= nil
end

function SearchUIPrototype:SelectPage(page)
	self:SetSelection((page - 1) * self.resultsPerPage + 1)
end

---@param index number
function SearchUIPrototype:SetSelection(index)
	if index < 1 then
		index = #self.results
	elseif index > #self.results then
		index = 1
	end

	local oldPage = math.ceil(self.selectedIndex / self.resultsPerPage)
	local newPage = math.ceil(index / self.resultsPerPage)

	if oldPage ~= newPage then
		self.selectedIndex = index
		self:SetPage(newPage)
	else
		local leftBound = self:GetPageBounds()
		local prevSelection = self.widgets.results[self.selectedIndex - leftBound + 1]
		if prevSelection then
			prevSelection:SetIsSelected(false)
		end

		local newSelection = self.widgets.results[index - leftBound + 1]
		if newSelection then
			newSelection:SetIsSelected(true)
		end

		self.selectedIndex = index
	end

	self:SetTooltip(self:GetSelectedItem())
	self:FireSelectionChange()
end

---@return SearchItem
function SearchUIPrototype:GetSelectedItem()
	local result = self.results[self.selectedIndex]
	return result and result.item
end

function SearchUIPrototype:GetSelectedIndex()
	return self.selectedIndex
end

function SearchUIPrototype:FireSelectionChange()
	self.callbacks:Fire("OnSelectionChanged", self:GetSelectedItem())
end

---@param query string
function SearchUIPrototype:SetSearchQuery(query)
	self.widgets.searchBar:SetText(query)
end

---@param results SearchContextItem[]
function SearchUIPrototype:SetResults(results)
	self.results = results
	self.page = 1
	self.selectedIndex = 1
	self:Render()
end

---@param page integer
function SearchUIPrototype:SetPage(page)
	if page < 1 then
		page = math.max(self:GetNumPages(), 1)
	elseif page > self:GetNumPages() then
		page = 1
	end

	self.page = page
	self:Render()
end

---@return integer
function SearchUIPrototype:GetPage()
	return self.page
end

---@return integer
function SearchUIPrototype:GetNumPages()
	return math.ceil(#self.results / self.resultsPerPage)
end

---@return integer
---@return integer
function SearchUIPrototype:GetPageBounds()
	local left = (self.page - 1) * self.resultsPerPage + 1
	local right = math.min(left + self.resultsPerPage - 1, #self.results)
	return left, right
end

---@param enabled boolean
function SearchUIPrototype:SetShowMouseoverTooltip(enabled)
	self.showMouseoverTooltip = enabled
end

-- TODO fully convert over to new menu API once classic supports it
-- consider usage of DropdownButton
if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
	function SearchUIPrototype:ShowContextMenu(menu)
		local function generator(owner, rootDescription)
			for _, item in ipairs(menu) do
				if item.isTitle then
					rootDescription:CreateTitle(item.text)
				else
					rootDescription:CreateButton(item.text, item.func)
				end
			end
		end
		-- TODO set parent so that menu hides if search results hide
		MenuUtil.CreateContextMenu(UIParent, generator)
	end
else
	local menuFrame = CreateFrame("Frame", "GlobalSearchResultMenuFrame", UIParent, "UIDropDownMenuTemplate")
	function SearchUIPrototype:ShowContextMenu(menu)
		EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU")
	end
end

function SearchUIPrototype:Render()
	self.widgets.resultsContainer:ReleaseChildren()

	self.widgets.results = {}
	self.widgets.resultsContainer:PauseLayout()
	local leftBound, rightBound = self:GetPageBounds()
	for i = leftBound, rightBound do
		local result = self.results[i]
		local resultWidget = AceGUI:Create("GlobalSearch-SearchResult")
		local item = result.item
		if result.matchRanges then
			resultWidget:SetText(self:HighlightRanges(item.name, result.matchRanges))
		else
			resultWidget:SetText(item.name)
		end
		resultWidget:SetCategory(item.category)
		resultWidget:SetCallback("OnClick", function()
			self.callbacks:Fire("OnClick", result.item)
		end)
		resultWidget:SetCallback("OnRightClick", function()
			self.callbacks:Fire("OnRightClick", item)
		end)
		if type(item.texture) == "function" then
			item.texture(resultWidget:GetTexture())
		else
			resultWidget:SetTexture(item.texture)
		end
		if item.pickup then
			resultWidget:SetCallback("OnPickup", item.pickup)
		end
		resultWidget:SetCallback("OnHyperlink", function()
			self.callbacks:Fire("OnHyperlink", item)
		end)
		resultWidget:SetFullWidth(true)
		resultWidget:SetHeight(self.barHeight)
		resultWidget:SetFontObject(self.font)
		resultWidget:SetUserData("item", item)

		if i == self.selectedIndex then
			resultWidget:SetIsSelected(true)
		end

		if self.showMouseoverTooltip then
			resultWidget:SetCallback("OnEnter", function()
				self:SetTooltip(item)
			end)
			resultWidget:SetCallback("OnLeave", function()
				self:SetTooltip(self:GetSelectedItem())
			end)
		end

		self.widgets.resultsContainer:AddChild(resultWidget)
		self.widgets.results[#self.widgets.results + 1] = resultWidget
	end

	if self:GetNumPages() >= 1 then
		local pageNumber = AceGUI:Create("Label")
		---@cast pageNumber AceGUILabel
		pageNumber:SetText(L.page_x_of_x:format(self:GetPage(), self:GetNumPages()))
		pageNumber:SetFontObject(self.helpTextFont)
		self.widgets.resultsContainer:AddChild(pageNumber)
	elseif self.helpText then
		local help = AceGUI:Create("Label")
		---@cast help AceGUILabel
		help:SetText(self.helpText)
		help:SetFontObject(self.helpTextFont)
		self.widgets.resultsContainer:AddChild(help)
	end

	self.widgets.resultsContainer:ResumeLayout()
	self.widgets.resultsContainer:DoLayout()

	self:SetTooltip(self:GetSelectedItem())
	self.callbacks:Fire("OnRender", self.widgets.results)
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
