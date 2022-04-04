local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomLanguagesModule
local languagesModule = BuffomatModule.DeclareModule("Languages") ---@type BomLanguagesModule

local L = setmetatable({}, { __index = function(t, k)
  if BOM.L and BOM.L[k] then
    return BOM.L[k]
  else
    return "[" .. k .. "]"
  end
end })

setmetatable(languagesModule, {
  __call = function(_, k)
    if BOM.L and BOM.L[k] then
      return BOM.L[k] or ("¶" .. k)
    else
      return "¶" .. k
    end
  end
})

local function bomLanguage_English()
  return {
    ["options.OptionsTitle"]                    = "Buffomat",

    ["options.general.group.AutoActions"]       = "Auto Actions",
    ["options.general.group.Convenience"]       = "Convenience",
    ["options.general.group.General"]           = "General",
    ["options.general.group.Scan"]              = "Scanning",
    ["options.general.group.Buffing"]           = "Buffing",

    ["options.short.ArgentumDawn"]              = "Warn about reputation items",
    ["options.short.AutoCrusaderAura"]          = "Suggest crusader aura",
    ["options.short.AutoDismount"]              = "Auto dismount",
    ["options.short.AutoDismountFlying"]        = "Auto dismount flying",
    ["options.short.AutoDisTravel"]             = "Auto leave travel form",
    ["options.short.AutoOpen"]                  = "Auto open Buffomat",
    ["options.short.AutoStand"]                 = "Auto stand up",
    ["options.short.BuffTarget"]                = "Buff target first",
    ["options.short.Carrot"]                    = "Warn about mount items",
    ["options.short.ActivateBomOnSpiritTap"]    = "Activate on Spirit Tap below mana %",
    ["options.short.DeathBlock"]                = "Pause if someone is dead",
    ["options.short.DontUseConsumables"]        = "Dont use consumables",
    ["options.short.HideSomeoneIsDrinking"]     = "Hide 'Someone is drinking'",
    ["options.short.InInstance"]                = "Scan in instance",
    ["options.short.InPVP"]                     = "Scan in PvP",
    ["options.short.InWorld"]                   = "Scan in world",
    ["options.short.LockMinimapButton"]         = "Lock minimap button",
    ["options.short.LockMinimapButtonDistance"] = "Lock minimap button distance",
    ["options.short.MainHand"]                  = "Missing mainhand enchantment",
    ["options.short.NoGroupBuff"]               = "Avoid group buffing",
    ["options.short.OpenLootable"]              = "Open lootable containers",
    ["options.short.PreventPVPTag"]             = "Prevent PvP tag",
    ["options.short.ReplaceSingle"]             = "Replace single buffs",
    ["options.short.ResGhost"]                  = "Attempt ressing ghosts",
    ["options.short.SameZone"]                  = "Scan members in same zone",
    ["options.short.ScanInRestArea"]            = "Scan in rest area",
    ["options.short.ScanInStealth"]             = "Scan in stealth",
    ["options.short.ScanWhileMounted"]          = "Scan while mounted",
    ["options.short.SecondaryHand"]             = "Missing offhand enchantment",
    ["options.short.SelfFirst"]                 = "Self first",
    ["options.short.ShowMinimapButton"]         = "Show minimap button",
    ["options.short.SlowerHardware"]            = "Scan buffs less often",
    ["options.short.UseRank"]                   = "Use ranked buffs",
    ["options.short.UseProfiles"]               = "Use profiles",

    ["options.long.ArgentumDawn"]               = "Remind to unequip Argent Dawn trinket",
    ["options.long.AutoCrusaderAura"]           = "Paladin: Auto crusader aura when mounted",
    ["options.long.AutoDismount"]               = "Auto-dismount from the ground mount on cast",
    ["options.long.AutoDismountFlying"]         = "Auto-drop from the flying mount on cast (OUCH)",
    ["options.long.AutoDisTravel"]              = "Auto-remove travel form (Does not work in Classic)",
    ["options.long.AutoOpen"]                   = "Auto show Buffomat when there's work to do (type /bom)",
    ["options.long.AutoStand"]                  = "If the character was sitting, Buffomat will stand up the character",
    ["options.long.BuffTarget"]                 = "Also try and buff the current target",
    ["options.long.Carrot"]                     = "Remind to unequip Riding/Flight trinkets",
    ["options.long.ActivateBomOnSpiritTap"]     = "Disable Buffomat if priest 'Spirit tap' is active and player mana is below %",
    ["options.long.DeathBlock"]                 = "Don't cast group buffs, when somebody is dead",
    ["options.long.DontUseConsumables"]         = "Use consumables only with Shift, Ctrl or Alt",
    ["options.long.GroupBuff"]                  = "Cast group buffs when necessary (extra reagent cost)",
    ["options.long.HideSomeoneIsDrinking"]      = "Hide 'Someone is drinking' info message",
    ["options.long.InInstance"]                 = "Scan buffs in dungeons and raids",
    ["options.long.InPVP"]                      = "Scan buffs in battlegrounds",
    ["options.long.InWorld"]                    = "Scan buffs in the world and cities",
    ["options.long.LockMinimapButton"]          = "Lock minimap button position",
    ["options.long.LockMinimapButtonDistance"]  = "Minimize minimap button distance",
    ["options.long.MainHand"]                   = "Warn if main hand enchantment is missing",
    ["options.long.NoGroupBuff"]                = "Single buff always",
    ["options.long.OpenLootable"]               = "Open lootable items in the bags",
    ["options.long.PreventPVPTag"]              = "Skip buffing PvP targets when your PvP is off",
    ["options.long.ReplaceSingle"]              = "Replace single buff with group buffs",
    ["options.long.ResGhost"]                   = "Attempt to resurrect ghosts",
    ["options.long.SameZone"]                   = "Watch only when in same zone",
    ["options.long.ScanInRestArea"]             = "Scan buffs in rest areas (city and inn)",
    ["options.long.ScanInStealth"]              = "Scan buffs in stealth",
    ["options.long.ScanWhileMounted"]           = "Scan while on a mount",
    ["options.long.SecondaryHand"]              = "Warn if secondary hand enchantment is missing",
    ["options.long.SelfFirst"]                  = "Always buff self first",
    ["options.long.ShowClassicConsumables"]     = "Show consumables available in Classic",
    ["options.long.ShowMinimapButton"]          = "Show minimap button",
    ["options.long.ShowTBCConsumables"]         = "Show consumables available in TBC",
    ["options.long.SlowerHardware"]             = "Less frequent buff checks (slow hardware/raid)",
    ["options.long.UseProfiles"]                = "Use profiles",
    ["options.long.UseRank"]                    = "Use spells with ranks",
    ["options.long.UseProfiles"]                = "Use profiles based on whether the player is solo, in a group, raid or a battleground",

    SELF                                        = "Self", -- use instead of name when buffing self
    BUFF_CLASS_SELF_ONLY                        = "Self-buff",
    BUFF_CLASS_REGULAR                          = "Buff",
    BUFF_CLASS_GROUPBUFF                        = "Buff group",
    BUFF_CLASS_TRACKING                         = "Tracking",
    TASK_CLASS_REMINDER                         = "Reminder",
    TASK_CLASS_RESURRECT                        = "Resurrect",
    TASK_CLASS_MISSING_CONSUM                   = "Missing consumable",
    BUFF_CLASS_CONSUMABLE                       = "Consumable",
    BUFF_CONSUMABLE_REMINDER                    = "Hold Shift/Ctrl or Alt",
    TASK_BLESS_GROUP                            = "Bless Group",
    TASK_BLESS                                  = "Bless",
    TASK_SUMMON                                 = "Summon",
    TASK_CAST                                   = "Cast",
    TASK_USE                                    = "Use",
    TASK_TBC_HUNTER_PET_BUFF                    = "Use on pet",
    TASK_ACTIVATE                               = "Activate",
    TASK_UNEQUIP                                = "Unequip",
    ERR_RANGE                                   = "Range",
    AD_REPUTATION_REMINDER                      = "Argent Dawn trinket",
    RIDING_SPEED_REMINDER                       = "Riding/Flight Speed trinket",
    OUT_OF_THAT_ITEM                            = "Not in bags",
    CboxNoGroupBuff                             = "Single buff always",
    CboxGroupBuff                               = "Cast group buffs when necessary (extra reagent cost)",

    CHAT_MSG_PREFIX                             = "Buffomat: ",
    Buffomat                                    = "Buffomat", -- addon title in the main window
    ResetWatchGroups                            = "resetting buff groups to 1-8",
    FORMAT_BUFF_SINGLE                          = "%s %s",
    FORMAT_BUFF_SELF                            = "%s %s on self",
    FORMAT_BUFF_GROUP                           = "Group %s %s",
    FORMAT_GROUP_NUM                            = "G%s",
    MsgNextCast                                 = "%s @ %s",
    --MsgNoSpell="Out of Range or Mana",
    MsgFlying                                   = "Flying; Dismount disabled",
    MsgOnTaxi                                   = "No buffing on taxi",
    MsgBusy                                     = "Busy / Casting",
    MsgBusyChanneling                           = "Busy / Channeling",
    MsgNothingToDo                              = "Nothing to do",
    MsgNeedOneMacroSlot                         = "Need one macro slot!",
    MsgLocalRestart                             = "The setting is not transferred until after a restart (/reload)",
    MsgCancelBuff                               = "Cancel buff %s from %s",
    MsgSpellExpired                             = "%s expired.",
    ActionInCombatError                         = "Can't show/hide window in combat",
    MsgOpenContainer                            = "Use or open",
    MSG_MAINHAND_ENCHANT_MISSING                = "Missing main hand temporary enchant",
    MSG_OFFHAND_ENCHANT_MISSING                 = "Missing off-hand temporary enchant",
    InfoSomeoneIsDrinking                       = "1 person is drinking",
    InfoMultipleDrinking                        = "%d persons are drinking",

    InactiveReason_PlayerDead                   = "You are dead",
    InactiveReason_InCombat                     = "You are in combat",
    InactiveReason_RestArea                     = "Buffing in rest areas disabled",
    InactiveReason_DeadMember                   = "A party member is dead",
    InactiveReason_IsStealthed                  = "Buffing in stealth disabled",
    InactiveReason_SpiritTap                    = "Priest's <Spirit Tap> is active",
    InactiveReason_PvpZone                      = "Buffing in PvP disabled",
    InactiveReason_Instance                     = "Buffing in dungeons disabled",
    InactiveReason_OpenWorld                    = "Buffing in the world disabled",
    InactiveReason_Mounted                      = "Buffing on mount disabled",

    MsgDownGrade                                = "Spell rank downgrade %s for %s. Please cast again.",

    CRUSADER_AURA_COMMENT                       = "Can auto-cast based on settings",

    HeaderRenew                                 = "Renew before it expires (in Seconds)",

    ["options.short.Time60"]                    = "Duration <=60 sec:",
    ["options.short.Time300"]                   = "Duration <=5 min:",
    ["options.short.Time600"]                   = "Duration <=10 min:",
    ["options.short.Time1800"]                  = "Duration <=30 min:",
    ["options.short.Time3600"]                  = "Duration <=60 min:",
    ["options.short.UIWindowScale"]             = "UI scale",
    ["options.short.MinBuff"]                   = "Missing buffs to use a group buff",
    ["options.short.MinBlessing"]               = "Blessing targets for a greater blessing",

    ["options.long.Time60"]                     = "Refresh buffs with total duration <=60 sec, if remaining less than",
    ["options.long.Time300"]                    = "Refresh buffs with total duration <=5 min, if remaining less than",
    ["options.long.Time600"]                    = "Refresh buffs with total duration <=10 min, if remaining less than",
    ["options.long.Time1800"]                   = "Refresh buffs with total duration <=30 min, if remaining less than",
    ["options.long.Time3600"]                   = "Refresh buffs with total duration <=60 min, if remaining less than",
    ["options.long.UIWindowScale"]              = "UI scale (default 1; Hide and show Buffomat to apply)",
    ["options.long.MinBuff"]                    = "Number of missing buffs required to use a group buff",
    ["options.long.MinBlessing"]                = "Number of missing blessing required to use a greater blessing",

    TooltipSelfCastCheckbox_Self                = "Self-cast only",
    TooltipSelfCastCheckbox_Party               = "Buff party and groups in raid",
    TooltipEnableSpell                          = "Add this buff to the task list",
    TooltipEnableBuffCancel                     = "Cancel this buff as soon as it is found",
    FormatToggleTarget                          = "Click to toggle player: %s",
    FormatAllForceCastTargets                   = "Force cast on: ",
    FormatForceCastNone                         = "Force cast list is empty",
    FormatAllExcludeTargets                     = "Ignoring: ",
    FormatExcludeNone                           = "Ignore list is empty",
    TooltipForceCastOnTarget                    = "Add the current raid or group target to watch list for buffs",
    TooltipExcludeTarget                        = "Add the current raid or group target to exclude list",
    TooltipSelectTarget                         = "Select a raid/party member to enable this option",
    TooltipGroup                                = "Watch buffs in raid group %d",
    TooltipRaidGroupsSettings                   = "Raid groups watch settings",
    MessageAddedForced                          = "Will force buff ",
    MessageClearedForced                        = "Removed force buff for",
    MessageAddedExcluded                        = "Will never buff ",
    MessageClearedExcluded                      = "Removed exclusion for",

    HintCancelThisBuff                          = "Cancel this buff",
    HintCancelThisBuff_Combat                   = "Before combat",
    HintCancelThisBuff_Always                   = "Always",

    TooltipWhisperWhenExpired                   = "Whisper the player who casted the buff, when the buff has expired",
    TooltipMainHand                             = "Main hand",
    TooltipOffHand                              = "Off hand",
    ShamanEnchantBlocked                        = "Waiting for main hand", -- TBC: Shown when shaman cannot enchant this hand because the other hand goes first
    PreventPVPTagBlocked                        = "Target is PvP", -- PreventPVPTag option enabled, player is non-PVP and target is PVP
    TooltipIncludesAllRanks                     = "Any buff of this type",
    TooltipSimilar                              = "Any similar",
    TooltipSimilarFoods                         = "Any similar food",

    TabBuff                                     = "Buff",
    TabDoNotBuff                                = "Do not buff",
    TabBuffOnlySelf                             = "Buff Self Only", -- Shown when all raid groups are deselected
    TabSpells                                   = "Spells",
    --TabItems = "Items",
    --TabBehaviour = "Behaviour",

    BtnOpen                                     = "Open",
    BtnCancel                                   = "Cancel",
    ["popup.QuickSettings"]                     = "Quick Settings",
    BtnSettings                                 = "Settings Window",
    BtnSettingsSpells                           = "Settings Spells",
    BtnBuffs                                    = "Consumables",
    ButtonCastBuff                              = "Cast buff",
    ButtonBuffomatWindow                        = "Show/hide Buffomat Window",

    Header_TRACKING                             = "Tracking",
    --ActivateTracking              = "Activate tracking:", -- message when tracking is enabled
    Header_INFO                                 = "Information",
    Header_CANCELBUFF                           = "Cancel Buff",
    Header_item                                 = "Consumables",
    HeaderSupportedSpells                       = "Supported Spells",
    HeaderWatchGroup                            = "Watch in raid group",
    PanelAbout                                  = "About",
    HeaderInfo                                  = "Information",
    HeaderUsage                                 = "Usage",
    HeaderSlashCommand                          = "Slash commands",
    HeaderCredits                               = "Credits",
    HeaderCustomLocales                         = "Localization",
    HeaderProfiles                              = "Profiles",

    SlashSpellBook                              = "Rescan spellbook",
    SlashUpdate                                 = "Update macro / list",
    SlashClose                                  = "Close BOM window",
    SlashReset                                  = "Reset BOM window",
    SlashOpen                                   = "Open BOM window",
    SlashProfile                                = "Change current profile to solo/group/raid/battleground/auto",

    Tank                                        = "Tank", -- unused?
    Pet                                         = "Pet", -- unused?
    TooltipCastOnClass                          = "Cast on class",
    TooltipCastOnTank                           = "Cast on tanks",
    TooltipCastOnPet                            = "Cast on pets",

    profile_solo                                = "Solo",
    profile_group                               = "Group",
    profile_raid                                = "Raid",
    profile_battleground                        = "Battleground",
    profile_auto                                = "Automatic",

    AboutInfo                                   = "Stamina! Int! Spirit! - Does that sound familiar? Buffomat scans "
            .. "the party/raid-member for missing buffs and with a click it is casted. When three "
            .. "or more members are missing one buff the group-version is used. It also activates "
            .. "tracking abilities like 'Find Herbs'.|nAlso it will help you to resurrect players by "
            .. "preferring paladins, priests and shamans over other classes. ",

    AboutUsage                                  = "You need a free macro-slot to use this addon. The main-window has "
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

    AboutSlashCommand                           = "", --<value> can be true, 1, enable, false, 0, disable. If <value> is omitted, the current status switches.",

    TooltipMacroButton                          = "Drag this macro to your action bar to cast the buffs|nYou can add a shortcut key to the macro in Key Bindings => Other",
    TooltipSettingsButton                       = "Open Quick Settings and Profiles popup menu",
    TooltipCloseButton                          = "Hide Buffomat window, type /bom to reopen or click the minimap button",
    TooltipCastButton                           = "Cast the spell from the list.|nNot available in combat.|nCan also be activated via the macro (in the top row)|nor bind a shortcut key in Key Bindings => Other",

    SpellLabel_TrackHumanoids                   = "Cat only - Overrides track herbs and ore",
  }
end

local function bomLanguage_Deutsch()
  return {
    AboutInfo                                   = "Ausdauer! Int! Wille! - klingt das bekannt? Buffomat überprüft alle "
            .. "Gruppen/Raid-Mitglieder auf fehlende Buffs und ermöglicht diese dann mit einen klick zu "
            .. "verteilen. Wenn drei oder mehr den gleichen Buff brauchen, wird die Gruppenversion benutzt. "
            .. "Es erinnert dich auch die Suche wie Kräutersuche wieder zu aktivieren.|nAuch beim "
            .. "Wiederbeleben wird unterstützt, indem Paladine, Priester und Schamanen bevorzugt werden.",
    AboutSlashCommand                           = "",
    AboutUsage                                  = "Es wird ein freier Makro-Platz benötigt. Das Hauptfenster hat zwei "
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
    BtnBuffs                                    = "Verbrauchbares",
    BtnCancel                                   = "Abbruch",
    BtnOpen                                     = "Öffnen",
    ButtonCastBuff                              = "Zaubere Buff",
    BtnSettings                                 = "Einstellungen",
    BtnSettingsSpells                           = "Einstellungen Zauber",

    ["options.short.ArgentumDawn"]              = "Erinnere an die Anstecknadel der Argentumdämmerung",
    ["options.short.AutoDismount"]              = "Automatisches Absitzen beim Zaubern",
    ["options.short.AutoDisTravel"]             = "Automatisch  Reiseform abbrechen beim Zaubern",
    ["options.short.AutoOpen"]                  = "Automatisches öffnen/schließen",
    ["options.short.AutoStand"]                 = "Automatisches Aufstehen beim Zaubern",
    ["options.short.BuffTarget"]                = "Aktuelles Ziel mit aufnehmen",
    ["options.short.Carrot"]                    = "Erinnere an die \"Karotte am Stiel\"",
    ["options.short.DeathBlock"]                = "Kein Gruppenbuff, wenn jemand tot ist",
    ["options.short.DontUseConsumables"]        = "Verbrauchbares nur mit shift, strg oder alt benutzen.",
    ["options.short.InInstance"]                = "In Instanzen aktiv",
    ["options.short.InPVP"]                     = "In Schlachtfelder aktiv",
    ["options.short.InWorld"]                   = "Auf der Welt aktiv",
    ["options.short.LockMinimapButton"]         = "Minimap-Icon-Position sperren",
    ["options.short.LockMinimapButtonDistance"] = "Minimap-Icon-Entfernung minimieren",
    ["options.short.MainHand"]                  = "Warne bei fehlender Haupthand-Waffenverzauberung",
    ["options.short.NoGroupBuff"]               = "Kein Gruppenbuff benutzen",
    ["options.short.OpenLootable"]              = "Öffne plünderbare Gegenstände",
    ["options.short.ReplaceSingle"]             = "Ersetze Einzelbuffs mit Gruppenbuffs",
    ["options.short.ResGhost"]                  = "Freigelassene wiederbeleben",
    ["options.short.SameZone"]                  = "Überwache nur wenn in der gleicher Zone",
    ["options.short.SecondaryHand"]             = "Warne bei fehlender Nebenhand-Waffenverzauberung",
    ["options.short.SelfFirst"]                 = "Immer zuerst sich selbst buffen",
    ["options.short.ShowMinimapButton"]         = "Minimap-Icon anzeigen",
    ["options.short.UseProfiles"]               = "Profile benutzen",
    ["options.short.UseRank"]                   = "Benutze Zauber mit Rang",

    ["options.short.MinBlessing"]               = "Anzahl der fehlenden Segen für einen Großen Segen",
    ["options.short.MinBuff"]                   = "Anzahl der fehldenen Buffs für einen Gruppenbuff",
    ["options.short.Time1800"]                  = "Dauer <=30 Min:",
    ["options.short.Time300"]                   = "Dauer <=5 Min:",
    ["options.short.Time3600"]                  = "Dauer <=60 Min:",
    ["options.short.Time60"]                    = "Dauer <=60 Sek:",
    ["options.short.Time600"]                   = "Dauer <=10 Min:",

    Header_CANCELBUFF                           = "Buffs Abbrechen",
    Header_INFO                                 = "Informationen",
    Header_item                                 = "Verbrauchbares",
    Header_TRACKING                             = "Suche",
    HeaderCredits                               = "Credits",
    HeaderCustomLocales                         = "Lokalisierung",
    HeaderInfo                                  = "Information",
    HeaderProfiles                              = "Profile",
    HeaderRenew                                 = "Vor dem auslaufen erneuern (in Sekunden)",
    HeaderSlashCommand                          = "Befehle",
    HeaderSupportedSpells                       = "Unterstützte Zauber",
    HeaderUsage                                 = "Benutzung",
    HeaderWatchGroup                            = "Im Raid Gruppe überwachen",
    FORMAT_BUFF_GROUP                           = "Gruppe %s %s",
    FORMAT_BUFF_SINGLE                          = "%s %s",
    FORMAT_BUFF_SELF                            = "%s %s auf dich",
    MsgBusy                                     = "Beschäftigt",
    MsgCancelBuff                               = "Beende Buff %s von %s",
    InactiveReason_InCombat                     = "Kampf",
    InactiveReason_PlayerDead                   = "Gestorben",
    MsgDownGrade                                = "Erniedrige den Rang für %s auf %s. Bitte neu zaubern.",
    MsgNothingToDo                              = "Nichts zu tun",
    MsgLocalRestart                             = "Die Lokalisierung wird erst nach einem Neustart übernommen (/reload)",
    MsgNeedOneMacroSlot                         = "Brauche Platz für ein Macro!",
    MsgNextCast                                 = "%s @ %s",
    InactiveReason_DeadMember                   = "Irgendjemand ist tot",
    MsgSpellExpired                             = "%s ist abgelaufen.",
    PanelAbout                                  = "Über",
    Pet                                         = "Tier",
    profile_auto                                = "Automatisch",
    profile_battleground                        = "Schlachtfeld",
    profile_group                               = "Gruppe",
    profile_raid                                = "Schlachtzug",
    profile_solo                                = "Alleine",
    SlashClose                                  = "BOM-Fenster schließen",
    SlashOpen                                   = "BOM-Fenster öffnen",
    SlashProfile                                = "Das aktuelle Profil zu solo/group/raid/battleground/auto wechseln",
    SlashReset                                  = "BOM-Fenster zurücksetzen",
    SlashSpellBook                              = "Zauberbuch neu einlesen",
    SlashUpdate                                 = "Update Macro / Liste",
    TabBuff                                     = "Buff",
    TabSpells                                   = "Zauber",
    Tank                                        = "Tank",
    TooltipIncludesAllRanks                     = "Alle Varianten",
    TooltipEnableSpell                          = "Buffüberwachung ein-/ausschalten",
    TooltipEnableBuffCancel                     = "Automatisches beenden des Buff ein-/ausschalten",
    TooltipGroup                                = "Gruppe %d",
    TooltipMainHand                             = "Waffenhand",
    TooltipOffHand                              = "Schildhand",
    HintCancelThisBuff_Combat                   = "Nur direkt vor einem Kampf",
    TooltipSelectTarget                         = "Wähle ein Gruppenmitglied um diese Option zu aktivieren.",
    --split into _Self and _Party ["TooltipSelfCastCheckbox"] = "Wirke auf Gruppe/Raid oder nur auf sich selbst",
    TooltipForceCastOnTarget                    = "Buff dauerhaft auf Ziel halten",
    TooltipWhisperWhenExpired                   = "Quelle anflüstern, wenn abgelaufen."
  }
end

local function bomLanguage_French()
  return {
    FORMAT_BUFF_SINGLE                          = "%s %s",
    FORMAT_BUFF_SELF                            = "%s %s sur toi-même",
    FORMAT_BUFF_GROUP                           = "Groupe %s %s",
    MsgNextCast                                 = "%s @ %s",
    --MsgNoSpell                    = "Hors portée ou Mana",
    InactiveReason_PlayerDead                   = "Mort",
    MsgBusy                                     = "Occupé",
    InactiveReason_InCombat                     = "En combat",
    MsgNothingToDo                              = "Rien à faire",
    InactiveReason_DeadMember                   = "Quelqu'un est mort",
    MsgNeedOneMacroSlot                         = "Besoin d'un emplacement macro!",

    ["options.short.ShowMinimapButton"]         = "Montrer bouton minimap",
    ["options.short.LockMinimapButton"]         = "Verrouiller position bouton minimap",
    ["options.short.LockMinimapButtonDistance"] = "Distance minimale bouton minimap",
    ["options.short.AutoOpen"]                  = "Ouvrir/fermer automatiquement",
    ["options.short.DeathBlock"]                = "Ne pas buff de groupe quand quelqu'un est mort",
    ["options.short.NoGroupBuff"]               = "Ne pas utiliser les buffs de groupe",
    ["options.short.SameZone"]                  = "Uniquement dans la même zone",

    HeaderRenew                                 = "Renouveler avant expiration (en Secondes)",

    ["options.short.Time60"]                    = "Durée <=60 sec:",
    ["options.short.Time300"]                   = "Durée <=5 min:",
    ["options.short.Time600"]                   = "Durée <=10 min:",
    ["options.short.Time1800"]                  = "Durée <=30 min:",
    ["options.short.Time3600"]                  = "Durée <=60 min:",

    --split into _Self and _Party TooltipSelfCastCheckbox = "Buff groupe/raid ou uniquement sois-même",
    TooltipEnableSpell                          = "Activer/Désactiver sort",
    TooltipForceCastOnTarget                    = "Forcer sort sur Cible actuelle",
    --missing TooltipExcludeTarget
    TooltipSelectTarget                         = "Choisir un membre groupe/raid pour activer cette option",
    TooltipGroup                                = "Groupe %d",

    TabBuff                                     = "Buff",
    TabSpells                                   = "Sorts",

    BtnOpen                                     = "Ouvrir",
    BtnCancel                                   = "Annuler",
    BtnSettings                                 = "Réglages",
    BtnSettingsSpells                           = "Réglage sorts",

    Header_TRACKING                             = "Pistage",
    HeaderSupportedSpells                       = "Sorts supportés",
    HeaderWatchGroup                            = "Groupe à surveiller en raid",
    PanelAbout                                  = "A propos",
    HeaderInfo                                  = "Information",
    HeaderUsage                                 = "Utilisation",
    HeaderSlashCommand                          = "Commandes",
    HeaderCredits                               = "Crédits",

    SlashSpellBook                              = "Rescanner Grimoire",
    SlashUpdate                                 = "Mettre à jour macro / liste",
    SlashClose                                  = "Fermer fenêtre BOM",
    SlashReset                                  = "Réinitialiser fenêtre BOM",
    SlashOpen                                   = "Ouvrir fenêtre BOM",

    --AboutInfo="<dummy info>",
    --AboutUsage="<dummy usage>",
    AboutSlashCommand                           = "<valeur> peut être true, 1, enable, false, 0, disable. Si <valeur> est omis, la valeur actuelle s'inverse.",
    --AboutCredits="wellcat pour la traduction Chinoise",
  }
end

local function bomLanguage_Russian()
  return {
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

    ["options.short.ArgentumDawn"]              = "Не забудьте (снять)экипировать Жетон Серебряного Рассвета",
    ["options.short.AutoOpen"]                  = "Автоматическое открытие/закрытие",
    ["options.short.DeathBlock"]                = "Не применять групповые эффекты, когда кто-то мертв",
    ["options.short.ScanInStealth"]             = "Сканировать бафы в режиме незаметности",
    ["options.short.ScanInRestArea"]            = "Сканировать бафы в городах и тавернах",
    ["options.short.InInstance"]                = "Сканировать бафы в подземельях и рейдах",
    ["options.short.InPVP"]                     = "Сканировать бафы на полях битвы",
    ["options.short.InWorld"]                   = "Сканировать бафы в открытом мире",
    ["options.short.PreventPVPTag"]             = "Не бафать PvP игроков, если ваш PvP выключен",
    ["options.short.LockMinimapButton"]         = "Блокировка положения кнопки у миникарты",
    ["options.short.LockMinimapButtonDistance"] = "Минимизировать расстояние до миникарты",
    ["options.short.NoGroupBuff"]               = "Всегда давать одиночные бафы",
    ["options.short.GroupBuff"]                 = "Групповые бафы, если это экономит ману (увеличенный расход реагентов)",
    ["options.short.ReplaceSingle"]             = "Заменить одиночный баф групповым",
    ["options.short.ResGhost"]                  = "Пытаться воскрешать призраки, если тело лежит близко",
    ["options.short.SameZone"]                  = "Только если находится в одной зоне со мной",
    ["options.short.ShowMinimapButton"]         = "Показать кнопку у миникарты",
    ["options.short.UseRank"]                   = "Использовать заклинание с рангом",
    ["options.short.ShowClassicConsumables"]    = "Показывать бафы из классической версии",
    ["options.short.ShowTBCConsumables"]        = "Показывать бафы из TBC",
    ["options.short.HideSomeoneIsDrinking"]     = "Не показывать сообщение о том, что 'Кто-то пьёт'",
    ["options.short.ActivateBomOnSpiritTap"]    = "Запретить Бафомёт, при 'Захвате духа' жреца",

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

    ["options.short.MinBlessing"]               = "Большое благословение, если нуждаются более",
    ["options.short.MinBuff"]                   = "Групповой баф, если нуждаются более",
    ["options.short.Time1800"]                  = "Продолжительность <=30 мин:",
    ["options.short.Time300"]                   = "Продолжительность <=5 мин:",
    ["options.short.Time3600"]                  = "Продолжительность <=60 мин:",
    ["options.short.Time60"]                    = "Продолжительность <=60 сек:",
    ["options.short.Time600"]                   = "Продолжительность <=10 мин:",

    --[[Translation missing --]]
    --[[ ["Header_INFO"] = "Information",--]]
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
    MsgBusy                                     = "Занят / Кастую",
    MsgBusyChanneling                           = "Занят / Долгое заклинание",
    InactiveReason_InCombat                     = "В бою",
    InactiveReason_RestArea                     = "В зоне отдыха (откл. в опциях)",
    InactiveReason_Mounted                      = "Игрок в седле (откл. в опциях)",
    InactiveReason_IsStealthed                  = "Режим незаметности (откл. в опциях)",
    InactiveReason_PlayerDead                   = "Мертв",
    MsgCancelBuff                               = "Отменён баф %s от %s",
    MsgSpellExpired                             = "%s заклинание истекло.",
    ActionInCombatError                         = "Во время боя нельзя показывать или скрывать панели",
    MsgDownGrade                                = "Понижение ранга заклинания %s для %s. Попробуйте выполнить баф ещё раз.",
    MsgNothingToDo                              = "Нечего делать",
    MsgLocalRestart                             = "Настройки не подействуют до перезагрузки модов (команда /reload)",
    MsgNeedOneMacroSlot                         = "Нужен хотя бы один свободный слот для макро!",
    MsgNextCast                                 = "%s @ %s",
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
  }
end

local function bomLanguage_Chinese()
  return {
    ["options.OptionsTitle"]                    = "Buffomat",

    ["options.general.group.AutoActions"]       = "自动操作",
    ["options.general.group.Convenience"]       = "便利性",
    ["options.general.group.General"]           = "常规",
    ["options.general.group.Scan"]              = "扫描",
    ["options.general.group.Buffing"]           = "增益",

    ["options.short.ArgentumDawn"]              = "警告:声望物品",
    ["options.short.AutoCrusaderAura"]          = "提醒：十字军光环",
    ["options.short.AutoDismount"]              = "自动离开坐骑",
    ["options.short.AutoDismountFlying"]        = "自动离开飞行坐骑",
    ["options.short.AutoDisTravel"]             = "自动离开旅行状态",
    ["options.short.AutoOpen"]                  = "自动打开 Buffomat",
    ["options.short.AutoStand"]                 = "自动站立",
    ["options.short.BuffTarget"]                = "优先目标增益",
    ["options.short.Carrot"]                    = "装备物品的警告",
    ["options.short.ActivateBomOnSpiritTap"]    = "在低于 % 的精神激活",
    ["options.short.DeathBlock"]                = "如果有人死亡就暂停",
    ["options.short.DontUseConsumables"]        = "不使用消耗品",
    ["options.short.HideSomeoneIsDrinking"]     = "隐藏'有人在喝酒'",
    ["options.short.InInstance"]                = "在地下城/团本扫描",
    ["options.short.InPVP"]                     = "在战场扫描",
    ["options.short.InWorld"]                   = "在世界扫描",
    ["options.short.LockMinimapButton"]         = "锁定小地图图标",
    ["options.short.LockMinimapButtonDistance"] = "锁定小地图图标距离",
    ["options.short.MainHand"]                  = "缺少主手附魔",
    ["options.short.NoGroupBuff"]               = "避免群体增益",
    ["options.short.OpenLootable"]              = "打开可拾取的容器",
    ["options.short.PreventPVPTag"]             = "防止PVP标志",
    ["options.short.ReplaceSingle"]             = "替换单体增益",
    ["options.short.ResGhost"]                  = "尝试复活灵魂",
    ["options.short.SameZone"]                  = "扫描同一地区的成员",
    ["options.short.ScanInRestArea"]            = "休息区时扫描",
    ["options.short.ScanInStealth"]             = "隐身时扫描",
    ["options.short.ScanWhileMounted"]          = "安装时扫描",
    ["options.short.SecondaryHand"]             = "缺少副手附魔",
    ["options.short.SelfFirst"]                 = "永远自我",
    ["options.short.ShowMinimapButton"]         = "显示小地图按钮",
    ["options.short.SlowerHardware"]            = "减少扫描增益的频率",
    ["options.short.UseRank"]                   = "使用等级增益",
    ["options.short.UseProfiles"]               = "使用配置文档",

    ["options.long.ArgentumDawn"]               = "提醒更换银色黎明饰品",
    ["options.long.AutoCrusaderAura"]           = "圣骑士: 骑乘时自动开启十字军光环",
    ["options.long.AutoDismount"]               = "施法时自动取消地面坐骑",
    ["options.long.AutoDismountFlying"]         = "施法时自动取消飞行坐骑 (小心摔死)",
    ["options.long.AutoDisTravel"]              = "自动离开旅行状态 (在经典中不起作用)",
    ["options.long.AutoOpen"]                   = "有工作要做时自动显示 Buffomat (输入/bom)",
    ["options.long.AutoStand"]                  = "如果你在坐着的状态, Buffomat 会站起来",
    ["options.long.BuffTarget"]                 = "强制给当前目标施放增益",
    ["options.long.Carrot"]                     = "提醒取消装备的骑乘/飞行饰品",
    ["options.long.ActivateBomOnSpiritTap"]     = "如果牧师的'精神' 处于活跃状态且玩家法力低于 % ,则禁用",
    ["options.long.DeathBlock"]                 = "当有人死亡,不施放群体增益",
    ["options.long.DontUseConsumables"]         = "仅通过 Shift, Ctrl 或 Alt 使用消耗品",
    ["options.long.GroupBuff"]                  = "一直施放群体BUFF(额外的材料成本)",
    ["options.long.HideSomeoneIsDrinking"]      = "隐藏'有人在喝酒' 的信息",
    ["options.long.InInstance"]                 = "在地下城和团本扫描增益",
    ["options.long.InPVP"]                      = "在战场扫描增益",
    ["options.long.InWorld"]                    = "在世界和城市扫描增益",
    ["options.long.LockMinimapButton"]          = "锁定小地图图标位置",
    ["options.long.LockMinimapButtonDistance"]  = "最小化小地图图标距离",
    ["options.long.MainHand"]                   = "主手缺少附魔,则发出警告",
    ["options.long.NoGroupBuff"]                = "总是单体增益",
    ["options.long.OpenLootable"]               = "开启背包内可拾取的物品",
    ["options.long.PreventPVPTag"]              = "当你非PVP状态时跳过开启PVP的目标",
    ["options.long.ReplaceSingle"]              = "将单体增益替换为群体增益",
    ["options.long.ResGhost"]                   = "尝试复活灵魂状态的",
    ["options.long.SameZone"]                   = "在同一地区扫描",
    ["options.long.ScanInRestArea"]             = "在休息区(城市和旅店)扫描增益",
    ["options.long.ScanInStealth"]              = "扫描增益(隐身的)",
    ["options.long.ScanWhileMounted"]           = "安装时扫描",
    ["options.long.SecondaryHand"]              = "副手缺少附魔,则发出警告",
    ["options.long.SelfFirst"]                  = "永远先给自己加BUFF",
    ["options.long.ShowClassicConsumables"]     = "显示经典可能的消耗品",
    ["options.long.ShowMinimapButton"]          = "显示小地图按钮",
    ["options.long.ShowTBCConsumables"]         = "显示TBC可用的消耗品",
    ["options.long.SlowerHardware"]             = "不太频繁的增益检查 (针对硬件不好/团队)",
    ["options.long.UseProfiles"]                = "使用配置文档",
    ["options.long.UseRank"]                    = "使用有等级的技能",
    ["options.long.UseProfiles"]                = "根据玩家个人/队伍/团队/战场使用配置文档",

    SELF                                        = "自己", -- use instead of name when buffing self
    BUFF_CLASS_SELF_ONLY                        = "自己-Buff",
    BUFF_CLASS_REGULAR                          = "Buff",
    BUFF_CLASS_GROUPBUFF                        = "团队-Buff ",
    BUFF_CLASS_TRACKING                         = "追踪",
    TASK_CLASS_REMINDER                         = "提醒",
    TASK_CLASS_RESURRECT                        = "复活",
    TASK_CLASS_MISSING_CONSUM                   = "缺少材料",
    BUFF_CLASS_CONSUMABLE                       = "材料",
    BUFF_CONSUMABLE_REMINDER                    = "按住 Shift/Ctrl 和 Alt",
    TASK_BLESS_GROUP                            = "强效祝福",
    TASK_BLESS                                  = "祝福",
    TASK_SUMMON                                 = "召唤",
    TASK_CAST                                   = "施放",
    TASK_USE                                    = "使用",
    TASK_TBC_HUNTER_PET_BUFF                    = "对宠物使用",
    TASK_ACTIVATE                               = "启用",
    TASK_UNEQUIP                                = "取下装备",
    ERR_RANGE                                   = "类别",
    AD_REPUTATION_REMINDER                      = "银色黎明徽记",
    RIDING_SPEED_REMINDER                       = "骑术/飞行速度饰品",
    OUT_OF_THAT_ITEM                            = "不在背包",
    CboxNoGroupBuff                             = "不使用群体BUFF",
    CboxGroupBuff                               = "一直施放群体BUFF(额外的材料成本)",

    CHAT_MSG_PREFIX                             = "Buffomat: ",
    Buffomat                                    = "Buffomat", -- addon title in the main window
    ResetWatchGroups                            = "重置为1-8队",
    FORMAT_BUFF_SINGLE                          = "%s %s",
    FORMAT_BUFF_SELF                            = "%s %s 对自己",
    FORMAT_BUFF_GROUP                           = "团队 %s %s",
    FORMAT_GROUP_NUM                            = "团%s",
    MsgNextCast                                 = "%s @ %s",
    --MsgNoSpell="Out of Range or Mana",
    MsgFlying                                   = "飞行:下坐骑禁用",
    MsgOnTaxi                                   = "坐骑上不检查",
    MsgBusy                                     = "繁忙中/角色",
    MsgBusyChanneling                           = "繁忙中/聊天信息",
    MsgNothingToDo                              = "无事可做",
    MsgNeedOneMacroSlot                         = "需要一个宏!",
    MsgLocalRestart                             = "重载界面后才能更新设置 (/reload))",
    MsgCancelBuff                               = "%s 取消增益 %s",
    MsgSpellExpired                             = "%s 时间到了",
    ActionInCombatError                         = "无法在战斗中显示/隐藏窗口",
    MsgOpenContainer                            = "使用/打开",
    MSG_MAINHAND_ENCHANT_MISSING                = "主手缺少临时附魔",
    MSG_OFFHAND_ENCHANT_MISSING                 = "副手缺少临时附魔",
    InfoSomeoneIsDrinking                       = "1 在喝酒",
    InfoMultipleDrinking                        = "%d 在喝酒",

    InactiveReason_PlayerDead                   = "你已死亡",
    InactiveReason_InCombat                     = "你在战斗中",
    InactiveReason_RestArea                     = "休息区禁用检查",
    InactiveReason_DeadMember                   = "队友死亡",
    InactiveReason_IsStealthed                  = "隐身禁用检查",
    InactiveReason_SpiritTap                    = "牧师的 <精神> 处于活跃状态",
    InactiveReason_PvpZone                      = "战场禁用检查",
    InactiveReason_Instance                     = "地下城禁用检查",
    InactiveReason_OpenWorld                    = "野外禁用检查",
    InactiveReason_Mounted                      = "坐骑上禁用检查",

    MsgDownGrade                                = "%s 的技能等级降级为 %s。请再补一次。",

    CRUSADER_AURA_COMMENT                       = "根据设置可以自动施放",

    HeaderRenew                                 = "到时间前通知 (秒)",

    ["options.short.Time60"]                    = "时间 <=60 秒:",
    ["options.short.Time300"]                   = "时间 <=5 分:",
    ["options.short.Time600"]                   = "时间 <=10 分:",
    ["options.short.Time1800"]                  = "时间 <=30 分:",
    ["options.short.Time3600"]                  = "时间 <=60 分:",
    ["options.short.UIWindowScale"]             = "UI 比例",
    ["options.short.MinBuff"]                   = "群体增益需达到多少人以上使用",
    ["options.short.MinBlessing"]               = "强效祝福需达到多少人以上使用",

    ["options.long.Time60"]                     = "刷新增益的时间，如何剩余时间少于 <=60 秒 ",
    ["options.long.Time300"]                    = "刷新增益的时间，如何剩余时间少于 <=5 分",
    ["options.long.Time600"]                    = "刷新增益的时间，如何剩余时间少于 <=10 分",
    ["options.long.Time1800"]                   = "刷新增益的时间，如何剩余时间少于 <=30 分",
    ["options.long.Time3600"]                   = "刷新增益的时间，如何剩余时间少于 <=60 分",
    ["options.long.UIWindowScale"]              = "UI 比例 (默认 1; 隐藏和显示Buffomat设置)",
    ["options.long.MinBuff"]                    = "群体增益使用需要缺失的数量",
    ["options.long.MinBlessing"]                = "强效祝福使用需要缺失祝福的数量",

    TooltipSelfCastCheckbox_Self                = "仅自己",
    TooltipSelfCastCheckbox_Party               = "队伍/团队的Buff",
    TooltipEnableSpell                          = "添加这个 Buff 到列表内",
    TooltipEnableBuffCancel                     = "发现这个 Buff 就取消",
    FormatToggleTarget                          = "点击切换队伍: %s",
    FormatAllForceCastTargets                   = "强制施法: ",
    FormatForceCastNone                         = "强制施法列表",
    FormatAllExcludeTargets                     = "忽略: ",
    FormatExcludeNone                           = "忽略施法列表",
    TooltipForceCastOnTarget                    = "将当前团队/队伍目标添加到监控列表",
    TooltipExcludeTarget                        = "将当前团队/队伍目标添加到忽略列表",
    TooltipSelectTarget                         = "选择一个团队/队伍启用此选项",
    TooltipGroup                                = "在副本中检查 Buff %d",
    TooltipRaidGroupsSettings                   = "团队小组检查设置",
    MessageAddedForced                          = "强制 Buff ",
    MessageClearedForced                        = "取消强制 Buff",
    MessageAddedExcluded                        = "永不 Buff ",
    MessageClearedExcluded                      = "删除为",

    HintCancelThisBuff                          = "取消这个 Buff",
    HintCancelThisBuff_Combat                   = "战斗前",
    HintCancelThisBuff_Always                   = "一直",

    TooltipWhisperWhenExpired                   = "当BUFF过期时，对施放者密语提醒",
    TooltipMainHand                             = "主手",
    TooltipOffHand                              = "副手",
    ShamanEnchantBlocked                        = "主手等待", -- TBC: Shown when shaman cannot enchant this hand because the other hand goes first
    PreventPVPTagBlocked                        = "目标开启 PvP", -- PreventPVPTag option enabled, player is non-PVP and target is PVP
    TooltipIncludesAllRanks                     = "所有这种类型的BUFF",
    TooltipSimilar                              = "任何类似的",
    TooltipSimilarFoods                         = "所有类型的食物",

    TabBuff                                     = "Buff",
    TabDoNotBuff                                = "不要 Buff",
    TabBuffOnlySelf                             = "Buff 仅限自己", -- Shown when all raid groups are deselected
    TabSpells                                   = "技能",
    --TabItems = "Items",
    --TabBehaviour = "Behaviour",

    BtnOpen                                     = "打开",
    BtnCancel                                   = "取消",
    ["popup.QuickSettings"]                     = "快速设置",
    BtnSettings                                 = "设置窗口",
    BtnSettingsSpells                           = "设置技能",
    BtnBuffs                                    = "材料",
    ButtonCastBuff                              = "施放BUFF",
    ButtonBuffomatWindow                        = "显示/隐藏 Buffomat 窗口",

    Header_TRACKING                             = "追踪",
    --ActivateTracking              = "Activate tracking:", -- message when tracking is enabled
    Header_INFO                                 = "信息",
    Header_CANCELBUFF                           = "取消 BUFF",
    Header_item                                 = "材料",
    HeaderSupportedSpells                       = "支持的技能",
    HeaderWatchGroup                            = "团队中监控[队伍]",
    PanelAbout                                  = "关于",
    HeaderInfo                                  = "信息",
    HeaderUsage                                 = "用法",
    HeaderSlashCommand                          = "可用命令",
    HeaderCredits                               = "Credits",
    HeaderCustomLocales                         = "本地化",
    HeaderProfiles                              = "简介",

    SlashSpellBook                              = "重新扫描技能书",
    SlashUpdate                                 = "更新宏/列表",
    SlashClose                                  = "取消 BOM 窗口",
    SlashReset                                  = "重置 BOM 窗口",
    SlashOpen                                   = "打开 BOM 窗口",
    SlashProfile                                = "将当前配置文件更改为 个人/队伍/团队/战场/自动",

    Tank                                        = "坦克",
    Pet                                         = "宠物",
    TooltipCastOnClass                          = "给职业施法",
    TooltipCastOnTank                           = "给坦克施法",
    TooltipCastOnPet                            = "给宠物施法",

    profile_solo                                = "个人",
    profile_group                               = "队伍",
    profile_raid                                = "团队",
    profile_battleground                        = "战场",
    profile_auto                                = "自动",

    AboutInfo                                   = "耐力!智力!精神! - 这听起来很熟悉吗？ Buffomat 监控 "
            .. "扫描团队成员是否缺失BUFF,然后单击它就能给缺失BUFF的队友施放。当三 "
            .. "个或更多成员丢失同一个BUFF时,会使用群体BUFF "
            .. "插件的另一个功能是你提醒你启用'寻找草药'之类的追踪技能。插件同样可以用于复活技能 "
            .. "当你点击宏时,它将复活你身边的人-优先级最高为萨满,圣骑士和牧师。 ",

    AboutUsage                                  = "你需要一个宏才能使用此插件。 主窗口有 "
            .. "两个标签'BUFF'和'技能'。 在'BUFF'下你会找到所有缺失的BUFF和一个施放按钮. "
            .. "在'技能'下,你可以设置那些技能应该被监控,是否 "
            .. "应该使用群体BUFF。选择是对你还是对所有队伍成员. "
            .. "选择哪个BUFF应该在哪个职业上使用。 你也可以忽略整个队伍 "
            .. "(例如在副本中,当你被分配给7队和8队上增益BUFF时)你也可以"
            .. "在这里选择,一个BUFF应该在当前目标上施放。例如 "
            .. "当德鲁伊点击主坦克,在'荆棘术'点击'-'（最后一个符号）- "
            .. "会变成十字准星,现在插件将记住你要把BUFF施放给主坦克。"
            .. "你有两个选项可以从缺失的BUFF列表中选择一个去施放BUFF。"
            .. "窗口中的法术按钮或插件的宏。 你可以在主窗口的'标题栏'上找到'M'按钮。"
            .. "|n重要提醒：插件只在脱战后起作用,因为暴雪 "
            .. "不允许在战斗中更改宏。"
            .. "另外,在战斗中也不允许打开或关闭主窗口！",

    AboutSlashCommand                           = "", --<value> can be true, 1, enable, false, 0, disable. If <value> is omitted, the current status switches.",

    TooltipMacroButton                          = "将此宏拖到您的动作条中来施放BUFF|您也可以在按键绑定 =>其他 中为宏添加快捷键 ",
    TooltipSettingsButton                       = "打开快速设置和配置文件存档",
    TooltipCloseButton                          = "隐藏 Buffomat 窗口,输入 /bom 重新打开或单击小地图按钮",
    TooltipCastButton                           = "从列表中施放法术。|n在战斗中不可用。|n可以通过宏来施放（在顶部）|n需要在按键绑定=>其他 中绑定快捷键",

    SpellLabel_TrackHumanoids                   = "Cat only - 覆盖跟踪草药和矿石",
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
  BOM.L.AboutCredits = "nanjuekaien1 & wellcat for the Chinese translation|n" ..
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
