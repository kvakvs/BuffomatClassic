---@alias WowClassName "WARRIOR"|"MAGE"|"ROGUE"|"DRUID"|"HUNTER"|"PRIEST"|"WARLOCK"|"SHAMAN"|"PALADIN"|"DEATHKNIGHT"
---@alias WowShapeshiftFormId number Shapeshift form for various classes
---@alias WowItemId number Wow Item ID
---@alias WowZoneId number Wow Zone ID
---@alias WowSpellId number Wow Spell ID

NUM_BAG_SLOTS = 4
BANK_CONTAINER = -1
BACKPACK_CONTAINER = 0
C_Seasons = {
  HasActiveSeason = function()
    return false
  end,
  GetActiveSeason = function()
    return 0
  end
}
WOW_PROJECT_ID = 0
WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 0
WOW_PROJECT_CLASSIC = 0
BomC_ListTab = --[[---@type BomWindowTab]] {}
BomC_ListTab_Button = --[[---@type WowControl]] {}
BomC_ListTab_MessageFrame = --[[---@type WowChatFrame]] {}
BomC_SpellTab = --[[---@type BomWindowTab]] {}
BomC_MainWindow = --[[---@type BomMainWindowFrame]] {}
BomC_MainWindow_Title = --[[---@type WowControl]] {}
BomC_SpellTab_Scroll_Child = --[[---@type WowControl]] {}
DEFAULT_CHAT_FRAME = --[[---@type WowChatFrame]] {}
GameTooltip = --[[---@type WowGameTooltip]] {}
UIDROPDOWNMENU_OPEN_MENU = --[[---@type WowChatFrame]] {}
UIErrorsFrame = --[[---@type WowUIErrorsFrame]] {}
UIParent = --[[---@type WowControl]] {}
InterfaceOptionsFrame = --[[---@type WowControl]] {}
GameMenuFrame = --[[---@type WowControl]] {}

---@class BomWindowTab: WowControl

---@class BomMainWindowFrame: WowControl
---@field Tabs BomWindowTab[]

BackdropTemplateMixin = ""
ERR_SPELL_OUT_OF_RANGE = "Out of range." ---@type string
ShapeShiftTravel = 0

---@param sep string
---@param str string
---@param count number|nil
function strsplit(sep, str, count)
  return "", ""
end
---@return number
function debugprofilestop()
  return 0
end
---@return number, string, boolean, string, string, number, number, string, string, number, number, WowSpellId, string, number, number, number
function CombatLogGetCurrentEventInfo()
  return 0, "", false, "", "", 0, 0, "", "", 0, 0, 0, "", 0, 0, 0
end
function Dismount()
end
---@param e string
function DoEmote(e)
end
---@shape WowSpellCost
---@field name string
---@field cost number
---@param name string
---@return WowSpellCost[]
function GetSpellPowerCost(name)
  return {}
end
---@param s string
function PlaySoundFile(s)
end
---@return number
function GetTime()
  return 0
end
---@return string, number, number, string, number, number, boolean, number, number, number
function GetInstanceInfo()
  return "", 0, 0, "", 0, 0, false, 0, 0, 0
end
---@return boolean, number, number, number, boolean, number, number, number
function GetWeaponEnchantInfo()
  return false, 0, 0, 0, false, 0, 0, 0
end
---@return number, number
function GetSpellCooldown(spellId)
  return 0, 0
end
---@return boolean
function UnitPlayerOrPetInParty(unitId)
  return false
end
---@param a string
---@param b string
---@return number
function UnitReaction(a, b)
  return 0
end
---@return boolean
function UnitPlayerOrPetInRaid(unitId)
  return false
end
function CastSpellByID(...)
end
---@return boolean
function IsFlying()
  return false
end
---@return boolean
function IsMounted()
  return false
end
---@return boolean
function IsSpellKnown(...)
  return false
end
---@return WowShapeshiftFormId
function GetShapeshiftForm(...)
  return 0
end
---@return WowShapeshiftFormId
function GetShapeshiftFormID(...)
  return 0
end
---@return boolean
function InCombatLockdown()
  return false
end
---@param u string
---@param i number
---@param b string
---@return string, string, number, number, number, number, string, boolean, boolean, number
function UnitBuff(u, i, b)
  return "", "", 0, 0, 0, 0, "", false, false, 0
end
---@param u string
---@param i number
function CancelUnitBuff(u, i)
end
---@param t table|any[]
---@return boolean
function tContains(t, v)
  return false
end
---@param t table
function wipe(t)
end
---@return string
function UnitName(...)
  return ""
end
---@return boolean
function UnitIsUnit(a, b)
  return false
end
---@return number
function UnitLevel(u)
  return 0
end
---@param spellId WowSpellId
---@return string
function GetSpellSubtext(spellId)
  return ""
end
---@param spellId WowSpellId
---@return string
function GetSpellInfo(spellId)
  return ""
end
---@return boolean
function IsSpellInRange(...)
  return false
end
---@param u string
---@return boolean
function UnitInParty(u)
  return false
end
---@param u string
---@return boolean
function UnitInRaid(u)
  return false
end
---@param u string
---@return boolean
function UnitIsPlayer(u)
  return false
end
---@param u string
---@param v string
---@return boolean
function UnitCanCooperate(u, v)
  return false
end
---@param u string
---@return string
function UnitFullName(u)
  return ""
end
---@param u string
---@return boolean
function UnitExists(u)
  return false
end
---@param u string
---@return string
function UnitCreatureType(u)
  return ""
end
---@param u string
---@return string
function UnitCreatureFamily(u)
  return ""
end
---@param u string
---@return boolean
function UnitIsPVP(u)
  return false
end
---@param u string
---@return boolean
function UnitIsDeadOrGhost(u)
  return false
end
---@param u string
---@return boolean
function UnitOnTaxi(u)
  return false
end
---@param u string
---@return boolean
function UnitInVehicle(u)
  return false
end
---@param u string
---@return string, WowClassName, string
function UnitClass(u)
  return "", "WARRIOR", ""
end
---@return boolean,
function IsModifierKeyDown()
  return false
end
---@return boolean, string
function IsInInstance()
  return false, ""
end
---@return boolean
function IsOutdoors()
  return false
end
---@return boolean
function IsInGroup()
  return false
end
---@return boolean
function IsInRaid()
  return false
end
---@return boolean
function IsResting()
  return false
end
---@return boolean
function IsStealthed()
  return false
end
---@param u string
---@param pow number
---@return number
function UnitPower(u, pow)
  return 0
end
---@param u string
---@param pow number
---@return number
function UnitPowerMax(u, pow)
  return 0
end
---@return string, string, number {localisedRace, englishRace, numericId}
---@param unit string
function UnitRace(unit)
  return "", "", 0
end
MAX_CHARACTER_MACROS = 0
MAX_ACCOUNT_MACROS = 0
---@param name string
function GetMacroInfo(name)
end
---@param name string
---@param icon string
---@param c string
---@param isChar boolean
function CreateMacro(name, icon, c, isChar)
end
---@param name string
---@param x nil
---@param icon string
---@param text string
function EditMacro(name, x, icon, text)
end
---@return number, number
function GetNumMacros()
  return 0, 0
end
---@return number, number, number, number
function GetNetStats()
  return 0, 0, 0, 0
end
---@return number
function GetActiveTalentGroup()
  return 0
end
---@return string, string, number, number
function GetBuildInfo()
  return "", "", 0, 0
end
---@return string, any, string
function GetCursorInfo()
  return "", 0, ""
end
function ClearCursor()
end