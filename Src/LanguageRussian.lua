---@class BomLanguageRussianModule
local russianModule = {}
BomModuleManager.languageRussianModule = russianModule

---@return BomLanguage
function russianModule:Translations()
  return {
    ["Category_class"]                          = "Бафы вашего класса",
    ["Category_classBlessing"]                  = "Благословения",
    ["Category_pet"]                            = "Питомец",
    ["Category_tracking"]                       = "Поиск вокруг",
    ["Category_aura"]                           = "Ауры",
    ["Category_seal"]                           = "Печати",

    ["Category_classicPhysicalFood"]            = "Еда для физ. атак (Classic)",
    ["Category_classicSpellFood"]               = "Еда для заклинаний (Classic)",
    ["Category_classicFood"]                    = "Прочая еда (Classic)",
    ["Category_classicPhysElixir"]              = "Эликсиры для физ. атак (Classic)",
    ["Category_classicPhysBuff"]                = "Бафы для физ. атак (Classic)",
    ["Category_classicSpellElixir"]             = "Эликсиры для заклинаний (Classic)",
    ["Category_classicBuff"]                    = "Бафы (Classic)",
    ["Category_classicElixir"]                  = "Эликсиры (Classic)",
    ["Category_classicFlask"]                   = "Настои (Classic)",

    ["Category_tbcPhysicalFood"]                = "Еда для физ. атак (TBC)",
    ["Category_tbcSpellFood"]                   = "Еда для заклинаний (TBC)",
    ["Category_tbcFood"]                        = "Прочая еда (TBC)",
    ["Category_tbcPhysElixir"]                  = "Эликсиры для физ. атак (TBC)",
    ["Category_tbcSpellElixir"]                 = "Эликсиры для заклинаний (TBC)",
    ["Category_tbcElixir"]                      = "Эликсиры (TBC)",
    ["Category_tbcFlask"]                       = "Настои (TBC)",

    ["Category_wotlkPhysicalFood"]              = "Еда для физ. атак (WotLK)",
    ["Category_wotlkSpellFood"]                 = "Еда для заклинаний (WotLK)",
    ["Category_wotlkFood"]                      = "Прочая еда (WotLK)",
    ["Category_wotlkPhysElixir"]                = "Эликсиры для физ. атак (WotLK)",
    ["Category_wotlkSpellElixir"]               = "Эликсиры для заклинаний (WotLK)",
    ["Category_wotlkElixir"]                    = "Эликсиры (WotLK)",
    ["Category_wotlkFlask"]                     = "Настои (WotLK)",

    ["Category_scroll"]                         = "Свитки",
    ["Category_weaponEnchantment"]              = "Временные зачарования оружия",
    ["Category_classWeaponEnchantment"]         = "Зачарования вашего класса",
    ["Category_none"]                           = "Прочее",

    CHAT_MSG_PREFIX                             = "Бафомёт: ", --префикс в чате
    Buffomat                                    = "Бафомёт", --шапка окна аддона
    AboutInfo                                   = "Выносливость! Интеллект! Дух! - Это звучит знакомо? "
            .. "Бафомёт просканирует участников рейда/группы на отсутствие положительных эффектов "
            .. "и в одно мгновение примените их. Когда у троих или более участников отсутствует эффект, "
            .. "то будет использовано одно заклинание для всей группы. Он также запоминает активацию "
            .. "отслеживания для 'Поиска травы'.|nОн также поможет вам воскресить игроков, выбрав "
            .. "сначала паладинов, священников и шаманов. ",
    AboutSlashCommand                           = "На данный момент это должна быть команда без параметров!",
    AboutUsage                                  = "Вам нужен свободный слот макроса, чтобы использовать это дополнение. "
            .. "Главное окно имеет две вкладки 'Эффекты' и 'Заклинания'. В разделе 'Эффектов' вы "
            .. "найдете все недостающие эффекты и кнопку применить.В разделе 'Заклинания' вы можете "
            .. "настроить, какие заклинания следует контролировать или если он должен использовать "
            .. "групповую версию. Выберите, если он должен использовать только на вас или для всех "
            .. "участников группы. Выберите, какой эффект должен быть активен, для какого класса. "
            .. "Вы также можете игнорировать целые группы (например, в рейде, когда вы должны использовать "
            .. "только инт в группе 7 и 8). Вы также можете выбрать здесь, что один эффект должен "
            .. "быть активен на текущей цели. Например, как друид, нажмите на основного танка и "
            .. "выберете 'Шипы' - или другой '-' (последний символ) - оно изменится на перекрестие, "
            .. "и теперь Бафомёт помнит, что вы держите эффект на основном танке. У вас есть два "
            .. "варианта, чтобы применить эффект из списка пропущенных эффектов. Кнопка с "
            .. "заклинанием в окне или макрос Buff'o'mat. Вы найдете его с помощью кнопки 'Macro' "
            .. "в «строке заголовка» главного окна.|nВАЖНо: Бафомёт работает только вне боя, потому "
            .. "что игра не позволяет менять макросы во время боя. Кроме того, вы не можете открыть "
            .. "или закрыть главное окно во время боя!",
    BtnCancel                                   = "Закрыть",
    BtnOpen                                     = "Открыть",
    BtnSettings                                 = "Настройки",
    BtnSettingsSpells                           = "Настройки заклинаний",

    ["options.general.group.AutoActions"]       = "Реакция на события",
    ["options.general.group.Convenience"]       = "Удобство",
    ["options.general.group.General"]           = "Общие настройки",
    ["options.general.group.Scan"]              = "Сканирование",
    ["options.general.group.Buffing"]           = "Время бафов",
    ["options.general.group.Visibility"]        = "Скрыть категории",
    ["options.general.group.Class"]             = "Классы",

    ["options.short.ActivateBomOnSpiritTap"]    = "Запретить Бафомёт, при 'Захвате духа' жреца",
    ["options.short.ArgentumDawn"]              = "Не забудьте (снять)экипировать Жетон Серебряного Рассвета",
    ["options.short.AutoOpen"]                  = "Автоматическое открытие/закрытие",
    ["options.short.DeathBlock"]                = "Не применять групповые эффекты, когда кто-то мертв",
    ["options.short.GroupBuff"]                 = "Групповые бафы, если это экономит ману (увеличенный расход реагентов)",
    ["options.short.InInstance"]                = "Сканировать бафы в подземельях и рейдах",
    ["options.short.InPVP"]                     = "Сканировать бафы на полях битвы",
    ["options.short.InWorld"]                   = "Сканировать бафы в открытом мире",
    ["options.short.LockMinimapButton"]         = "Блокировка положения кнопки у миникарты",
    ["options.short.LockMinimapButtonDistance"] = "Минимизировать расстояние до миникарты",
    ["options.short.NoGroupBuff"]               = "Всегда давать одиночные бафы",
    ["options.short.PreventPVPTag"]             = "Не бафать PvP игроков, если ваш PvP выключен",
    ["options.short.ReplaceSingle"]             = "Заменить одиночный баф групповым",
    ["options.short.ResGhost"]                  = "Пытаться воскрешать призраки, если тело лежит близко",
    ["options.short.SameZone"]                  = "Только если находится в одной зоне со мной",
    ["options.short.ScanInRestArea"]            = "Сканировать бафы в городах и тавернах",
    ["options.short.ScanInStealth"]             = "Сканировать бафы в режиме незаметности",
    ["options.short.ShowClassicConsumables"]    = "Показывать бафы из классической версии",
    ["options.short.ShowMinimapButton"]         = "Показать кнопку у миникарты",
    ["options.short.ShowTBCConsumables"]        = "Показывать бафы из TBC",
    ["options.short.SomeoneIsDrinking"]         = "Когда кто-то в группе пьёт",
    ["options.short.UseRank"]                   = "Использовать заклинание с рангом",
    ["options.short.FadeWhenNothingToDo"]       = "Делать окно прозрачным, когда нет задач",
    ["options.short.ShamanFlametongueRanked"]   = "Шаман: Использовать пониженный ранг языков пламени на правой руке",

    ["options.long.FadeWhenNothingToDo"]        = "Установить прозрачность окна Бафомёта, если нечего делать",
    ["options.long.ActivateBomOnSpiritTap"]     = "Запретить Бафомёт, если 'Захват духа' жреца активен и мана меньше указанного процента",

    InfoSomeoneIsDrinking                       = "Один игрок пьёт",
    InfoMultipleDrinking                        = "Несколько игроков пьют (%d)",

    ["options.long.MinBlessing"]                = "Количество отсутствующих благословений, чтобы использовать большее благословение",
    ["options.long.MinBuff"]                    = "Количество отсутствующих бафов, необходимое для использования группового бафа",
    ["options.long.Time1800"]                   = "Освежать баф продолжительностью <=30 мин, если осталось менее",
    ["options.long.Time300"]                    = "Освежать баф продолжительностью <=5 мин, если осталось менее",
    ["options.long.Time3600"]                   = "Освежать баф продолжительностью <=60 мин, если осталось менее",
    ["options.long.Time60"]                     = "Освежать баф продолжительностью <=60 сек, если осталось менее",
    ["options.long.Time600"]                    = "Освежать баф продолжительностью <=10 мин, если осталось менее",
    ["options.long.ShamanFlametongueRanked"]    = "Шаман: Для spellhancement шаманов использовать язык пламени "
            .. "пониженного ранга на правом оружии, и максимального ранга на левом. "
            .. "Включайте эту опцию, когда в правой руке у вас оружие с силой заклинаний.",

    ["options.short.MinBlessing"]               = "Большое благословение, если нуждаются более",
    ["options.short.MinBuff"]                   = "Групповой баф, если нуждаются более",
    ["options.short.Time1800"]                  = "Продолжительность <=30 мин:",
    ["options.short.Time300"]                   = "Продолжительность <=5 мин:",
    ["options.short.Time3600"]                  = "Продолжительность <=60 мин:",
    ["options.short.Time60"]                    = "Продолжительность <=60 сек:",
    ["options.short.Time600"]                   = "Продолжительность <=10 мин:",

    ["options.general.sound.None"]              = "- не играть звук -", -- play no sound on task

    ["tasklist.IgnoredBuffOn"]                  = "Пропускаем %s: %s", -- when a buff is not listed because a better buff exists
    ["task.target.Self"]                        = "На себя", -- use instead of name when buffing self
    ["task.target.SelfOnly"]                    = "Самобаф",
    ["task.type.RegularBuff"]                   = "Баф",
    ["task.type.GroupBuff"]                     = "Групповой",
    ["task.type.GroupBuff.Self"]                = "Групповой (на себя)",
    ["task.type.Tracking"]                      = "Слежение",
    ["task.type.Reminder"]                      = "Напоминание",
    ["task.type.Resurrect"]                     = "Воскрешение",
    ["task.type.MissingConsumable"]             = "Не хватает", -- deprecated?
    ["task.type.Consumable"]                    = "Расходник", -- deprecated?
    ["task.hint.HoldShiftConsumable"]           = "Удерживайте Shift/Ctrl или Alt",

    Header_TRACKING                             = "Отслеживание",
    HeaderCredits                               = "Авторы",
    HeaderCustomLocales                         = "Перевод",
    HeaderInfo                                  = "Информация",
    HeaderRenew                                 = "Продлить баф до истечения срока действия (в секундах)",
    HeaderSlashCommand                          = "/ Команды",
    HeaderSupportedSpells                       = "Поддерживаемые заклинания",
    HeaderUsage                                 = "Использование",
    HeaderWatchGroup                            = "Смотреть в рейдовой группе",
    FORMAT_BUFF_GROUP                           = "Группа %s %s",
    FORMAT_BUFF_SINGLE                          = "%s %s",
    FORMAT_BUFF_SELF                            = "%s %s на себя",
    ["castButton.Busy"]                         = "Занят / Кастую",
    ["castButton.BusyChanneling"]               = "Занят / Долгое заклинание",
    ["castButton.inactive.InCombat"]            = "В бою",
    ["castButton.inactive.RestArea"]            = "В зоне отдыха (откл. в опциях)",
    ["castButton.inactive.Mounted"]             = "Игрок в седле (откл. в опциях)",
    ["castButton.inactive.IsStealth"]           = "Режим незаметности (откл. в опциях)",
    ["castButton.inactive.IsDead"]              = "Мертв",
    ["castButton.CantCastMaybeOOM"]             = "Недостаточно маны или другая причина",
    ["message.CancelBuff"]                      = "Отменён баф %s от %s",
    ["message.BuffExpired"]                     = "%s заклинание истекло.",
    ["message.ShowHideInCombat"]                = "Во время боя нельзя показывать или скрывать панели",
    MsgDownGrade                                = "Понижение ранга заклинания %s для %s. Попробуйте выполнить баф ещё раз.",
    ["castButton.NothingToDo"]                  = "Нечего делать",
    --MsgLocalRestart                             = "Настройки не подействуют до перезагрузки модов (команда /reload)",
    ["castButton.NoMacroSlots"]                 = "Нужен хотя бы один свободный слот для макро!",
    ["castButton.Next"]                         = "%s @ %s",
    InactiveReason_DeadMember                   = "Кто-то мертв",
    PanelAbout                                  = "Информация",
    SlashClose                                  = "Закрыть окно Бафомёта",
    SlashOpen                                   = "Открыть Бафомёт",
    SlashReset                                  = "Сбросить окно Бафомёта",
    SlashSpellBook                              = "Повторное сканирование книги заклинаний",
    SlashUpdate                                 = "Обновить список макросов",
    TabBuff                                     = "Баф",
    TabBuffOnlySelf                             = "Баф только себя", -- Shown if all raid groups deselected
    TabSpells                                   = "Заклинания",
    TooltipEnableSpell                          = "Вкл./откл. заклинание",
    TooltipGroup                                = "Следить за группой %d в рейде",
    TooltipRaidGroupsSettings                   = "Настройки рейдовых групп",
    MessageAddedForced                          = "Добавлена цель в список бафов",
    MessageClearedForced                        = "Убрана дополнительная цель из списка бафов",
    MessageAddedExcluded                        = "Добавлена цель в список пропуска",
    MessageClearedExcluded                      = "Цель убрана из списка пропуска",

    HintCancelThisBuff                          = "Отменять баф",
    HintCancelThisBuff_Combat                   = "Перед боем",
    HintCancelThisBuff_Always                   = "Сразу",

    TooltipWhisperWhenExpired                   = "Сообщить игроку, который дал этот баф, когда время бафа истечёт",
    TooltipMainHand                             = "Правая рука",
    TooltipOffHand                              = "Левая рука",
    ShamanEnchantBlocked                        = "Ожидание бафа на другую руку", -- TBC
    TooltipIncludesAllRanks                     = "Любой вариант этого бафа",
    TooltipSimilarFoods                         = "Любая подобная еда",

    ["tooltip.buff.agility"]                    = "+Ловк.",
    ["tooltip.buff.allResist"]                  = "+Сопр. магии всех школ",
    ["tooltip.buff.attackPower"]                = "+Атака",
    ["tooltip.buff.crit"]                       = "+Крит",
    ["tooltip.buff.fireResist"]                 = "+Сопр. огню",
    ["tooltip.buff.frostResist"]                = "+Сопр. льду",
    ["tooltip.buff.haste"]                      = "+Скорость",
    ["tooltip.buff.healing"]                    = "+Лечение",
    ["tooltip.buff.hit"]                        = "+Меткость",
    ["tooltip.buff.maxHealth"]                  = "+Макс. здоровье",
    ["tooltip.buff.mp5"]                        = "+Мана/5",
    ["tooltip.buff.resilience"]                 = "+Устойч.",
    ["tooltip.buff.spellPower"]                 = "+Заклинания",
    ["tooltip.buff.spellCrit"]                  = "+Крит заклинаний",
    ["tooltip.buff.spirit"]                     = "+Дух",
    ["tooltip.buff.stamina"]                    = "+Выносл.",
    ["tooltip.buff.strength"]                   = "+Сила",
    ["tooltip.buff.comboMealWotlk"]             = "+Атака/+Заклинания",
    ["tooltip.food.multipleFoodItems"]          = " (различная еда с таким бафом)",
    ["tooltip.buff.armorPenetration"]           = "+Пробивание брони",

    ["tooltip.alcohol.stamina"]                 = "Алкоголь +Выносл",
    ["tooltip.alcohol.spirit"]                  = "Алкоголь +Дух",

    TooltipForceCastOnTarget                    = "Добавить выбранного игрока в список целей для бафа",
    TooltipExcludeTarget                        = "Добавить выбранного игрока в список исключений и не бафать",

    TooltipSelectTarget                         = "Выберите участника рейда/группы, чтобы включить эту опцию",
    TooltipSelfCastCheckbox_Self                = "Применить баф только на себя",
    TooltipSelfCastCheckbox_Party               = "Бафать группу или рейд",
    TooltipForceCastOnTarget                    = "Наложить заклинание на текущую цель",
    TooltipMacroButton                          = "Перетащите этот макрос на вашу панель заклинаний|nМожно также привязать клавишу в Настройках - Прочие",
    TooltipSettingsButton                       = "Открыть меню быстрых настроек и профайлов",
    TooltipCloseButton                          = "Скрыть окно Бафомёта, введите /bom или нажмите кнопку на мини-карте",
    TooltipCastButton                           = "Скастовать заклинание из списка.|nКнопка становится недоступной в бою.|nТакже можно использовать макро (вытащите кнопку Макро сверху на панель заклинаний)|nили привязать клавишу в Настройках - Прочие",

    ["profile.activeProfileMenuTag"]            = "[активный]",
    profile_solo                                = "Соло",
    profile_solo_spec2                          = "Соло (Вторая специализация)",
    profile_group                               = "Группа",
    profile_group_spec2                         = "Группа (Вторая специализация)",
    profile_raid                                = "Рейд",
    profile_raid_spec2                          = "Рейд (Вторая специализация)",
    profile_battleground                        = "Поле боя",
    profile_battleground_spec2                  = "Поле боя (вторая специализация)",
    profile_auto                                = "Авто профиль",
  }
end