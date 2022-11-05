local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@alias BomElixirType "battle"|"guardian"|"both"
---@alias BomItemId number Wow Item ID
---@alias BomZoneId number Wow Zone ID
---@alias BomSpellId number Wow Spell ID

---@class BomBuffDefinitionModule
local buffDefModule = {}
BomModuleManager.buffDefinitionModule = buffDefModule

local buffomatModule = BomModuleManager.buffomatModule
local spellCacheModule = BomModuleManager.spellCacheModule
local itemCacheModule = BomModuleManager.itemCacheModule
local buffRowModule = BomModuleManager.buffRowModule
local allBuffsModule = BomModuleManager.allBuffsModule

--BOM.Class = BOM.Class or {}

---@alias BomShapeshiftFormId number Shapeshift form for various classes

---type="aura" Auras are no target buff check. True if the buff affects others in radius, and not a target buff
---type="seal" Seals are 1hand enchants which are unique for equipped weapon. Paladins use seals. Shamans also use seals but in TBC shamans have 2 independent seals.
---type="resurrection" The spell will bring up a dead person
---type="tracking" the buff grants the tracking of some resource or enemy type
---type="weapon" The buff is a temporary weapon enchant on user's weapons (poison or shaman etc)
---@alias BomBuffType "aura"|"consumable"|"weapon"|"seal"|"tracking"|"resurrection"|"summon"

---@alias BomCreatureType "Demon"|"Undead"
---@alias BomCreatureFamily "Ghoul"|"Voidwalker"|"Imp"|"Succubus"|"Incubus"|"Felhunter"|"Felguard"
---@alias BomPlayerRace "BloodElf"|"Draenei"|"Dwarf"|"Gnome"|"Human"|"NightElf"|"Orc"|"Tauren"|"Troll"|"Undead"

---@shape BomSpellLimitations
---@field cancelForm boolean Casting spell requires leaving shapeshift, shadow form etc.
---@field requireTBC boolean
---@field hideInTBC boolean
---@field requireWotLK boolean
---@field hideInWotLK boolean
---@field playerRace BomPlayerRace
---@field playerClass BomClassName|BomClassName[] Collection of classes for this spell, or classname
---@field maxLevel number Hide the spell if player is above this level (to deprecate old spells)
---@field minLevel number Hide the spell if player is below this level
---@field hideIfSpellKnown number Hide the spell if spellId is in their spellbook

---
--- A class describing a spell in available spells collection
---
-- -@shape BomBuffDefinitionTable
-- -@field [BomSpellId] BomBuffDefinition

---@shape BomBuffDefinition
---@field AllowWhisper boolean [⚠DO NOT RENAME] Allow whispering expired soulstone to the warlock
---@field buffId BomBuffId Spell id of level 60 spell used as key everywhere else
---@field buffSource string Unit/player who gave this buff
---@field category BomBuffCategoryName Group by this field and use special translation table to display headers
---@field Class table<BomClassName, boolean> [⚠DO NOT RENAME] List of classes to receive this buff
---@field consumableEra string One of constants BOM.CLASSIC_ERA or BOM.IsTBC_ERA which will affect buff visibility based on used choice
---@field consumableTarget string Add "[@" .. consumableTarget .. "]" to the "/use bag slot" macro
---@field creatureFamily BomCreatureFamily Warlock summon pet family for type='summon' (Imp, etc)
---@field creatureType BomCreatureType Warlock summon pet type for type='summon' (Demon)
---@field default boolean Whether the spell auto-cast is enabled by default
---@field elixirType string|nil Use this for elixir mutual exclusions on elixirs
---@field Enable boolean [⚠DO NOT RENAME]  Whether buff is to be watched
---@field ExcludedTarget table<string, boolean> [⚠DO NOT RENAME] List of target names to never buff
---@field extraText string Added to the right of spell name in the spells config
---@field ForcedTarget table<string, boolean> [⚠DO NOT RENAME] List of extra targets to buff
---@field frames BomBuffRowFrames Dynamic list of controls associated with this spell in the UI
---@field groupDuration number Buff duration for group buff in seconds
---@field groupFamily number[] Family of group buff spell ids which are mutually exclusive
---@field groupLink string Printable link for group buff
---@field groupMana number Mana cost for group buff
---@field GroupsHaveBetterBuff table List of groups who have better version of this buff
---@field GroupsHaveDead table<string, boolean> Group/class members who might be dead but their class needs this buff
---@field GroupsNeedBuff table List of groups who might need this buff
---@field groupText string Name of group buff spell (from GetSpellInfo())
---@field hasCD boolean There's a cooldown on this spell
---@field ignoreIfBetterBuffs BomSpellId[] If these auras are present on target, the buff is not queued
---@field isBlessing boolean Spell will be cast on group members of the same class
---@field isConsumable boolean Is an item-based buff; the spell must have 'items' field too
---@field isInfo boolean
---@field isOwn boolean Spell only casts on self
---@field isScanned boolean
---@field itemIcon string
---@field items BomItemId[] Conjuration spells create these items. Or buff is granted by an item in user's bag. Number is item id shows as the icon.
---@field limitations BomSpellLimitations|nil [Temporary] field for post-filtering on spell list creation, later zeroed
---@field lockIfHaveItem BomItemId[] Item ids which prevent this buff (unique conjured items for example)
---@field MainHandEnable boolean [⚠DO NOT RENAME]
---@field OffHandEnable boolean [⚠DO NOT RENAME]
---@field onlyUsableFor string[] list of classes which only can see this buff (hidden for others)
---@field optionText string Used to create sections in spell list in the options page
---@field reagentRequired BomItemId[] | BomItemId Reagent item ids required for group buff
---@field requiresForm number Required shapeshift form ID to cast this buff
---@field requiresOutdoors boolean Spell can only be cast outdoors
---@field requireWarlockPet boolean For Soul Link - must check if a demon pet is present
---@field sacrificeAuraIds BomSpellId[]|nil Aura id for demonic sacrifice of that pet. Do not summon if buff is present.
---@field section string Custom section to begin new spells group in the row builder
---@field SelfCast boolean [⚠DO NOT RENAME]
---@field shapeshiftFormId BomShapeshiftFormId Class-based form id (coming from GetShapeshiftFormID LUA API) if active, the spell is skipped
---@field shapeshiftFormId number Check this shapeshift form to know whether spell is already casted
---@field singleDuration number - buff duration for single buff in seconds
---@field singleFamily BomSpellId[] Family of single buff spell ids which are mutually exclusive
---@field singleLink string Printable link for single buff
---@field singleMana number Mana cost
---@field singleText string Name of single buff spell (from GetSpellInfo())
---@field SkipList table If spell cast failed, contains recently failed targets
---@field spellIcon string
---@field targetClasses BomClassName[] List of target classes which are shown as toggle boxes to enable cast per class
---@field tbcHunterPetBuff boolean True for TBC hunter pet consumable which places aura on the hunter pet
---@field trackingIconId number Numeric id for the tracking texture icon
---@field trackingSpellName string For tracking spells, contains string name for the spell
---@field type BomBuffType Defines type: "aura", "consumable", "weapon" for Enchant Consumables, "seal", "tracking", "resurrection"
---@field UnitsHaveBetterBuff BomUnit[] List of group members who might need this buff but won't get it because they have better
---@field UnitsNeedBuff BomUnit[] List of group members who might need this buff
local buffDefClass = {}
buffDefClass.__index = buffDefClass

---Creates a new SpellDef
---@param singleId BomSpellId Spell id also serving as buffId key
---@return BomBuffDefinition
function buffDefModule:New(singleId)
  local newSpell = --[[---@type BomBuffDefinition]] {}
  newSpell.category = "" -- special value no category
  newSpell.frames = buffRowModule:New(tostring(singleId)) -- spell buttons from the UI go here
  newSpell.buffId = singleId
  newSpell.singleFamily = { singleId }
  newSpell.limitations = --[[---@type BomSpellLimitations]] {}
  newSpell.ForcedTarget = {}
  newSpell.ExcludedTarget = {}
  newSpell.UnitsNeedBuff = {}
  newSpell.UnitsHaveBetterBuff = {}
  newSpell.GroupsNeedBuff = {}
  newSpell.GroupsHaveDead = {}

  setmetatable(newSpell, buffDefClass)
  return newSpell
end

function buffDefModule:tbcConsumable(dst, singleId, itemId)
  return self:genericConsumable(dst, singleId, itemId)
             :RequireTBC()
end

function buffDefModule:wotlkConsumable(dst, singleId, itemId)
  return self:genericConsumable(dst, singleId, itemId)
             :RequireWotLK()
end

---@param allBuffs BomBuffDefinition[]
---@param singleId BomSpellId
---@param providedByItem BomItemId|BomItemId[] Item or multiple items giving this buff
---@return BomBuffDefinition
function buffDefModule:genericConsumable(allBuffs, singleId, providedByItem)
  local b = buffDefModule:createAndRegisterBuff(allBuffs, singleId, nil)
                         :IsConsumable(true)
                         :IsDefault(false)
                         :CreatesOrProvidedByItem(providedByItem)
  return b
end

local _, playerClass, _ = UnitClass("player")

--TODO: Belongs to `BomBuffDefinition`
---@param limitations BomSpellLimitations
function buffDefModule:CheckLimitations(_spell, limitations)
  -- empty limitations return true
  if next(limitations) == nil then
    return true
  end

  if limitations.requireTBC == true and not BOM.haveTBC then
    return false
  end
  if limitations.hideInTBC == true and BOM.haveTBC then
    return false
  end

  if limitations.requireWotLK == true and not BOM.haveWotLK then
    return false
  end
  if limitations.hideInWotLK == true and BOM.haveWotLK then
    return false
  end

  if limitations.playerRace then
    local _localisedRace, englishRace, _numericId = UnitRace("player")
    if englishRace ~= limitations.playerRace then
      return false
    end
  end

  if type(limitations.playerClass) == "table" then
    -- Fail if val is a table and player class is not in it
    if not tContains(limitations.playerClass, playerClass) then
      return false
    end
  end

  -- Fail if val is not equal to the player class
  if type(limitations.playerClass) == "string"
          and limitations.playerClass ~= playerClass then
    return false
  end

  if type(limitations.maxLevel) == "number"
          and UnitLevel("player") > limitations.maxLevel then
    return false -- too old
  end

  if type(limitations.minLevel) == "number"
          and UnitLevel("player") < limitations.minLevel then
    return false -- too young
  end

  if type(limitations.hideIfSpellKnown) == "number"
          and IsSpellKnown(limitations.hideIfSpellKnown) then
    return false -- know a blocker spell, a better version like ice armor/frost armor pair
  end

  return true
end

---Create a spelldef if the limitations apply and add to the table.
---Only check permanent limitations here like minlevel, TBC, or player class.
---@param allBuffs BomBuffDefinition[]
---@param buffSpellId number The buff spell ID is key in the AllSpells table
---@param limitations BomSpellLimitations|nil Check these conditions to skip adding the spell. Permanent conditions only like minlevel or class
---@return BomBuffDefinition
function buffDefModule:createAndRegisterBuff(allBuffs, buffSpellId, limitations)
  local spell = self:New(buffSpellId)

  if self:CheckLimitations(spell, limitations or --[[---@type BomSpellLimitations]] {}) then
    return self:registerBuff(allBuffs, spell)
  end

  return buffDefModule:New(0) -- limitations check failed
end

---@param dst BomBuffDefinition[]
---@return BomBuffDefinition
function buffDefModule:registerBuff(dst, spell)
  tinsert(dst, spell)
  return spell
end

---@param spellId number
---@param itemId number
function buffDefModule:conjureItem(spellId, itemId)
  return buffDefModule:New(spellId)
                      :IsOwn(true)
                      :IsDefault(true)
                      :LockIfHaveItem({ itemId })
                      :SingleFamily({ spellId })
end

---Add "[@" .. consumableTarget .. "]" to the "/use bag slot" macro
---@param unit string
---@return BomBuffDefinition
function buffDefClass:ConsumableTarget(unit)
  self.consumableTarget = unit
  return self
end

---@param own boolean
---@return BomBuffDefinition
function buffDefClass:IsOwn(own)
  self.isOwn = own
  return self
end

---@param isConsum boolean
---@return BomBuffDefinition
function buffDefClass:IsConsumable(isConsum)
  self.isConsumable = isConsum
  return self
end

---@param itemId BomItemId|BomItemId[]
---@return BomBuffDefinition
function buffDefClass:CreatesOrProvidedByItem(itemId)
  if type(itemId) == "number" then
    self.items = { --[[---@type BomItemId]] itemId }
  else
    self.items = --[[---@type BomItemId[] ]] itemId
  end
  return self
end

---@param auraIds BomSpellId[]
---@return BomBuffDefinition
function buffDefClass:SacrificeAuraIds(auraIds)
  self.sacrificeAuraIds = auraIds
  return self
end

---@param cf BomCreatureFamily
---@return BomBuffDefinition
function buffDefClass:SummonCreatureFamily(cf)
  self.creatureFamily = cf
  return self
end

---@param ct BomCreatureType
---@return BomBuffDefinition
function buffDefClass:SummonCreatureType(ct)
  self.creatureType = ct
  return self
end

---@param cancel boolean
---@return BomBuffDefinition
function buffDefClass:RequiresCancelForm(cancel)
  self.cancelForm = cancel
  return self
end

---@param form BomShapeshiftFormId
---@return BomBuffDefinition
function buffDefClass:RequiresForm(form)
  self.requiresForm = form
  return self
end

---@param bt BomBuffType
---@return BomBuffDefinition
function buffDefClass:BuffType(bt)
  self.type = bt
  return self
end

---@param onlyCombat boolean
---@return BomBuffDefinition
function buffDefClass:OnlyCombat(onlyCombat)
  self.onlyCombat = onlyCombat
  return self
end

---@param enabled boolean
---@return BomBuffDefinition
function buffDefClass:IsDefault(enabled)
  self.default = enabled
  return self
end

---@param spell BomSpellId
---@return BomBuffDefinition
function buffDefClass:GroupId(spell)
  self.groupId = spell
  return self
end

---@param formId BomShapeshiftFormId
---@return BomBuffDefinition
function buffDefClass:ShapeshiftFormId(formId)
  self.shapeshiftFormId = formId
  return self
end

---@param itemIds BomItemId[]
---@return BomBuffDefinition
function buffDefClass:LockIfHaveItem(itemIds)
  self.lockIfHaveItem = itemIds
  return self
end

---@param itemIds BomItemId[]
---@return BomBuffDefinition
function buffDefClass:ReagentRequired(itemIds)
  self.reagentRequired = itemIds
  return self
end

---@param spellIds BomSpellId[]
---@return BomBuffDefinition
function buffDefClass:SingleFamily(spellIds)
  self.singleFamily = spellIds
  return self
end

---@param spellIds BomSpellId[]
---@return BomBuffDefinition
function buffDefClass:GroupFamily(spellIds)
  self.groupFamily = spellIds
  return self
end

---@param isBlessing boolean
---@return BomBuffDefinition
function buffDefClass:IsBlessing(isBlessing)
  self.isBlessing = isBlessing
  return self
end

---@param duration number
---@return BomBuffDefinition
function buffDefClass:SingleDuration(duration)
  self.singleDuration = duration
  return self
end

---@param duration number
---@return BomBuffDefinition
function buffDefClass:GroupDuration(duration)
  self.groupDuration = duration
  return self
end

function buffDefClass:ClassicBuffTypeIsSeal()
  -- for before TBC make this a seal spell, for TBC do not modify
  if not BOM.haveTBC then
    self.type = "seal"
  end
  return self
end

---@param cat BomBuffCategoryName
---@return BomBuffDefinition
function buffDefClass:Category(cat)
  self.category = cat
  return self
end

---@param requirePet boolean
---@return BomBuffDefinition
function buffDefClass:RequireWarlockPet(requirePet)
  self.requireWarlockPet = requirePet
  return self
end

---@param level number
---@return BomBuffDefinition
function buffDefClass:MaxLevel(level)
  (--[[---@not nil]] self.limitations).maxLevel = level
  return self
end

---@return BomBuffDefinition
---@param level number
function buffDefClass:MinLevel(level)
  (--[[---@not nil]] self.limitations).minLevel = level
  return self
end

---@return BomBuffDefinition
---@param spellId number Do not show spell if a better spell of different spell group is available
function buffDefClass:HideIfSpellKnown(spellId)
  (--[[---@not nil]] self.limitations).hideIfSpellKnown = spellId
  return self
end

---@return BomBuffDefinition
function buffDefClass:RequireTBC()
  (--[[---@not nil]] self.limitations).requireTBC = true
  return self
end

---@param hasCD boolean
---@return BomBuffDefinition
function buffDefClass:HasCooldown(hasCD)
  self.hasCD = hasCD
  return self
end

---@return BomBuffDefinition
function buffDefClass:HideInTBC()
  (--[[---@not nil]] self.limitations).hideInTBC = true
  (--[[---@not nil]] self.limitations).hideInWotLK = true
  return self
end

---@return BomBuffDefinition
function buffDefClass:RequireWotLK()
  (--[[---@not nil]] self.limitations).requireWotLK = true
  return self
end

---@return BomBuffDefinition
function buffDefClass:HideInWotLK()
  (--[[---@not nil]] self.limitations).hideInWotLK = true
  return self
end

---@return BomBuffDefinition
function buffDefClass:HunterPetFood()
  self.tbcHunterPetBuff = true
  return self
end

---@return BomBuffDefinition
---@param classNames BomClassName[] Class names to use as the default targets (user can modify)
function buffDefClass:DefaultTargetClasses(classNames)
  self.targetClasses = classNames
  return self
end

---@param className BomClassName[]|BomClassName The class name or table of class names
---@return BomBuffDefinition
function buffDefClass:RequirePlayerClass(className)
  (--[[---@not nil]] self.limitations).playerClass = className
  return self
end

---@param raceName BomPlayerRace Player race
---@return BomBuffDefinition
function buffDefClass:RequirePlayerRace(raceName)
  (--[[---@not nil]] self.limitations).playerRace = raceName
  return self
end

---@param outdoors boolean
---@return BomBuffDefinition
function buffDefClass:RequiresOutdoors(outdoors)
  self.requiresOutdoors = outdoors
  return self
end

---@return BomBuffDefinition
---@param text string
function buffDefClass:ExtraText(text)
  self.extraText = text
  return self
end

---@param manaCost number
---@return BomBuffDefinition
function buffDefClass:SingleManaCost(manaCost)
  self.singleMana = manaCost
  return self
end

---@return BomBuffDefinition
---@param spellId BomSpellId|BomSpellId[]
function buffDefClass:IgnoreIfHaveBuff(spellId)
  self.ignoreIfBetterBuffs = self.ignoreIfBetterBuffs or {}
  if type(spellId) == "number" then
    tinsert(self.ignoreIfBetterBuffs, spellId)
  else
    for _i, spell in ipairs(--[[---@type BomSpellId[] ]] spellId) do
      tinsert(self.ignoreIfBetterBuffs, spell)
    end
  end
  return self
end

---@param elixirType BomElixirType
---@return BomBuffDefinition
function buffDefClass:ElixirType(elixirType)
  self.elixirType = elixirType
  return self
end

---@return boolean Whether the spell allows user to do target class choices
function buffDefClass:HasClasses()
  return not (self.isConsumable
          or self.isOwn
          or self.type == "resurrection"
          or self.type == "seal"
          or self.type == "tracking"
          or self.type == "aura"
          or self.isInfo)
end

---@param class_name string
function buffDefClass:IncrementNeedGroupBuff(class_name)
  self.GroupsNeedBuff[class_name] = (self.GroupsNeedBuff[class_name] or 0) + 1
end

---@param spellId number
---@param profileName BomProfileName|nil
function buffDefModule:GetProfileBuff(spellId, profileName)
  if profileName == nil then
    return buffomatModule.currentProfile.Spell[spellId]
    --return allBuffsModule.allBuffs[spellId]
  end

  local profile = buffomatModule.character[--[[---@not nil]] profileName]
  if profile == nil then
    return nil
  end

  return profile.Spell[spellId]
end

---Returns true whether spell is enabled by the player (has checkbox)
---@param buffId number The key to the allSpells dictionary
---@param profileName BomProfileName|nil
---@return boolean
function buffDefModule:IsBuffEnabled(buffId, profileName)
  local spell = buffDefModule:GetProfileBuff(buffId, profileName)
  if spell == nil then
    return false
  end
  return (--[[---@not nil]] spell).Enable
end

---Call function with the icon when icon value is ready, or immediately if value
---is available. This allows for late loaded icons.
---@param iconReadyFn fun(icon: string)
function buffDefClass:GetIcon(iconReadyFn)
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
---@param nameReadyFn fun(name: string)
function buffDefClass:GetSingleText(nameReadyFn)
  if self.singleText then
    nameReadyFn(self.singleText)
    return
  end

  self:RefreshTextAndIcon(nil, nameReadyFn)
end

function buffDefClass:IsItem()
  -- TODO: self.isConsumable does this too?
  return self.items and next(self.items) ~= nil
end

---@param unit BomUnit
function buffDefClass:DoesUnitHaveBetterBuffs(unit)
  if type(self.ignoreIfBetterBuffs) == "table" then
    for _i, spellId in ipairs(self.ignoreIfBetterBuffs) do
      if unit.knownBuffs[spellId] ~= nil or unit.allBuffs[spellId] ~= nil then
        return true
      end
    end
  end
  return false
end

function buffDefClass:ResetBuffTargets()
  wipe(self.GroupsNeedBuff)
  --wipe(self.GroupsHaveBetterBuff)
  wipe(self.GroupsHaveDead)
  wipe(self.UnitsNeedBuff)
  wipe(self.UnitsHaveBetterBuff)
end

---@param iconReadyFn fun(texture: string)|nil Call with result when icon value is ready
---@param nameReadyFn fun(name: string)|nil Call with result when name value is ready
function buffDefClass:RefreshTextAndIcon(iconReadyFn, nameReadyFn)
  -- TODO: If refresh is in progress and multiple requests come in parallel, that might also be a problem
  if self:IsItem() then
    local _, itemId = next(self.items)

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

  local _, singleId = next(self.singleFamily)
  spellCacheModule:LoadSpell(
          singleId,
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

---@return BomSpellId
function buffDefClass:GetFirstSingleId()
  local _, singleId = next(self.singleFamily)
  return singleId
end

---@return BomItemId|nil
function buffDefClass:GetFirstItem()
  local _, itemId = next(self.items)
  return itemId
end
