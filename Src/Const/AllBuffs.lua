local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@alias BomBuffCategory string

---@class BomAllBuffsModule
---@field buffCategories BomBuffCategory[] Category names for buffs
---@field allBuffs {[BomBuffId] BomBuffDefinition} All buffs, same as BOM.AllBuffomatSpells for convenience
local allBuffsModule = {}

BomModuleManager.allBuffsModule = allBuffsModule

local _t = BomModuleManager.languagesModule
local buffDefModule = BomModuleManager.buffDefinitionModule
local deathknightModule = BomModuleManager.allSpellsDeathknightModule
local druidModule = BomModuleManager.allSpellsDruidModule
local elixirsModule = BomModuleManager.allConsumesElixirsModule
local enchantmentsModule = BomModuleManager.allConsumesEnchantmentsModule
local flasksModule = BomModuleManager.allConsumesFlasksModule
local foodModule = BomModuleManager.allConsumesFoodModule
local hunterModule = BomModuleManager.allSpellsHunterModule
local itemCacheModule = BomModuleManager.itemCacheModule
local mageModule = BomModuleManager.allSpellsMageModule
local otherModule = BomModuleManager.allConsumesOtherModule
local paladinModule = BomModuleManager.allSpellsPaladinModule
local priestModule = BomModuleManager.allSpellsPriestModule
local rogueModule = BomModuleManager.allSpellsRogueModule
local scrollsModule = BomModuleManager.allConsumesScrollsModule
local shamanModule = BomModuleManager.allSpellsShamanModule
local spellCacheModule = BomModuleManager.spellCacheModule
local spellIdsModule = BomModuleManager.spellIdsModule
local warlockModule = BomModuleManager.allSpellsWarlockModule
local warriorModule = BomModuleManager.allSpellsWarriorModule

-----@deprecated
--local L = setmetatable(
--        {},
--        {
--          __index = function(_t, k)
--            if BOM.L and BOM.L[k] then
--              return BOM.L[k]
--            else
--              return "[" .. k .. "]"
--            end
--          end
--        })

---@alias BomClass "WARRIOR"|"MAGE"|"ROGUE"|"DRUID"|"HUNTER"|"PRIEST"|"WARLOCK"|"SHAMAN"|"PALADIN"|"DEATHKNIGHT"

local BOM_ALL_CLASSES = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "PRIEST", "WARLOCK",
                          "SHAMAN", "PALADIN", "DEATHKNIGHT" } ---@type BomClass[]
local BOM_NO_CLASS = { } ---@type BomClass[]
allBuffsModule.BOM_ALL_CLASSES = BOM_ALL_CLASSES
allBuffsModule.BOM_NO_CLASSES = BOM_NO_CLASS

---Classes which have a resurrection ability
---@type BomClass[]
local RESURRECT_CLASSES = { "SHAMAN", "PRIEST", "PALADIN", "DRUID" } -- Druid in WotLK
BOM.RESURRECT_CLASS = RESURRECT_CLASSES --used in TaskScan.lua
allBuffsModule.RESURRECT_CLASSES = RESURRECT_CLASSES

--- Classes which have mana bar and benefit from mp/5 and spirit
---@type BomClass[]
local MANA_CLASSES = { "HUNTER", "WARLOCK", "MAGE", "DRUID", "SHAMAN", "PRIEST", "PALADIN" }
BOM.MANA_CLASSES = MANA_CLASSES --used in TaskScan.lua
allBuffsModule.MANA_CLASSES = MANA_CLASSES

--- Classes which deal spell damage
---@type BomClass[]
allBuffsModule.SPELL_CLASSES = { "WARLOCK", "MAGE", "DRUID", "SHAMAN", "PRIEST", "PALADIN", "DEATHKNIGHT", "HUNTER" }

--- Classes which hit with weapons or claws
---@type BomClass[]
allBuffsModule.MELEE_CLASSES = { "WARRIOR", "ROGUE", "DRUID", "SHAMAN", "PALADIN", "DEATHKNIGHT" }

--- Classes capable of dealing shadow damage
---@type BomClass[]
allBuffsModule.SHADOW_CLASSES = { "PRIEST", "WARLOCK", "DEATHKNIGHT" }

--- Classes capable of dealing fire damage
---@type BomClass[]
allBuffsModule.FIRE_CLASSES = { "MAGE", "WARLOCK", "SHAMAN", "HUNTER" }

--- Classes capable of dealing frost damage
---@type BomClass[]
allBuffsModule.FROST_CLASSES = { "MAGE", "SHAMAN", "DEATHKNIGHT" }

--- Classes dealing physical ranged or melee damage
---@type BomClass[]
allBuffsModule.PHYSICAL_CLASSES = { "HUNTER", "ROGUE", "SHAMAN", "WARRIOR", "DRUID", "PALADIN", "DEATHKNIGHT" }

allBuffsModule.DURATION_1M = 60
allBuffsModule.DURATION_2M = allBuffsModule.DURATION_1M * 2
allBuffsModule.DURATION_5M = allBuffsModule.DURATION_1M * 5
allBuffsModule.DURATION_10M = allBuffsModule.DURATION_5M * 10
allBuffsModule.DURATION_15M = allBuffsModule.DURATION_1M * 15
allBuffsModule.DURATION_20M = allBuffsModule.DURATION_1M * 20
allBuffsModule.DURATION_30M = allBuffsModule.DURATION_1M * 30
allBuffsModule.DURATION_1H = allBuffsModule.DURATION_1M * 60

--- From 2 choices return TBC if BOM.IsTBC is true, otherwise return classic
local function tbcOrClassic(tbc, classic)
  if BOM.HaveTBC then
    return tbc
  end
  return classic
end
allBuffsModule.TbcOrClassic = tbcOrClassic

--- From 2 choices return TBC if BOM.IsTBC is true, otherwise return classic
function allBuffsModule.ExpansionChoice(classic, tbc, wotlk)
  if BOM.HaveWotLK then
    return wotlk
  end
  if BOM.HaveTBC then
    return tbc
  end
  return classic
end

---Add RESOURCE TRACKING spells
---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function allBuffsModule:SetupTrackingSpells(allBuffs, enchantments)
  buffDefModule:createAndRegisterBuff(allBuffs, spellIdsModule.FindHerbs, -- Find Herbs / kräuter
          { type = "tracking", default = true })
               :Category(self.TRACKING)

  buffDefModule:createAndRegisterBuff(allBuffs, spellIdsModule.FindMinerals, -- Find Minerals / erz
          { type = "tracking", default = true })
               :Category(self.TRACKING)

  buffDefModule:createAndRegisterBuff(allBuffs, spellIdsModule.FindTreasure, -- Find Treasure / Schatzsuche / Zwerge
          { type = "tracking", default = true })
               :Category(self.TRACKING)

  buffDefModule:createAndRegisterBuff(allBuffs, spellIdsModule.FindFish, -- Find Fish (TBC daily quest reward)
          { type = "tracking", default = false })
               :Category(self.TRACKING)

  return allBuffs
end

function allBuffsModule:SetupConstantsCategories()
  self.CLASSIC_PHYS_FOOD = "classicPhysicalFood"
  self.CLASSIC_SPELL_FOOD = "classicSpellFood"
  self.CLASSIC_FOOD = "classicFood"
  self.CLASSIC_PHYS_ELIXIR = "classicPhysElixir"
  self.CLASSIC_PHYS_BUFF = "classicPhysBuff"
  self.CLASSIC_BUFF = "classicBuff"
  self.CLASSIC_SPELL_ELIXIR = "classicSpellElixir"
  self.CLASSIC_ELIXIR = "classicElixir"
  self.CLASSIC_FLASK = "classicFlask"

  self.TBC_PHYS_FOOD = "tbcPhysicalFood"
  self.TBC_SPELL_FOOD = "tbcSpellFood"
  self.TBC_FOOD = "tbcFood"
  self.TBC_PHYS_ELIXIR = "tbcPhysElixir"
  self.TBC_SPELL_ELIXIR = "tbcSpellElixir"
  self.TBC_ELIXIR = "tbcElixir"
  self.TBC_FLASK = "tbcFlask"

  self.WOTLK_PHYS_FOOD = "wotlkPhysicalFood"
  self.WOTLK_SPELL_FOOD = "wotlkSpellFood"
  self.WOTLK_FOOD = "wotlkFood"
  self.WOTLK_PHYS_ELIXIR = "wotlkPhysElixir"
  self.WOTLK_SPELL_ELIXIR = "wotlkSpellElixir"
  self.WOTLK_ELIXIR = "wotlkElixir"
  self.WOTLK_FLASK = "wotlkFlask"

  self.SCROLL = "scroll"
  self.WEAPON_ENCHANTMENT = "weaponEnchantment"
  self.CLASS_WEAPON_ENCHANTMENT = "classWeaponEnchantment"

  -- Categories ordered for display
  self.buffCategories = {
    self.CLASS,
    self.CLASS_WEAPON_ENCHANTMENT,
    self.BLESSING, self.SEAL, self.AURA,
    self.PET,
    self.TRACKING,

    self.WOTLK_PHYS_ELIXIR,
    self.WOTLK_SPELL_ELIXIR,
    self.WOTLK_ELIXIR,
    self.WOTLK_FLASK,
    self.WOTLK_PHYS_FOOD,
    self.WOTLK_SPELL_FOOD,
    self.WOTLK_FOOD,

    self.TBC_PHYS_ELIXIR,
    self.TBC_SPELL_ELIXIR,
    self.TBC_ELIXIR,
    self.TBC_FLASK,
    self.TBC_PHYS_FOOD,
    self.TBC_SPELL_FOOD,
    self.TBC_FOOD,

    self.CLASSIC_PHYS_ELIXIR,
    self.CLASSIC_PHYS_BUFF,
    self.CLASSIC_SPELL_ELIXIR,
    self.CLASSIC_ELIXIR,
    self.CLASSIC_FLASK,
    self.CLASSIC_BUFF,
    self.CLASSIC_PHYS_FOOD,
    self.CLASSIC_SPELL_FOOD,
    self.CLASSIC_FOOD,

    self.SCROLL, self.WEAPON_ENCHANTMENT,

    "", -- special value no category
  }
end

function allBuffsModule:SetupConstants()
  -- Elixir types for mutual exclusions
  self.ELIX_BATTLE = "elixir-battle"
  self.ELIX_GUARDIAN = "elixir-guardian"
  self.ELIX_FLASK = "elixir-flask" -- both battle and guardian

  --- Categories for nice display of titles and grouping
  self.CLASS = "class" -- class buffs go first
  self.BLESSING = "classBlessing" -- paladin blessings
  self.PET = "pet" -- class buffs for pets
  self.TRACKING = "tracking"
  self.AURA = "aura" -- auras for paladins and hunters etc
  self.SEAL = "seal" -- seals for paladins

  self:SetupConstantsCategories()
end

--- Filter away the 'false' element and return only keys, values become the translation strings
---@return {[string] string}
function allBuffsModule:GetBuffCategories()
  local result = {}
  for _i, cat in ipairs(self.buffCategories) do
    if type(cat) == "string" then
      result[--[[---@type string]]cat] = _t("Category_" .. cat)
    end
  end
  return result
end

---Filter the input `allbuffs` if the limitations check returns true
---@param allBuffs BomBuffDefinition[] Input list of all buffs
---@return BomBuffDefinition[] Filtered list
function allBuffsModule:ApplyPostLimitations(allBuffs)
  -- Apply post-limitations (added with :Limitation() functions on spell construction)
  local result = {}

  for _i, buff in ipairs(allBuffs) do
    if buff.limitations ~= nil then
      if buffDefModule:CheckLimitations(buff, buff.limitations) then
        tinsert(result, buff)
      end
    end
    buff.limitations = nil -- do not need to store this
  end

  return result
end

---@alias BomBuffId number
---@alias BomEnchantmentId number

---@alias BomAllBuffsTable {[BomBuffId] BomBuffDefinition}

---@alias BomEnchantmentsMapping {[BomSpellId] BomEnchantmentId[]}

---All spells known to Buffomat
---Note: you can add your own spell in the "WTF\Account\<accountname>\SavedVariables\buffOmat.lua"
---table CustomSpells
function allBuffsModule:SetupSpells()
  local allBuffs = --[[---@type BomBuffDefinition[] ]] {}
  local enchantments = --[[---@type BomEnchantmentsMapping]] {}
  self:SetupConstants()

  priestModule:SetupPriestSpells(allBuffs, enchantments)
  druidModule:SetupDruidSpells(allBuffs, enchantments)
  mageModule:SetupMageSpells(allBuffs, enchantments)
  shamanModule:SetupShamanSpells(allBuffs, enchantments)
  warlockModule:SetupWarlockSpells(allBuffs, enchantments)
  hunterModule:SetupHunterSpells(allBuffs, enchantments)
  paladinModule:SetupPaladinSpells(allBuffs, enchantments)
  warriorModule:SetupWarriorSpells(allBuffs, enchantments)
  rogueModule:SetupRogueSpells(allBuffs, enchantments)
  deathknightModule:SetupDeathknightSpells(allBuffs, enchantments)

  self:SetupTrackingSpells(allBuffs, enchantments)

  scrollsModule:SetupScrolls(allBuffs, enchantments)
  enchantmentsModule:SetupEnchantments(allBuffs, enchantments)
  elixirsModule:SetupElixirs(allBuffs, enchantments)
  flasksModule:SetupFlasks(allBuffs, enchantments)
  foodModule:SetupFood(allBuffs, enchantments)
  otherModule:SetupOtherConsumables(allBuffs, enchantments)

  allBuffs = self:ApplyPostLimitations(allBuffs) --filter the list and make new shorter list

  --Preload items!
  for x, spell in ipairs(allBuffs) do
    if spell.isConsumable and spell.item then
      BOM.GetItemInfo(spell.item)
    end
  end

  BOM.EnchantToSpell = {}
  for dest, list in pairs(enchantments) do
    for i, id in ipairs(list) do
      BOM.EnchantToSpell[id] = dest
    end
  end

  self.allBuffs = allBuffs
  BOM.AllBuffomatBuffs = allBuffs
  BOM.EnchantList = enchantments
end

BOM.ArgentumDawn = {
  itemIds = {
    12846, -- Simple AD trinket
    13209, -- Seal of the Dawn +81 AP
    19812, -- Rune of the Dawn +48 SPELL
    23206, -- Mark of the Chamption +150 AP
    23207, -- Mark of the Chamption +85 SPELL
  },
  zoneId  = {
    329, 289, 533, 535, --Stratholme/scholomance; Naxxramas LK 10/25
    558, -- TBC: Auchenai
    532, -- TBC: Karazhan
  },
}

BOM.Carrot = {
  itemIds = {
    11122, -- Classic: Item [Carrot on a Stick]
    25653, -- TBC: Item [Riding Crop]
    32481, -- TBC: Item [Charm of Swift Flight]
  },
  --Allow Riding Speed trinkets in:
  zoneId  = {
    0, 1, 530, -- Eastern Kingdoms, Kalimdor, Outland
    30, -- Alterac Valley
    529, -- Arathi Basin,
    489, -- Warsong Gulch
    566, 968, -- TBC: Eye of the Storm
    --1672, 1505, 572, -- TBC: Blade's Edge Arena, Nagrand Arena, Ruins of Lordaeron
  },
}

BOM.BuffExchangeId = { -- combine-spell-ids to new one
  [18788] = { 18791, 18790, 18789, 18792 }, -- Demonic Sacrifice-Buffs to Demonic Sacrifice
  [16591] = { 16591, 16589, 16595, 16593 }, -- noggenfoger
}

BOM.SpellToSpell = {}
for dest, list in pairs(BOM.BuffExchangeId) do
  for i, id in ipairs(list) do
    BOM.SpellToSpell[id] = dest
  end
end

BOM.ItemList = {
  --{6948}, -- Hearthstone | Ruhestein
  --{4604}, -- Forest Mushroom | Waldpilz
  --{8079},-- Water | wasser
  { 5232, 16892, 16893, 16895, -- Soulstone | Seelenstein
    16896 }, -- TBC: Major Soulstone
}
BOM.ItemListSpell = {
  [8079]  = 432, -- Water | Wasser
  [5232]  = 20762,
  [16892] = 20762,
  [16893] = 20762,
  [16895] = 20762,
  [16896] = 20762, -- Soulstone | Seelenstein
}
BOM.ItemListTarget = {}

-- -@return table<number, BomBuffDefinition>
function allBuffsModule:SetupCancelBuffs()
  -- Note: you can add your own spell in the "WTF\Account\<accountname>\SavedVariables\buffOmat.lua"
  -- table CustomCancelBuff
  local spirit = priestModule:CreatePrayerOfSpiritBuff()
  spirit.default = false

  local intelli = mageModule:CreateIntelligenceBuff()
  intelli.default = false

  local s = {
    priestModule:CreatePowerWordShieldBuff(),
    spirit,
    intelli,
  }

  do
    local _, class, _ = UnitClass("unit")
    if class == "HUNTER" then
      local buff = buffDefModule:New(5118)--Aspect of the Cheetah/of the pack
                                :OnlyCombat(true)
                                :IsDefault(true)
                                :SingleFamily({ 5118, 13159 })
      tinsert(s, buff)
    end

    if (UnitFactionGroup("player")) ~= "Horde" or BOM.IsTBC then
      local buff = buffDefModule:New(1038) --Blessing of Salvation
                                :IsDefault(false)
                                :SingleFamily({ 1038, 25895 })
      tinsert(s, buff)
    end
  end

  BOM.CancelBuffs = s
end

-- Having this buff on target excludes the target (phaseshifted imp for example)
BOM.BuffIgnoreAll = {
  4511 -- Phase Shift (imp)
}

local ShapeShiftTravel = {
  2645,
  783
} --Ghost wolf and travel druid

BOM.drinkingPersonCount = false
BOM.AllDrink = {
  30024, -- Restores 20% mana
  430, -- level 5 drink
  431, -- level 15 drink
  432, -- level 25 drink
  1133, -- level 35 drink
  1135, -- level 45 drink
  1137, 29007, 43154, 24355, 25696, 43155, 26261, -- level 55 drink
  10250, 22734, -- TBC: level 65 drink
  34291, -- TBC: level 70 drink
  27089, 43706, 46755, -- TBC? level 75 drink
}

---For all spells database load data for spellids and items
function allBuffsModule:LoadItemsAndSpells()
  for _id, buffDef in pairs(BOM.AllBuffomatBuffs) do
    if type(buffDef.singleText) == "number" then
      spellCacheModule:LoadSpell(buffDef.singleText)
    end
    if type(buffDef.groupText) == "number" then
      spellCacheModule:LoadSpell(buffDef.groupText)
    end

    if type(buffDef.items) == "table" then
      for _index, itemId in ipairs(buffDef.items) do
        itemCacheModule:LoadItem(itemId)
      end
    elseif type(buffDef.buffCreatesItem) == "number" then
      itemCacheModule:LoadItem(buffDef.buffCreatesItem)
    end
  end
end
