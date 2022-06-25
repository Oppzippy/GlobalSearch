local widgetType, widgetVersion = "GlobalSearch-SearchBar", 1

local AceGUI = LibStub("AceGUI-3.0")

local methods = {
	OnAcquire = function(self)
		self.frame:SetText("")
		self.frame:SetSize(350, 40)
	end,
	SetText = function(self, text)
		self.frame:SetText(text)
	end,
	GetText = function(self)
		return self.frame:GetText()
	end,
}

do
	local function onEscapePressed(frame)
		frame.obj:Fire("OnClose")
	end

	local function onArrowPressed(frame, button)
		if button == "DOWN" then
			frame.obj:Fire("OnSelectNextItem")
		elseif button == "UP" then
			frame.obj:Fire("OnSelectPreviousItem")
		end
	end

	local function onEnterPressed(frame)
		frame.obj:Fire("OnItemChosen")
	end

	local function onTextChanged(frame)
		frame.obj:Fire("OnTextChanged")
	end

	local function constructor()
		local frame = CreateFrame("EditBox", nil, UIParent, "BackdropTemplate")
		frame:Hide()

		frame.backdropInfo = {
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 12,
			tileEdge = true,
			insets = { left = 3, right = 1.5, top = 1.5, bottom = 3 },
		}
		frame:ApplyBackdrop()

		frame:SetFontObject("GameFontWhite")
		frame:SetJustifyH("CENTER")
		frame:SetJustifyV("CENTER")

		frame:SetScript("OnEscapePressed", onEscapePressed)
		frame:SetScript("OnArrowPressed", onArrowPressed)
		frame:SetScript("OnEnterPressed", onEnterPressed)
		frame:SetScript("OnTextChanged", onTextChanged)

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
