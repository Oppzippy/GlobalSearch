local widgetType, widgetVersion = "GlobalSearch-Container", 1

local AceGUI = LibStub("AceGUI-3.0")

local methods = {
	OnAcquire = function(self)
		-- Defaults for SimpleGroup
		self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		self.content:SetFrameStrata("MEDIUM")
	end,
	SetFrameStrata = function(self, strata)
		self.frame:SetFrameStrata(strata)
	end
}

do
	local function constructor()
		local group = AceGUI:Create("SimpleGroup")
		---@cast group AceGUISimpleGroup

		for method, func in next, methods do
			group[method] = func
		end

		return group
	end

	AceGUI:RegisterWidgetType(widgetType, constructor, widgetVersion)
end
