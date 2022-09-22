local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllBuffsModule
---@field buffCategories table<number, string> Category names for buffs
---@field allBuffs table<number, BomBuffDefinition> All buffs, same as BOM.AllBuffomatSpells for convenience
local allBuffsModule = BuffomatModule.New("AllBuffs") ---@type BomAllBuffsModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule
local deathknightModule = BuffomatModule.Import("AllSpellsDeathknight") ---@type BomAllSpellsDeathknightModule
local druidModule = BuffomatModule.Import("AllSpellsDruid") ---@type BomAllSpellsDruidModule
local elixirsModule = BuffomatModule.New("AllConsumesElixirs") ---@type BomAllConsumesElixirsModule
local enchantmentsModule = BuffomatModule.New("AllConsumesEnchantments") ---@type BomAllConsumesEnchantmentsModule
local flasksModule = BuffomatModule.New("AllConsumesFlasks") ---@type BomAllConsumesFlasksModule
local foodModule = BuffomatModule.New("AllConsumesFood") ---@type BomAllConsumesFoodModule
local hunterModule = BuffomatModule.Import("AllSpellsHunter") ---@type BomAllSpellsHunterModule
local itemCacheModule = BuffomatModule.Import("ItemCache") ---@type BomItemCacheModule
local mageModule = BuffomatModule.Import("AllSpellsMage") ---@type BomAllSpellsMageModule
local otherModule = BuffomatModule.New("AllConsumesOther") ---@type BomAllConsumesOtherModule
local paladinModule = BuffomatModule.Import("AllSpellsPaladin") ---@type BomAllSpellsPaladinModule
local priestModule = BuffomatModule.Import("AllSpellsPriest") ---@type BomAllSpellsPriestModule
local rogueModule = BuffomatModule.Import("AllSpellsRogue") ---@type BomAllSpellsRogueModule
local scrollsModule = BuffomatModule.Import("AllConsumesScrolls") ---@type BomAllConsumesScrollsModule
local shamanModule = BuffomatModule.Import("AllSpellsShaman") ---@type BomAllSpellsShamanModule
local spellCacheModule = BuffomatModule.Import("SpellCache") ---@type BomSpellCacheModule
local spellIdsModule = BuffomatModule.Import("SpellIds") ---@type BomSpellIdsModule
local warlockModule = BuffomatModule.Import("AllSpellsWarlock") ---@type BomAllSpellsWarlockModule
local warriorModule = BuffomatModule.Import("AllSpellsWarrior") ---@type BomAllSpellsWarriorModule

local L = setmetatable(
        {},
        {
          __index = function(_t, k)
            if BOM.L and BOM.L[k] then
              return BOM.L[k]
            else
              return "[" .. k .. "]"
            end
          end
        })

local BOM_ALL_CLASSES = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "PRIEST", "WARLOCK",
                          "SHAMAN", "PALADIN", "DEATHKNIGHT" }
local BOM_NO_CLASS = { }
allBuffsModule.BOM_ALL_CLASSES = BOM_ALL_CLASSES
allBuffsModule.BOM_NO_CLASSES = BOM_NO_CLASS

---Classes which have a resurrection ability
local RESURRECT_CLASSES = { "SHAMAN", "PRIEST", "PALADIN", "DRUID" } -- Druid in WotLK
BOM.RESURRECT_CLASS = RESURRECT_CLASSES --used in TaskScan.lua
allBuffsModule.RESURRECT_CLASSES = RESURRECT_CLASSES
--- Classes which have mana bar and benefit from mp/5 and spirit
local MANA_CLASSES = { "HUNTER", "WARLOCK", "MAGE", "DRUID", "SHAMAN", "PRIEST", "PALADIN" }
BOM.MANA_CLASSES = MANA_CLASSES --used in TaskScan.lua
allBuffsModule.MANA_CLASSES = MANA_CLASSES
--- Classes which deal spell damage
allBuffsModule.SPELL_CLASSES = { "WARLOCK", "MAGE", "DRUID", "SHAMAN", "PRIEST", "PALADIN", "DEATHKNIGHT", "HUNTER" }
--- Classes which hit with weapons or claws
allBuffsModule.MELEE_CLASSES = { "WARRIOR", "ROGUE", "DRUID", "SHAMAN", "PALADIN", "DEATHKNIGHT" }
--- Classes capable of dealing shadow damage
allBuffsModule.SHADOW_CLASSES = { "PRIEST", "WARLOCK", "DEATHKNIGHT" }
--- Classes capable of dealing fire damage
allBuffsModule.FIRE_CLASSES = { "MAGE", "WARLOCK", "SHAMAN", "HUNTER" }
--- Classes capable of dealing frost damage
allBuffsModule.FROST_CLASSES = { "MAGE", "SHAMAN", "DEATHKNIGHT" }
--- Classes dealing physical ranged or melee damage
allBuffsModule.PHYSICAL_CLASSES = { "HUNTER", "ROGUE", "SHAMAN", "WARRIOR", "DRUID", "PALADIN", "DEATHKNIGHT" }

local DURATION_1H = 3600
local DURATION_30M = 1800
local DURATION_20M = 1200
local DURATION_15M = 900
local DURATION_10M = 600
local DURATION_5M = 300
local DURATION_2M = 120

allBuffsModule.DURATION_1H = DURATION_1H
allBuffsModule.DURATION_30M = DURATION_30M
allBuffsModule.DURATION_20M = DURATION_20M
allBuffsModule.DURATION_15M = DURATION_15M
allBuffsModule.DURATION_10M = DURATION_10M
allBuffsModule.DURATION_5M = DURATION_5M
allBuffsModule.DURATION_2M = DURATION_2M

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
---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function allBuffsModule:SetupTrackingSpells(buffs, enchantments)
  buffDefModule:createAndRegisterBuff(buffs, spellIdsModule.FindHerbs, -- Find Herbs / kräuter
          { type = "tracking", default = true })
               :Category(self.TRACKING)

  buffDefModule:createAndRegisterBuff(buffs, spellIdsModule.FindMinerals, -- Find Minerals / erz
          { type = "tracking", default = true })
               :Category(self.TRACKING)

  buffDefModule:createAndRegisterBuff(buffs, spellIdsModule.FindTreasure, -- Find Treasure / Schatzsuche / Zwerge
          { type = "tracking", default = true })
               :Category(self.TRACKING)

  buffDefModule:createAndRegisterBuff(buffs, spellIdsModule.FindFish, -- Find Fish (TBC daily quest reward)
          { type = "tracking", default = false })
               :Category(self.TRACKING)

  return buffs
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

    false, -- special value no category
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
function allBuffsModule:GetBuffCategories()
  local result = {}
  for _i, cat in ipairs(self.buffCategories) do
    if type(cat) == "string" then
      result[cat] = _t("Category_" .. cat)
    end
  end
  return result
end

---Filter the input `allbuffs` if the limitations check returns true
---@param allBuffs table<number, BomBuffDefinition> Input list of all buffs
---@return table<number, BomBuffDefinition> Filtered list
function allBuffsModule:ApplyPostLimitations(allBuffs)
  -- Apply post-limitations (added with :Limitation() functions on spell construction)
  local result = {}

  for _i, buff in ipairs(allBuffs) do
    if buffDefModule:CheckLimitations(buff, buff.limitations) then
      tinsert(result, buff)
    end
    buff.limitations = nil -- do not need to store this
  end

  return result
end

---All spells known to Buffomat
---Note: you can add your own spell in the "WTF\Account\<accountname>\SavedVariables\buffOmat.lua"
---table CustomSpells
---@return table<number, BomBuffDefinition> All known spells table (all spells to be scanned)
function allBuffsModule:SetupSpells()
  local allBuffs = {} ---@type table<number, BomBuffDefinition>
  local enchantments = {} ---@type table<number, table<number>>
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

---@return table<number, BomBuffDefinition>
function allBuffsModule:SetupCancelBuffs()
  -- Note: you can add your own spell in the "WTF\Account\<accountname>\SavedVariables\buffOmat.lua"
  -- table CustomCancelBuff
  local spirit = BOM.SpellDef_PrayerOfSpirit()
  spirit.default = false

  local intelli = BOM.SpellDef_ArcaneIntelligence()
  intelli.default = false

  local s = {
    BOM.SpellDef_PW_Shield(),
    spirit,
    intelli,
  }

  do
    local _, class, _ = UnitClass("unit")
    if class == "HUNTER" then
      tinsert(s, buffDefModule:New(5118, --Aspect of the Cheetah/of the pack
              { OnlyCombat = true, default = true, singleFamily = { 5118, 13159 } }))
    end

    if (UnitFactionGroup("player")) ~= "Horde" or BOM.IsTBC then
      tinsert(s, buffDefModule:New(1038, --Blessing of Salvation
              { default = false, singleFamily = { 1038, 25895 } }))
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
    elseif type(buffDef.item) == "number" then
      itemCacheModule:LoadItem(buffDef.item)
    end
  end
end
