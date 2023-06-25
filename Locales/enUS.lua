local L = LibStub("AceLocale-3.0"):NewLocale("GlobalSearch", "enUS", true)

L.global_search = "GlobalSearch"
L.enabled_providers = "Enabled Providers"
L.provider_options = "Provider Options"
L.ui_panels = "UI Panels"
L.calendar = "Calendar"
L.toys = "Toys"
L.slash_commands = "Slash Commands"
L.emotes = "Emotes"
L.bags = "Bags"
L.equipment_sets = "Equipment Sets"
L.guilds_and_communities = "Guilds and Communities"
L.does_show_keybind_toggle = "Keybind Hides When Shown"
L.does_show_keybind_toggle_desc = "When the search bar is shown, the show keybind will instead hide the search bar."
L.select_next_item = "Select Next Item"
L.select_previous_item = "Select Previous Item"
L.select_next_page = "Select Next Page"
L.select_previous_page = "Select Previous Page"
L.keybinding_in_use = "Keybinding %s is already in use by GlobalSearch."
L.building_achievement_cache =
"Building achievement cache. Your frame rate will be affected until this completes. This is usually done within 15 seconds."
L.rebuild_cache = "Rebuild Cache"
L.done = "Done"
L.page_x_of_x = "Page %d of %d"
L.show_mouseover_tooltip = "Show Mouseover Tooltip"
L.show_mouseover_tooltip_desc =
"If enabled, mousing over a search result will show the tooltip for the item under the cursor rather than the selected item."
L.system_options = "System Options"
L.boss_from_instance = "%s (%s)"
L.minimap_tracking = "Minimap Tracking"
L.x_is_enabled = "%s is enabled."
L.x_is_disabled = "%s is disabled."
L.dungeon_difficulty_x = "Dungeon Difficulty: %s"
L.raid_difficulty_x = "Raid Difficulty: %s"
L.legacy_raid_difficulty_x = "Legacy Raid Difficulty: %s"
L.maps = "Maps"
L.enabled_map_types = "Enabled Map Types"
L.map_with_floor = "%s: %s"
L.list_floors_separately = "List Floors Separately"
L.instance_types = "Instance Types"
L.instances = "Instances"
L.bosses = "Bosses"
L.item_types = "Item Types"
L.uncategorized = "Uncategorized"
L.keybinding_help = [[Close: %s
Select Item: ENTER
Link Item in Chat: %s
Previous Item: %s
Next Item: %s
Previous Page: %s
Next Page: %s]]
L.not_bound = "Not Bound"
L.show_help = "Show Help"
L.show_help_desc = "If enabled, the GlobalSearch keybindings will be shown when the search has no results."
L.position = "Position"
L.x_offset_from_center = "X Offset from Center"
L.y_offset_from_top = "Y Offset from Top"
L.size = "Size"
L.width = "Width"
L.height = "Height"
L.font = "Font"
L.outline = "Outline"
L.none = "None"
L.thin = "Thin"
L.thick = "Thick"
L.monochrome = "Monochrome"
L.number_of_recent_items = "Number of Recent Items"
L.clear_recent_items = "Clear Recent Items"
L.x_items_removed = "%d items removed."
L.frame_strata = "Frame Strata"
L.appearance = "Appearance"
L.tooltip_font = "Tooltip Font"
L.help_text_font = "Help Text Font"
L.results_per_page = "Results per Page"
L.preload_cache = "Preload Cache"
L.preload_cache_desc =
"The item cache will be slowly built up in the background after logging in. This stops the game from freezing for a second when opening the search for the first time in most cases."
L.task_queue_time_allocation_ms = "Task Queue Time Allocation (ms)"
L.task_queue_time_allocation_ms_desc =
"Maximum amount of time per frame in milliseconds that can be spent on background tasks, such as building caches."
L.remove_from_recent_items = "Remove from Recent Items"
L.hyperlink = "Hyperlink"
L.preload_cache_delay_sec = "Preload Cache Delay (sec)"
L.preload_cache_delay_sec_desc = "Delay after login in seconds before preloading the cache."

L.achievements_search_provider_desc =
"Provides all achievements. Includes earned, unearned, and achievements further in chains that aren't visible in the UI yet."
L.bags_search_provider_desc = "Provides all usable items in bags."
L.encounter_journal_search_provider_desc = "Provides all dungeon and raid bosses from the dungeon journal."
L.interface_options_search_provider_desc =
"Provides all options in Game Menu > Interface > Game. Selecting an option will open its options tab."
L.mounts_search_provider_desc = "Provides all known mounts."
L.pets_search_provider_desc = "Provides all known pets."
L.slash_commands_search_provider_desc =
"Provides all slash commands. When a command is selected, it will be run as is with no arguments. It is not possible to pass any arguments to the command when running it through GlobalSearch."
L.spells_search_provider_desc = "Provides all usable spells."
L.system_options_search_provider_desc = "Provides all options from Game Menu > System."
L.toys_search_provider_desc = "Provides all known toys."
L.ui_panels_search_provider_desc = "Provides various UI panels from the base UI."
L.instance_options_search_provider_desc = "Provides dungeon/raid difficulty controls."

L.key_bindings = KEY_BINDINGS
L.general = GENERAL
L.show = SHOW
L.mounts = MOUNTS
L.pets = PETS
L.game_menu = MAINMENU_BUTTON
L.adventure_guide = ADVENTURE_JOURNAL
L.collections = COLLECTIONS
L.group_finder = DUNGEONS_BUTTON
L.quest_log = QUESTLOG_BUTTON
L.world_map = WORLDMAP_BUTTON
L.achievements = ACHIEVEMENT_BUTTON
L.specialization_and_talents = TALENTS_BUTTON
L.spellbook_and_abilities = SPELLBOOK_ABILITIES_BUTTON
L.character_info = CHARACTER_BUTTON
L.open_all_bags = BINDING_NAME_OPENALLBAGS
L.spells = SPELLS
L.macros = MACROS
L.interface_options = INTERFACE_OPTIONS
L.encounter_journal = ENCOUNTER_JOURNAL
L.instance_options = UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INSTANCE
L.reset_all_instances = RESET_INSTANCES
L.dungeons = DUNGEONS
L.raids = RAIDS
