---@class ns
local ns = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")
local CallbackHandler = LibStub("CallbackHandler-1.0")

---@class SearchUI
---@field callbacks table
---@field keybindingRegistry KeybindingRegistry
---@field RegisterCallback function
local SearchUIPrototype = {
	maxResults = 10,
}

local function CreateSearchUI()
	local searchUI = setmetatable({
		widgets = { results = {} },
		selectedIndex = 1,
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
		text = strtrim(text) -- XXX Temporary fix for the search bar starting with a space in it due to the keybind
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

function SearchUIPrototype:SelectNextItem()
	local newSelectedIndex = self.selectedIndex + 1
	if newSelectedIndex > math.min(#self.widgets.results, self.maxResults) then
		newSelectedIndex = 1
	end
	self:SetSelection(newSelectedIndex)
end

function SearchUIPrototype:SelectPreviousItem()
	local newSelectedIndex = self.selectedIndex - 1
	if newSelectedIndex < 1 then
		newSelectedIndex = math.min(#self.widgets.results, self.maxResults)
	end
	self:SetSelection(newSelectedIndex)
end

function SearchUIPrototype:UpdateTooltip()
	local selection = self.widgets.results[self.selectedIndex]
	if selection then
		local item = selection:GetUserData("item")
		local tooltipType = type(item.tooltip)
		-- TODO add string tooltip type
		if tooltipType == "function" then
			self:ShowTooltip(item.tooltip)
			return
		end
	end
	self:HideTooltip()
end

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

---@param index number
function SearchUIPrototype:SetSelection(index)
	local prevSelection = self.widgets.results[self.selectedIndex]
	if prevSelection then
		prevSelection:SetIsSelected(false)
	end

	local newSelection = self.widgets.results[index]
	if newSelection then
		newSelection:SetIsSelected(true)
	end
	self.selectedIndex = index

	self:UpdateTooltip()
	self:FireSelectionChange()
end

---@return SearchItem
function SearchUIPrototype:GetSelection()
	local widget = self.widgets.results[self.selectedIndex]
	return widget and widget:GetUserData("item")
end

function SearchUIPrototype:FireSelectionChange()
	local widget = self.widgets.results[self.selectedIndex]
	local item = widget and widget:GetUserData("item")
	self.callbacks:Fire("OnSelectionChanged", item)
end

---@param query string
function SearchUIPrototype:SetSearchQuery(query)
	self.widgets.searchBar:SetText(query)
end

---@param results SearchContextItem[]
function SearchUIPrototype:RenderResults(results)
	self.widgets.resultsContainer:ReleaseChildren()
	self.selectedIndex = 1

	self.widgets.results = {}
	self.widgets.resultsContainer:PauseLayout()
	for i, result in ipairs(results) do
		local resultWidget = AceGUI:Create("GlobalSearch-SearchResult")
		resultWidget:SetText(self:HighlightRanges(result.item.name, result.matchRanges))
		resultWidget:SetCategory(result.item.category)
		resultWidget:SetTexture(result.item.texture)
		if result.item.pickup then
			resultWidget:SetCallback("OnPickup", result.item.pickup)
		end
		resultWidget:SetFullWidth(true)
		resultWidget:SetHeight(40)
		resultWidget:SetUserData("item", result.item)

		if i == self.selectedIndex then
			resultWidget:SetIsSelected(true)
		end

		self.widgets.resultsContainer:AddChild(resultWidget)
		self.widgets.results[i] = resultWidget

		if i >= self.maxResults then break end
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
