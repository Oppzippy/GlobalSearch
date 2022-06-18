local _, addon = ...

local AceGUI = LibStub("AceGUI-3.0")

local frame = AceGUI:Create("GlobalSearch-SearchBar")
frame:SetPoint("TOP", 0, -20)
frame:SetCallback("OnClose", function()
	frame:Release()
end)

local result = AceGUI:Create("GlobalSearch-SearchResult")
result:SetPoint("TOP", 0, -100)
