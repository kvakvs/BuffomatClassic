local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomCharacterStateModule
local characterStateModule = BuffomatModule.New("CharacterState") ---@type BomCharacterStateModule

---@class BomCharacterState Current character state snapshots per profile
---@field Spell table<number, BomSpellDef>
---@field Duration table<string, number> Remaining aura duration on SELF, keyed with buff names
---@field LastTracking number Icon id for the last active tracking (not relevant in TBC?)
---@field solo BomProfile
---@field group BomProfile
---@field raid BomProfile
---@field battleground BomProfile
---@field BuffCategoriesHidden table<string, boolean> True if category is hidden (control in options)
---@field WatchGroup table<string, boolean> True to watch buffs in group 1..8

---@type BomCharacterState
local characterStateClass = {}
characterStateClass.__index = characterStateClass

---@param init BomCharacterState
---@return BomCharacterState
function characterStateModule:New(init)
  local tab = init or self:Defaults()
  tab.Spell = tab.Spell or {}
  tab.Duration = tab.Duration or {}
  tab.LastTracking = tab.LastTracking or 0
  tab.solo = tab.solo or {}
  tab.group = tab.group or {}
  tab.raid = tab.raid or {}
  tab.battleground = tab.battleground or {}
  tab.BuffCategoriesHidden = tab.BuffCategoriesHidden or {}

  --setmetatable(tab, characterStateClass)
  return tab
end

---@return BomCharacterState
function characterStateModule:Defaults()
  return {}
end