-- Translator ZamestoTV
local L = LibStub("AceLocale-3.0"):NewLocale("GlobalSearch", "ruRU")
if not L then return end

--@localization(locale="ruRU", handle-unlocalized="comment")@

L.global_search = "Глобальный поиск"
L.enabled_providers = "Включенные провайдеры"
L.provider_options = "Настройки провайдеров"
L.ui_panels = "Панели интерфейса"
L.calendar = "Календарь"
L.toys = "Игрушки"
L.slash_commands = "Слэш-команды"
L.emotes = "Эмоции"
L.bags = "Сумки"
L.equipment_sets = "Комплекты снаряжения"
L.guilds_and_communities = "Гильдии и сообщества"
L.does_show_keybind_toggle = "Привязка клавиши скрывает при показе"
L.does_show_keybind_toggle_desc = "Когда строка поиска отображается, привязка клавиши будет скрывать строку поиска."
L.select_next_item = "Выбрать следующий предмет"
L.select_previous_item = "Выбрать предыдущий предмет"
L.select_next_page = "Выбрать следующую страницу"
L.select_previous_page = "Выбрать предыдущую страницу"
L.keybinding_in_use = "Привязка клавиши %s уже используется GlobalSearch."
L.building_achievement_cache = "Построение кэша достижений. Ваш FPS может снизиться до завершения процесса. Обычно это занимает до 15 секунд."
L.rebuild_cache = "Перестроить кэш"
L.done = "Готово"
L.page_x_of_x = "Страница %d из %d"
L.show_mouseover_tooltip = "Показывать подсказку при наведении"
L.show_mouseover_tooltip_desc = "Если включено, при наведении на результат поиска будет отображаться подсказка для предмета под курсором, а не для выбранного предмета."
L.system_options = "Системные настройки"
L.boss_from_instance = "%s (%s)"
L.minimap_tracking = "Отслеживание на миникарте"
L.x_is_enabled = "%s включен."
L.x_is_disabled = "%s отключен."
L.dungeon_difficulty_x = "Сложность подземелья: %s"
L.raid_difficulty_x = "Сложность рейда: %s"
L.legacy_raid_difficulty_x = "Сложность устаревшего рейда: %s"
L.maps = "Карты"
L.enabled_map_types = "Включенные типы карт"
L.map_with_floor = "%s: %s"
L.list_floors_separately = "Отдельно перечислять этажи"
L.instance_types = "Типы подземелий"
L.instances = "Подземелья"
L.bosses = "Боссы"
L.item_types = "Типы предметов"
L.uncategorized = "Без категории"
L.keybinding_help = [[Закрыть: %s
Выбрать предмет: ENTER
Ссылка на предмет в чате: %s
Предыдущий предмет: %s
Следующий предмет: %s
Предыдущая страница: %s
Следующая страница: %s]]
L.not_bound = "Не назначено"
L.show_help = "Показывать справку"
L.show_help_desc = "Если включено, привязки клавиш GlobalSearch будут показаны, если в поиске нет результатов."
L.position = "Позиция"
L.x_offset_from_center = "Смещение по X от центра"
L.y_offset_from_top = "Смещение по Y сверху"
L.size = "Размер"
L.width = "Ширина"
L.height = "Высота"
L.font = "Шрифт"
L.outline = "Контур"
L.none = "Нет"
L.thin = "Тонкий"
L.thick = "Толстый"
L.monochrome = "Монохромный"
L.number_of_recent_items = "Количество недавних предметов"
L.clear_recent_items = "Очистить недавние предметов"
L.x_items_removed = "%d предметов удалено."
L.frame_strata = "Слой фрейма"
L.appearance = "Внешний вид"
L.tooltip_font = "Шрифт подсказки"
L.help_text_font = "Шрифт текста справки"
L.results_per_page = "Результатов на странице"
L.preload_cache = "Предзагрузка кэша"
L.preload_cache_desc = "Кэш предметов будет медленно заполняться в фоновом режиме после входа в игру. Это предотвращает зависание игры на секунду при первом открытии поиска в большинстве случаев."
L.task_queue_time_allocation_ms = "Выделение времени для задач (мс)"
L.task_queue_time_allocation_ms_desc = "Максимальное количество времени в миллисекундах, которое может быть потрачено на фоновые задачи, такие как построение кэшей."
L.remove_from_recent_items = "Удалить из недавних предметов"
L.hyperlink = "Гиперссылка"
L.preload_cache_delay_sec = "Задержка предзагрузки кэша (сек)"
L.preload_cache_delay_sec_desc = "Задержка в секундах после входа в игру перед началом предзагрузки кэша."

L.achievements_search_provider_desc = "Предоставляет все достижения. Включает полученные, неполученные и достижения, которые еще не видны в интерфейсе."
L.bags_search_provider_desc = "Предоставляет все используемые предметы в сумках."
L.encounter_journal_search_provider_desc = "Предоставляет всех боссов подземелий и рейдов из журнала встреч."
L.interface_options_search_provider_desc = "Предоставляет все опции в Меню игры > Интерфейс > Игра. Выбор опции откроет соответствующую вкладку настроек."
L.mounts_search_provider_desc = "Предоставляет всех известных маунтов."
L.pets_search_provider_desc = "Предоставляет всех известных питомцев."
L.slash_commands_search_provider_desc = "Предоставляет все слэш-команды. При выборе команды она будет выполнена без аргументов. Невозможно передать аргументы команде при выполнении через GlobalSearch."
L.spells_search_provider_desc = "Предоставляет все используемые заклинания."
L.system_options_search_provider_desc = "Предоставляет все опции из Меню игры > Система."
L.toys_search_provider_desc = "Предоставляет все известные игрушки."
L.ui_panels_search_provider_desc = "Предоставляет различные панели интерфейса из базового интерфейса."
L.instance_options_search_provider_desc = "Предоставляет управление сложностью подземелий/рейдов."

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
