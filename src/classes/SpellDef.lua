local TOCNAME, BOM = ...

---
--- A class describing a spell in available spells collection
---
---@field classes table - list of target classes which are shown as toggle boxes to enable cast per class
---@field default boolean - whether the spell auto-cast is enabled by default
---@field groupDuration number - buff duration for group buff in seconds
---@field groupFamily table - family of group buff spell ids which are mutually exclusive
---@field groupId number - spell id for group buff
---@field hasCD boolean - there's a cooldown on this spell
---@field isAura boolean - true if the buff affects others in radius, and not a target buff
---@field isTracking boolean - true if the buff is tracking of some resource or enemy
---@field isWeapon boolean - the buff is a temporary weapon enchant on user's weapons
---@field item number - buff is granted by an item in user's bag
---@field itemLock table - item ids
---@field NeededGroupItem table - reagent item ids for group buff
---@field onlyUsableFor table - list of classes which only can see this buff (hidden for others)
---@field singleDuration number - buff duration for single buff in seconds
---@field singleFamily table - family of single buff spell ids which are mutually exclusive
---@field singleId number - spell id for single buff
BOM.SpellDef = {}
BOM.SpellDef.__index = BOM.SpellDef

local CLASS_TAG = "spelldef"

---Creates a new SpellDef
---@param single_id number - spell id also serving as configId key
---@param fields table - other fields
function BOM.SpellDef:new(single_id, fields)
  fields = fields or {}
  setmetatable(fields, BOM.SpellDef)

  fields.t = CLASS_TAG
  fields.ConfigID = single_id
  fields.singleId = single_id

  return fields
end
