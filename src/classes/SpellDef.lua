---@type BuffomatAddon
local TOCNAME, BOM = ...

---
--- A class describing a spell in available spells collection
---
---@class SpellDef
---@field classes table<string> List of target classes which are shown as toggle boxes to enable cast per class
---@field default boolean Whether the spell auto-cast is enabled by default
---@field groupDuration number Buff duration for group buff in seconds
---@field groupFamily table<number> Family of group buff spell ids which are mutually exclusive
---@field groupId number Spell id for group buff
---@field hasCD boolean There's a cooldown on this spell
---@field isAura boolean No target buff check. True if the buff affects others in radius, and not a target buff
---@field isTracking boolean True if the buff is tracking of some resource or enemy
---@field isInfo boolean
---@field isBuff boolean
---@field isSeal boolean TODO: Document this - Only one can be active/casts on self???
---@field isOwn boolean Spell only casts on self
---@field isWeapon boolean The buff is a temporary weapon enchant on user's weapons
---@field item number - buff is granted by an item in user's bag
---@field itemLock table<number> Item ids which prevent this buff (unique conjured items for example)
---@field reagentRequired table<number> | number Reagent item ids required for group buff
---@field onlyUsableFor table<string> list of classes which only can see this buff (hidden for others)
---@field shapeshiftFormId number Class-based form id (coming from GetShapeshiftFormID LUA API) if active, the spell is skipped
---@field singleDuration number - buff duration for single buff in seconds
---@field singleFamily table<number> Family of single buff spell ids which are mutually exclusive
---@field singleId number Spell id for single buff
---@field singleMana number Mana cost
---@field groupMana number Mana cost for group buff
---
---Fields created dynamically while the addon is running
---
---@field ConfigID number Spell id of level 60 spell used as key everywhere else
---@field NeedMember table List of group members who might need this buff
---@field NeedGroup table List of group members who might need group version of this buff
---@field DeathGroup table List of group members who might be dead but in need of this buff
---@field TrackingIcon number Numeric id for the tracking texture icon
---@field SkipList table If spell cast failed, contains recently failed targets
---@field Class table
---@field ForcedTarget table<string> List of extra targets to buff
---@field ExcludedTarget table<string> List of target names to never buff
---@field Enable boolean Whether buff is to be watched
---@field SelfCast boolean
---@field frames table<string, Control> Dynamic list of controls associated with this spell
---xxx field isShamanDualwield boolean If true, will display seal spell for both hands (TBC shamans!)
BOM.SpellDef = {}
BOM.SpellDef.__index = BOM.SpellDef

local CLASS_TAG = "spelldef"

---Creates a new SpellDef
---@param single_id number Spell id also serving as configId key
---@param fields table<string, any> Other fields
---@return SpellDef
function BOM.SpellDef:new(single_id, fields)
  fields = fields or {}
  setmetatable(fields, BOM.SpellDef)

  fields.t = CLASS_TAG
  fields.ConfigID = single_id
  fields.singleId = single_id

  return fields
end
