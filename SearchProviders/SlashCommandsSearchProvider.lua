---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class SlashCommandsSearchProvider : SearchProvider
local SlashCommandsSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.slash_commands)
SlashCommandsSearchProvider.description = L.slash_commands_search_provider_desc

---@return SearchItem[]
function SlashCommandsSearchProvider:Fetch()
	ChatFrame_ImportAllListsToHash()
	local commands = {}
	for command in next, hash_SlashCmdList do
		commands[command] = true
	end
	for _, identifier in ipairs(self:GetSecureSlashCommands()) do
		local i = 1
		while true do
			local command = _G["SLASH_" .. identifier .. i]
			if not command then
				break
			end
			commands[command] = true
			i = i + 1
		end
	end

	local items = {}
	for command in next, commands do
		local lowercaseCommand = ns.UTF8.FromCodePoints(ns.Unicode.ToLower(ns.UTF8.ToCodePoints(command)))
		items[#items + 1] = {
			id = command,
			name = lowercaseCommand,
			texture = 136243, -- Interface/Icons/Trade_Engineering
			macroText = command,
		}
	end
	return items
end

function SlashCommandsSearchProvider:GetSecureSlashCommands()
	local expansion = GetClientDisplayExpansionLevel()
	return ns.SecureSlashCommandLists[expansion] or ns.SecureSlashCommandLists.default
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_SlashCommands", SlashCommandsSearchProvider)
