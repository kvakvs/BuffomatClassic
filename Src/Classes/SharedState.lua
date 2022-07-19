local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomSharedStateModule
local sharedStateModule = BuffomatModule.New("SharedState") ---@type BomSharedStateModule

--- Values to use when the saved data is evolving with an update, and the key doesn't exist
sharedStateModule.defaults = {
  SomeoneIsDrinking = "low-prio",
}

---@class BomMinimapSettings
---@field visible boolean
---@field lock boolean
---@field lockDistance boolean
---@field position number
---@field distance number

---@class BomSharedState Current character state snapshots per profile
---@field Minimap BomMinimapSettings
---@field SpellGreatherEqualThan table
---@field CustomLocales table
---@field CustomSpells table Additional spells from the config file. Deprecated
---@field CustomCancelBuff table Additional cancel spells. Deprecated
---@field UIWindowScale number
---@field AutoOpen boolean
---@field UseProfiles boolean
---@field SlowerHardware boolean
---@field ScanInRestArea boolean
---@field ScanInStealth boolean
---@field ScanWhileMounted boolean
---@field InWorld boolean
---@field InPVP boolean
---@field InInstance boolean
---@field SameZone boolean
---@field AutoCrusaderAura boolean
---@field AutoDismount boolean
---@field AutoDismountFlying boolean
---@field AutoStand boolean
---@field AutoDisTravel boolean
---@field PreventPVPTag boolean
---@field DeathBlock boolean
---@field NoGroupBuff boolean
---@field ResGhost boolean
---@field ReplaceSingle boolean
---@field ArgentumDawn boolean
---@field Carrot boolean
---@field MainHand boolean
---@field SecondaryHand boolean
---@field UseRank boolean
---@field BuffTarget boolean
---@field OpenLootable boolean
---@field SelfFirst boolean
---@field DontUseConsumables boolean
---@field SomeoneIsDrinking string "low-prio" - Show as a comment; "hide" - no show; "show" - Show as a task and show buffomat window
---@field ActivateBomOnSpiritTap number Percent mana to deactivate Buffomat if Spirit Tap is active for a priest
---@field MinBuff number
---@field MinBlessing number
---@field Time60 number
---@field Time300 number
---@field Time600 number
---@field Time1800 number
---@field Time3600 number

---@type BomSharedState
local sharedStateClass = {}
sharedStateClass.__index = sharedStateClass

---@param init BomSharedState
---@return BomSharedState
function sharedStateModule:New(init)
  local tab = init or self:Defaults()
  tab.Minimap = tab.Minimap or {}
  tab.SpellGreatherEqualThan = tab.SpellGreatherEqualThan or {}
  tab.CustomLocales = tab.CustomLocales or {}
  tab.CustomSpells = tab.CustomSpells or {}
  tab.CustomCancelBuff = tab.CustomCancelBuff or {}

  -- Upgrades from older versions (SomeoneIsDrinking was renamed from HideSomeoneIsDrinking)
  tab.HideSomeoneIsDrinking = nil -- delete old key
  tab.SomeoneIsDrinking = tab.SomeoneIsDrinking or self.defaults.SomeoneIsDrinking

  --setmetatable(tab, sharedStateClass)
  return tab
end

---@return BomSharedState
function sharedStateModule:Defaults()
  return {
    UIWindowScale          = 1,
    AutoOpen               = true,
    UseProfiles            = false,
    SlowerHardware         = false,
    ----------------------
    ScanInRestArea         = false,
    ScanInStealth          = false,
    ScanWhileMounted       = false,
    InWorld                = true,
    InPVP                  = true,
    InInstance             = true,
    SameZone               = true,
    ----------------------
    AutoCrusaderAura       = true,
    AutoDismount           = true,
    AutoDismountFlying     = false,
    AutoStand              = true,
    AutoDisTravel          = false,
    ----------------------
    PreventPVPTag          = true,
    DeathBlock             = true,
    NoGroupBuff            = false,
    ResGhost               = false,
    ReplaceSingle          = true,
    ArgentumDawn           = true,
    Carrot                 = true,
    MainHand               = false,
    SecondaryHand          = false,
    UseRank                = false,
    BuffTarget             = false,
    OpenLootable           = true,
    SelfFirst              = true,
    DontUseConsumables     = false,
    SomeoneIsDrinking      = self.defaults.SomeoneIsDrinking,
    ActivateBomOnSpiritTap = 90,
    ----------------------
    MinBuff                = 3,
    MinBlessing            = 3,
    Time60                 = 10,
    Time300                = 90,
    Time600                = 120,
    Time1800               = 180,
    Time3600               = 180,
    ----------------------
    Minimap                = {
      visible      = true,
      lock         = false,
      lockDistance = false,
      position     = 0,
      distance     = 0
    },
  }
end
