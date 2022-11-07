local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomCharacterSettingsModule
local characterSettingsModule = BomModuleManager.characterSettingsModule ---@type BomCharacterSettingsModule

local profileModule = BomModuleManager.profileModule

---@alias BomProfileName "solo"|"group"|"raid"|"battleground"|"solo_spec2"|"group_spec2"|"raid_spec2"|"battleground_spec2"

---@shape BomSpellCooldownsTable
---@field [string] number

---@shape BomHiddenCategoryTable
---@field [string] boolean

---@shape BomCharacterSettings Current character state snapshots per profile
---@field [BomProfileName] BomProfile Access to subprofiles [solo, group, raid, battleground, ...]
---@field UseProfiles boolean [⚠DO NOT RENAME] Checkbox to use profiles / automatic profiles
---@field remainingDurations BomSpellCooldownsTable Remaining aura duration on SELF, keyed with buff names
---@field lastTrackingIconId WowIconId|nil Icon id for the last active tracking (not relevant in TBC?)
---@field solo BomProfile
---@field group BomProfile
---@field raid BomProfile
---@field battleground BomProfile
---@field solo_spec2 BomProfile Alternate talents for WotLK dualspec
---@field group_spec2 BomProfile Alternate talents for WotLK dualspec
---@field raid_spec2 BomProfile Alternate talents for WotLK dualspec
---@field battleground_spec2 BomProfile Alternate talents for WotLK dualspec
---@field BuffCategoriesHidden BomHiddenCategoryTable [⚠DO NOT RENAME] True if category is hidden (control in options)
---@field WatchGroup table<number, boolean> [⚠DO NOT RENAME] True to watch buffs in group 1..8
---@field Spell BomBuffDefinitionDict [⚠DO NOT RENAME] Enabled/disabled buffs; see also assignment to ["Spell"] in buffomatModule:InitGlobalStates()
---@field CancelBuff table<BomBuffId, BomBuffDefinition>|nil [⚠DO NOT RENAME]
---@field LastSeal number|nil
---@field LastAura number|nil

local characterStateClass = {}
characterStateClass.__index = characterStateClass

---@param init BomCharacterSettings|nil
---@return BomCharacterSettings
function characterSettingsModule:New(init)
  local tab = init or self:Defaults()
  tab.Spell = tab.Spell or {}
  tab.remainingDurations = tab.remainingDurations or {}
  tab.lastTrackingIconId = tab.lastTrackingIconId or 0

  tab.solo = tab.solo or profileModule:New()
  tab.group = tab.group or profileModule:New()
  tab.raid = tab.raid or profileModule:New()
  tab.battleground = tab.battleground or profileModule:New()

  if BOM.haveWotLK then
    tab.solo_spec2 = tab.solo_spec2 or profileModule:New()
    tab.group_spec2 = tab.group_spec2 or profileModule:New()
    tab.raid_spec2 = tab.raid_spec2 or profileModule:New()
    tab.battleground_spec2 = tab.battleground_spec2 or profileModule:New()
  end

  tab.BuffCategoriesHidden = tab.BuffCategoriesHidden or {}

  --setmetatable(tab, characterStateClass)
  return tab
end

---@return BomCharacterSettings
function characterSettingsModule:Defaults()
  return --[[---@type BomCharacterSettings]] {}
end