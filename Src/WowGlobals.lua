UIErrorsFrame = --[[---@type WowUIErrorsFrame]] {}
DEFAULT_CHAT_FRAME = --[[---@type WowChatFrame]] {}
UIParent = --[[---@type WowControl]] {}
BomC_ListTab_Button = --[[---@type WowControl]] {}
BomC_MainWindow = --[[---@type WowControl]] {}
BomC_MainWindow_Title = --[[---@type WowControl]] {}
BomC_ListTab_MessageFrame = --[[---@type WowControl]] {}
BomC_ListTab_Button = --[[---@type WowControl]] {}
GameTooltip = --[[---@type WowGameTooltip]] {}

BackdropTemplateMixin = ""
ERR_SPELL_OUT_OF_RANGE = "Out of range." ---@type string
ShapeShiftTravel = 0

---@return number
function debugprofilestop() return 0 end
---@param a string
---@param b string
function GetAddOnMetadata(a, b)
end
---@param name string
---@param x WowControl|nil
---@param parent WowControl
---@param template string|nil
---@return WowControl
function CreateFrame(name, x, parent, template)
  return --[[---@type WowControl]] {}
end
---@param t WowControl
---@param n number
function PanelTemplates_TabResize(t, n)
end
---@param name string
function PickupMacro(name)
end
---@return number, string, boolean, string, string, number, number, string, string, number, number, BomSpellId, string, number, number, number
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
---@return number, boolean
function GetInventoryItemID(u, slot)
  return 0, false
end
---@param u string
---@param slot number
---@return string
function GetInventoryItemLink(u, slot)
  return ""
end
---@param slot string
---@return number
function GetInventorySlotInfo(slot)
  return 0
end
---@param b number bag
---@param s number slot
function GetContainerItemInfo(b, s)
  return string, nil, nil, nil, nil, nil, string, nil, nil, nil
end
---@return number, number
function GetSpellCooldown(spellId)
  return 0, 0
end
---@return boolean
function UnitPlayerOrPetInParty(unitId)
  return false
end
---@return boolean
function UnitPlayerOrPetInRaid(unitId)
  return false
end
function SetTracking(...)
end
function GetNumTrackingTypes(...)
end
---@return string, string, boolean, string, number, BomSpellId
function GetTrackingInfo(...)
  return "", "", false, "", 0, 0
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
---@return BomShapeshiftFormId
function GetShapeshiftForm(...)
  return 0
end
---@return BomShapeshiftFormId
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
---@param s string
---@param msg string
---@param lang string|nil
---@param name string
function SendChatMessage(s, msg, lang, name)
end
---@return number
function UnitLevel(u)
  return 0
end
---@param spellId BomSpellId
---@return string
function GetSpellSubtext(spellId)
  return ""
end
---@param spellId BomSpellId
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
---@return string, BomClassName, string
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
