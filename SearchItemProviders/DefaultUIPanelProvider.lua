---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@return SearchItem[]
local function GetDefaultUIPanels()
	-- TODO
	-- Covenant Sanctum (and grarrison etc)

	return {
		{
			name = MAINMENU_BUTTON,
			category = L.ui_panels,
			texture = 130801, -- Interface/Buttons/UI-MICROBUTTON-MAINMENU-UP
			searchableText = MAINMENU_BUTTON,
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
			name = ADVENTURE_JOURNAL,
			category = L.ui_panels,
			texture = 525019, -- Interface/Buttons/UI-MicroButton-EJ-Up
			searchableText = ADVENTURE_JOURNAL,
			action = function()
				ToggleEncounterJournal()
			end,
		},
		{
			name = COLLECTIONS,
			category = L.ui_panels,
			texture = 615164, -- Interface/Buttons/UI-MicroButton-Mounts-Up
			searchableText = COLLECTIONS,
			action = function()
				ToggleCollectionsJournal()
			end,
		},
		{
			name = DUNGEONS_BUTTON,
			category = L.ui_panels,
			texture = 130798, -- Interface/Buttons/UI-MicroButton-LFG-Up
			searchableText = DUNGEONS_BUTTON,
			action = function()
				PVEFrame_ToggleFrame()
			end,
		},
		{
			name = GUILD_AND_COMMUNITIES,
			category = L.ui_panels,
			texture = 440546, -- Interface/Buttons/UI-MicroButton-Guild-Banner
			searchableText = GUILD_AND_COMMUNITIES,
			action = function()
				ToggleGuildFrame()
			end,
		},
		{
			name = QUESTLOG_BUTTON,
			category = L.ui_panels,
			texture = 130804, -- Interface/Buttons/UI-MICROBUTTON-QUEST-UP
			searchableText = QUESTLOG_BUTTON,
			action = function()
				ToggleQuestLog()
			end,
		},
		{
			name = WORLDMAP_BUTTON,
			category = L.ui_panels,
			texture = 137176, -- Interface/WorldMap/UI-World-Icon
			searchableText = WORLDMAP_BUTTON,
			action = function()
				ToggleWorldMap()
			end,
		},
		{
			name = ACHIEVEMENT_BUTTON,
			category = L.ui_panels,
			texture = 235422, -- Interface/Buttons/UI-MicroButton-Achievement-Up
			searchableText = ACHIEVEMENT_BUTTON,
			action = function()
				ToggleAchievementFrame()
			end,
		},
		{
			name = TALENTS_BUTTON,
			category = L.ui_panels,
			texture = 130786, -- Interface/Buttons/UI-MicroButton-Abilities-Up
			searchableText = TALENTS_BUTTON,
			action = function()
				ToggleTalentFrame()
			end,
		},
		{
			name = SPELLBOOK_ABILITIES_BUTTON,
			category = L.ui_panels,
			texture = 130810, -- Interface/Buttons/UI-MicroButton-Spellbook-Up
			searchableText = SPELLBOOK_ABILITIES_BUTTON,
			action = function()
				ToggleSpellBook("spell")
			end,
		},
		{
			name = CHARACTER_BUTTON,
			category = L.ui_panels,
			-- SetPortraitTexture should ideally be used to match the default UI, but that adds complication for a single case.
			-- A basic sword texture will suffice.
			texture = 135349, -- Interface/Icons/INV_Sword_39
			searchableText = CHARACTER_BUTTON,
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
			name = BINDING_NAME_OPENALLBAGS,
			category = L.ui_panels,
			-- SetPortraitTexture should ideally be used to match the default UI, but that adds complication for a single case.
			-- A basic sword texture will suffice.
			texture = 130716, -- Interface/Buttons/Button-Backpack-Up
			searchableText = BINDING_NAME_OPENALLBAGS,
			action = function()
				ToggleAllBags()
			end,
		},
	}
end

ns.SearchItemProvider.GetDefaultUIPanels = GetDefaultUIPanels
