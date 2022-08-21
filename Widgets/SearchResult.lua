local widgetType, widgetVersion = "GlobalSearch-SearchResult", 1

local AceGUI = LibStub("AceGUI-3.0")

local methods = {
	OnAcquire = function(self)
		self.frame:SetSize(350, 40)
		self.texture:SetTexture(0)
		self.fontString:SetText("")
		self.categoryFontString:SetText("")
		self.highlightTexture:Hide()
		self.frame:SetAttribute("macrotext", "")
	end,
	SetText = function(self, text)
		self.fontString:SetText(text)
	end,
	SetCategory = function(self, category)
		self.categoryFontString:SetText(category)
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
	SetMacroText = function(self, macroText)
		self.frame:SetAttribute("macrotext", macroText)
	end,
}

do
	local function onDragStart(frame)
		frame.obj:Fire("OnPickup")
	end

	local function constructor()
		local frame = CreateFrame("Button", nil, UIParent, "InsecureActionButtonTemplate,BackdropTemplate")
		frame:Hide()

		frame.backdropInfo = {
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
			insets = { left = 3, right = 1.5, top = 1.5, bottom = 3 },
		}
		frame:ApplyBackdrop()
		frame:EnableMouse(true)
		frame:RegisterForDrag("LeftButton")
		frame:SetScript("OnDragStart", onDragStart)
		frame:RegisterForClicks("LeftButtonUp")
		frame:SetAttribute("type", "macro")

		local highlightTexture = frame:CreateTexture(nil, "ARTWORK")
		highlightTexture:SetAllPoints(frame)
		highlightTexture:SetColorTexture(1, 1, 1, 0.3)
		highlightTexture:Hide()

		local textureFrame = CreateFrame("Frame", nil, frame)
		textureFrame:SetPoint("LEFT", 4, 0)
		textureFrame:SetSize(32, 32)

		local texture = textureFrame:CreateTexture(nil, "OVERLAY")
		texture:SetAllPoints(textureFrame)

		local isMasqueEnabled, Masque = pcall(LibStub, "Masque")
		if isMasqueEnabled then
			local group = Masque:Group("GlobalSearch", "Search Results")
			group:AddButton(textureFrame, { Icon = texture })
		end

		local categoryFontString = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
		categoryFontString:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
		categoryFontString:SetTextColor(0.8, 0.8, 0.8, 1)
		categoryFontString:SetJustifyH("RIGHT")

		local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
		fontString:SetPoint("LEFT", textureFrame, "RIGHT", 6, 0)
		fontString:SetPoint("RIGHT", categoryFontString, "LEFT", -6, 0)
		fontString:SetJustifyH("LEFT")
		fontString:SetMaxLines(2)

		local widget = {
			type = widgetType,
			frame = frame,
			textureFrame = textureFrame,
			texture = texture,
			highlightTexture = highlightTexture,
			fontString = fontString,
			categoryFontString = categoryFontString,
		}

		for method, func in next, methods do
			widget[method] = func
		end

		return AceGUI:RegisterAsWidget(widget)
	end

	AceGUI:RegisterWidgetType(widgetType, constructor, widgetVersion)
end
