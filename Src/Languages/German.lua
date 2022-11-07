---@shape BomLanguageGermanModule
local germanModule = BomModuleManager.languageGermanModule ---@type BomLanguageGermanModule

---@return BomLocaleDict
function germanModule:Translations()
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
    ["castButton.Busy"]                         = "Beschäftigt",
    ["message.CancelBuff"]                      = "Beende Buff %s von %s",
    ["castButton.inactive.InCombat"]            = "Kampf",
    ["castButton.inactive.IsDead"]              = "Gestorben",
    MsgDownGrade                                = "Erniedrige den Rang für %s auf %s. Bitte neu zaubern.",
    ["castButton.NothingToDo"]                  = "Nichts zu tun",
    --MsgLocalRestart                             = "Die Lokalisierung wird erst nach einem Neustart übernommen (/reload)",
    ["castButton.NoMacroSlots"]                 = "Brauche Platz für ein Macro!",
    ["castButton.Next"]                         = "%s @ %s",
    InactiveReason_DeadMember                   = "Irgendjemand ist tot",
    ["message.BuffExpired"]                     = "%s ist abgelaufen.",
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
