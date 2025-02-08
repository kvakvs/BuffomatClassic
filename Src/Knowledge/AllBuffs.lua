local TOCNAME, _ = ...
local BOM = BuffomatAddon

---@alias BomBuffCategoryName ""|"tracking"|"pet"|"aura"|"seal"|"blessing"|"class"|"classicPhysFood"|"classicSpellFood"|"classicFood"|"classicPhysElixir"|"classicPhysBuff"|"classicBuff"|"classicSpellElixir"|"classicElixir"|"classicFlask"|"tbcPhysFood"|"tbcSpellFood"|"tbcFood"|"tbcPhysElixir"|"tbcSpellElixir"|"tbcElixir"|"tbcFlask"|"wotlkPhysFood"|"wotlkSpellFood"|"wotlkFood"|"wotlkPhysElixir"|"wotlkSpellElixir"|"wotlkElixir"|"wotlkFlask"|"scroll"|"weaponEnchantment"|"classWeaponEnchantment"|"cataElixir"|"cataFood"|"cataFlask"

---@alias BomBuffidBuffdefLookup {[BomBuffId]: BomBuffDefinition}
---@alias BomEnchantToSpellLookup {[BomEnchantmentId]: WowSpellId}
---@alias BomBuffBySpellId {[WowSpellId]: BomBuffDefinition}

---@class BomAllBuffsModule
---@field allBuffs BomBuffidBuffdefLookup All buffs, same as BOM.AllBuffomatSpells for convenience
---@field allSpellIds number[]
---@field buffCategories BomBuffCategoryName[] Category names for buffs
---@field buffFromSpellIdLookup BomBuffBySpellId Lookup table for buff definitions by spell id
---@field CrusaderAuraSpell BomBuffDefinition
---@field enchantToSpellLookup BomEnchantToSpellLookup Reverse-maps enchantment ids back to spells
---@field itemListSpellLookup table<number, number> Map itemid to spell?
---@field selectedBuffs BomBuffDefinition[] Buffs available to the player
---@field selectedBuffsSpellIds BomBuffBySpellId All spellids from selected buffs
---@field spellIdIsSingleLookup table<number, boolean> Whether spell ids are single buffs
---@field spellIdtoBuffId {[WowSpellId]: BomBuffId} Maps spell ids to the key id of spell in the AllSpells
---@field spellToSpellLookup {[WowSpellId]: WowSpellId} Maps spells ids to other spell ids
---@field cancelForm WowSpellId[] Spell ids which cancel shapeshift form
local allBuffsModule = BomModuleManager.allBuffsModule

allBuffsModule.cancelForm = {}
allBuffsModule.spellIdtoBuffId = {}
allBuffsModule.selectedBuffs = {}
allBuffsModule.selectedBuffsSpellIds = --[[---@type BomBuffBySpellId]] {}
allBuffsModule.spellIdIsSingleLookup = {}
allBuffsModule.buffFromSpellIdLookup = --[[---@type {[WowSpellId]: BomBuffDefinition}]] {}
allBuffsModule.enchantToSpellLookup = --[[---@type BomEnchantToSpellLookup]] {}

local _t = BomModuleManager.languagesModule
local buffDefModule = BomModuleManager.buffDefinitionModule
local deathknightModule = BomModuleManager.allSpellsDeathknightModule
local druidModule = BomModuleManager.allSpellsDruidModule
local elixirsModule = BomModuleManager.allConsumesElixirsModule
local enchantmentsModule = BomModuleManager.allConsumesEnchantmentsModule
local envModule = KvModuleManager.envModule
local flasksModule = BomModuleManager.allConsumesFlasksModule
local foodModule = BomModuleManager.allConsumesFoodModule
local hunterModule = BomModuleManager.allSpellsHunterModule
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

---@alias BomClassName WowClassName|"tank"|"pet"

allBuffsModule.ALL_CLASSES = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "PRIEST", "WARLOCK",
  "SHAMAN", "PALADIN", "DEATHKNIGHT" } ---@type BomClassName[]
allBuffsModule.BOM_NO_CLASSES = {} ---@type BomClassName[]

---TODO: Move to constModule
---Classes which have a resurrection ability
---@type BomClassName[]
local RESURRECT_CLASSES = { "SHAMAN", "PRIEST", "PALADIN", "DRUID" } -- Druid in WotLK
BOM.RESURRECT_CLASS = RESURRECT_CLASSES                              --used in TaskScan.lua
allBuffsModule.RESURRECT_CLASSES = RESURRECT_CLASSES

---TODO: Move to constModule
--- Classes which have mana bar and benefit from mp/5 and spirit
---@type BomClassName[]
local MANA_CLASSES = { "HUNTER", "WARLOCK", "MAGE", "DRUID", "SHAMAN", "PRIEST", "PALADIN" }
BOM.MANA_CLASSES = MANA_CLASSES --used in TaskScan.lua
allBuffsModule.MANA_CLASSES = MANA_CLASSES

---TODO: Move to constModule
--- Classes which deal spell damage
---@type BomClassName[]
allBuffsModule.SPELL_CLASSES = { "WARLOCK", "MAGE", "DRUID", "SHAMAN", "PRIEST", "PALADIN", "DEATHKNIGHT", "HUNTER" }

---TODO: Move to constModule
--- Classes which hit with weapons or claws
---@type BomClassName[]
allBuffsModule.MELEE_CLASSES = { "WARRIOR", "ROGUE", "DRUID", "SHAMAN", "PALADIN", "DEATHKNIGHT" }

---TODO: Move to constModule
--- Classes capable of dealing shadow damage
---@type BomClassName[]
allBuffsModule.SHADOW_CLASSES = { "PRIEST", "WARLOCK", "DEATHKNIGHT" }

---TODO: Move to constModule
--- Classes capable of dealing fire damage
---@type BomClassName[]
allBuffsModule.FIRE_CLASSES = { "MAGE", "WARLOCK", "SHAMAN", "HUNTER" }

---TODO: Move to constModule
--- Classes capable of dealing frost damage
---@type BomClassName[]
allBuffsModule.FROST_CLASSES = { "MAGE", "SHAMAN", "DEATHKNIGHT" }

---TODO: Move to constModule
--- Classes dealing physical ranged or melee damage
---@type BomClassName[]
allBuffsModule.PHYSICAL_CLASSES = { "HUNTER", "ROGUE", "SHAMAN", "WARRIOR", "DRUID", "PALADIN", "DEATHKNIGHT" }

allBuffsModule.MINUTE = 60
allBuffsModule.TWO_MINUTES = allBuffsModule.MINUTE * 2
allBuffsModule.FIVE_MINUTES = allBuffsModule.MINUTE * 5
allBuffsModule.TEN_MINUTES = allBuffsModule.MINUTE * 10
allBuffsModule.FIFTEEN_MINUTES = allBuffsModule.MINUTE * 15
allBuffsModule.TWENTY_MINUTES = allBuffsModule.MINUTE * 20
allBuffsModule.HALF_AN_HOUR = allBuffsModule.MINUTE * 30
allBuffsModule.HOUR = allBuffsModule.MINUTE * 60

--- From 2 choices return TBC if BOM.IsTBC is true, otherwise return classic
local function tbcOrClassic(tbc, classic)
  if envModule.haveTBC then
    return tbc
  end
  return classic
end
allBuffsModule.TbcOrClassic = tbcOrClassic

--- From 2 choices return TBC if BOM.IsTBC is true, otherwise return classic
function allBuffsModule.ExpansionChoice(classic, tbc, wotlk)
  if envModule.haveWotLK then
    return wotlk
  end
  if envModule.haveTBC then
    return tbc
  end
  return classic
end

---Add RESOURCE TRACKING spells
---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function allBuffsModule:SetupTrackingSpells(allBuffs, enchantments)
  -- Find Herbs / kräuter
  buffDefModule:createAndRegisterBuff(allBuffs, spellIdsModule.FindHerbs, nil)
      :BuffType("tracking")
      :IsDefault(true)
      :Category("tracking")

  -- Find Minerals / erz
  buffDefModule:createAndRegisterBuff(allBuffs, spellIdsModule.FindMinerals, nil)
      :BuffType("tracking")
      :IsDefault(true)
      :Category("tracking")

  -- Find Treasure / Schatzsuche / Zwerge
  buffDefModule:createAndRegisterBuff(allBuffs, spellIdsModule.FindTreasure, nil)
      :BuffType("tracking")
      :IsDefault(true)
      :Category("tracking")

  -- Find Fish (TBC daily quest reward)
  buffDefModule:createAndRegisterBuff(allBuffs, spellIdsModule.FindFish, nil)
      :BuffType("tracking")
      :IsDefault(false)
      :Category("tracking")

  return allBuffs
end

function allBuffsModule:SetupConstantsCategories()
  --self.CLASSIC_PHYS_FOOD = "classicPhysFood"
  --self.CLASSIC_SPELL_FOOD = "classicSpellFood"
  --self.CLASSIC_FOOD = "classicFood"
  --self.CLASSIC_PHYS_ELIXIR = "classicPhysElixir"
  --self.CLASSIC_PHYS_BUFF = "classicPhysBuff"
  --self.CLASSIC_BUFF = "classicBuff"
  --self.CLASSIC_SPELL_ELIXIR = "classicSpellElixir"
  --self.CLASSIC_ELIXIR = "classicElixir"
  --self.CLASSIC_FLASK = "classicFlask"
  --
  --self.SCROLL = "scroll"
  --self.WEAPON_ENCHANTMENT = "weaponEnchantment"
  --self.CLASS_WEAPON_ENCHANTMENT = "classWeaponEnchantment"

  -- Categories ordered for display
  self.buffCategories = {
    "class", "classWeaponEnchantment", "blessing", "seal", "aura", "pet", "tracking",
    "cataFood", "cataElixir", "cataFlask",
    "wotlkPhysElixir", "wotlkSpellElixir", "wotlkElixir", "wotlkFlask", "wotlkFood", "wotlkPhysFood", "wotlkSpellFood",
    "tbcPhysElixir", "tbcSpellElixir", "tbcElixir", "tbcFlask", "tbcFood", "tbcPhysFood", "tbcSpellFood",
    "classicPhysElixir", "classicPhysBuff", "classicSpellElixir", "classicElixir", "classicFlask",
    "classicFood", "classicPhysFood", "classicSpellFood",
    "scroll", "weaponEnchantment",
    "", -- special value no category
  }
end

function allBuffsModule:SetupConstants()
  self:SetupConstantsCategories()
end

--- Filter away the 'false' element and return only keys, values become the translation strings
---@return {[string]: string}
function allBuffsModule:GetBuffCategories()
  local result = {}
  for _i, cat in ipairs(self.buffCategories) do
    if type(cat) == "string" and cat ~= "" then
      result[ --[[---@type string]] cat ] = _t("Category_" .. cat)
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
      if buffDefModule:CheckStaticLimitations(buff, --[[---@not nil]] buff.limitations) then
        table.insert(result, buff)
      end
    end
    buff.limitations = nil -- do not need to store this
  end

  return result
end

-- TODO: Change BomBuffId to string and get rid of spell ids as keys
---@alias NewBuffId string
---@alias BomBuffId number
---@alias BomEnchantmentId number #Wow Enchantment ID https://wowwiki-archive.fandom.com/wiki/EnchantId/Enchant_IDs

---@class BomAllBuffsTable
---@field [BomBuffId] BomBuffDefinition

---@alias BomEnchantmentsMapping {[WowSpellId]: BomEnchantmentId[]}

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
    if spell.isConsumable and spell.items then
      for _, item in ipairs(spell.items or {}) do
        BOM.GetItemInfo(item)
      end
    end
  end

  allBuffsModule.enchantToSpellLookup = {}
  for dest, list in pairs(enchantments) do
    for i, id in ipairs(list) do
      allBuffsModule.enchantToSpellLookup[id] = dest
    end
  end

  -- Move from list of buffs to buffid-keyed buff dictionary
  self.allBuffs = --[[---@type BomBuffidBuffdefLookup]] {}
  for _i, buff in ipairs(allBuffs) do
    self.allBuffs[buff.buffId] = buff
  end

  BOM.enchantList = enchantments
end

---@class BomReputationTrinketZones
---@field itemIds WowItemId[]
---@field zoneId WowZoneId[]
---@field Link string
---@field spell WowSpellId
BOM.reputationTrinketZones = {
  itemIds = {
    12846, -- Simple AD trinket
    13209, -- Seal of the Dawn +81 AP
    19812, -- Rune of the Dawn +48 SPELL
    23206, -- Mark of the Chamption +150 AP
    23207, -- Mark of the Chamption +85 SPELL
  },
  zoneId  = {
    329, 289, 533, 535, --Stratholme/scholomance; Naxxramas LK 10/25
    558,                -- TBC: Auchenai
    532,                -- TBC: Karazhan
  },
}

---@class BomRidingSpeedZones
---@field itemIds WowItemId[]
---@field zoneId WowZoneId[]
---@field Link string
---@field spell WowSpellId
BOM.ridingSpeedZones = {
  itemIds = {
    11122, -- Classic: Item [Carrot on a Stick]
    25653, -- TBC: Item [Riding Crop]
    32481, -- TBC: Item [Charm of Swift Flight]
  },
  --Allow Riding Speed trinkets in:
  zoneId  = {
    0, 1, 530, -- Eastern Kingdoms, Kalimdor, Outland
    30,        -- Alterac Valley
    529,       -- Arathi Basin,
    489,       -- Warsong Gulch
    566, 968,  -- TBC: Eye of the Storm
    --1672, 1505, 572, -- TBC: Blade's Edge Arena, Nagrand Arena, Ruins of Lordaeron
  },
}

BOM.buffExchangeId = {                      -- combine-spell-ids to new one
  [18788] = { 18791, 18790, 18789, 18792 }, -- Demonic Sacrifice-Buffs to Demonic Sacrifice
  [16591] = { 16591, 16589, 16595, 16593 }, -- noggenfoger
}

allBuffsModule.spellToSpellLookup = {}
for dest, list in pairs(BOM.buffExchangeId) do
  for i, id in ipairs(list) do
    allBuffsModule.spellToSpellLookup[id] = dest
  end
end

---@deprecated
BOM.itemList = {
  --{6948}, -- Hearthstone | Ruhestein
  --{4604}, -- Forest Mushroom | Waldpilz
  --{8079},-- Water | wasser
  { 5232, 16892, 16893, 16895, -- Soulstone | Seelenstein
    16896 },                   -- TBC: Major Soulstone
}
allBuffsModule.itemListSpellLookup = {
  [8079]  = 432, -- Water | Wasser
  [5232]  = 20762,
  [16892] = 20762,
  [16893] = 20762,
  [16895] = 20762,
  [16896] = 20762, -- Soulstone | Seelenstein
}

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
      local buff = buffDefModule:New(5118) --Aspect of the Cheetah/of the pack
          :OnlyCombat(true)
          :IsDefault(true)
          :SingleFamily({ 5118, 13159 })
      table.insert(s, buff)
    end

    if (UnitFactionGroup("player")) ~= "Horde" or envModule.haveTBC then
      local buff = buffDefModule:New(1038) --Blessing of Salvation
          :IsDefault(false)
          :SingleFamily({ 1038, 25895 })
      table.insert(s, buff)
    end
  end

  BOM.cancelBuffs = s
end

-- Having this buff on target excludes the target (phaseshifted imp for example)
BOM.buffIgnoreAll = {
  4511 -- Phase Shift (imp)
}

local ShapeShiftTravel = {
  2645,
  783
} --Ghost wolf and travel druid

BOM.drinkingPersonCount = 0
BOM.AllDrink = {
  30024,                                          -- Restores 20% mana
  430,                                            -- level 5 drink
  431,                                            -- level 15 drink
  432,                                            -- level 25 drink
  1133,                                           -- level 35 drink
  1135,                                           -- level 45 drink
  1137, 29007, 43154, 24355, 25696, 43155, 26261, -- level 55 drink
  10250, 22734,                                   -- TBC: level 65 drink
  34291,                                          -- TBC: level 70 drink
  27089, 43706, 46755,                            -- TBC? level 75 drink
}

---For all spells database load data for spellids and items
function allBuffsModule:LoadItemsAndSpells()
  for _index, buffDef in pairs(self.allBuffs) do
    buffDef:Preload()
  end
end