local bindingFrame = CreateFrame("Frame", nil, UIParent)
bindingFrame:SetPropagateKeyboardInput(true)
bindingFrame:SetScript("OnKeyDown", function(_, key)
	if IsAltKeyDown() and key == "a" then
		-- show
	end
end)


local editBox = CreateFrame("Button", "GlobalSearchEditBox", UIParent, "SecureActionButtonTemplate")
editBox:Hide()
editBox:SetAttribute("type", "spell")

for i = 65, 90 do
	local c = string.char(i)
	local action = CreateFrame("Button", "GlobalSearch" .. c .. "Button", UIParent,
		"SecureActionButtonTemplate,SecureHandlerClickTemplate")
	action:SetFrameRef("editBox", editBox)
	action:SetAttribute("_onclick", "local button = \"" .. c .. "\"" .. [=[
		local editBox = self:GetFrameRef("editBox")
		local t = ""
		if editBox:GetAttribute("spell") then
			t = editBox:GetAttribute("spell")
		end
		editBox:SetAttribute("spell", t .. button)
		print(editBox:GetAttribute("spell"))
	]=])

	action:SetAttribute("type", "macro")
	action:SetAttribute("macrotext", "/dump " .. tostring(i))

	SetOverrideBindingClick(bindingFrame, 10, string.char(i), "GlobalSearch" .. c .. "Button")
end

local execute = CreateFrame("Button", "GlobalSearchExecute", UIParent, "SecureActionButtonTemplate")
SetOverrideBindingClick(execute, 10, "ENTER", "GlobalSearchEditBox")
