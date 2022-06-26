---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class SlashCommandsItemProvider
---@field cache SearchItem[]
local SlashCommandsItemProvider = {}

---@return SearchItem[]
function SlashCommandsItemProvider:Get()
	if not self.cache then
		self.cache = self:SlashCommands()
	end
	return self.cache
end

---@return SearchItem[]
function SlashCommandsItemProvider:SlashCommands()
	local items = {}

	local commands = {}
	-- SlashCmdList seems to get cleared somewhat randomly (10-15 sec after
	-- /reload or so), so it's not reliable to use that as a source of slash
	-- commands.
	for k, v in next, _G do
		if type(k) == "string" and type(v) == "string" and k:find("SLASH_") == 1 then
			commands[v] = true
		end
	end

	for command in next, commands do
		items[#items + 1] = {
			name = command,
			category = L.slash_commands,
			-- TODO texture = 0,
			searchableText = command,
			macro = command,
		}
	end
	return items
end

ns.SearchItemProviders[#ns.SearchItemProviders + 1] = SlashCommandsItemProvider
