local widgetType, widgetVersion = "GlobalSearch-ResultsContainer", 1

local AceGUI = LibStub("AceGUI-3.0")

local methods = {
	OnAcquire = function(self)
		-- Defaults for SimpleGroup
		self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		self.content:SetFrameStrata("MEDIUM")
	end,
}

do
	local function onMouseWheel(frame, delta)
		if delta > 0 then -- Wheel up
			frame.obj:Fire("OnSelectPreviousPage")
		elseif delta < 0 then -- Wheel down
			frame.obj:Fire("OnSelectNextPage")
		end
	end

	local function constructor()
		local group = AceGUI:Create("SimpleGroup")
		---@cast group AceGUISimpleGroup

		group.frame:EnableMouseWheel(true)
		group.frame:SetScript("OnMouseWheel", onMouseWheel)

		for method, func in next, methods do
			group[method] = func
		end

		return group
	end

	AceGUI:RegisterWidgetType(widgetType, constructor, widgetVersion)
end
