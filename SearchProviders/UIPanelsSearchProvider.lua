---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")

---@class UIPanelsSearchProvider : SearchProvider
local UIPanelsSearchProvider = GlobalSearchAPI:CreateProvider(L.global_search, L.ui_panels)
UIPanelsSearchProvider.description = L.ui_panels_search_provider_desc

---@param atlas string
---@return fun(texture: Texture)
local function createAtlasTextureSetter(atlas)
	---@param texture Texture
	return function(texture)
		texture:SetAtlas(atlas)
	end
end

local itemsByRequirement = {
	GameMenuFrame = {
		id = "GameMenuFrame",
		name = L.game_menu,
		texture = createAtlasTextureSetter("hud-microbutton-MainMenu-Up"),
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
	ToggleEncounterJournal = {
		id = "ToggleEncounterJournal",
		name = L.adventure_guide,
		texture = createAtlasTextureSetter("hud-microbutton-EJ-Up"),
		action = function()
			ToggleEncounterJournal()
		end,
	},
	ToggleCollectionsJournal = {
		id = "ToggleCollectionsJournal",
		name = L.collections,
		texture = createAtlasTextureSetter("hud-microbutton-Mounts-Up"),
		action = function()
			ToggleCollectionsJournal()
		end,
	},
	PVEFrame_ToggleFrame = {
		id = "PVEFrame_ToggleFrame",
		name = L.group_finder,
		texture = createAtlasTextureSetter("hud-microbutton-LFG-Up"),
		action = function()
			PVEFrame_ToggleFrame()
		end,
	},
	ToggleLFGParentFrame = {
		id = "ToggleLFGParentFrame",
		name = L.group_finder,
		texture = createAtlasTextureSetter("hud-microbutton-LFG-Up"),
		action = function()
			ToggleLFGParentFrame()
		end,
	},
	ToggleGuildFrame = {
		id = "ToggleGuildFrame",
		name = L.guilds_and_communities,
		texture = createAtlasTextureSetter("hud-microbutton-Guild-Banner"),
		action = function()
			ToggleGuildFrame()
		end,
	},
	ToggleQuestLog = {
		id = "ToggleQuestLog",
		name = L.quest_log,
		texture = createAtlasTextureSetter("hud-microbutton-Quest-Up"),
		action = function()
			ToggleQuestLog()
		end,
	},
	ToggleWorldMap = {
		id = "ToggleWorldMap",
		name = L.world_map,
		texture = 137176, -- Interface/WorldMap/UI-World-Icon
		action = function()
			ToggleWorldMap()
		end,
	},
	ToggleAchievementFrame = {
		id = "ToggleAchievementFrame",
		name = L.achievements,
		texture = createAtlasTextureSetter("hud-microbutton-Achievement-Up"),
		action = function()
			ToggleAchievementFrame()
		end,
	},
	ToggleTalentFrame = {
		id = "ToggleTalentFrame",
		name = L.specialization_and_talents,
		texture = createAtlasTextureSetter("hud-microbutton-Talents-Up"),
		action = function()
			ToggleTalentFrame()
		end,
	},
	ToggleSpellBook = {
		id = "ToggleSpellBook",
		name = L.spellbook_and_abilities,
		texture = createAtlasTextureSetter("hud-microbutton-Spellbook-Up"),
		action = function()
			ToggleSpellBook("spell")
		end,
	},
	ToggleCharacter = {
		id = "ToggleCharacter",
		name = L.character_info,
		-- SetPortraitTexture should ideally be used to match the default UI, but that adds complication for a single case.
		-- A basic sword texture will suffice.
		texture = function(texture)
			SetPortraitTexture(texture, "player")
		end,
		action = function()
			ToggleCharacter("PaperDollFrame")
		end,
	},
	ToggleCalendar = {
		id = "ToggleCalendar",
		name = L.calendar,
		---@param texture Texture
		texture = function(texture)
			texture:SetTexture("Interface\\Calendar\\UI-Calendar-Button")
			texture:SetTexCoord(0, 0.390625, 0, 0.78125)
		end,
		action = function()
			ToggleCalendar()
		end,
	},
	ToggleAllBags = {
		id = "ToggleAllBags",
		name = L.open_all_bags,
		texture = 130716, -- Interface/Buttons/Button-Backpack-Up
		action = function()
			ToggleAllBags()
		end,
	},
}

---@return fun(): SearchItem?
function UIPanelsSearchProvider:Fetch()
	return coroutine.wrap(function()
		for requirement, item in next, itemsByRequirement do
			if _G[requirement] then
				coroutine.yield(item)
			end
		end
	end)
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_DefaultUIPanels", UIPanelsSearchProvider)
