local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomSpellDefModule
local spellDefModule = BuffomatModule.New("SpellDef") ---@type BomSpellDefModule

local buffomatModule = BuffomatModule.Import("Buffomat") ---@type BomBuffomatModule
local spellCacheModule = BuffomatModule.Import("SpellCache") ---@type BomSpellCacheModule
local itemCacheModule = BuffomatModule.Import("ItemCache") ---@type BomItemCacheModule
local buffRowModule = BuffomatModule.Import("Ui/BuffRow") ---@type BomBuffRowModule

BOM.Class = BOM.Class or {}

---@class BomSpellLimitations
---@field showInTBC boolean
---@field hideInTBC boolean
---@field showInWotLK boolean
---@field hideInWotLK boolean
---@field playerRace string
---@field playerClass string|table<number, string> Collection of classes for this spell, or classname
---@field maxLevel number Hide the spell if player is above this level (to deprecate old spells)
---@field hideIfSpellKnown number Hide the spell if spellId is in their spellbook

---
--- A class describing a spell in available spells collection
---
---@class BomSpellDef
---@field limitations BomSpellLimitations
---@field category string|nil Group by this field and use special translation table to display headers
---@field elixirType string|nil Use this for elixir mutual exclusions on elixirs
---@field targetClasses table<string> List of target classes which are shown as toggle boxes to enable cast per class
---@field default boolean Whether the spell auto-cast is enabled by default
---@field groupDuration number Buff duration for group buff in seconds
---@field groupFamily table<number> Family of group buff spell ids which are mutually exclusive
---@field groupId number Spell id for group buff
---@field groupMana number Mana cost for group buff
---@field hasCD boolean There's a cooldown on this spell
---@field minLevel number If not nil, will hide spell when below this level
---@field maxLevel number If not nil, will hide spell when above this level
---@field consumableEra string One of constants BOM.CLASSIC_ERA or BOM.IsTBC_ERA which will affect buff visibility based on used choice
---@field tbcHunterPetBuff boolean True for TBC hunter pet consumable which places aura on the hunter pet
---
---@field creatureFamily string Warlock summon pet family for type='summon' (Imp, etc)
---@field creatureType string Warlock summon pet type for type='summon' (Demon)
---@field sacrificeAuraIds number Aura id for demonic sacrifice of that pet. Do not summon if buff is present.
---@field requiresWarlockPet boolean For Soul Link - must check if a demon pet is present
---
--- Selected spell casting and display on the cast button
---@field extraText string Added to the right of spell name in the spells config
---@field singleLink string Printable link for single buff
---@field groupLink string Printable link for group buff
---@field singleText string Name of single buff spell (from GetSpellInfo())
---@field groupText string Name of group buff spell (from GetSpellInfo())
---@field spellIcon string
---@field itemIcon string
---
---type="aura" Auras are no target buff check. True if the buff affects others in radius, and not a target buff
---type="seal" Seals are 1hand enchants which are unique for equipped weapon. Paladins use seals. Shamans also use seals but in TBC shamans have 2 independent seals.
---type="resurrection" The spell will bring up a dead person
---type="tracking" the buff grants the tracking of some resource or enemy type
---type="weapon" The buff is a temporary weapon enchant on user's weapons (poison or shaman etc)
---@field type string Defines type: "aura", "consumable", "weapon" for Enchant Consumables, "seal", "tracking", "resurrection"
---@field isConsumable boolean Is an item-based buff; the spell must have 'items' field too
---@field consumableTarget string Add "[@" .. consumableTarget .. "]" to the "/use bag slot" macro
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
---@field ignoreIfBetterBuffs table<number> If these auras are present on target, the buff is not queued
---@field section string Custom section to begin new spells group in the row builder
---
---Fields created dynamically while the addon is running
---
---@field isScanned boolean
---@field Class table
---@field buffId number Spell id of level 60 spell used as key everywhere else
---@field Enable boolean Whether buff is to be watched
---@field ExcludedTarget table<string> List of target names to never buff
---@field ForcedTarget table<string> List of extra targets to buff
---@field frames BomBuffRowFrames Dynamic list of controls associated with this spell in the UI
---@field GroupsHaveDead table<string, boolean> Group/class members who might be dead but their class needs this buff
---@field GroupsNeedBuff table List of groups who might need this buff
---@field GroupsHaveBetterBuff table List of groups who have better version of this buff
---@field UnitsNeedBuff table<number, BomUnit> List of group members who might need this buff
---@field UnitsHaveBetterBuff table<number, BomUnit> List of group members who might need this buff but won't get it because they have better
---@field SelfCast boolean
---@field SkipList table If spell cast failed, contains recently failed targets
---@field trackingIconId number Numeric id for the tracking texture icon
---@field trackingSpellName string For tracking spells, contains string name for the spell
---@field shapeshiftFormId number Check this shapeshift form to know whether spell is already casted
---@field optionText string Used to create sections in spell list in the options page
---@field buffSource string Unit/player who gave this buff

local spellDefClass = {} ---@type BomSpellDef
spellDefClass.__index = spellDefClass

---Creates a new SpellDef
---@param singleId number Spell id also serving as buffId key
---@param fields BomSpellDef Other fields
---@return BomSpellDef
function spellDefModule:New(singleId, fields)
  local newSpell = fields or {} ---@type BomSpellDef
  setmetatable(newSpell, spellDefClass)

  newSpell.category = false -- special value no category
  newSpell.frames = buffRowModule:New() -- spell buttons from the UI go here
  newSpell.buffId = singleId
  newSpell.singleId = singleId

  newSpell.ForcedTarget = {}
  newSpell.ExcludedTarget = {}

  newSpell.UnitsNeedBuff = {}
  newSpell.UnitsHaveBetterBuff = {}
  newSpell.GroupsNeedBuff = {}
  --newSpell.GroupsHaveBetterBuff = {}
  newSpell.GroupsHaveDead = {}

  newSpell.limitations = {}

  return newSpell
end

function spellDefModule:tbcConsumable(dst, singleId, itemId, limitations, extraText, extraFields)
  if not BOM.HaveTBC then
    return spellDefModule:New(0, {}) -- dummy spelldef to not crash following setters
  end
  return self:genericConsumable(dst, singleId, itemId, limitations, extraText, extraFields)
             :ShowInTBC()
end

function spellDefModule:wotlkConsumable(dst, singleId, itemId, limitations,
                                        extraText, extraFields)
  if not BOM.HaveWotLK then
    return spellDefModule:New(0, {}) -- dummy spelldef to not crash following setters
  end
  return self:genericConsumable(dst, singleId, itemId, limitations, extraText, extraFields)
             :ShowInWotLK()
end

---@param dst table<BomSpellDef>
---@param singleId number
---@param itemId number|table<number> Item or multiple items giving this buff
---@param limitations BomSpellLimitations Add extra conditions, if not nil
---@param extraText string Add extra text to the right if not nil
---@return BomSpellDef
function spellDefModule:genericConsumable(dst, singleId, itemId, limitations,
                                          extraText, extraFields)
  local fields = extraFields or {} ---@type BomSpellDef
  fields.isConsumable = true
  fields.default = false

  if type(itemId) == "table" then
    fields.item = itemId[1]
    fields.items = itemId
  else
    fields.item = itemId
  end

  if extraText then
    fields.extraText = extraText
  end

  return spellDefModule:createAndRegisterBuff(dst, singleId, fields, limitations)
end

---@param dst table<BomSpellDef>
---@param singleId number
---@param itemId number
---@param limitations BomSpellLimitations Add extra conditions, if not nil
---@param extraText string Add extra text to the right if not nil
---@return BomSpellDef
function spellDefModule:classicConsumable(dst, singleId, itemId, limitations, extraText)
  return self:genericConsumable(dst, singleId, itemId, limitations, extraText)
end

local _, playerClass, _ = UnitClass("player")

---@param limitations BomSpellLimitations
function spellDefModule:CheckLimitations(spell, limitations)
  -- empty limitations return true
  if limitations == nil or limitations == { } then
    return true
  end

  if limitations.showInTBC == true and not BOM.HaveTBC then
    return false
  end
  if limitations.hideInTBC == true and BOM.HaveTBC then
    return false
  end

  if limitations.showInWotLK == true and not BOM.HaveWotLK then
    return false
  end
  if limitations.hideInWotLK == true and BOM.HaveWotLK then
    return false
  end

  if limitations.playerRace then
    local _localisedRace, englishRace, _numericId = UnitRace("player")
    if englishRace ~= limitations.playerRace then
      return false
    end
  end

  if limitations.playerClass then
    if type(limitations.playerClass) == "table" then
      -- Fail if val is a table and player class is not in it
      if not tContains(limitations.playerClass, playerClass) then
        return false
      end
    else
      -- Fail if val is not equal to the player class
      if limitations.playerClass ~= playerClass then
        return false
      end
    end
  end -- if playerclass check

  if type(limitations.maxLevel) == "number" and limitations.maxLevel > UnitLevel("player") then
    return false -- too old
  end

  if type(limitations.hideIfSpellKnown) == "number" and IsSpellKnown(limitations.hideIfSpellKnown) then
    return false -- know a blocker spell, a better version like ice armor/frost armor pair
  end

  return true
end

-----@param spell BomSpellDef
-----@param modifications table<function>
--function spellDefModule:CheckModifications(spell, modifications)
--  -- empty modifications do not change the spell
--  if modifications == nil or modifications == { } then
--    return true
--  end
--
--  for _, mod in ipairs(modifications) do
--    if mod == "shamanEnchant" then
--      spell:ShamanEnchant()
--    end
--  end
--end

---Create a spelldef if the limitations apply and add to the table.
---Only check permanent limitations here like minlevel, TBC, or player class.
---@param dst table<number, BomSpellDef>
---@param buffSpellId number The buff spell ID is key in the AllSpells table
---@param fields table<string, any>
---@param limitations BomSpellLimitations Check these conditions to skip adding the spell. Permanent conditions only like minlevel or class
---@param modifications table<function> Check these conditions and maybe modify the spelldef.
---@return BomSpellDef
function spellDefModule:createAndRegisterBuff(dst, buffSpellId, fields,
                                              limitations, modifications, extraText)
  local spell = self:New(buffSpellId, fields)

  if spell.buffId > 0
          and self:CheckLimitations(spell, limitations) -- Limitations passed as arg here
          and self:CheckLimitations(spell, spell.limitations) -- Limitations set via :Function() modifiers
  then
    tinsert(dst, spell)
  end

  return spell
end

---@param spellId number
---@param itemId number
function spellDefModule:conjureItem(spellId, itemId)
  return spellDefModule:New(spellId,
          { isOwn          = true,
            default        = true,
            lockIfHaveItem = { itemId },
            singleFamily   = { spellId } })
end

function spellDefClass:Seal()
  -- for before TBC make this a seal spell, for TBC do not modify
  if not BOM.HaveTBC then
    self.type = "seal"
  end
  return self
end

---@return BomSpellDef
function spellDefClass:Category(cat)
  self.category = cat
  return self
end

---@return BomSpellDef
---@param level number
function spellDefClass:MaxLevel(level)
  self.limitations.maxLevel = level
  return self
end

---@return BomSpellDef
---@param spellId number Do not show spell if a better spell of different spell group is available
function spellDefClass:HideIfSpellKnown(spellId)
  self.limitations.hideIfSpellKnown = spellId
  return self
end

---@return BomSpellDef
function spellDefClass:ShowInTBC()
  self.limitations.showInTBC = true
  self.limitations.showInWotLK = true
  return self
end

---@return BomSpellDef
function spellDefClass:ShowInWotLK()
  self.limitations.showInWotLK = true
  return self
end

---@return BomSpellDef
function spellDefClass:HideInWotLK()
  self.limitations.hideInWotLK = true
  return self
end

---@return BomSpellDef
---@param classNames table<number,string> Class names to use as the default targets (user can modify)
function spellDefClass:DefaultTargetClasses(classNames)
  self.targetClasses = classNames
  return self
end

---@return BomSpellDef
---@param className table<number,string>|string The class name or table of class names
function spellDefClass:ClassOnly(className)
  self.limitations.playerClass = className
  return self
end

---@return BomSpellDef
function spellDefClass:IgnoreIfHaveBuff(spellId)
  self.ignoreIfBetterBuffs = self.ignoreIfBetterBuffs or {}
  tinsert(self.ignoreIfBetterBuffs, spellId)
  return self
end

---@return BomSpellDef
function spellDefClass:ElixirType(elixirType)
  self.elixirType = elixirType
  return self
end

---@return boolean Whether the spell allows user to do target class choices
function spellDefClass:HasClasses()
  return not (self.isConsumable
          or self.isOwn
          or self.type == "resurrection"
          or self.type == "seal"
          or self.type == "tracking"
          or self.type == "aura"
          or self.isInfo)
end

---@param class_name string
function spellDefClass:IncrementNeedGroupBuff(class_name)
  self.GroupsNeedBuff[class_name] = (self.GroupsNeedBuff[class_name] or 0) + 1
end

---@param spell_id number
---@param profile_name string|nil
function spellDefModule:GetProfileSpell(spell_id, profile_name)
  local spell
  if profile_name == nil then
    spell = BOM.CurrentProfile.Spell[spell_id]
  else
    local profile = buffomatModule.character[profile_name]
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
function spellDefModule:IsSpellEnabled(spell_id, profile_name)
  local spell = spellDefModule:GetProfileSpell(spell_id, profile_name)
  if spell == nil then
    return false
  end
  return spell.Enable
end

---Call function with the icon when icon value is ready, or immediately if value
---is available. This allows for late loaded icons.
---@param iconReadyFn function
---@return string|nil
function spellDefClass:GetIcon(iconReadyFn)
  if self.itemIcon then
    iconReadyFn(self.itemIcon) -- value was ready
    return
  end

  if self.spellIcon then
    iconReadyFn(self.spellIcon) -- value was ready
    return
  end

  -- Value was not ready
  self:RefreshTextAndIcon(iconReadyFn, nil)
end

---Get single text for item or spell. Apply text as a parameter to function
---immediately if ready, or when ready. This allows for late loaded names.
---@param nameReadyFn function
---@return string|nil
function spellDefClass:GetSingleText(nameReadyFn)
  if self.singleText then
    nameReadyFn(self.singleText)
    return
  end

  self:RefreshTextAndIcon(nil, nameReadyFn)
end

function spellDefClass:IsItem()
  -- TODO: self.isConsumable does this too?
  return self.items or self.item
end

---@param unit BomUnit
function spellDefClass:DoesUnitHaveBetterBuffs(unit)
  if type(self.ignoreIfBetterBuffs) == "table" then
    for _i, spellId in ipairs(self.ignoreIfBetterBuffs) do
      if unit.knownBuffs[spellId] ~= nil or unit.allBuffs[spellId] ~= nil then
        return true
      end
    end
  end
  return false
end

function spellDefClass:ResetBuffTargets()
  wipe(self.GroupsNeedBuff)
  --wipe(self.GroupsHaveBetterBuff)
  wipe(self.GroupsHaveDead)
  wipe(self.UnitsNeedBuff)
  wipe(self.UnitsHaveBetterBuff)
end

---@param iconReadyFn function|nil Call with result when icon value is ready
---@param nameReadyFn function|nil Call with result when name value is ready
function spellDefClass:RefreshTextAndIcon(iconReadyFn, nameReadyFn)
  if self:IsItem() then
    local itemId = self.item

    if self.items then
      local _, firstItem = next(self.items)
      itemId = firstItem
    end

    itemCacheModule:LoadItem(
            itemId,
            function(loadedItem)
              self.itemIcon = loadedItem.itemTexture
              if iconReadyFn ~= nil then
                iconReadyFn(loadedItem.itemTexture)
              end

              self.singleText = loadedItem.itemName
              if nameReadyFn ~= nil then
                nameReadyFn(loadedItem.itemName)
              end
            end)
    return
  end

  spellCacheModule:LoadSpell(
          self.singleId,
          function(loadedSpell)
            self.spellIcon = loadedSpell.icon -- update own copy of icon
            if iconReadyFn ~= nil then
              iconReadyFn(loadedSpell.icon)
            end

            self.singleText = loadedSpell.name -- update own copy of spell name
            if nameReadyFn ~= nil then
              nameReadyFn(loadedSpell.name)
            end
          end)

  -- nil otherwise
end
