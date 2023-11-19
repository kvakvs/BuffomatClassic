local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomSharedSettingsModule
local sharedSettingsModule = BomModuleManager.sharedSettingsModule ---@type BomSharedSettingsModule

--- Values to use when the saved data is evolving with an update, and the key doesn't exist
sharedSettingsModule.defaults = {
  SomeoneIsDrinking = "low-prio",
}

---@shape BomMinimapSettings
---@field visible boolean
---@field lock boolean
---@field lockDistance boolean
---@field position number
---@field distance number

---@shape BomSharedSettings Current character state snapshots per profile
---@field Cache BomItemCache Caches responses from GetItemInfo() and GetSpellInfo()
---@field X number Window horizontal position
---@field Y number Window vertical position
---@field Width number Window width
---@field Height number Window height
---@field DebugLogging boolean
---@field PlaySoundWhenTask string Play a sound when task list is not empty
---@field Minimap BomMinimapSettings
---@field SpellGreaterEqualThan table
---@field CustomLocales table
---@field UIWindowScale number
---@field AutoOpen boolean
---@field FadeWhenNothingToDo number Allows Buffomat window to fade when nothing to do
---@field UseProfiles boolean
---@field SlowerHardware boolean
---@field ScanInRestArea boolean
---@field ScanInStealth boolean
---@field ScanWhileMounted boolean
---@field BestAvailableConsume boolean
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
---@field ReputationTrinket boolean
---@field Carrot boolean
---@field MainHand boolean
---@field SecondaryHand boolean
---@field UseRank boolean
---@field BuffTarget boolean
---@field OpenLootable boolean
---@field SelfFirst boolean
---@field DontUseConsumables boolean
---@field SomeoneIsDrinking string "low-prio" - Show as a comment; "hide" - no show; "show" - Show as a task and show buffomat window
---@field HideSomeoneIsDrinking nil
---@field ActivateBomOnSpiritTap number Percent mana to deactivate Buffomat if Spirit Tap is active for a priest
---@field MinBuff number How many missing buffs to prefer group buff
---@field MinBlessing number
---@field Time60 number
---@field Time300 number
---@field Time600 number
---@field Time1800 number
---@field Time3600 number
---@field Duration BomSpellDurationsTable Copy from character settings
---@field ShamanFlametongueRanked boolean Try and use rank 9 on mainhand for shaman when buffing double Flametongue

local sharedStateClass = {}
sharedStateClass.__index = sharedStateClass

---@param init BomSharedSettings
---@return BomSharedSettings
function sharedSettingsModule:New(init)
  local tab = init or self:Defaults()
  tab.Minimap = tab.Minimap or {}
  tab.SpellGreaterEqualThan = tab.SpellGreaterEqualThan or {}
  tab.CustomLocales = tab.CustomLocales or {}

  -- Upgrades from older versions (SomeoneIsDrinking was renamed from HideSomeoneIsDrinking)
  tab.HideSomeoneIsDrinking = nil -- delete old key
  tab.SomeoneIsDrinking = tab.SomeoneIsDrinking or self.defaults.SomeoneIsDrinking

  --setmetatable(tab, sharedStateClass)
  return tab
end

---@return BomSharedSettings
function sharedSettingsModule:Defaults()
  return --[[---@type BomSharedSettings]] {
    UIWindowScale = 1,
    AutoOpen = true,
    FadeWhenNothingToDo = 1.0,
    UseProfiles = false,
    SlowerHardware = false,
    ----------------------
    ScanInRestArea = false,
    ScanInStealth = false,
    ScanWhileMounted = false,
    InWorld = true,
    InPVP = true,
    InInstance = true,
    SameZone = true,
    ----------------------
    AutoCrusaderAura = true,
    AutoDismount = true,
    AutoDismountFlying = false,
    AutoStand = true,
    AutoDisTravel = false,
    ----------------------
    PreventPVPTag = true,
    DeathBlock = true,
    NoGroupBuff = false,
    ResGhost = false,
    ReplaceSingle = true,
    ReputationTrinket = true,
    Carrot = true,
    MainHand = false,
    SecondaryHand = false,
    UseRank = true,
    BuffTarget = false,
    OpenLootable = true,
    SelfFirst = true,
    DontUseConsumables = false,
    SomeoneIsDrinking = self.defaults.SomeoneIsDrinking,
    ActivateBomOnSpiritTap = 90,
    ShamanFlametongueRanked = true,
    ----------------------
    MinBuff = 3,
    MinBlessing = 3,
    Time60 = 10,
    Time300 = 90,
    Time600 = 120,
    Time1800 = 180,
    Time3600 = 180,
    ----------------------
    Minimap = {
      visible = true,
      lock = false,
      lockDistance = false,
      position = 0,
      distance = 0
    },
    PlaySoundWhenTask = "-",
  }
end
