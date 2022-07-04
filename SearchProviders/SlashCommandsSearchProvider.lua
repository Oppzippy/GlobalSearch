---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class SlashCommandsSearchProvider : SearchProvider
local SlashCommandsSearchProvider = {
	localizedName = L.slash_commands,
}

---@return SearchItem[]
function SlashCommandsSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end
	return self.cache
end

---@return SearchItem[]
function SlashCommandsSearchProvider:Fetch()
	local items = {}

	local commands = {}
	-- SlashCmdList seems to get cleared somewhat randomly (10-15 sec after
	-- /reload or so), so it's not reliable to use that as a source of slash
	-- commands.
	local type, strfind = type, string.find
	for key, value in next, _G do
		if type(key) == "string" and strfind(key, "^SLASH_.+%d+$") then
			-- Filter out SLASH_TEXTTOSPEECH and other non-slash commands with the prefix
			if type(value) == "string" and strfind(value, "/", nil, true) == 1 then
				commands[value] = true
			end
		end
	end

	for command in next, commands do
		items[#items + 1] = {
			name = command,
			category = L.slash_commands,
			texture = 136243, -- Interface/Icons/Trade_Engineering
			macroText = command,
		}
	end
	return items
end

GlobalSearchAPI:RegisterProvider("slashCommands", SlashCommandsSearchProvider)
