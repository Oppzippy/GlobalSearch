local widgetType, widgetVersion = "GlobalSearch-SearchResult", 1

local AceGUI = LibStub("AceGUI-3.0")

local methods = {
	OnAcquire = function(self)
		self.frame:SetSize(350, 40)
		self.texture:SetTexture(0)
		self.fontString:SetText("")
		self.highlightTexture:Hide()
	end,
	SetText = function(self, text)
		self.fontString:SetText(text)
	end,
	SetTexture = function(self, texture)
		self.texture:SetTexture(texture)
	end,
	SetIsSelected = function(self, isSelected)
		if isSelected then
			self.highlightTexture:Show()
		else
			self.highlightTexture:Hide()
		end
	end,
}

do
	local function constructor()
		local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
		frame:Hide()

		frame.backdropInfo = {
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
			insets = { left = 3, right = 1.5, top = 1.5, bottom = 3 },
		}
		frame:ApplyBackdrop()

		local highlightTexture = frame:CreateTexture(nil, "ARTWORK")
		highlightTexture:SetAllPoints(frame)
		highlightTexture:SetColorTexture(1, 1, 1, 0.5)
		highlightTexture:Hide()

		local texture = frame:CreateTexture(nil, "OVERLAY")
		texture:SetPoint("LEFT", 4, 0)
		texture:SetSize(32, 32)

		local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
		fontString:SetPoint("LEFT", frame, "LEFT", 45, 0)

		local widget = {
			type = widgetType,
			frame = frame,
			texture = texture,
			highlightTexture = highlightTexture,
			fontString = fontString,
		}

		for method, func in next, methods do
			widget[method] = func
		end

		return AceGUI:RegisterAsWidget(widget)
	end

	AceGUI:RegisterWidgetType(widgetType, constructor, widgetVersion)
end
