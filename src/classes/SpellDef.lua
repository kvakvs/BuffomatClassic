---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---
--- A class describing a spell in available spells collection
---
---@class SpellDef
---@field targetClasses table<string> List of target classes which are shown as toggle boxes to enable cast per class
---@field default boolean Whether the spell auto-cast is enabled by default
---@field groupDuration number Buff duration for group buff in seconds
---@field groupFamily table<number> Family of group buff spell ids which are mutually exclusive
---@field groupId number Spell id for group buff
---@field groupMana number Mana cost for group buff
---@field hasCD boolean There's a cooldown on this spell
---@field minLevel number If not nil, will hide spell when below this level
---@field maxLevel number If not nil, will hide spell when above this level
---@field consumableEra string One of constants BOM.CLASSIC_ERA or BOM.TBC_ERA which will affect buff visibility based on used choice
---@field tbcHunterPetBuff boolean True for TBC hunter pet consumable which places aura on the hunter pet
---
--- Selected spell casting and display on the cast button
---@field extraText string Added to the right of spell name in the spells config
---@field singleLink string Printable link for single buff
---@field groupLink string Printable link for group buff
---@field single string Name of single buff spell (from GetSpellInfo())
---@field group string Name of group buff spell (from GetSpellInfo())
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
---@field isBlessing boolean Spell will be cast on group members of the same class
---
---@field item number Buff is granted by an item in user's bag. Number is item id shows as the icon.
---@field items table<number> All inventory item ids providing the same effect
---@field lockIfHaveItem table<number> Item ids which prevent this buff (unique conjured items for example)
---@field needForm number Required shapeshift form ID to cast this buff
---@field onlyUsableFor table<string> list of classes which only can see this buff (hidden for others)
---@field reagentRequired table<number> | number Reagent item ids required for group buff
---@field shapeshiftFormId number Class-based form id (coming from GetShapeshiftFormID LUA API) if active, the spell is skipped
---@field singleDuration number - buff duration for single buff in seconds
---@field singleFamily table<number> Family of single buff spell ids which are mutually exclusive
---@field singleId number Spell id for single buff
---@field singleMana number Mana cost
---@field ignoreIfHaveBuff table<number> If these auras are present on target, the buff is not queued
---@field section string Custom section to begin new spells group in the row builder
---
---Fields created dynamically while the addon is running
---
---@field isScanned boolean
---@field Class table
---@field ConfigID number Spell id of level 60 spell used as key everywhere else
---@field DeathGroup table<string, boolean> Group/class members who might be dead but their class needs this buff
---@field Enable boolean Whether buff is to be watched
---@field ExcludedTarget table<string> List of target names to never buff
---@field ForcedTarget table<string> List of extra targets to buff
---@field frames table<string, Control> Dynamic list of controls associated with this spell
---@field NeedGroup table List of group members who might need group version of this buff
---@field NeedMember table<number, Member> List of group members who might need this buff
---@field SelfCast boolean
---@field SkipList table If spell cast failed, contains recently failed targets
---@field trackingIconId number Numeric id for the tracking texture icon
---@field trackingSpellName string For tracking spells, contains string name for the spell
---@field shapeshiftFormId number Check this shapeshift form to know whether spell is already casted
---@field optionText string Used to create sections in spell list in the options page
---@field playerActiv boolean
---@field wasPlayerActiv boolean
---@field buffSource string Unit/player who gave this buff

---@type SpellDef
BOM.Class.SpellDef = {}
BOM.Class.SpellDef.__index = BOM.Class.SpellDef

local CLASS_TAG = "spelldef"

---Creates a new SpellDef
---@param single_id number Spell id also serving as configId key
---@param fields SpellDef Other fields
---@return SpellDef
function BOM.Class.SpellDef:new(single_id, fields)
  fields = fields or {}
  setmetatable(fields, BOM.Class.SpellDef)

  fields.t = CLASS_TAG
  fields.ConfigID = single_id
  fields.singleId = single_id

  fields.ForcedTarget = {}
  fields.ExcludedTarget = {}

  return fields
end

---@param dst table<SpellDef>
---@param single_id number
---@param item_id number|table<number> Item or multiple items giving this buff
---@param limitations table Add extra conditions, if not nil
---@param extraText string Add extra text to the right if not nil
---@return SpellDef
function BOM.Class.SpellDef:tbc_consumable(dst, single_id, item_id, limitations, extraText, extraFields)
  if not BOM.TBC then
    return
  end

  ---@type SpellDef
  local fields = extraFields or {}
  fields.isConsumable = true
  fields.default = false
  fields.consumableEra = BOM.TBC_ERA

  if type(item_id) == "table" then
    fields.item = item_id[1]
    fields.items = item_id
  else
    fields.item = item_id
  end

  if extraText then
    fields.extraText = extraText
  end

  BOM.Class.SpellDef:scan_spell(dst, single_id, fields, limitations)
end

---@param dst table<SpellDef>
---@param single_id number
---@param item_id number
---@param limitations table Add extra conditions, if not nil
---@param extraText string Add extra text to the right if not nil
---@return SpellDef
function BOM.Class.SpellDef:classic_consumable(dst, single_id, item_id, limitations, extraText)
  local fields = { item = item_id, isConsumable = true, default = false, consumableEra = BOM.CLASSIC_ERA }
  if extraText then
    fields.extraText = extraText
  end
  BOM.Class.SpellDef:scan_spell(dst, single_id, fields, limitations)
end

local _, bom_player_class, _ = UnitClass("player")

local function bom_check_limitations(spell, limitations)
  -- empty limitations return true
  if limitations == nil or limitations == { } then
    return true
  end

  for lim, val in pairs(limitations) do
    if lim == "isTBC" then
      if (BOM.TBC == true and val == false) or (BOM.TBC == false and val == true) then
        return false
      end
    end

    if lim == "minLevel" then
      if UnitLevel("player") < val then
        return false
      end
    end

    if lim == "maxLevel" then
      if UnitLevel("player") > val then
        return false
      end
    end

    --if lim == "consumableEra" then
    --  if BOM.TBC then
    --    -- Fail if era is TBC, and consumable is from Classic era and show Classic consumes is disabled
    --    if val == BOM.CLASSIC_ERA and not BOM.SharedState.ShowClassicConsumables then
    --      return false
    --    end
    --  else
    --    -- Fail if era is Classic, and consumable is from TBC era and show TBC consumes is disabled
    --    if val == BOM.TBC_ERA and not BOM.SharedState.ShowTBCConsumables then
    --      return false
    --    end
    --  end
    --end

    if lim == "playerClass" then
      if type(val) == "table" then
        -- Fail if val is a table and player class is not in it
        if not tContains(val, bom_player_class) then
          return false
        end
      else
        -- Fail if val is not equal to the player class
        if val ~= bom_player_class then
          return false
        end
      end
    end -- if playerclass check
  end -- for all limitations

  return true
end

---@param spell SpellDef
---@param modifications table<function>
local function bom_check_modifications(spell, modifications)
  -- empty modifications do not change the spell
  if modifications == nil or modifications == { } then
    return true
  end

  for _, mod in ipairs(modifications) do
    if mod == "shamanEnchant" then
      spell:ShamanEnchant()
    end
  end
end

---Create a spelldef if the limitations apply and add to the table.
---Only check permanent limitations here like minlevel, TBC, or player class.
---@param dst table<SpellDef>
---@param single_id number
---@param fields table<string, any>
---@param limitations table<function> Check these conditions to skip adding the spell. Permanent conditions only like minlevel or class
---@param modifications table<function> Check these conditions and maybe modify the spelldef.
function BOM.Class.SpellDef:scan_spell(dst, single_id, fields, limitations, modifications)
  local spell = BOM.Class.SpellDef:new(single_id, fields)

  if bom_check_limitations(spell, limitations) then
    bom_check_modifications(spell, modifications)
    tinsert(dst, spell)
  end
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

---@param self SpellDef
function BOM.Class.SpellDef.ShamanEnchant(self)
  -- for before TBC make this a seal spell, for TBC do not modify
  if not BOM.TBC then
    self.type = "seal"
  end
  return self
end

---@param self SpellDef
---@return boolean Whether the spell allows user to do target class choices
function BOM.Class.SpellDef.HasClasses(self)
  return not (self.isConsumable
          or self.isOwn
          or self.type == "resurrection"
          or self.type == "seal"
          or self.type == "tracking"
          or self.type == "aura"
          or self.isInfo)
end

---@param class_name string
function BOM.Class.SpellDef:IncrementNeedGroupBuff(class_name)
  self.NeedGroup[class_name] = (self.NeedGroup[class_name] or 0) + 1
end

---@param spell_id number
---@param profile_name string|nil
function BOM.GetProfileSpell(spell_id, profile_name)
  local spell
  if profile_name == nil then
    spell = BOM.CurrentProfile.Spell[spell_id]
  else
    local profile = BOM.CharacterState[profile_name]
    if profile == nil then
      return nil
    end
    spell = profile.Spell[spell_id]
  end

  return spell
end

---Returns true whether spell is enabled by the player (has checkbox)
---@param spell_id number
---@return boolean
---@param profile_name string|nil
function BOM.IsSpellEnabled(spell_id, profile_name)
  local spell = BOM.GetProfileSpell(spell_id, profile_name)
  if spell == nil then
    return false
  end
  return spell.Enable
end
