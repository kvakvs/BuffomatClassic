---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---
--- A class describing a spell in available spells collection
---
---@class SpellDef
---@field classes table<string> List of target classes which are shown as toggle boxes to enable cast per class
---@field default boolean Whether the spell auto-cast is enabled by default
---@field groupDuration number Buff duration for group buff in seconds
---@field groupFamily table<number> Family of group buff spell ids which are mutually exclusive
---@field groupId number Spell id for group buff
---@field groupMana number Mana cost for group buff
---@field hasCD boolean There's a cooldown on this spell
---
--- Selected spell casting and display on the cast button
---@field singleLink string Printable link for single buff
---@field groupLink string Printable link for group buff
---@field single string Name of single buff spell
---@field group string Name of group buff spell
---
---type="aura" Auras are no target buff check. True if the buff affects others in radius, and not a target buff
---type="seal" Seals are 1hand enchants which are unique for equipped weapon. Paladins use seals. Shamans also use seals but in TBC shamans have 2 independent seals.
---type="resurrection" The spell will bring up a dead person
---type="tracking" the buff grants the tracking of some resource or enemy type
---type="weapon" The buff is a temporary weapon enchant on user's weapons (poison or shaman etc)
---@field type string Defines type: "aura", "consumable", "weapon" for Enchant Consumables, "seal", "tracking", "resurrection"
---@field isConsumable boolean Is an item-based buff; the spell must have 'items' field too
---@field isInfo boolean
---@field isOwn boolean Spell only casts on self
---
---@field item number - buff is granted by an item in user's bag. Number is item id shows as the icon.
---@field items table<number> - ids of items providing the enchant or buff?
---@field lockIfHaveItem table<number> Item ids which prevent this buff (unique conjured items for example)
---@field needForm number Required shapeshift form ID to cast this buff
---@field onlyUsableFor table<string> list of classes which only can see this buff (hidden for others)
---@field reagentRequired table<number> | number Reagent item ids required for group buff
---@field shapeshiftFormId number Class-based form id (coming from GetShapeshiftFormID LUA API) if active, the spell is skipped
---@field singleDuration number - buff duration for single buff in seconds
---@field singleFamily table<number> Family of single buff spell ids which are mutually exclusive
---@field singleId number Spell id for single buff
---@field singleMana number Mana cost
---
---Fields created dynamically while the addon is running
---
---@field Class table
---@field ConfigID number Spell id of level 60 spell used as key everywhere else
---@field DeathGroup table List of group members who might be dead but in need of this buff
---@field Enable boolean Whether buff is to be watched
---@field ExcludedTarget table<string> List of target names to never buff
---@field ForcedTarget table<string> List of extra targets to buff
---@field frames table<string, Control> Dynamic list of controls associated with this spell
---@field NeedGroup table List of group members who might need group version of this buff
---@field NeedMember table<Member> List of group members who might need this buff
---@field SelfCast boolean
---@field SkipList table If spell cast failed, contains recently failed targets
---@field trackingIconId number Numeric id for the tracking texture icon
---@field trackingSpellName string For tracking spells, contains string name for the spell
---@field shapeshiftFormId number Check this shapeshift form to know whether spell is already casted
BOM.Class.SpellDef = {}
BOM.Class.SpellDef.__index = BOM.Class.SpellDef

local CLASS_TAG = "spelldef"

---Creates a new SpellDef
---@param single_id number Spell id also serving as configId key
---@param fields table<string, any> Other fields
---@return SpellDef
function BOM.Class.SpellDef:new(single_id, fields)
  fields = fields or {}
  setmetatable(fields, BOM.Class.SpellDef)

  fields.t = CLASS_TAG
  fields.ConfigID = single_id
  fields.singleId = single_id

  return fields
end

---@param spellId number
---@param itemId number
function BOM.Class.SpellDef:conjure_item(spellId, itemId)
  return BOM.Class.SpellDef:new(spellId,
          { isOwn          = true,
            default        = true,
            lockIfHaveItem = { itemId },
            singleFamily   = { spellId } })
end
