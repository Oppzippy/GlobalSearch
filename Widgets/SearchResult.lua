local widgetType, widgetVersion = "GlobalSearch-SearchResult", 1

local AceGUI = LibStub("AceGUI-3.0")

local methods = {
	OnAcquire = function(self)
		self.frame:SetWidth(350)
		self:SetHeight(40)

		-- This texture is provided to consumers of the api, so everything that can be modified (within reason)
		-- should be reset. It's necessary to pass the actual texture rather than a read only view of it like
		-- LimitedTooltip for functions such as SetPortraitTexture.
		self.texture:SetAllPoints(self.textureFrame)
		self.texture:SetParent(self.textureFrame)
		self.texture:SetTexture(0)
		self.texture:SetTexCoord(0, 1, 0, 1)
		self.texture:SetBlendMode("BLEND")
		self.texture:SetVertTile(false)
		self.texture:SetHorizTile(false)
		self.texture:SetDesaturated(false)
		self.texture:SetVertexColor(1, 1, 1, 1)
		self.texture:SetRotation(0)
		self.texture:SetSnapToPixelGrid()
		if self.texture.SetNonBlocking then
			-- Shadowlands and classic
			self.texture:SetNonBlocking(true)
		end
		if self.texture.SetBlockingLoadsRequested then
			-- Dragonflight
			self.texture:SetBlockingLoadsRequested(false)
		end
		self.texture:SetVertexOffset(1, 0, 0)
		self.texture:SetVertexOffset(2, 0, 0)
		self.texture:SetVertexOffset(3, 0, 0)
		self.texture:SetVertexOffset(4, 0, 0)
		self.texture:Show()

		self.fontString:SetText("")
		self.categoryFontString:SetText("")
		self.highlightTexture:Hide()
		self.mouseoverHighlightTexture:Hide()
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
	GetTexture = function(self)
		return self.texture
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
	SetHeight = function(self, height)
		self.frame:SetHeight(height)
		self.textureFrame:SetWidth(height - 8) -- subtract top and bottom border
	end,
	SetFontObject = function(self, font)
		self.fontString:SetFontObject(font)
		self.categoryFontString:SetFontObject(font)
	end,
}

do
	local function onDragStart(frame)
		frame.obj:Fire("OnPickup")
	end

	local function onEnter(frame)
		frame.obj.mouseoverHighlightTexture:Show()
		frame.obj:Fire("OnEnter")
	end

	local function onLeave(frame)
		frame.obj.mouseoverHighlightTexture:Hide()
		frame.obj:Fire("OnLeave")
	end

	local function onHyperlink(frame)
		frame.obj:Fire("OnHyperlink")
	end

	local function onRightClick(frame)
		frame.obj:Fire("OnRightClick")
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
		frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

		-- Unmodified left click
		frame:SetAttribute("type1", "macro")

		-- Unmodified right click
		frame:SetAttribute("type2", "rightclick")
		frame:SetAttribute("rightclick", "_rightclick")
		frame:SetAttribute("_rightclick", onRightClick)

		-- Shift left click
		frame:SetAttribute("shift-type1", "hyperlink")
		frame:SetAttribute("hyperlink", "_hyperlink")
		frame:SetAttribute("_hyperlink", onHyperlink)

		frame:SetScript("OnEnter", onEnter)
		frame:SetScript("OnLeave", onLeave)

		local highlightTexture = frame:CreateTexture(nil, "ARTWORK")
		highlightTexture:SetAllPoints(frame)
		highlightTexture:SetColorTexture(1, 1, 1, 0.3)
		highlightTexture:Hide()

		local mouseoverHighlightTexture = frame:CreateTexture(nil, "ARTWORK")
		mouseoverHighlightTexture:SetAllPoints(frame)
		mouseoverHighlightTexture:SetColorTexture(1, 1, 1, 0.1)
		mouseoverHighlightTexture:Hide()

		local textureFrame = CreateFrame("Frame", nil, frame)
		-- 4 pixel border on the top, bottom, and left.
		textureFrame:SetPoint("TOPLEFT", 4, -4)
		textureFrame:SetPoint("BOTTOMLEFT", 0, 4)

		local texture = textureFrame:CreateTexture(nil, "OVERLAY")

		local categoryFontString = frame:CreateFontString(nil, "OVERLAY")
		categoryFontString:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
		categoryFontString:SetTextColor(0.8, 0.8, 0.8, 1)
		categoryFontString:SetJustifyH("RIGHT")

		local fontString = frame:CreateFontString(nil, "OVERLAY")
		fontString:SetPoint("LEFT", textureFrame, "RIGHT", 6, 0)
		fontString:SetPoint("RIGHT", categoryFontString, "LEFT", -6, 0)
		fontString:SetJustifyH("LEFT")
		fontString:SetMaxLines(2)

		categoryFontString:SetFontObject("GameFontWhite")
		fontString:SetFontObject("GameFontWhite")

		local widget = {
			type = widgetType,
			frame = frame,
			textureFrame = textureFrame,
			texture = texture,
			highlightTexture = highlightTexture,
			mouseoverHighlightTexture = mouseoverHighlightTexture,
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
