---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GlobalSearch")
--ToggleLFGParentFrame

---@class UIPanelsSearchProvider : SearchProvider
local UIPanelsSearchProvider = {
	localizedName = L.ui_panels,
	description = L.ui_panels_search_provider_desc,
}

---@return SearchItem[]
function UIPanelsSearchProvider:Get()
	if not self.cache then
		self.cache = self:Fetch()
	end

	return self.cache
end

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
		name = L.adventure_guide,
		texture = createAtlasTextureSetter("hud-microbutton-EJ-Up"),
		action = function()
			ToggleEncounterJournal()
		end,
	},
	ToggleCollectionsJournal = {
		name = L.collections,
		texture = createAtlasTextureSetter("hud-microbutton-Mounts-Up"),
		action = function()
			ToggleCollectionsJournal()
		end,
	},
	PVEFrame_ToggleFrame = {
		name = L.group_finder,
		texture = createAtlasTextureSetter("hud-microbutton-LFG-Up"),
		action = function()
			PVEFrame_ToggleFrame()
		end,
	},
	ToggleLFGParentFrame = {
		name = L.group_finder,
		texture = createAtlasTextureSetter("hud-microbutton-LFG-Up"),
		action = function()
			ToggleLFGParentFrame()
		end,
	},
	ToggleGuildFrame = {
		name = L.guilds_and_communities,
		texture = createAtlasTextureSetter("hud-microbutton-Guild-Banner"),
		action = function()
			ToggleGuildFrame()
		end,
	},
	ToggleQuestLog = {
		name = L.quest_log,
		texture = createAtlasTextureSetter("hud-microbutton-Quest-Up"),
		action = function()
			ToggleQuestLog()
		end,
	},
	ToggleWorldMap = {
		name = L.world_map,
		texture = 137176, -- Interface/WorldMap/UI-World-Icon
		action = function()
			ToggleWorldMap()
		end,
	},
	ToggleAchievementFrame = {
		name = L.achievements,
		texture = createAtlasTextureSetter("hud-microbutton-Achievement-Up"),
		action = function()
			ToggleAchievementFrame()
		end,
	},
	ToggleTalentFrame = {
		name = L.specialization_and_talents,
		texture = createAtlasTextureSetter("hud-microbutton-Talents-Up"),
		action = function()
			ToggleTalentFrame()
		end,
	},
	ToggleSpellBook = {
		name = L.spellbook_and_abilities,
		texture = createAtlasTextureSetter("hud-microbutton-Spellbook-Up"),
		action = function()
			ToggleSpellBook("spell")
		end,
	},
	ToggleCharacter = {
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
		name = L.open_all_bags,
		texture = 130716, -- Interface/Buttons/Button-Backpack-Up
		action = function()
			ToggleAllBags()
		end,
	},
}

---@return SearchItem[]
function UIPanelsSearchProvider:Fetch()
	---@type SearchItem[]
	local items = {}
	for requirement, item in next, itemsByRequirement do
		if _G[requirement] then
			items[#items + 1] = item
		end
	end
	return items
end

GlobalSearchAPI:RegisterProvider("GlobalSearch_DefaultUIPanels", UIPanelsSearchProvider)
