local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsModule
---@field buffCategories table<number, string> Category names for buffs
---@field allBuffs table<number, BomBuffDefinition> All buffs, same as BOM.AllBuffomatSpells for convenience
local allSpellsModule = BuffomatModule.New("AllSpells") ---@type BomAllSpellsModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local itemCacheModule = BuffomatModule.Import("ItemCache") ---@type BomItemCacheModule
local spellCacheModule = BuffomatModule.Import("SpellCache") ---@type BomSpellCacheModule
local spellDefModule = BuffomatModule.Import("SpellDef") ---@type BomSpellDefModule
local priestModule = BuffomatModule.Import("AllSpellsPriest") ---@type BomAllSpellsPriestModule
local mageModule = BuffomatModule.Import("AllSpellsMage") ---@type BomAllSpellsMageModule
local druidModule = BuffomatModule.Import("AllSpellsDruid") ---@type BomAllSpellsDruidModule
local shamanModule = BuffomatModule.Import("AllSpellsShaman") ---@type BomAllSpellsShamanModule
local warlockModule = BuffomatModule.Import("AllSpellsWarlock") ---@type BomAllSpellsWarlockModule
local hunterModule = BuffomatModule.Import("AllSpellsHunter") ---@type BomAllSpellsHunterModule
local paladinModule = BuffomatModule.Import("AllSpellsPaladin") ---@type BomAllSpellsPaladinModule
local warriorModule = BuffomatModule.Import("AllSpellsWarrior") ---@type BomAllSpellsWarriorModule
local rogueModule = BuffomatModule.Import("AllSpellsRogue") ---@type BomAllSpellsRogueModule
local deathknightModule = BuffomatModule.Import("AllSpellsDeathknight") ---@type BomAllSpellsDeathknightModule

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
allSpellsModule.ALL_CLASSES = BOM_ALL_CLASSES
allSpellsModule.NO_CLASSES = BOM_NO_CLASS

---Classes which have a resurrection ability
local BOM_RESURRECT_CLASSES = { "SHAMAN", "PRIEST", "PALADIN" }
BOM.RESURRECT_CLASS = BOM_RESURRECT_CLASSES --used in TaskScan.lua
allSpellsModule.RESURRECT_CLASSES = BOM_RESURRECT_CLASSES

---Classes which have mana bar
local BOM_MANA_CLASSES = { "HUNTER", "WARLOCK", "MAGE", "DRUID", "SHAMAN", "PRIEST", "PALADIN" }
BOM.MANA_CLASSES = BOM_MANA_CLASSES --used in TaskScan.lua
allSpellsModule.MANA_CLASSES = BOM_MANA_CLASSES

---@deprecated
BOM.CLASSIC_ERA = "Classic"
---@deprecated
BOM.IsTBC_ERA = "TBC"

local BOM_MELEE_CLASSES = { "WARRIOR", "ROGUE", "DRUID", "SHAMAN", "PALADIN", "DEATHKNIGHT" }
local BOM_SHADOW_CLASSES = { "PRIEST", "WARLOCK", "DEATHKNIGHT" }
local BOM_FIRE_CLASSES = { "MAGE", "WARLOCK", "SHAMAN", "HUNTER" }
local BOM_FROST_CLASSES = { "MAGE", "SHAMAN", "DEATHKNIGHT" }
local BOM_PHYSICAL_CLASSES = { "HUNTER", "ROGUE", "SHAMAN", "WARRIOR", "DRUID", "PALADIN", "DEATHKNIGHT" }

allSpellsModule.BOM_MELEE_CLASSES = BOM_MELEE_CLASSES
allSpellsModule.BOM_SHADOW_CLASSES = BOM_SHADOW_CLASSES
allSpellsModule.BOM_FIRE_CLASSES = BOM_FIRE_CLASSES
allSpellsModule.BOM_FROST_CLASSES = BOM_FROST_CLASSES
allSpellsModule.BOM_PHYSICAL_CLASSES = BOM_PHYSICAL_CLASSES

local DURATION_1H = 3600
local DURATION_30M = 1800
local DURATION_20M = 1200
local DURATION_15M = 900
local DURATION_10M = 600
local DURATION_5M = 300

allSpellsModule.DURATION_1H = DURATION_1H
allSpellsModule.DURATION_30M = DURATION_30M
allSpellsModule.DURATION_20M = DURATION_20M
allSpellsModule.DURATION_15M = DURATION_15M
allSpellsModule.DURATION_10M = DURATION_10M
allSpellsModule.DURATION_5M = DURATION_5M

--- From 2 choices return TBC if BOM.IsTBC is true, otherwise return classic
local function tbcOrClassic(tbc, classic)
  if BOM.HaveTBC then
    return tbc
  end
  return classic
end
allSpellsModule.TbcOrClassic = tbcOrClassic

--- From 2 choices return TBC if BOM.IsTBC is true, otherwise return classic
function allSpellsModule.ExpansionChoice(classic, tbc, wotlk)
  if BOM.HaveWotLK then
    return wotlk
  end
  if BOM.HaveTBC then
    return tbc
  end
  return classic
end

---Add RESOURCE TRACKING spells
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupTrackingSpells(spells, enchants)
  spells[BOM.SpellId.FindHerbs] = spellDefModule:New(BOM.SpellId.FindHerbs, -- Find Herbs / kräuter
          { type = "tracking", default = true
          })                                    :Category(self.TRACKING)

  spells[BOM.SpellId.FindMinerals] = spellDefModule:New(BOM.SpellId.FindMinerals, -- Find Minerals / erz
          { type = "tracking", default = true
          })                                       :Category(self.TRACKING)
  spells[2481] = spellDefModule:New(2481, -- Find Treasure / Schatzsuche / Zwerge
          { type = "tracking", default = true })
                               :Category(self.TRACKING)

  spells[43308] = spellDefModule:New(43308, -- Find Fish (TBC daily quest reward)
          { type = "tracking", default = false })
                                :Category(self.TRACKING)

  return spells
end

---MISC spells applicable to every class
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupMiscSpells(spells, enchants)
  return spells
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupPhysicalDpsBattleElixirs(spells, enchants)
  spellDefModule:createAndRegisterBuff(spells, 28497, --TBC: Elixir of Major Agility +35 AGI +20 CRIT
          { item          = 22831, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :ShowInTBC()
                :Category(self.TBC_PHYS_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)
  spellDefModule:createAndRegisterBuff(spells, 38954, --TBC: Fel Strength Elixir +90AP -10 STA
          { item          = 31679, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :ShowInTBC()
                :Category(self.TBC_PHYS_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)
  spellDefModule:createAndRegisterBuff(spells, 28490, --TBC: Elixir of Major Strength +35 STR
          { item          = 22824, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :ShowInTBC()
                :Category(self.TBC_PHYS_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)
  spellDefModule:createAndRegisterBuff(spells, 33720, --TBC: Onslaught Elixir +60 AP
          { item          = 28102, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :ShowInTBC()
                :Category(self.TBC_PHYS_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupPhysicalDpsConsumables(spells, enchants)
  spellDefModule:createAndRegisterBuff(spells, 17538, --Elixir of the Mongoose
          { item          = 13452, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :Category(self.CLASSIC_PHYS_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)
  spellDefModule:createAndRegisterBuff(spells, 11334, --Elixir of Greater Agility
          { item          = 9187, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :Category(self.CLASSIC_PHYS_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)
  spellDefModule:createAndRegisterBuff(spells, 11405, --Elixir of Giants
          { item          = 9206, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :Category(self.CLASSIC_PHYS_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)
  spellDefModule:createAndRegisterBuff(spells, 17038, --Winterfall Firewater
          { item          = 12820, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :Category(self.CLASSIC_PHYS_BUFF)
  spellDefModule:createAndRegisterBuff(spells, 16329, --Juju Might +40AP
          { item        = 12460, isConsumable = true, default = false,
            playerClass = BOM_PHYSICAL_CLASSES, })
                :Category(self.CLASSIC_PHYS_BUFF)
  spellDefModule:createAndRegisterBuff(spells, 16323, --Juju Power +30Str
          { item        = 12451, isConsumable = true, default = false,
            playerClass = BOM_PHYSICAL_CLASSES, })
                :Category(self.CLASSIC_PHYS_BUFF)
  --
  -- Scrolls
  --
  spellDefModule:createAndRegisterBuff(spells, 33077, --TBC: Scroll of Agility V
          { item           = 27498, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = DURATION_30M, playerClass = BOM_PHYSICAL_CLASSES })
                :ShowInTBC()
                :Category(self.SCROLL)
  spellDefModule:createAndRegisterBuff(spells, 12174, --Scroll of Agility IV
          { item           = 10309, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = DURATION_30M, playerClass = BOM_PHYSICAL_CLASSES, })
                :Category(self.SCROLL)
  spellDefModule:createAndRegisterBuff(spells, 8117, --Scroll of Agility III
          { item           = 4425, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = DURATION_30M, playerClass = BOM_PHYSICAL_CLASSES, })
                :Category(self.SCROLL)

  spellDefModule:createAndRegisterBuff(spells, 33082, --TBC: Scroll of Strength V
          { item           = 27503, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = DURATION_30M, playerClass = BOM_MELEE_CLASSES })
                :ShowInTBC()
                :Category(self.SCROLL)
  spellDefModule:createAndRegisterBuff(spells, 12179, --Scroll of Strength IV
          { item           = 10310, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = DURATION_30M, playerClass = BOM_MELEE_CLASSES, })
                :Category(self.SCROLL)
  spellDefModule:createAndRegisterBuff(spells, 8120, --Scroll of Strength III
          { item           = 4426, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = DURATION_30M, playerClass = BOM_MELEE_CLASSES, })
                :Category(self.SCROLL)

  spellDefModule:createAndRegisterBuff(spells, 33079, --TBC: Scroll of Protection V
          { item           = 27500, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = DURATION_30M })
                :ShowInTBC()
                :Category(self.SCROLL)
  spellDefModule:createAndRegisterBuff(spells, 12175, --Scroll of Protection IV
          { item           = 10305, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = DURATION_30M, })
                :Category(self.SCROLL)

  spellDefModule:createAndRegisterBuff(spells, 12177, --Scroll of Spirit IV
          { item           = 10306, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = DURATION_30M, playerClass = BOM_MANA_CLASSES })
                :Category(self.SCROLL)
  spellDefModule:createAndRegisterBuff(spells, 33080, --Scroll of Spirit V
          { item           = 27501, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = DURATION_30M, playerClass = BOM_MANA_CLASSES })
                :ShowInTBC()
                :Category(self.SCROLL)

  --
  -- Rune of Warding
  --
  spellDefModule:createAndRegisterBuff(spells, 32282, --TBC: Greater Rune of Warding
          { item           = 25521, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = DURATION_1H, targetClasses = BOM_ALL_CLASSES, playerClass = BOM_MELEE_CLASSES })

  --
  -- Weightstones for blunt weapons
  --
  spellDefModule:createAndRegisterBuff(spells, 16622, --Weightstone
          { item         = 12643, items = { 12643, 7965, 3241, 3240, 3239 },
            isConsumable = true, type = "weapon", duration = DURATION_30M,
            default      = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :Category(self.WEAPON_ENCHANTMENT)
  enchants[16622] = { 1703, 484, 21, 20, 19 } -- Weightstone

  spellDefModule:createAndRegisterBuff(spells, 34340, --TBC: Adamantite Weightstone +12 BLUNT +14 CRIT
          { item    = 28421, items = { 28421 }, isConsumable = true, type = "weapon", duration = DURATION_1H,
            default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :ShowInTBC()
                :Category(self.WEAPON_ENCHANTMENT)
  enchants[34340] = { 2955 } --TBC: Adamantite Weightstone (Weight Weapon)

  spellDefModule:createAndRegisterBuff(spells, 34339, --TBC: Fel Weightstone +12 BLUNT
          { item    = 28420, items = { 28420 }, isConsumable = true, type = "weapon", duration = DURATION_1H,
            default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :ShowInTBC()
                :Category(self.WEAPON_ENCHANTMENT)
  enchants[34339] = { 2954 } --TBC: Fel Weightstone (Weighted +12)


  --
  -- Sharpening Stones for sharp weapons
  --
  spellDefModule:createAndRegisterBuff(spells, 16138, --Sharpening Stone
          { item          = 12404, items = { 12404, 7964, 2871, 2863, 2862 },
            isConsumable  = true, type = "weapon", duration = DURATION_30M, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :Category(self.WEAPON_ENCHANTMENT)
  enchants[16138] = { 1643, 483, 14, 13, 40 } --Sharpening Stone

  spellDefModule:createAndRegisterBuff(spells, 28891, --Consecrated Sharpening Stone
          { item     = 23122, isConsumable = true, type = "weapon",
            duration = DURATION_1H, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :Category(self.WEAPON_ENCHANTMENT)
  enchants[28891] = { 2684 } --Consecrated Sharpening Stone

  spellDefModule:createAndRegisterBuff(spells, 22756, --Elemental Sharpening Stone
          { item     = 18262, isConsumable = true, type = "weapon",
            duration = DURATION_30M, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :Category(self.WEAPON_ENCHANTMENT)
  enchants[22756] = { 2506 } --Elemental Sharpening Stone

  spellDefModule:createAndRegisterBuff(spells, 29453, --TBC: Adamantite Sharpening Stone +12 WEAPON +14 CRIT
          { item    = 23529, items = { 23529 }, isConsumable = true, type = "weapon", duration = DURATION_1H,
            default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :ShowInTBC()
                :Category(self.WEAPON_ENCHANTMENT)

  spellDefModule:createAndRegisterBuff(spells, 29452, --TBC: Fel Sharpening Stone +12 WEAPON
          { item    = 23528, items = { 23528 }, isConsumable = true, type = "weapon", duration = DURATION_1H,
            default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :ShowInTBC()
                :Category(self.WEAPON_ENCHANTMENT)
  enchants[29452] = { 2712 } --TBC: Fel Sharpening Stone (Sharpened +12)
  enchants[29453] = { 2713 } --TBC: Adamantite Sharpening Stone (Sharpened +14 Crit, +12)
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupCasterBattleElixirs(spells, enchants)
  -- Not visible in Classic
  spellDefModule:tbcConsumable(spells, 28273, 22710, --TBC: Bloodthistle (Belf only)
          { playerRace = "BloodElf", playerClass = BOM_MANA_CLASSES },
          "+10 spell")
                :Category(self.TBC_FOOD)
                :ElixirType(self.ELIX_BATTLE)

  spellDefModule:tbcConsumable(spells, 28509, 22840) --TBC: Elixir of Major Mageblood +16 mp5
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)

  spellDefModule:tbcConsumable(spells, 28503, 22835, --TBC: Elixir of Major Shadow Power +55 SHADOW
          { playerClass = BOM_SHADOW_CLASSES })
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)

  spellDefModule:tbcConsumable(spells, 28501, 22833, --TBC: Elixir of Major Firepower +55 FIRE
          { playerClass = BOM_FIRE_CLASSES })
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)

  spellDefModule:tbcConsumable(spells, 28493, 22827, --TBC: Elixir of Major Frost Power +55 FROST
          { playerClass = BOM_FROST_CLASSES })
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)

  spellDefModule:tbcConsumable(spells, 28491, 22825, --TBC: Elixir of Healing Power +50 HEAL
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)

  spellDefModule:tbcConsumable(spells, 33721, 28103, --TBC: Adept's Elixir +24 SPELL, +24 SPELLCRIT
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)

  spellDefModule:tbcConsumable(spells, 39627, 32067, --TBC: Elixir of Draenic Wisdom +30 SPI
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  -- Visible in TBC but marked as Classic consumables
  spellDefModule:classicConsumable(spells, 24363, 20007, --Mageblood Potion
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.CLASSIC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  spellDefModule:classicConsumable(spells, 17539, 13454, --Greater Arcane Elixir
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.CLASSIC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)

  spellDefModule:classicConsumable(spells, 11390, 9155, --Greater Arcane Elixir
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.CLASSIC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)

  spellDefModule:classicConsumable(spells, 11474, 9264, -- Elixir of Shadow Power
          { playerClass = BOM_SHADOW_CLASSES })
                :Category(self.CLASSIC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)

  spellDefModule:classicConsumable(spells, 26276, 21546, --Elixir of Greater Firepower
          { playerClass = BOM_FIRE_CLASSES })
                :Category(self.CLASSIC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)

  spellDefModule:classicConsumable(spells, 21920, 17708, --Elixir of Frost Power
          { playerClass = BOM_FROST_CLASSES })
                :Category(self.CLASSIC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_BATTLE)
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupCasterGuardianElixirs(spells, enchants)
  spellDefModule:classicConsumable(spells, 11396, 9179, --Elixir of Greater Intellect +25
          nil)
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  spellDefModule:tbcConsumable(spells, 28514, 22848, --TBC: Elixir of Empowerment, -30 TARGET RESIST
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  spellDefModule:tbcConsumable(spells, 17535, 13447, --TBC: Elixir of the Sages +18 INT/+18 SPI
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.CLASSIC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)
end

---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupCasterConsumables(spells, enchants)
  spellDefModule:classicConsumable(spells, 18194, 13931, --Nightfin Soup +8Mana/5
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.CLASSIC_SPELL_FOOD)

  spellDefModule:classicConsumable(spells, 19710, 12218, --Monster Omelette
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.CLASSIC_SPELL_FOOD)

  spellDefModule:createAndRegisterBuff(spells, 18141, --Blessed Sunfruit Juice +10 SPIRIT
          { item          = 13813, isConsumable = true, default = false,
            onlyUsableFor = BOM_MANA_CLASSES, })
                :Category(self.CLASSIC_SPELL_FOOD)

  if BOM.IsTBC then
    spellDefModule:createAndRegisterBuff(spells, 28017, --Superior Wizard Oil +42 SPELL
            { item          = 22522, items = { 22522 }, isConsumable = true,
              type          = "weapon", duration = DURATION_1H, default = false,
              onlyUsableFor = BOM_MANA_CLASSES })
                  :Category(self.WEAPON_ENCHANTMENT)
  end

  spellDefModule:createAndRegisterBuff(spells, 25123, --Minor, Lesser, Brilliant Mana Oil
          { item     = 20748, isConsumable = true, type = "weapon",
            items    = { 20748, 20747, 20745, -- Minor, Lesser, Brilliant Mana Oil
                         22521 }, -- TBC: Superior Mana Oil
            duration = DURATION_30M, default = false, onlyUsableFor = BOM_MANA_CLASSES })
                :Category(self.WEAPON_ENCHANTMENT)
  enchants[25123] = { 2624, 2625, 2629, -- Minor, Lesser, Brilliant Mana Oil (enchant)
                      2677 } -- TBC: Superior Mana Oil (enchant)

  spellDefModule:createAndRegisterBuff(spells, 25122, -- Wizard Oil
          { item     = 20749, isConsumable = true, type = "weapon",
            items    = { 20749, 20746, 20744, 20750, --Minor, Lesser, "regular", Brilliant Wizard Oil
                         22522 }, -- TBC: Superior Wizard Oil
            duration = DURATION_30M, default = false, onlyUsableFor = BOM_MANA_CLASSES })
                :Category(self.WEAPON_ENCHANTMENT)
  enchants[25122] = { 2623, 2626, 2627, 2628, --Minor, Lesser, "regular", Brilliant Wizard Oil (enchant)
                      2678 }, -- TBC: Superior Wizard Oil (enchant)

  spellDefModule:createAndRegisterBuff(spells, 28898, --Blessed Wizard Oil
          { item     = 23123, isConsumable = true, type = "weapon",
            duration = DURATION_1H, default = false, onlyUsableFor = BOM_MANA_CLASSES })
                :Category(self.WEAPON_ENCHANTMENT)
  enchants[28898] = { 2685 } --Blessed Wizard Oil
end

---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupBattleElixirs(spells, enchants)
  -- Sunwell only
  --tinsert(s, BOM.Class.SpellDef:new(45373, --TBC: Bloodberry Elixir +15 all stats
  --        { item = 34537, isConsumable = true, default = false }))
end

---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupGuardianElixirs(spells, enchants)
  spellDefModule:tbcConsumable(spells, 33726, 28104) --TBC: Elixir of Mastery +15 all stats
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  spellDefModule:tbcConsumable(spells, 28502, 22834) --TBC: Elixir of Major Defense +550 ARMOR
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  spellDefModule:tbcConsumable(spells, 39628, 32068) --TBC: Elixir of Ironskin +30 RESIL
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  spellDefModule:tbcConsumable(spells, 39625, 32062) --TBC: Elixir of Major Fortitude +250 HP and 10 HP/5
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  spellDefModule:tbcConsumable(spells, 39626, 32063) --TBC: Earthen Elixir -20 ALL DMG TAKEN
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  spellDefModule:classicConsumable(spells, 3593, 3825, --Elixir of Fortitude
          nil)
                :Category(self.CLASSIC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  spellDefModule:classicConsumable(spells, 11348, 13445, --Elixir of Superior Defense
          nil)
                :Category(self.CLASSIC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  spellDefModule:classicConsumable(spells, 24361, 20004, --Major Troll's Blood Potion
          nil)
                :Category(self.CLASSIC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  spellDefModule:classicConsumable(spells, 11371, 9088, --Gift of Arthas
          nil)
                :Category(self.CLASSIC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  spellDefModule:classicConsumable(spells, 16326, 12455, --Juju Ember +15FR
          nil)
                :Category(self.CLASSIC_BUFF)

  spellDefModule:classicConsumable(spells, 16325, 12457, --Juju Chill +15FrostR
          nil)
                :Category(self.CLASSIC_BUFF)

  spellDefModule:classicConsumable(spells, 22730, 18254, --Runn Tum Tuber Surprise
          nil)
                :Category(self.CLASSIC_SPELL_FOOD)
  spellDefModule:classicConsumable(spells, 25661, 21023, --Dirge's Kickin' Chimaerok Chops x
          nil)
                :Category(self.CLASSIC_FOOD)
  spellDefModule:classicConsumable(spells, 22790, 18284, --Kreeg's Stout Beatdown
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.CLASSIC_FOOD)
  spellDefModule:classicConsumable(spells, 22789, 18269, --Gordok Green Grog
          nil)
                :Category(self.CLASSIC_FOOD)
  spellDefModule:classicConsumable(spells, 25804, 21151, --Rumsey Rum Black Label
          nil)
                :Category(self.CLASSIC_FOOD)

  spellDefModule:classicConsumable(spells, 17549, 13461, --Greater Arcane Protection Potion
          nil)
                :Category(self.CLASSIC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)
  spellDefModule:classicConsumable(spells, 17543, 13457, --Greater Fire Protection Potion
          nil)
                :Category(self.CLASSIC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)
  spellDefModule:classicConsumable(spells, 17544, 13456, --Greater Frost Protection Potion
          nil)
                :Category(self.CLASSIC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)
  spellDefModule:classicConsumable(spells, 17546, 13458, --Greater Nature Protection Potion
          nil)
                :Category(self.CLASSIC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)
  spellDefModule:classicConsumable(spells, 17548, 13459, --Greater Shadow Protection Potion
          nil)
                :Category(self.CLASSIC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)

  spellDefModule:tbcConsumable(spells, 28536, 22845) --Major Arcane Protection Potion (crafted and cauldron 32840)
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)
  spellDefModule:tbcConsumable(spells, 28511, 22841) --Major Fire Protection Potion (crafted and cauldron 32846)
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)
  spellDefModule:tbcConsumable(spells, 28512, 22842) --Major Frost Protection Potion (crafted and cauldron 32847)
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)
  spellDefModule:tbcConsumable(spells, 28513, 22844) --Major Nature Protection Potion (crafted and cauldron 32844)
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)
  spellDefModule:tbcConsumable(spells, 28537, 22846) --Major Shadow Protection Potion (crafted and cauldron 32845)
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)
  spellDefModule:tbcConsumable(spells, 28538, 22847) --Major Holy Protection Potion (crafted)
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_GUARDIAN)
end

---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupItemSpells(spells, enchants)
  spellDefModule:classicConsumable(spells, 15233, 11564, --Crystal Ward
          nil)
                :Category(self.CLASSIC_BUFF)

  spellDefModule:classicConsumable(spells, 15279, 11567, --Crystal Spire +12 THORNS
          nil)
                :Category(self.CLASSIC_BUFF)

  spellDefModule:classicConsumable(spells, 15231, 11563, --Crystal Force +30 SPI
          nil)
                :Category(self.CLASSIC_BUFF)
end

---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupFood(spells, enchants)
  --
  -- Food (Classic)
  --
  spellDefModule:createAndRegisterBuff(spells, 18192, --Grilled Squid +10 Agility
          { item = 13928, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :Category(self.CLASSIC_PHYS_FOOD)
  spellDefModule:createAndRegisterBuff(spells, 24799, --Smoked Desert Dumplings +Strength
          { item = 20452, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, })
                :Category(self.CLASSIC_PHYS_FOOD)
  spellDefModule:classicConsumable(spells, 18125, 13810, --Blessed Sunfruit +STR
          { playerClass = BOM_MELEE_CLASSES })
                :Category(self.CLASSIC_PHYS_FOOD)

  --
  -- Food (The Burning Crusade)
  --
  spellDefModule:tbcConsumable(spells, 33257, { 33052, 27667 }, --Well Fed +30 STA +20 SPI
          nil, _t("TooltipSimilarFoods"))
                :Category(self.TBC_FOOD)

  spellDefModule:tbcConsumable(spells, 35254, { 27651, 30155, 27662, 33025 }, --Well Fed +20 STA +20 SPI
          nil, _t("TooltipSimilarFoods"))
                :Category(self.TBC_FOOD)
  --BOM.Class.SpellDef:tbc_consumable(spells, 35272, { 27660, 31672, 33026 }) --Well Fed +20 STA +20 SPI

  -- Warp Burger, Grilled Mudfish, ...
  spellDefModule:tbcConsumable(spells, 33261, { 27659, 30358, 27664, 33288, 33293 }, --Well Fed +20 AGI +20 SPI
          { playerClass = BOM_PHYSICAL_CLASSES }, _t("TooltipSimilarFoods"))
                :Category(self.TBC_PHYS_FOOD)

  spellDefModule:tbcConsumable(spells, 43764, 33872, --Spicy Hot Talbuk: Well Fed +20 HITRATING +20 SPI
          { playerClass = BOM_PHYSICAL_CLASSES })
                :Category(self.TBC_PHYS_FOOD)

  spellDefModule:tbcConsumable(spells, 33256, { 27658, 30359 }, -- Well Fed +20 STR +20 SPI
          { playerClass = BOM_MELEE_CLASSES }, _t("TooltipSimilarFoods"))
                :Category(self.TBC_PHYS_FOOD)

  spellDefModule:tbcConsumable(spells, 33259, 27655,
          { playerClass = BOM_PHYSICAL_CLASSES }) --Ravager Dog: Well Fed +40 AP +20 SPI
                :Category(self.TBC_PHYS_FOOD)

  spellDefModule:tbcConsumable(spells, 46899, 35563, --Charred Bear Kabobs +24 AP
          { playerClass = BOM_PHYSICAL_CLASSES })
                :Category(self.TBC_PHYS_FOOD)

  spellDefModule:tbcConsumable(spells, 41030, 32721, --Skyguard Rations: Well Fed +15 STA +15 SPI
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.TBC_FOOD)

  spellDefModule:tbcConsumable(spells, 33263, { 27657, 31673, 27665, 30361 }, --Well Fed +23 SPELL +20 SPI
          { playerClass = BOM_MANA_CLASSES },
          _t("TooltipSimilarFoods"))
                :Category(self.TBC_SPELL_FOOD)

  spellDefModule:tbcConsumable(spells, 33265, 27663, --Blackened Sporefish: Well Fed +8 MP5 +20 STA
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.TBC_SPELL_FOOD)

  spellDefModule:tbcConsumable(spells, 33268, { 27666, 30357 }, --Golden Fish Sticks: Well Fed +44 HEAL +20 SPI
          { playerClass = BOM_MANA_CLASSES },
          _t("TooltipSimilarFoods"))
                :Category(self.TBC_SPELL_FOOD)
end

---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupFlasks(spells, enchants)
  spellDefModule:tbcConsumable(spells, 28540, 22866, --TBC: Flask of Pure Death +80 SHADOW +80 FIRE +80 FROST
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  spellDefModule:tbcConsumable(spells, 28521, 22861, --TBC: Flask of Blinding Light +80 ARC +80 HOLY +80 NATURE
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  spellDefModule:tbcConsumable(spells, 28520, 22854, --TBC: Flask of Relentless Assault +120 AP
          { playerClass = BOM_PHYSICAL_CLASSES })
                :Category(self.TBC_PHYS_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  spellDefModule:tbcConsumable(spells, 28518, 22851) --TBC: Flask of Fortification +500 HP +10 DEF RATING
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  spellDefModule:tbcConsumable(spells, 28519, 22853) --TBC: Flask of Mighty Restoration +25 MP/5
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  spellDefModule:tbcConsumable(spells, 42735, 33208) --TBC: Flask of Chromatic Wonder +35 ALL RESIST +18 ALL STATS
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  --
  -- Shattrath Flasks...
  --
  spellDefModule:tbcConsumable(spells, 46837, 35716, --TBC: Shattrath Flask of Pure Death +80 SHADOW +80 FIRE +80 FROST
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  spellDefModule:tbcConsumable(spells, 46839, 35717, --TBC: Shattrath Flask of Blinding Light +80 ARC +80 HOLY +80 NATURE
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  spellDefModule:tbcConsumable(spells, 41608, 32901, --TBC: Shattrath Flask of Relentless Assault +120 AP
          { playerClass = BOM_PHYSICAL_CLASSES })
                :Category(self.TBC_PHYS_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  spellDefModule:tbcConsumable(spells, 41609, 32898) --TBC: Shattrath Flask of Fortification +500 HP +10 DEF RATING
                :Category(self.TBC_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  spellDefModule:tbcConsumable(spells, 41610, 32899) --TBC: Shattrath Flask of Mighty Restoration +25 MP/5
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  spellDefModule:tbcConsumable(spells, 41611, 32900, --TBC: Shattrath Flask of Supreme Power +70 SPELL
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.TBC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  -- TODO: Unstable Flask of... (Blade's Edge and Gruul's Lair only)

  spellDefModule:classicConsumable(spells, 17628, 13512, --Flask of Supreme Power +70 SPELL
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.CLASSIC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  spellDefModule:classicConsumable(spells, 17626, 13510, --Flask of the Titans +400 HP
          nil)
                :Category(self.CLASSIC_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  spellDefModule:classicConsumable(spells, 17627, 13511, --Flask of Distilled Wisdom +65 INT
          { playerClass = BOM_MANA_CLASSES })
                :Category(self.CLASSIC_SPELL_ELIXIR)
                :ElixirType(self.ELIX_FLASK)

  spellDefModule:classicConsumable(spells, 17629, 13513, --Flask of Chromatic Resistance
          nil)
                :Category(self.CLASSIC_ELIXIR)
                :ElixirType(self.ELIX_FLASK)
end

function allSpellsModule:SetupConstantsCategories()
  self.CLASSIC_PHYS_FOOD = "classicPhysicalFood"
  self.CLASSIC_SPELL_FOOD = "classicSpellFood"
  self.CLASSIC_FOOD = "classicFood"
  self.CLASSIC_PHYS_ELIXIR = "classicPhysElixir"
  self.CLASSIC_PHYS_BUFF = "classicPhysBuff"
  self.CLASSIC_BUFF = "classicBuff"
  self.CLASSIC_SPELL_ELIXIR = "classicSpellElixir"
  self.CLASSIC_ELIXIR = "classicElixir"

  self.TBC_PHYS_FOOD = "tbcPhysicalFood"
  self.TBC_SPELL_FOOD = "tbcSpellFood"
  self.TBC_FOOD = "tbcFood"
  self.TBC_PHYS_ELIXIR = "tbcPhysElixir"
  self.TBC_SPELL_ELIXIR = "tbcSpellElixir"
  self.TBC_ELIXIR = "tbcElixir"

  self.WOTLK_PHYS_FOOD = "wotlkPhysicalFood"
  self.WOTLK_SPELL_FOOD = "wotlkSpellFood"
  self.WOTLK_FOOD = "wotlkFood"
  self.WOTLK_PHYS_ELIXIR = "wotlkPhysElixir"
  self.WOTLK_SPELL_ELIXIR = "wotlkSpellElixir"
  self.WOTLK_ELIXIR = "wotlkElixir"

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

    self.CLASSIC_PHYS_ELIXIR,
    self.CLASSIC_PHYS_BUFF,
    self.CLASSIC_SPELL_ELIXIR,
    self.CLASSIC_ELIXIR,
    self.CLASSIC_BUFF,
    self.CLASSIC_PHYS_FOOD,
    self.CLASSIC_SPELL_FOOD,
    self.CLASSIC_FOOD,

    self.TBC_PHYS_ELIXIR,
    self.TBC_SPELL_ELIXIR,
    self.TBC_ELIXIR,
    self.TBC_PHYS_FOOD,
    self.TBC_SPELL_FOOD,
    self.TBC_FOOD,

    self.WOTLK_PHYS_ELIXIR,
    self.WOTLK_SPELL_ELIXIR,
    self.WOTLK_ELIXIR,
    self.WOTLK_PHYS_FOOD,
    self.WOTLK_SPELL_FOOD,
    self.WOTLK_FOOD,

    self.SCROLL, self.WEAPON_ENCHANTMENT,

    false, -- special value no category
  }
end

function allSpellsModule:SetupConstants()
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
function allSpellsModule:GetBuffCategories()
  local result = {}
  for _i, cat in ipairs(self.buffCategories) do
    if type(cat) == "string" then
      result[cat] = _t("Category_" .. cat)
    end
  end
  return result
end

---@param allBuffs table<number, BomBuffDefinition> Input list of all buffs
---@return table<number, BomBuffDefinition> Filtered list
function allSpellsModule:ApplyPostLimitations(allBuffs)
  -- Apply post-limitations (added with :Limitation() functions on spell construction)
  local result = {}

  for _i, buff in ipairs(allBuffs) do
    if spellDefModule:CheckLimitations(buff, buff.limitations) then
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
function allSpellsModule:SetupSpells()
  local allBuffs = {} ---@type table<number, BomBuffDefinition>
  local enchants = {} ---@type table<number, table<number>>
  self:SetupConstants()

  priestModule:SetupPriestSpells(allBuffs, enchants)
  druidModule:SetupDruidSpells(allBuffs, enchants)
  mageModule:SetupMageSpells(allBuffs, enchants)
  shamanModule:SetupShamanSpells(allBuffs, enchants)
  warlockModule:SetupWarlockSpells(allBuffs, enchants)
  hunterModule:SetupHunterSpells(allBuffs, enchants)
  paladinModule:SetupPaladinSpells(allBuffs, enchants)
  warriorModule:SetupWarriorSpells(allBuffs, enchants)
  rogueModule:SetupRogueSpells(allBuffs, enchants)
  deathknightModule:SetupDeathknightSpells(allBuffs, enchants)

  self:SetupTrackingSpells(allBuffs, enchants)
  self:SetupMiscSpells(allBuffs, enchants)

  self:SetupPhysicalDpsConsumables(allBuffs, enchants)
  self:SetupPhysicalDpsBattleElixirs(allBuffs, enchants)
  self:SetupCasterConsumables(allBuffs, enchants)
  self:SetupCasterBattleElixirs(allBuffs, enchants)
  self:SetupCasterGuardianElixirs(allBuffs, enchants)
  self:SetupBattleElixirs(allBuffs, enchants)
  self:SetupGuardianElixirs(allBuffs, enchants)
  self:SetupFlasks(allBuffs, enchants)

  self:SetupItemSpells(allBuffs, enchants)
  self:SetupFood(allBuffs, enchants)

  allBuffs = self:ApplyPostLimitations(allBuffs) --filter the list and make new shorter list

  --Preload items!
  for x, spell in ipairs(allBuffs) do
    if spell.isConsumable and spell.item then
      BOM.GetItemInfo(spell.item)
    end
  end

  BOM.EnchantToSpell = {}
  for dest, list in pairs(enchants) do
    for i, id in ipairs(list) do
      BOM.EnchantToSpell[id] = dest
    end
  end

  self.allBuffs = allBuffs
  BOM.AllBuffomatBuffs = allBuffs
  BOM.EnchantList = enchants
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
function allSpellsModule:SetupCancelBuffs()
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
      tinsert(s, spellDefModule:New(5118, --Aspect of the Cheetah/of the pack
              { OnlyCombat = true, default = true, singleFamily = { 5118, 13159 } }))
    end

    if (UnitFactionGroup("player")) ~= "Horde" or BOM.IsTBC then
      tinsert(s, spellDefModule:New(1038, --Blessing of Salvation
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
  10250, 22734, -- level 65 drink
  34291, -- level 70 drink
  27089, 43706, 46755, -- level 75 drink
}

---For all spells database load data for spellids and items
function allSpellsModule:LoadItemsAndSpells()
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
