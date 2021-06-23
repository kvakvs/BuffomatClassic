---@type BuffomatAddon
local TOCNAME, BOM = ...
local L = setmetatable({}, { __index = function(t, k)
  if BOM.L and BOM.L[k] then
    return BOM.L[k]
  else
    return "[" .. k .. "]"
  end
end })

local function bomLanguage_English()
  return {
    SELF                          = "Self", -- use instead of name when buffing self
    BUFF_CLASS_SELF_ONLY          = "Self-buff",
    BUFF_CLASS_REGULAR            = "Buff",
    BUFF_CLASS_GROUPBUFF          = "Buff group",
    BUFF_CLASS_TRACKING           = "Tracking",
    TASK_CLASS_REMINDER           = "Reminder",
    TASK_CLASS_RESURRECT          = "Resurrect",
    TASK_CLASS_MISSING_CONSUM     = "Missing consumable",
    BUFF_CLASS_CONSUMABLE         = "Consumable",
    BUFF_CONSUMABLE_REMINDER      = "Hold Shift/Ctrl or Alt",
    TASK_BLESS_GROUP              = "Bless Group",
    TASK_BLESS                    = "Bless",
    TASK_CAST                     = "Cast",
    TASK_USE                      = "Use",
    TASK_ACTIVATE                 = "Activate",
    TASK_UNEQUIP                  = "Unequip",
    ERR_RANGE                     = "Range",
    AD_REPUTATION_REMINDER        = "Argent Dawn trinket",
    RIDING_SPEED_REMINDER         = "Riding/Flight Speed trinket",

    CHAT_MSG_PREFIX               = "Buffomat: ",
    Buffomat                      = "Buffomat", -- addon title in the main window
    ResetWatchGroups              = "resetting buff groups to 1-8",
    FORMAT_BUFF_SINGLE            = "%s %s",
    FORMAT_BUFF_SELF              = "%s %s on self",
    FORMAT_BUFF_GROUP             = "Group %s %s",
    FORMAT_GROUP_NUM              = "G%s",
    MsgNextCast                   = "%s @ %s",
    --MsgNoSpell="Out of Range or Mana",
    MsgFlying                     = "Flying; Dismount disabled",
    MsgOnTaxi                     = "No buffing on taxi",
    MsgBusy                       = "Busy / Casting",
    MsgBusyChanneling             = "Busy / Channeling",
    MsgNothingToDo                = "Nothing to do",
    MsgNeedOneMacroSlot           = "Need one macro slot!",
    MsgLocalRestart               = "The setting is not transferred until after a restart (/reload)",
    MsgCancelBuff                 = "Cancel buff %s from %s",
    MsgSpellExpired               = "%s expired.",
    ActionInCombatError           = "Can't show/hide window in combat",
    MsgOpenContainer              = "Use or open",
    MSG_MAINHAND_ENCHANT_MISSING  = "Missing main hand temporary enchant",
    MSG_OFFHAND_ENCHANT_MISSING   = "Missing off-hand temporary enchant",

    InactiveReason_PlayerDead     = "You are dead",
    InactiveReason_InCombat       = "You are in combat",
    InactiveReason_RestArea       = "Buffing in rest areas disabled",
    InactiveReason_DeadMember     = "A party member is dead",
    InactiveReason_IsStealthed    = "Buffing in stealth disabled",
    InactiveReason_PvpZone        = "Buffing in PvP disabled",
    InactiveReason_Instance       = "Buffing in dungeons disabled",
    InactiveReason_OpenWorld      = "Buffing in the world disabled",

    MsgDownGrade                  = "Spell rank downgrade %s for %s. Please cast again.",

    Cboxshowminimapbutton         = "Show minimap button",
    CboxLockMinimapButton         = "Lock minimap button position",
    CboxLockMinimapButtonDistance = "Minimize minimap button distance",
    CboxAutoOpen                  = "Auto show Buffomat when there's work to do (type /bom)",
    CboxDeathBlock                = "Don't cast group buffs, when somebody is dead",
    CboxNoGroupBuff               = "Single buff always",
    CboxGroupBuff                 = "Cast group buffs when necessary (extra reagent cost)",
    CboxSameZone                  = "Watch only when in same zone",
    CboxResGhost                  = "Attempt to resurrect ghosts",
    CboxReplaceSingle             = "Replace single buff with group buffs",
    CboxArgentumDawn              = "Remind to unequip Argent Dawn trinket",
    CboxCarrot                    = "Remind to unequip Riding/Flight trinkets",

    CboxScanInStealth             = "Scan buffs in stealth",
    CboxScanInRestArea            = "Scan buffs in rest areas (city and inn)",
    CboxInWorld                   = "Scan buffs in the world and cities",
    CboxInPVP                     = "Scan buffs in battlegrounds",
    CboxInInstance                = "Scan buffs in dungeons and raids",

    CboxPreventPVPTag             = "Skip buffing PvP targets when your PvP is off",
    CboxUseRank                   = "Use spell with rank",
    CboxMainHand                  = "Warn if main hand enchantment is missing",
    CboxSecondaryHand             = "Warn if secondary hand enchantment is missing",
    CboxAutoStand                 = "Stand up on cast",
    CboxAutoDismount              = "Auto-dismount Ground on cast",
    CboxAutoDismountFlying        = "Auto-dismount Flying on cast",
    CboxAutoDisTravel             = "Auto-remove travel form",
    CboxBuffTarget                = "Also try and buff the current target",
    CboxOpenLootable              = "Open lootable items in the bags",
    CboxUseProfiles               = "Use profiles",
    CboxSelfFirst                 = "Always buff self first",
    CboxDontUseConsumables        = "Use consumables only with Shift, Ctrl or Alt",
    CboxShowClassicConsumables    = "Show consumables available in Classic",
    CboxShowTBCConsumables        = "Show consumables available in TBC",
    CboxSlowerHardware            = "Less frequent buff checks (slow hardware/raid)",

    HeaderRenew                   = "Renew before it expires (in Seconds)",
    EboxTime60                    = "Duration <=60 sec:",
    EboxTime300                   = "Duration <=5 min:",
    EboxTime600                   = "Duration <=10 min:",
    EboxTime1800                  = "Duration <=30 min:",
    EboxTime3600                  = "Duration <=60 min:",
    EboxMinBuff                   = "Number of missing buffs required to use a group buff",
    EboxMinBlessing               = "Number of missing blessing required to use a greater blessing",

    TooltipSelfCastCheckbox_Self  = "Self-cast only",
    TooltipSelfCastCheckbox_Party = "Buff party and groups in raid",
    TooltipEnableSpell            = "Add this buff to the task list",
    TooltipEnableBuffCancel       = "Cancel this buff as soon as it is found",
    FormatToggleTarget            = "Click to toggle player: %s",
    FormatAllForceCastTargets     = "Force cast on: ",
    FormatForceCastNone           = "Force cast list is empty",
    FormatAllExcludeTargets       = "Ignoring: ",
    FormatExcludeNone             = "Ignore list is empty",
    TooltipForceCastOnTarget      = "Add the current raid or group target to watch list for buffs",
    TooltipExcludeTarget          = "Add the current raid or group target to exclude list",
    TooltipSelectTarget           = "Select a raid/party member to enable this option",
    TooltipGroup                  = "Watch buffs in raid group %d",
    TooltipRaidGroupsSettings     = "Raid groups watch settings",
    MessageAddedForced            = "Will force buff ",
    MessageClearedForced          = "Removed force buff for",
    MessageAddedExcluded          = "Will never buff ",
    MessageClearedExcluded        = "Removed exclusion for",

    HintCancelThisBuff            = "Cancel this buff",
    HintCancelThisBuff_Combat     = "Before combat",
    HintCancelThisBuff_Always     = "Always",

    TooltipWhisperWhenExpired     = "Whisper the player who casted the buff, when the buff has expired",
    TooltipMainHand               = "Main hand",
    TooltipOffHand                = "Off hand",
    ShamanEnchantBlocked          = "Waiting for main hand", -- TBC: Shown when shaman cannot enchant this hand because the other hand goes first
    PreventPVPTagBlocked          = "Target is PvP", -- PreventPVPTag option enabled, player is non-PVP and target is PVP
    TooltipIncludesAllRanks       = "Any buff of this type",
    TooltipSimilarFoods           = "Any similar food",

    TabBuff                       = "Buff",
    TabDoNotBuff                  = "Do not buff",
    TabBuffOnlySelf               = "Buff Self Only", -- Shown when all raid groups are deselected
    TabSpells                     = "Spells",
    --TabItems = "Items",
    --TabBehaviour = "Behaviour",

    BtnOpen                       = "Open",
    BtnCancel                     = "Cancel",
    BtnQuickSettings              = "Quick Settings",
    BtnSettings                   = "Settings Window",
    BtnSettingsSpells             = "Settings Spells",
    BtnBuffs                      = "Consumables",
    ButtonCastBuff                = "Cast buff",
    ButtonBuffomatWindow          = "Show/hide Buffomat Window",

    Header_TRACKING               = "Tracking",
    --ActivateTracking              = "Activate tracking:", -- message when tracking is enabled
    Header_INFO                   = "Information",
    Header_CANCELBUFF             = "Cancel Buff",
    Header_item                   = "Consumables",
    HeaderSupportedSpells         = "Supported Spells",
    HeaderWatchGroup              = "Watch in raid group",
    PanelAbout                    = "About",
    HeaderInfo                    = "Information",
    HeaderUsage                   = "Usage",
    HeaderSlashCommand            = "Slash commands",
    HeaderCredits                 = "Credits",
    HeaderCustomLocales           = "Localization",
    HeaderProfiles                = "Profiles",

    SlashSpellBook                = "Rescan spellbook",
    SlashUpdate                   = "Update macro / list",
    SlashClose                    = "Close BOM window",
    SlashReset                    = "Reset BOM window",
    SlashOpen                     = "Open BOM window",
    SlashProfile                  = "Change current profile to solo/group/raid/battleground/auto",

    Tank                          = "Tank", -- unused?
    Pet                           = "Pet", -- unused?
    TooltipCastOnClass            = "Cast on class",
    TooltipCastOnTank             = "Cast on tanks",
    TooltipCastOnPet              = "Cast on pets",

    profile_solo                  = "Solo",
    profile_group                 = "Group",
    profile_raid                  = "Raid",
    profile_battleground          = "Battleground",
    profile_auto                  = "Automatic",

    AboutInfo                     = "Stamina! Int! Spirit! - Does that sound familiar? Buffomat scans "
            .. "the party/raid-member for missing buffs and with a click it is casted. When three "
            .. "or more members are missing one buff the group-version is used. It also activates "
            .. "tracking abilities like 'Find Herbs'.|nAlso it will help you to resurrect players by "
            .. "preferring paladins, priests and shamans over other classes. ",

    AboutUsage                    = "You need a free macro-slot to use this addon. The main-window has "
            .. "two tabs 'Buff' and 'Spells'. Under 'Buff' you find all missing buffs and a cast button. "
            .. "Under 'Spells' you can choose which spells should be monitored, and whether the group "
            .. "version should be cast. Select if it should only cast an you or on all party members. "
            .. "Choose which buff should be active on which class. You can also ignore entire groups "
            .. "(for example in raid, when you should only cast int on group 7&8). You can also "
            .. "select here, that one buff should be active on the current target. For example as "
            .. "druid click on the main tank and in the 'Thorns'-section on the '-' (last symbol) - "
            .. "it will changed to a crosshair and now Buffomat remind you to rebuff the main tank. "
            .. "You have two options to Cast a buff from the missing-buff-list. The spell-button in "
            .. "the window or the Buff'o'mat-macro. You find it with the 'M'-Button in the 'titel bar' "
            .. "of the main window.|nIMPORTANT: Buff'o'mat works only out of combat because Blizzard "
            .. "doesn't allow to change macros during combat. "
            .. "Additionally you can't open or close the main window during combat!",

    AboutSlashCommand             = "", --<value> can be true, 1, enable, false, 0, disable. If <value> is omitted, the current status switches.",

    TooltipMacroButton            = "Drag this macro to your action bar to cast the buffs|nYou can add a shortcut key to the macro in Key Bindings => Other",
    TooltipSettingsButton         = "Open Quick Settings and Profiles popup menu",
    TooltipCloseButton            = "Hide Buffomat window, type /bom to reopen or click the minimap button",
    TooltipCastButton             = "Cast the spell from the list.|nNot available in combat.|nCan also be activated via the macro (in the top row)|nor bind a shortcut key in Key Bindings => Other",

    SpellLabel_TrackHumanoids     = "Cat only - Overrides track herbs and ore",
  }
end

local function bomLanguage_Deutsch()
  return {
    AboutInfo                     = "Ausdauer! Int! Wille! - klingt das bekannt? Buffomat überprüft alle "
            .. "Gruppen/Raid-Mitglieder auf fehlende Buffs und ermöglicht diese dann mit einen klick zu "
            .. "verteilen. Wenn drei oder mehr den gleichen Buff brauchen, wird die Gruppenversion benutzt. "
            .. "Es erinnert dich auch die Suche wie Kräutersuche wieder zu aktivieren.|nAuch beim "
            .. "Wiederbeleben wird unterstützt, indem Paladine, Priester und Schamanen bevorzugt werden.",
    AboutSlashCommand             = "",
    AboutUsage                    = "Es wird ein freier Makro-Platz benötigt. Das Hauptfenster hat zwei "
            .. "Reiter 'Buff' und 'Zauber'. Unter 'Buff' findet man die fehlenden buffs und ein "
            .. "'Zaubern'-Button.|nUnter 'Zauber' findet man Einstellungen z.B.: Welche Zauber überwacht "
            .. "werden sollen, ob die Gruppen-Varianten erlaubt sind, ob der Zauber nur auf den Spieler "
            .. "oder alle erfolgen soll, welche Klassen diesen Zauber bekommen sollen. Zudem lassen "
            .. "sich die Gruppen einschränken, bspw. im Raid, wenn man nur Gruppe 7&8 mit Int "
            .. "buffen soll. Auch kann man hier Einstellen, dass das aktuelle Ziel immer einen "
            .. "bestimmten Buff bekommen soll. Bspw. kann ein Druide den Haupttank auswählen und in "
            .. "der Zeile von 'Dornen' auf das '-' klicken. Es sollte sich dann in ein Zielkreuz "
            .. "änden. Von nun an wird immer Dornen auf den Tank aufrecht gehalten.|nMan hat zwei "
            .. "Möglichkeiten, einen Buff zu zaubern: Einmal der 'Zaubern'-Button in Hauptfenster oder "
            .. "das Buff'o'mat-Makro. Man findet es unter dem 'M'-Button in der Titelzeile des Fensters.|n"
            .. "ACHTUNG: Aufgrund von Einschränkungen von Blizzard funktioniert Buffomat nur außerhalb des "
            .. "Kampfes. Es kann auch bspw. das Hauptfenster nur außerhalb geöffnet und geschlossen werden!",
    BtnBuffs                      = "Verbrauchbares",
    BtnCancel                     = "Abbruch",
    BtnOpen                       = "Öffnen",
    ButtonCastBuff                = "Zaubere Buff",
    BtnSettings                   = "Einstellungen",
    BtnSettingsSpells             = "Einstellungen Zauber",
    CboxArgentumDawn              = "Erinnere an die Anstecknadel der Argentumdämmerung",
    CboxAutoDismount              = "Automatisches Absitzen beim Zaubern",
    CboxAutoDisTravel             = "Automatisch  Reiseform abbrechen beim Zaubern",
    CboxAutoOpen                  = "Automatisches öffnen/schließen",
    CboxAutoStand                 = "Automatisches Aufstehen beim Zaubern",
    CboxBuffTarget                = "Aktuelles Ziel mit aufnehmen",
    CboxCarrot                    = "Erinnere an die \"Karotte am Stiel\"",
    CboxDeathBlock                = "Kein Gruppenbuff, wenn jemand tot ist",
    CboxDontUseConsumables        = "Verbrauchbares nur mit shift, strg oder alt benutzen.",
    CboxInInstance                = "In Instanzen aktiv",
    CboxInPVP                     = "In Schlachtfelder aktiv",
    CboxInWorld                   = "Auf der Welt aktiv",
    CboxLockMinimapButton         = "Minimap-Icon-Position sperren",
    CboxLockMinimapButtonDistance = "Minimap-Icon-Entfernung minimieren",
    CboxMainHand                  = "Warne bei fehlender Haupthand-Waffenverzauberung",
    CboxNoGroupBuff               = "Kein Gruppenbuff benutzen",
    CboxOpenLootable              = "Öffne plünderbare Gegenstände",
    CboxReplaceSingle             = "Ersetze Einzelbuffs mit Gruppenbuffs",
    CboxResGhost                  = "Freigelassene wiederbeleben",
    CboxSameZone                  = "Überwache nur wenn in der gleicher Zone",
    CboxSecondaryHand             = "Warne bei fehlender Nebenhand-Waffenverzauberung",
    CboxSelfFirst                 = "Immer zuerst sich selbst buffen",
    Cboxshowminimapbutton         = "Minimap-Icon anzeigen",
    CboxUseProfiles               = "Profile benutzen",
    CboxUseRank                   = "Benutze Zauber mit Rang",
    EboxMinBlessing               = "Anzahl der fehlenden Segen für einen Großen Segen",
    EboxMinBuff                   = "Anzahl der fehldenen Buffs für einen Gruppenbuff",
    EboxTime1800                  = "Dauer <=30 Min:",
    EboxTime300                   = "Dauer <=5 Min:",
    EboxTime3600                  = "Dauer <=60 Min:",
    EboxTime60                    = "Dauer <=60 Sek:",
    EboxTime600                   = "Dauer <=10 Min:",
    Header_CANCELBUFF             = "Buffs Abbrechen",
    Header_INFO                   = "Informationen",
    Header_item                   = "Verbrauchbares",
    Header_TRACKING               = "Suche",
    HeaderCredits                 = "Credits",
    HeaderCustomLocales           = "Lokalisierung",
    HeaderInfo                    = "Information",
    HeaderProfiles                = "Profile",
    HeaderRenew                   = "Vor dem auslaufen erneuern (in Sekunden)",
    HeaderSlashCommand            = "Befehle",
    HeaderSupportedSpells         = "Unterstützte Zauber",
    HeaderUsage                   = "Benutzung",
    HeaderWatchGroup              = "Im Raid Gruppe überwachen",
    FORMAT_BUFF_GROUP             = "Gruppe %s %s",
    FORMAT_BUFF_SINGLE            = "%s %s",
    FORMAT_BUFF_SELF              = "%s %s auf dich",
    MsgBusy                       = "Beschäftigt",
    MsgCancelBuff                 = "Beende Buff %s von %s",
    InactiveReason_InCombat       = "Kampf",
    InactiveReason_PlayerDead     = "Gestorben",
    MsgDownGrade                  = "Erniedrige den Rang für %s auf %s. Bitte neu zaubern.",
    MsgNothingToDo                = "Nichts zu tun",
    MsgLocalRestart               = "Die Lokalisierung wird erst nach einem Neustart übernommen (/reload)",
    MsgNeedOneMacroSlot           = "Brauche Platz für ein Macro!",
    MsgNextCast                   = "%s @ %s",
    InactiveReason_DeadMember     = "Irgendjemand ist tot",
    MsgSpellExpired               = "%s ist abgelaufen.",
    PanelAbout                    = "Über",
    Pet                           = "Tier",
    profile_auto                  = "Automatisch",
    profile_battleground          = "Schlachtfeld",
    profile_group                 = "Gruppe",
    profile_raid                  = "Schlachtzug",
    profile_solo                  = "Alleine",
    SlashClose                    = "BOM-Fenster schließen",
    SlashOpen                     = "BOM-Fenster öffnen",
    SlashProfile                  = "Das aktuelle Profil zu solo/group/raid/battleground/auto wechseln",
    SlashReset                    = "BOM-Fenster zurücksetzen",
    SlashSpellBook                = "Zauberbuch neu einlesen",
    SlashUpdate                   = "Update Macro / Liste",
    TabBuff                       = "Buff",
    TabSpells                     = "Zauber",
    Tank                          = "Tank",
    TooltipIncludesAllRanks       = "Alle Varianten",
    TooltipEnableSpell            = "Buffüberwachung ein-/ausschalten",
    TooltipEnableBuffCancel       = "Automatisches beenden des Buff ein-/ausschalten",
    TooltipGroup                  = "Gruppe %d",
    TooltipMainHand               = "Waffenhand",
    TooltipOffHand                = "Schildhand",
    HintCancelThisBuff_Combat     = "Nur direkt vor einem Kampf",
    TooltipSelectTarget           = "Wähle ein Gruppenmitglied um diese Option zu aktivieren.",
    --split into _Self and _Party ["TooltipSelfCastCheckbox"] = "Wirke auf Gruppe/Raid oder nur auf sich selbst",
    TooltipForceCastOnTarget      = "Buff dauerhaft auf Ziel halten",
    TooltipWhisperWhenExpired     = "Quelle anflüstern, wenn abgelaufen."
  }
end

local function bomLanguage_French()
  return {
    FORMAT_BUFF_SINGLE            = "%s %s",
    FORMAT_BUFF_SELF              = "%s %s sur toi-même",
    FORMAT_BUFF_GROUP             = "Groupe %s %s",
    MsgNextCast                   = "%s @ %s",
    --MsgNoSpell                    = "Hors portée ou Mana",
    InactiveReason_PlayerDead     = "Mort",
    MsgBusy                       = "Occupé",
    InactiveReason_InCombat       = "En combat",
    MsgNothingToDo                = "Rien à faire",
    InactiveReason_DeadMember     = "Quelqu'un est mort",
    MsgNeedOneMacroSlot           = "Besoin d'un emplacement macro!",

    Cboxshowminimapbutton         = "Montrer bouton minimap",
    CboxLockMinimapButton         = "Verrouiller position bouton minimap",
    CboxLockMinimapButtonDistance = "Distance minimale bouton minimap",
    CboxAutoOpen                  = "Ouvrir/fermer automatiquement",
    CboxDeathBlock                = "Ne pas buff de groupe quand quelqu'un est mort",
    CboxNoGroupBuff               = "Ne pas utiliser les buffs de groupe",
    CboxSameZone                  = "Uniquement dans la même zone",

    HeaderRenew                   = "Renouveler avant expiration (en Secondes)",
    EboxTime60                    = "Durée <=60 sec:",
    EboxTime300                   = "Durée <=5 min:",
    EboxTime600                   = "Durée <=10 min:",
    EboxTime1800                  = "Durée <=30 min:",
    EboxTime3600                  = "Durée <=60 min:",

    --split into _Self and _Party TooltipSelfCastCheckbox = "Buff groupe/raid ou uniquement sois-même",
    TooltipEnableSpell            = "Activer/Désactiver sort",
    TooltipForceCastOnTarget      = "Forcer sort sur Cible actuelle",
    --missing TooltipExcludeTarget
    TooltipSelectTarget           = "Choisir un membre groupe/raid pour activer cette option",
    TooltipGroup                  = "Groupe %d",

    TabBuff                       = "Buff",
    TabSpells                     = "Sorts",

    BtnOpen                       = "Ouvrir",
    BtnCancel                     = "Annuler",
    BtnSettings                   = "Réglages",
    BtnSettingsSpells             = "Réglage sorts",

    Header_TRACKING               = "Pistage",
    HeaderSupportedSpells         = "Sorts supportés",
    HeaderWatchGroup              = "Groupe à surveiller en raid",
    PanelAbout                    = "A propos",
    HeaderInfo                    = "Information",
    HeaderUsage                   = "Utilisation",
    HeaderSlashCommand            = "Commandes",
    HeaderCredits                 = "Crédits",

    SlashSpellBook                = "Rescanner Grimoire",
    SlashUpdate                   = "Mettre à jour macro / liste",
    SlashClose                    = "Fermer fenêtre BOM",
    SlashReset                    = "Réinitialiser fenêtre BOM",
    SlashOpen                     = "Ouvrir fenêtre BOM",

    --AboutInfo="<dummy info>",
    --AboutUsage="<dummy usage>",
    AboutSlashCommand             = "<valeur> peut être true, 1, enable, false, 0, disable. Si <valeur> est omis, la valeur actuelle s'inverse.",
    --AboutCredits="wellcat pour la traduction Chinoise",
  }
end

local function bomLanguage_Russian()
  return {
    CHAT_MSG_PREFIX               = "Бафомёт: ", --префикс в чате
    Buffomat                      = "Бафомёт", --шапка окна аддона
    AboutInfo                     = "Выносливость! Интеллект! Дух! - Это звучит знакомо? "
            .. "Бафомёт просканирует участников рейда/группы на отсутствие положительных эффектов "
            .. "и в одно мгновение примените их. Когда у троих или более участников отсутствует эффект, "
            .. "то будет использовано одно заклинание для всей группы. Он также запоминает активацию "
            .. "отслеживания для 'Поиска травы'.|nОн также поможет вам воскресить игроков, выбрав "
            .. "сначала паладинов, священников и шаманов. ",
    AboutSlashCommand             = "На данный момент это должна быть команда без параметров!",
    AboutUsage                    = "Вам нужен свободный слот макроса, чтобы использовать это дополнение. "
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
    BtnCancel                     = "Закрыть",
    BtnOpen                       = "Открыть",
    BtnSettings                   = "Настройки",
    BtnSettingsSpells             = "Настройки заклинаний",
    CboxArgentumDawn              = "Не забудьте (снять)экипировать Жетон Серебряного Рассвета",
    CboxAutoOpen                  = "Автоматическое открытие/закрытие",
    CboxDeathBlock                = "Не применять групповые эффекты, когда кто-то мертв",

    CboxScanInStealth             = "Сканировать бафы в режиме незаметности",
    CboxScanInRestArea            = "Сканировать бафы в городах и тавернах",
    CboxInInstance                = "Сканировать бафы в подземельях и рейдах",
    CboxInPVP                     = "Сканировать бафы на полях битвы",
    CboxInWorld                   = "Сканировать бафы в открытом мире",
    CboxPreventPVPTag             = "Не бафать PvP игроков, если ваш PvP выключен",

    CboxLockMinimapButton         = "Блокировка положения кнопки у миникарты",
    CboxLockMinimapButtonDistance = "Минимизировать расстояние до миникарты",
    CboxNoGroupBuff               = "Всегда давать одиночные бафы",
    CboxGroupBuff                 = "Групповые бафы, если это экономит ману (увеличенный расход реагентов)",
    CboxReplaceSingle             = "Заменить одиночный баф групповым",
    CboxResGhost                  = "Пытаться воскрешать призраки, если тело лежит близко",
    CboxSameZone                  = "Только если находится в одной зоне со мной",
    Cboxshowminimapbutton         = "Показать кнопку у миникарты",
    CboxUseRank                   = "Использовать заклинание с рангом",
    CboxShowClassicConsumables    = "Показывать бафы из классической версии",
    CboxShowTBCConsumables        = "Показывать бафы из TBC",
    EboxMinBlessing               = "Количество отсутствующих благословений, чтобы использовать большее благословение",
    EboxMinBuff                   = "Количество отсутствующих бафов, необходимое для использования группового бафа",
    EboxTime1800                  = "Продолжительность <=30 мин:",
    EboxTime300                   = "Продолжительность <=5 мин:",
    EboxTime3600                  = "Продолжительность <=60 мин:",
    EboxTime60                    = "Продолжительность <=60 сек:",
    EboxTime600                   = "Продолжительность <=10 мин:",
    --[[Translation missing --]]
    --[[ ["Header_INFO"] = "Information",--]]
    Header_TRACKING               = "Отслеживание",
    HeaderCredits                 = "Авторы",
    HeaderCustomLocales           = "Перевод",
    HeaderInfo                    = "Информация",
    HeaderRenew                   = "Продлить баф до истечения срока действия (в секундах)",
    HeaderSlashCommand            = "/ Команды",
    HeaderSupportedSpells         = "Поддерживаемые заклинания",
    HeaderUsage                   = "Использование",
    HeaderWatchGroup              = "Смотреть в рейдовой группе",
    FORMAT_BUFF_GROUP             = "Группа %s %s",
    FORMAT_BUFF_SINGLE            = "%s %s",
    FORMAT_BUFF_SELF              = "%s %s на себя",
    MsgBusy                       = "Занят / Кастую",
    MsgBusyChanneling             = "Занят / Долгое заклинание",
    InactiveReason_InCombat       = "В бою",
    InactiveReason_RestArea       = "В зоне отдыха (откл. в опциях)",
    InactiveReason_IsStealthed    = "Режим незаметности (откл. в опциях)",
    InactiveReason_PlayerDead     = "Мертв",
    MsgCancelBuff                 = "Отменён баф %s от %s",
    MsgSpellExpired               = "%s заклинание истекло.",
    ActionInCombatError           = "Во время боя нельзя показывать или скрывать панели",
    MsgDownGrade                  = "Понижение ранга заклинания %s для %s. Попробуйте выполнить баф ещё раз.",
    MsgNothingToDo                = "Нечего делать",
    MsgLocalRestart               = "Настройки не подействуют до перезагрузки модов (команда /reload)",
    MsgNeedOneMacroSlot           = "Нужен хотя бы один свободный слот для макро!",
    MsgNextCast                   = "%s @ %s",
    InactiveReason_DeadMember     = "Кто-то мертв",
    PanelAbout                    = "Информация",
    SlashClose                    = "Закрыть окно Бафомёта",
    SlashOpen                     = "Открыть Бафомёт",
    SlashReset                    = "Сбросить окно Бафомёта",
    SlashSpellBook                = "Повторное сканирование книги заклинаний",
    SlashUpdate                   = "Обновить список макросов",
    TabBuff                       = "Баф",
    TabBuffOnlySelf               = "Баф только себя", -- Shown if all raid groups deselected
    TabSpells                     = "Заклинания",
    TooltipEnableSpell            = "Вкл./откл. заклинание",
    TooltipGroup                  = "Следить за группой %d в рейде",
    TooltipRaidGroupsSettings     = "Настройки рейдовых групп",
    MessageAddedForced            = "Добавлена цель в список бафов",
    MessageClearedForced          = "Убрана дополнительная цель из списка бафов",
    MessageAddedExcluded          = "Добавлена цель в список пропуска",
    MessageClearedExcluded        = "Цель убрана из списка пропуска",

    HintCancelThisBuff            = "Отменять баф",
    HintCancelThisBuff_Combat     = "Перед боем",
    HintCancelThisBuff_Always     = "Сразу",

    TooltipWhisperWhenExpired     = "Сообщить игроку, который дал этот баф, когда время бафа истечёт",
    TooltipMainHand               = "Правая рука",
    TooltipOffHand                = "Левая рука",
    ShamanEnchantBlocked          = "Ожидание бафа на другую руку", -- TBC
    TooltipIncludesAllRanks       = "Любой вариант этого бафа",
    TooltipSimilarFoods           = "Любая подобная еда",
    TooltipForceCastOnTarget      = "Добавить выбранного игрока в список целей для бафа",
    TooltipExcludeTarget          = "Добавить выбранного игрока в список исключений и не бафать",

    TooltipSelectTarget           = "Выберите участника рейда/группы, чтобы включить эту опцию",
    TooltipSelfCastCheckbox_Self  = "Применить баф только на себя",
    TooltipSelfCastCheckbox_Party = "Бафать группу или рейд",
    TooltipForceCastOnTarget      = "Наложить заклинание на текущую цель",
    TooltipMacroButton            = "Перетащите этот макрос на вашу панель заклинаний|nМожно также привязать клавишу в Настройках - Прочие",
    TooltipSettingsButton         = "Открыть меню быстрых настроек и профайлов",
    TooltipCloseButton            = "Скрыть окно Бафомёта, введите /bom или нажмите кнопку на мини-карте",
    TooltipCastButton             = "Скастовать заклинание из списка.|nКнопка становится недоступной в бою.|nТакже можно использовать макро (вытащите кнопку Макро сверху на панель заклинаний)|nили привязать клавишу в Настройках - Прочие",
  }
end

local function bomLanguage_Chinese()
  return {
    AboutInfo                     = "Buff'o'mat将扫描团队成员是否丢失Buff，然后单击它就能施放和补充。当三个或更多成员丢失同一个buff时，会使用大buff。插件的另一个功能是你死后提醒你再次施放“寻找草药”或“寻找矿物。插件同样可以用于复活技能。当你点击宏时，它将复活你身边的人-优先级最高为萨满，圣骑士和牧师 ",
    --[[Translation missing --]]
    --[[ ["AboutSlashCommand"] = "",--]]
    AboutUsage                    = "你需要一个空闲的宏才能使用此插件. 主窗口有两个标签“Buff”和“法术”. 在“Buff”下你会找到所有缺失的Buff和一个施放按钮在“法术”下，你可以配置哪些法术应该被监控, 是否应该使用大buff版本。选择是只对你还是对所有队伍成员. 选择哪个buff应该在哪个职业上有效. 你也可以忽略完整的组（例如在raid中，当你被分配给7队和8队上智慧Buff时）你也可以在这里选择，一个buff应该在当前目标上激活。例如，当德鲁伊点击主坦克，在“荆棘术”部分点击“-”（最后一个符号）时，它会变成十字准星，现在插件将记住你要把buff施放给主坦克.你有两个选项可以从缺失的buff列表中选择一个去施放buff. 窗口中的法术按钮或插件的宏. 你可以在主窗口的“标题栏”上找到“M”按钮|n重要提示：插件只在脱战后起作用，因为暴雪不允许在战斗中更改宏. 另外，在战斗中不能打开或关闭主窗口!",
    BtnCancel                     = "取消",
    BtnOpen                       = "打开",
    BtnSettings                   = "设置",
    BtnSettingsSpells             = "设置各个法术",
    --[[Translation missing --]]
    --[[ ["CboxArgentumDawn"] = "Remember to (un)equip Argent Dawn Commission",--]]
    CboxAutoOpen                  = "自动 打开/取消",
    CboxDeathBlock                = "当有人死了就不施放大Buffs",
    --[[Translation missing --]]
    --[[ ["CboxInInstance"] = "Check in dungeons",--]]
    --[[Translation missing --]]
    --[[ ["CboxInPVP"] = "Check in battleground",--]]
    --[[Translation missing --]]
    --[[ ["CboxInWorld"] = "Check in overworld",--]]
    CboxLockMinimapButton         = "锁定小地图按钮位置",
    CboxLockMinimapButtonDistance = "最小化小地图按钮距离",
    CboxNoGroupBuff               = "不使用大Buff",
    --[[Translation missing --]]
    --[[ ["CboxReplaceSingle"] = "Replace single buff with group buffs",--]]
    CboxResGhost                  = "复活",
    CboxSameZone                  = "仅在某些区域",
    Cboxshowminimapbutton         = "显示小地图按钮",
    --[[Translation missing --]]
    --[[ ["CboxUseRank"] = "Use spell with rank",--]]
    --[[Translation missing --]]
    --[[ ["EboxMinBlessing"] = "Number of missing blessing required to use a greater blessing",--]]
    --[[Translation missing --]]
    --[[ ["EboxMinBuff"] = "Number of missing buffs required to use a group buff",--]]
    EboxTime1800                  = "持续时间 <=30 分:",
    EboxTime300                   = "持续时间 <=5 分:",
    EboxTime3600                  = "持续时间 <=60 分:",
    EboxTime60                    = "持续时间 <=60 秒:",
    EboxTime600                   = "持续时间 <=10 分:",
    --[[Translation missing --]]
    --[[ ["Header_INFO"] = "Information",--]]
    Header_TRACKING               = "跟踪中",
    HeaderCredits                 = "Credits",
    HeaderCustomLocales           = "本地化",
    HeaderInfo                    = "信息",
    HeaderRenew                   = "到期前续订（秒）",
    HeaderSlashCommand            = "可用命令",
    HeaderSupportedSpells         = "支持的法术",
    HeaderUsage                   = "用法",
    HeaderWatchGroup              = "在团队中监视",
    FORMAT_BUFF_GROUP             = "队伍 %s %s",
    FORMAT_BUFF_SINGLE            = "%s %s",
    MsgBusy                       = "繁忙中",
    InactiveReason_InCombat       = "战斗",
    InactiveReason_PlayerDead     = "死亡",
    --[[Translation missing --]]
    --[[ ["MsgDownGrade"] = "" --]]
    MsgNothingToDo                = "无事可做",
    MsgLocalRestart               = "重新启动后才能更新设置 (/reload)",
    MsgNeedOneMacroSlot           = "需要一个宏槽!",
    MsgNextCast                   = "%s @ %s",
    InactiveReason_DeadMember     = "有人死了",
    PanelAbout                    = "关于",
    SlashClose                    = "取消插件窗口",
    SlashOpen                     = "打开插件窗口",
    SlashReset                    = "重置插件窗口",
    SlashSpellBook                = "重新扫描法术书",
    SlashUpdate                   = "更新宏/列表",
    TabBuff                       = "Buff",
    TabSpells                     = "法术",
    TooltipEnableSpell            = "启用/禁用 法术",
    TooltipGroup                  = "队伍 %d",
    TooltipSelectTarget           = "选择一个团队/小队成员,启用这个选项",
    TooltipSelfCastCheckbox       = "施放给小队/团队,或仅自己",
    TooltipForceCastOnTarget      = "对当前目标强制施法"
  }
end

function BOM.SetupTranslations()
  -- Always add english and add one language that is supported and is current
  BOM.locales = {
    enEN = bomLanguage_English(),
  }

  local currentLang = GetLocale()
  if currentLang == "deDE" then
    BOM.locales.deDE = bomLanguage_Deutsch()
  end
  if currentLang == "frFR" then
    BOM.locales.frFR = bomLanguage_French()
  end
  if currentLang == "ruRU" then
    BOM.locales.ruRU = bomLanguage_Russian()
  end
  if currentLang == "zhCN" then
    BOM.locales.zhCN = bomLanguage_Chinese()
  end

  BOM.L = BOM.locales[GetLocale()] or {}
  setmetatable(BOM.L, {
    __index = BOM.locales["enEN"]
  })
  BOM.L.AboutCredits = "wellcat for the Chinese translation|n" ..
          "OlivBEL for the french translation|n" ..
          "Arrogant_Dreamer & kvakvs for the russian translation|n"
end

function BOM.LocalizationInit()
  if BomSharedState and BomSharedState.CustomLocales then
    for key, value in pairs(BomSharedState.CustomLocales) do
      if value ~= nil and value ~= "" then
        BOM.L[key .. "_org"] = BOM.L[key]
        BOM.L[key] = value
      end
    end
  end
end
