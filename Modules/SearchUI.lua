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
local SearchUIPrototype = {
	resultsPerPage = 10,
}

local function CreateSearchUI()
	local searchUI = setmetatable({
		widgets = { results = {} },
		selectedIndex = 1,
		page = 1,
		keybindingRegistry = ns.KeybindingRegistry.Create(CallbackHandler),
	}, { __index = SearchUIPrototype })
	searchUI.callbacks = CallbackHandler:New(searchUI)
	return searchUI
end

function SearchUIPrototype:Show()
	if self.widgets.container then return end

	self.selectedIndex = 1

	local container = AceGUI:Create("SimpleGroup")
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
	searchBar:SetHeight(40)

	local resultsContainer = AceGUI:Create("SimpleGroup")
	---@cast resultsContainer AceGUISimpleGroup
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
end

function SearchUIPrototype:UpdateTooltip()
	local item = self:GetSelectedItem()
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
		return
	end
	self:HideTooltip()
end

---@param tooltipFunc fun(tooltip: LimitedTooltip)
function SearchUIPrototype:ShowTooltip(tooltipFunc)
	self:HideTooltip()

	local tooltip = AceGUI:Create("GlobalSearch-Tooltip")
	self.widgets.tooltip = tooltip

	tooltip:ClearAllPoints()
	tooltip.frame:SetOwner(UIParent, "ANCHOR_NONE")
	tooltip:SetPoint("TOPLEFT", self.widgets.resultsContainer.frame, "TOPRIGHT", 4, 0)

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

	self:HideTooltip()
	self.widgets.container:Release()
	self.widgets = { results = {} }
end

---@return boolean
function SearchUIPrototype:IsVisible()
	return self.widgets.container ~= nil
end

function SearchUIPrototype:SelectNextItem()
	self:SetSelection(self.selectedIndex + 1)
end

function SearchUIPrototype:SelectPreviousItem()
	self:SetSelection(self.selectedIndex - 1)
end

function SearchUIPrototype:SelectNextPage()
	local _, rightBound = self:GetPageBounds()
	self:SetSelection(rightBound + 1)
end

function SearchUIPrototype:SelectPreviousPage()
	local leftBound = self:GetPageBounds()
	self:SetSelection(leftBound - self.resultsPerPage)
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

	self:UpdateTooltip()
	self:FireSelectionChange()
end

---@return SearchItem
function SearchUIPrototype:GetSelectedItem()
	local result = self.results[self.selectedIndex]
	return result and result.item
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

function SearchUIPrototype:GetPage()
	return self.page
end

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
		resultWidget:SetTexture(item.texture)
		if item.pickup then
			resultWidget:SetCallback("OnPickup", item.pickup)
		end
		resultWidget:SetFullWidth(true)
		resultWidget:SetHeight(40)
		resultWidget:SetUserData("item", item)

		if i == self.selectedIndex then
			resultWidget:SetIsSelected(true)
		end

		self.widgets.resultsContainer:AddChild(resultWidget)
		self.widgets.results[#self.widgets.results + 1] = resultWidget
	end
	if self:GetNumPages() >= 1 then
		local pageNumber = AceGUI:Create("Label")
		---@cast pageNumber AceGUILabel
		pageNumber:SetText(L.page_x_of_x:format(self:GetPage(), self:GetNumPages()))
		pageNumber:SetFontObject("GameFontWhite")
		self.widgets.resultsContainer:AddChild(pageNumber)
	end

	self.widgets.resultsContainer:ResumeLayout()
	self.widgets.resultsContainer:DoLayout()

	self:UpdateTooltip()
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
