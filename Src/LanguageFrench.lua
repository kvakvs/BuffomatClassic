---@class BomLanguageFrenchModule
local frenchModule = BuffomatModule.New("LanguageFrench") ---@type BomLanguageFrenchModule

function frenchModule:Translations()
  return {
    FORMAT_BUFF_SINGLE                          = "%s %s",
    FORMAT_BUFF_SELF                            = "%s %s sur toi-même",
    FORMAT_BUFF_GROUP                           = "Groupe %s %s",
    ["castButton.Next"]                         = "%s @ %s",
    --MsgNoSpell                    = "Hors portée ou Mana",
    ["castButton.inactive.IsDead"]              = "Mort",
    ["castButton.Busy"]                         = "Occupé",
    ["castButton.inactive.InCombat"]            = "En combat",
    ["castButton.NothingToDo"]                  = "Rien à faire",
    InactiveReason_DeadMember                   = "Quelqu'un est mort",
    ["castButton.NoMacroSlots"]                 = "Besoin d'un emplacement macro!",

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