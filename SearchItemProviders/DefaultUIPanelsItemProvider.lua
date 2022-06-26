---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class DefaultUIPanelsItemProvider
---@field cache SearchItem[]
local DefaultUIPanelsItemProvider = {}

---@return SearchItem[]
function DefaultUIPanelsItemProvider:Get()
	if not self.cache then
		self.cache = self:CreateItems()
	end

	return self.cache
end

---@return SearchItem[]
function DefaultUIPanelsItemProvider:CreateItems()
	-- TODO
	-- Covenant Sanctum (and grarrison etc)
	return {
		{
			name = L.game_menu,
			category = L.ui_panels,
			texture = 130801, -- Interface/Buttons/UI-MICROBUTTON-MAINMENU-UP
			searchableText = L.game_menu,
			action = function()
				if GameMenuFrame:IsVisible() then
					PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
					HideUIPanel(GameMenuFrame)
				else
					PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
					ShowUIPanel(GameMenuFrame)
				end
			end,
		},
		{
			name = L.adventure_guide,
			category = L.ui_panels,
			texture = 525019, -- Interface/Buttons/UI-MicroButton-EJ-Up
			searchableText = L.adventure_guide,
			action = function()
				ToggleEncounterJournal()
			end,
		},
		{
			name = L.collections,
			category = L.ui_panels,
			texture = 615164, -- Interface/Buttons/UI-MicroButton-Mounts-Up
			searchableText = L.collections,
			action = function()
				ToggleCollectionsJournal()
			end,
		},
		{
			name = L.group_finder,
			category = L.ui_panels,
			texture = 130798, -- Interface/Buttons/UI-MicroButton-LFG-Up
			searchableText = L.group_finder,
			action = function()
				PVEFrame_ToggleFrame()
			end,
		},
		{
			name = L.guilds_and_communities,
			category = L.ui_panels,
			texture = 440546, -- Interface/Buttons/UI-MicroButton-Guild-Banner
			searchableText = L.guilds_and_communities,
			action = function()
				ToggleGuildFrame()
			end,
		},
		{
			name = L.quest_log,
			category = L.ui_panels,
			texture = 130804, -- Interface/Buttons/UI-MICROBUTTON-QUEST-UP
			searchableText = L.quest_log,
			action = function()
				ToggleQuestLog()
			end,
		},
		{
			name = L.world_map,
			category = L.ui_panels,
			texture = 137176, -- Interface/WorldMap/UI-World-Icon
			searchableText = L.world_map,
			action = function()
				ToggleWorldMap()
			end,
		},
		{
			name = L.achievements,
			category = L.ui_panels,
			texture = 235422, -- Interface/Buttons/UI-MicroButton-Achievement-Up
			searchableText = L.achievements,
			action = function()
				ToggleAchievementFrame()
			end,
		},
		{
			name = L.specialization_and_talents,
			category = L.ui_panels,
			texture = 130786, -- Interface/Buttons/UI-MicroButton-Abilities-Up
			searchableText = L.specialization_and_talents,
			action = function()
				ToggleTalentFrame()
			end,
		},
		{
			name = L.spellbook_and_abilities,
			category = L.ui_panels,
			texture = 130810, -- Interface/Buttons/UI-MicroButton-Spellbook-Up
			searchableText = L.spellbook_and_abilities,
			action = function()
				ToggleSpellBook("spell")
			end,
		},
		{
			name = L.character_info,
			category = L.ui_panels,
			-- SetPortraitTexture should ideally be used to match the default UI, but that adds complication for a single case.
			-- A basic sword texture will suffice.
			texture = 135349, -- Interface/Icons/INV_Sword_39
			searchableText = L.character_info,
			action = function()
				ToggleCharacter("PaperDollFrame")
			end,
		},
		{
			name = L.calendar,
			category = L.ui_panels,
			-- SetPortraitTexture should ideally be used to match the default UI, but that adds complication for a single case.
			-- A basic sword texture will suffice.
			texture = 986189, -- Interface/Calendar/Calendar
			searchableText = L.calendar,
			action = function()
				ToggleCalendar()
			end,
		},
		{
			name = L.open_all_bags,
			category = L.ui_panels,
			-- SetPortraitTexture should ideally be used to match the default UI, but that adds complication for a single case.
			-- A basic sword texture will suffice.
			texture = 130716, -- Interface/Buttons/Button-Backpack-Up
			searchableText = L.open_all_bags,
			action = function()
				ToggleAllBags()
			end,
		},
	}
end

ns.SearchItemProviders[#ns.SearchItemProviders + 1] = DefaultUIPanelsItemProvider
