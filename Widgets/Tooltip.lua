local widgetType, widgetVersion = "GlobalSearch-Tooltip", 1

local AceGUI = LibStub("AceGUI-3.0")

local methods = {
	OnAcquire = function(self)
		self.frame:ClearLines()
		self.frame:Show()
		self.frame:SetFrameStrata("MEDIUM")
	end,
	SetFrameStrata = function(self, strata)
		self.frame:SetFrameStrata(strata)
	end,
}

do
	local function constructor()
		local name = "AceGUI30GlobalSearchTooltip" .. AceGUI:GetNextWidgetNum(widgetType)
		local frame = CreateFrame("GameTooltip", name, UIParent, "GameTooltipTemplate")
		frame:Hide()

		local widget = {
			type = widgetType,
			frame = frame,
		}

		for method, func in next, methods do
			widget[method] = func
		end

		return AceGUI:RegisterAsWidget(widget)
	end

	AceGUI:RegisterWidgetType(widgetType, constructor, widgetVersion)
end
