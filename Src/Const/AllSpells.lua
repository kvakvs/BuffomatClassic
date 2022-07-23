local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsModule
---@field buffCategories table<number, string> Category names for buffs
---@field allBuffs table<number, BomSpellDef> All buffs, same as BOM.AllBuffomatSpells for convenience
local allSpellsModule = BuffomatModule.New("AllSpells") ---@type BomAllSpellsModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local itemCacheModule = BuffomatModule.Import("ItemCache") ---@type BomItemCacheModule
local mageModule = BuffomatModule.Import("AllSpellsMage") ---@type BomAllSpellsMageModule
local spellCacheModule = BuffomatModule.Import("SpellCache") ---@type BomSpellCacheModule
local spellDefModule = BuffomatModule.Import("SpellDef") ---@type BomSpellDefModule

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
  if BOM.IsTBC then
    return tbc
  end
  return classic
end

---Add PRIEST spells
---@param spells table<string, BomSpellDef>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupPriestSpells(spells, enchants)
  local priestOnly = { playerClass = "PRIEST" }

  spellDefModule:createAndRegisterBuff(spells, 10938, -- Fortitude / Seelenstärke
          { groupId        = 21562, default = true,
            singleFamily   = { 1243, 1244, 1245, 2791, 10937, 10938, -- Ranks 1-6
                               25389 }, -- TBC: Rank 7
            groupFamily    = { 21562, 21564, -- Ranks 1-2
                               25392 }, -- TBC: Rank 3
            singleDuration = DURATION_30M, groupDuration = DURATION_1H, reagentRequired = { 17028, 17029 },
            targetClasses  = BOM_ALL_CLASSES })
                :Category(self.CLASS)

  BOM.SpellDef_PrayerOfSpirit = function()
    return spellDefModule:New(14819, -- Divine Spirit / Prayer of Spirit / Willenstärke
            { groupId        = 27681, default = true,
              singleFamily   = { 14752, 14818, 14819, 27841, -- Ranks 1-4
                                 25312 }, -- TBC: Rank 5
              groupFamily    = { 27681, -- Rank 1
                                 32999 }, --- TBC: Rank 2
              singleDuration = DURATION_30M, groupDuration = DURATION_1H, reagentRequired = { 17028, 17029 },
              targetClasses  = BOM_MANA_CLASSES })
                         :Category(self.CLASS)
  end
  tinsert(spells, BOM.SpellDef_PrayerOfSpirit())

  spellDefModule:createAndRegisterBuff(spells, 10958, --Shadow Protection / Prayer of Shadow / Schattenschutz
          { groupId         = 27683, default = false, singleDuration = DURATION_10M, groupDuration = 1200,
            singleFamily    = { 976, 10957, 10958, -- Ranks 1-3
                                25433 }, -- TBC: Rank 4
            groupFamily     = { 27683, -- Rank 1
                                39374 }, -- TBC: Rank 2
            reagentRequired = { 17028, 17029 }, targetClasses = BOM_ALL_CLASSES },
          priestOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 6346, -- Fear Ward
          { default = false, singleDuration = DURATION_10M, hasCD = true, targetClasses = BOM_ALL_CLASSES })
                :Category(self.CLASS)

  BOM.SpellDef_PW_Shield = function()
    return spellDefModule:New(10901, -- Power Word: Shield / Powerword:Shild
            { default        = false,
              singleFamily   = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901, -- Ranks 1-10
                                 25217, 25218 }, -- TBC: Ranks 11-12
              singleDuration = 30, hasCD = true, targetClasses = { } })
                         :Category(self.CLASS)
  end
  tinsert(spells, BOM.SpellDef_PW_Shield())

  spellDefModule:createAndRegisterBuff(spells, 19266, -- Touch of Weakness / Berührung der Schwäche
          { default      = true, isOwn = true,
            singleFamily = { 2652, 19261, 19262, 19264, 19265, 19266, -- Ranks 1-6
                             25461 } }, -- TBC: Rank 7
          priestOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 10952, -- Inner Fire / inneres Feuer
          { default      = true, isOwn = true,
            singleFamily = { 588, 7128, 602, 1006, 10951, 10952, -- Ranks 1-6
                             25431 } }, -- TBC: Rank 7
          priestOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 19312, -- Shadowguard
          { default      = true, isOwn = true,
            singleFamily = { 18137, 19308, 19309, 19310, 19311, 19312, -- Ranks 1-6
                             25477 } }, -- TBC: Rank 7
          priestOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 19293, -- Elune's Grace
          { default      = true, isOwn = true,
            singleFamily = { 2651, -- Rank 1 also TBC: The only rank
                             19289, 19291, 19292, 19293 } }, -- Ranks 2-5 (non-TBC)
          priestOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 15473, -- Shadow Form
          { default = false, isOwn = true },
          priestOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 20770, -- Resurrection / Auferstehung
          { cancelForm   = true, type = "resurrection", default = true,
            singleFamily = { 2006, 2010, 10880, 10881, 20770, -- Ranks 1-5
                             25435 } }, -- TBC: Rank 6
          priestOnly)
                :Category(self.CLASS)
end

---Add DRUID spells
---@param spells table<string, BomSpellDef>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupDruidSpells(spells, enchants)
  local druidOnly = { playerClass = "DRUID" }

  spellDefModule:createAndRegisterBuff(spells, 9885, --Gift/Mark of the Wild | Gabe/Mal der Wildniss
          { groupId         = 21849, cancelForm = true, default = true,
            singleFamily    = { 1126, 5232, 6756, 5234, 8907, 9884, 9885, -- Ranks 1-7
                                26990 }, -- TBC: Rank 8
            groupFamily     = { 21849, 21850, -- Ranks 1-2
                                26991 }, -- TBC: Rank 3
            singleDuration  = DURATION_30M, groupDuration = DURATION_1H,
            reagentRequired = { 17021, 17026 }, targetClasses = BOM_ALL_CLASSES },
          druidOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 9910, --Thorns | Dornen
          { cancelForm     = false, default = false,
            singleFamily   = { 467, 782, 1075, 8914, 9756, 9910, -- Ranks 1-6
                               26992 }, -- TBC: Rank 7
            singleDuration = DURATION_10M, targetClasses = BOM_MELEE_CLASSES },
          druidOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 16864, --Omen of Clarity
          { isOwn = true, cancelForm = true, default = true },
          druidOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 17329, -- Nature's Grasp | Griff der Natur
          { isOwn        = true, cancelForm = true, default = false,
            hasCD        = true, requiresOutdoors = true,
            singleFamily = { 16689, 16810, 16811, 16812, 16813, 17329, -- Rank 1-6
                             27009 } }, -- TBC: Rank 7
          druidOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 33891, --TBC: Tree of life
          { isOwn = true, default = true, default = false, singleId = 33891, shapeshiftFormId = 2 },
          { playerClass = "DRUID" })
                :ShowInTBC()
                :Category(self.CLASS)

  -- Special code: This will disable herbalism and mining tracking in Cat Form
  spellDefModule:createAndRegisterBuff(spells, BOM.SpellId.Druid.TrackHumanoids, -- Track Humanoids (Cat Form)
          { type      = "tracking", needForm = CAT_FORM, default = true,
            extraText = _t("SpellLabel_TrackHumanoids") },
          druidOnly)
                :Category(self.TRACKING)
end

---Add SHAMAN spells
---@param spells table<string, BomSpellDef>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupShamanSpells(spells, enchants)
  local duration = tbcOrClassic(DURATION_20M, DURATION_10M)
  local enchant_duration = tbcOrClassic(DURATION_30M, DURATION_5M) -- TBC: Shaman enchants become 30min
  local shamanOnly = { playerClass = "SHAMAN" }

  spellDefModule:createAndRegisterBuff(spells, 16342, --Flametongue Weapon
          { type         = "weapon", isOwn = true, isConsumable = false,
            default      = false, singleDuration = enchant_duration,
            singleFamily = { 8024, 8027, 8030, 16339, 16341, 16342, -- Ranks 1-6
                             25489 } }, -- TBC: Rank 7
          shamanOnly,
          { "shamanEnchant" })
                :Category(self.CLASS)
  enchants[16342] = { 3, 4, 5, 523, 1665, 1666, --Flametongue
                      2634 } --TBC: Flametongue 7

  spellDefModule:createAndRegisterBuff(spells, 16356, --Frostbrand Weapon
          { type         = "weapon", isOwn = true, isConsumable = false,
            default      = false, singleDuration = enchant_duration,
            singleFamily = { 8033, 8038, 10456, 16355, 16356, -- Ranks 1-5
                             25500 } }, -- TBC: Rank 6
          shamanOnly,
          { "shamanEnchant" })
                :Category(self.CLASS)
  enchants[16356] = { 2, 12, 524, 1667, 1668, -- Frostbrand
                      2635 } -- TBC: Frostbrand 6

  spellDefModule:createAndRegisterBuff(spells, 16316, --Rockbiter Weapon
          { type         = "weapon", isOwn = true, isConsumable = false,
            default      = false, singleDuration = enchant_duration,
            singleFamily = { 8017, 8018, 8019, 10399, 16314, 16315, 16316, -- Ranks 1-7
                             25479, 25485 } }, -- TBC: Ranks 8-9
          shamanOnly,
          { "shamanEnchant" })
                :Category(self.CLASS)
  -- Note: in TBC all enchantIds for rockbiter have changed
  enchants[16316] = { 1, 6, 29, 503, 504, 683, 1663, 1664, -- Rockbiter, also 504 some special +80 Rockbiter?
                      3040, -- rockbiter 7
                      3023, 3026, 3028, 3031, 3034, 3037, 3040, -- TBC: Rockbiter 1-7
                      2632, 2633 } -- TBC: Rockbiter 8-9

  spellDefModule:createAndRegisterBuff(spells, 16362, --Windfury Weapon
          { type         = "weapon", isOwn = true, isConsumable = false,
            default      = false, singleDuration = enchant_duration,
            singleFamily = { 8232, 8235, 10486, 16362, -- Ranks 1-4
                             25505 } }, -- TBC: Rank 5
          shamanOnly,
          { "shamanEnchant" })
                :Category(self.CLASS)
  enchants[16362] = { 283, 284, 525, 1669, -- Windfury 1-4
                      2636 } -- TBC: Windfury 5

  spellDefModule:createAndRegisterBuff(spells, 10432, -- Lightning Shield / Blitzschlagschild
          { default      = false, isOwn = true, duration = duration,
            singleFamily = { 324, 325, 905, 945, 8134, 10431, 10432, -- Ranks 1-7
                             25469, 25472 } }, -- TBC: Ranks 8-9
          shamanOnly)
                :Category(self.CLASS)

  spellDefModule:createAndRegisterBuff(spells, 33736, -- TBC: Water Shield 1, 2
          { isOwn = true, default = true, duration = duration, singleFamily = { 24398, 33736 } },
          { playerClass = "SHAMAN" })
                :ShowInTBC()
                :Category(self.CLASS)

  spellDefModule:createAndRegisterBuff(spells, 20777, -- Ancestral Spirit / Auferstehung
          { type         = "resurrection", default = true,
            singleFamily = { 2008, 20609, 20610, 20776, 20777 } },
          shamanOnly)
                :Category(self.CLASS)
end

---Add WARLOCK spells
---@param spells table<string, BomSpellDef>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupWarlockSpells(spells, enchants)
  local warlockOnly = { playerClass = "WARLOCK" }

  spellDefModule:createAndRegisterBuff(spells, 5697, -- Unending Breath
          { default = false, singleDuration = DURATION_10M, targetClasses = BOM_ALL_CLASSES },
          warlockOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 11743, -- Detect Greater Invisibility | Große Unsichtbarkeit entdecken
          { default        = false, singleFamily = { 132, 2970, 11743 },
            singleDuration = DURATION_10M, targetClasses = BOM_ALL_CLASSES },
          warlockOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 28610, -- Shadow Ward / Schattenzauberschutz
          { isOwn = true, default = false, singleFamily = { 6229, 11739, 11740, 28610 } },
          warlockOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 28176, -- TBC: Fel Armor
          { isOwn = true, default = false, singleFamily = { 28176, 28189 } }, -- TBC: Rank 1-2
          { playerClass = "WARLOCK" })
                :ShowInTBC()
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 11735, -- Demon Armor
          { isOwn = true, default = false, singleFamily = { 706, 1086, 11733, 11734, 11735, -- Rank 5
                                                            27260 } }, -- TBC: Rank 6
          warlockOnly)
                :Category(self.CLASS)
  -- Obsolete at level 20, assuming the player will visit the trainer and at 21
  -- the spell will disappear from Buffomat
  spellDefModule:createAndRegisterBuff(spells, 696, -- Demon skin
          { isOwn = true, default = false, singleFamily = { 687, 696 } },
          { playerClass = "WARLOCK", maxLevel = 20 })
                :Category(self.CLASS)

  spellDefModule:createAndRegisterBuff(spells, 17953, -- Firestone
          { isOwn          = true, default = false,
            lockIfHaveItem = { 1254, 13699, 13700, 13701,
                               22128 }, -- TBC: Master Firestone
            singleFamily   = { 6366, 17951, 17952, 17953, -- Rank 1-4
                               27250 } }, -- TBC: Rank 5
          warlockOnly)
                :Category(self.CLASS)

  spellDefModule:createAndRegisterBuff(spells, 17728, -- Spellstone
          { isOwn          = true, default = false,
            lockIfHaveItem = { 5522, 13602, 13603, -- "normal", Greater, Major Spellstone
                               22646 }, -- TBC: Master Spellstone
            singleFamily   = { 2362, 17727, 17728, -- Rank 1-3
                               28172 } }, -- TBC: Rank 4
          warlockOnly)
                :Category(self.CLASS)

  spellDefModule:createAndRegisterBuff(spells, 11730, -- Healtstone
          { isOwn          = true, default = true,
            lockIfHaveItem = { 5512, 19005, 19004, 5511, 19007, 19006, 5509, 19009,
                               19008, 5510, 19011, 19010, 9421, 19013, 19012, -- Healthstones (3 talent ranks)
                               22103, 22104, 22105 }, -- TBC: Master Healthstone (3 talent ranks)
            singleFamily   = { 6201, 6202, 5699, 11729, 11730, -- Rank 1-5
                               27230 } },
          warlockOnly) -- TBC: Rank 6
                :Category(self.CLASS)

  spellDefModule:createAndRegisterBuff(spells, 20757, --Soulstone
          { isOwn          = true, default = true,
            lockIfHaveItem = { 5232, 16892, 16893, 16895, 16896,
                               22116 }, -- TBC: Master Soulstone
            singleFamily   = { 693, 20752, 20755, 20756, 20757, -- Ranks 1-5
                               27238 } },
          warlockOnly) -- TBC: Rank 6
                :Category(self.CLASS)

  spellDefModule:createAndRegisterBuff(spells, 5500, --Sense Demons
          { type = "tracking", default = false },
          warlockOnly)
                :Category(self.TRACKING)

  ------------------------
  -- Pet Management
  ------------------------
  spellDefModule:createAndRegisterBuff(spells, BOM.SpellId.Warlock.DemonicSacrifice, -- Demonic Sacrifice
          { isOwn = true, default = true, requiresWarlockPet = true },
          warlockOnly)
                :Category(self.PET)
  spellDefModule:createAndRegisterBuff(spells, 19028, -- TBC: Soul Link, talent spell 19028, gives buff 25228
          { isOwn              = true, default = true, singleFamily = { 19028, 25228 },
            requiresWarlockPet = true },
          warlockOnly)
                :Category(self.PET)

  spellDefModule:createAndRegisterBuff(spells, 688, --Summon Imp
          { type           = "summon", default = true, isOwn = true,
            creatureFamily = "Imp", creatureType = "Demon", sacrificeAuraIds = { 18789 } },
          warlockOnly)
                :Category(self.PET)

  spellDefModule:createAndRegisterBuff(spells, 697, --Summon Voidwalker
          { type             = "summon", default = false, isOwn = true,
            reagentRequired  = { BOM.ItemId.Warlock.SoulShard },
            creatureFamily   = "Voidwalker", creatureType = "Demon",
            sacrificeAuraIds = { 18790, 1905 } }, -- TBC: Restore 2% hp, and Classic: Shield the warlock
          warlockOnly)
                :Category(self.PET)

  spellDefModule:createAndRegisterBuff(spells, 712, --Summon Succubus
          { type            = "summon", default = false, isOwn = true,
            reagentRequired = { BOM.ItemId.Warlock.SoulShard },
            creatureFamily  = "Succubus", creatureType = "Demon", sacrificeAuraIds = { 18791 } },
          warlockOnly)
                :Category(self.PET)

  spellDefModule:createAndRegisterBuff(spells, 713, --Summon Incubus (TBC)
          { type            = "summon", default = false, isOwn = true,
            reagentRequired = { BOM.ItemId.Warlock.SoulShard },
            creatureFamily  = "Incubus", creatureType = "Demon", sacrificeAuraIds = { 18791 } },
          warlockOnly)
                :Category(self.PET)

  spellDefModule:createAndRegisterBuff(spells, 691, --Summon Felhunter
          { type            = "summon", default = false, isOwn = true,
            reagentRequired = { BOM.ItemId.Warlock.SoulShard },
            creatureFamily  = "Felhunter", creatureType = "Demon", sacrificeAuraIds = { 18792 } },
          warlockOnly)
                :Category(self.PET)

  spellDefModule:createAndRegisterBuff(spells, 30146, --Summon Felguard
          { type            = "summon", default = false, isOwn = true,
            reagentRequired = { BOM.ItemId.Warlock.SoulShard },
            creatureFamily  = "Felguard", creatureType = "Demon", sacrificeAuraIds = { 35701 } },
          warlockOnly)
                :Category(self.PET)
end

---Add HUNTER spells
---@param spells table<string, BomSpellDef>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupHunterSpells(spells, enchants)
  local hunterOnly = { playerClass = "HUNTER" }

  spellDefModule:createAndRegisterBuff(spells, 20906, -- Trueshot Aura
          { isOwn        = true, default = true,
            singleFamily = { 19506, 20905, 20906, -- Ranks 1-3
                             27066 } }, -- TBC: Rank 4
          hunterOnly)
                :Category(self.AURA)

  spellDefModule:createAndRegisterBuff(spells, 25296, --Aspect of the Hawk
          { type         = "aura", default = true,
            singleFamily = { 13165, 14318, 14319, 14320, 14321, 14322, 25296, -- Rank 1-7
                             27044 } }, -- TBC: Rank 8
          hunterOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 13163, --Aspect of the monkey
          { type = "aura", default = false },
          hunterOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 34074, -- TBC: Aspect of the Viper
          { type = "aura", default = false },
          { playerClass = "HUNTER" })
                :ShowInTBC()
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 20190, --Aspect of the wild
          { type         = "aura", default = false,
            singleFamily = { 20043, 20190, -- Ranks 1-2
                             27045 } }, -- TBC: Rank 3
          hunterOnly)
                :Category(self.AURA)
  spellDefModule:createAndRegisterBuff(spells, 5118, --Aspect of the Cheetah
          { type = "aura", default = false }, hunterOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 13159, --Aspect of the pack
          { type = "aura", default = false }, hunterOnly)
                :Category(self.AURA)
  spellDefModule:createAndRegisterBuff(spells, 13161, -- Aspect of the beast
          { type = "aura", default = false }, hunterOnly)
                :Category(self.CLASS)

  spellDefModule:createAndRegisterBuff(spells, 1494, -- Track Beast
          { type = "tracking", default = false }, hunterOnly)
                :Category(self.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19878, -- Track Demon
          { type = "tracking", default = false }, hunterOnly)
                :Category(self.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19879, -- Track Dragonkin
          { type = "tracking", default = false }, hunterOnly)
                :Category(self.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19880, -- Track Elemental
          { type = "tracking", default = false }, hunterOnly)
                :Category(self.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19883, -- Track Humanoids
          { type = "tracking", default = false }, hunterOnly)
                :Category(self.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19882, -- Track Giants / riesen
          { type = "tracking", default = false }, hunterOnly)
                :Category(self.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19884, -- Track Undead
          { type = "tracking", default = false }, hunterOnly)
                :Category(self.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19885, -- Track Hidden / verborgenes
          { type = "tracking", default = false }, hunterOnly)
                :Category(self.TRACKING)

  -- TODO: Do not use tbc_consumable function, add new flags for pet-buff
  spellDefModule:tbcConsumable(spells, 43771, 33874,
          hunterOnly, "Pet buff +Str",
          { tbcHunterPetBuff = true }) --TBC: Kibler's Bits +20 STR/20 SPI for hunter pet
                :Category(self.PET)
  spellDefModule:tbcConsumable(spells, 33272, 27656,
          hunterOnly, "Pet buff +Stamina",
          { tbcHunterPetBuff = true }) --TBC: Sporeling Snack +20 STAM/20 SPI for hunter pet
                :Category(self.PET)
end

---Add PALADIN spells
---@param spells table<string, BomSpellDef>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupPaladinSpells(spells, enchants)
  local paladinOnly = { playerClass = "PALADIN" }

  spellDefModule:createAndRegisterBuff(spells, 25780, --Righteous Fury, same in TBC
          { isOwn = true, default = false })
                :Category(self.CLASS)

  local blessing_duration = tbcOrClassic(DURATION_10M, DURATION_5M)
  local greater_blessing_duration = tbcOrClassic(DURATION_15M, DURATION_30M)

  --
  -- LESSER BLESSINGS

  spellDefModule:createAndRegisterBuff(spells, 20217, --Blessing of Kings
          { groupFamily    = { 25898 }, isBlessing = true, default = false,
            singleDuration = blessing_duration,
            targetClasses  = { "MAGE", "HUNTER", "WARLOCK" } },
          paladinOnly)
                :IgnoreIfHaveBuff(25898) -- Greater Kings
                :Category(self.BLESSING)

  spellDefModule:createAndRegisterBuff(spells, 19979, -- Blessing of Light
          { singleFamily   = { 19977, 19978, 19979, -- Ranks 1-3
                               27144 }, -- TBC: Rank 4
            isBlessing     = true, default = false,
            singleDuration = blessing_duration, groupDuration = greater_blessing_duration,
            targetClasses  = BOM_NO_CLASS },
          paladinOnly)
                :IgnoreIfHaveBuff(21177) -- Greater Light
                :Category(self.BLESSING)

  spellDefModule:createAndRegisterBuff(spells, 25291, --Blessing of Might
          { isBlessing     = true, default = true,
            singleFamily   = { 19740, 19834, 19835, 19836, 19837, 19838, 25291, -- Ranks 1-7
                               27140 }, -- TBC: Rank 8
            singleDuration = blessing_duration, targetClasses = BOM_PHYSICAL_CLASSES }, paladinOnly)
                :IgnoreIfHaveBuff(25782) -- Greater Might
                :IgnoreIfHaveBuff(25916) -- Greater Might
                :IgnoreIfHaveBuff(27141) -- Greater Might
                :Category(self.BLESSING)

  spellDefModule:createAndRegisterBuff(spells, 1038, --Blessing of Salvation
          { isBlessing    = true, default = false, singleDuration = blessing_duration,
            targetClasses = BOM_NO_CLASS, },
          paladinOnly)
                :IgnoreIfHaveBuff(25895) -- Greater Salv
                :Category(self.BLESSING)

  spellDefModule:createAndRegisterBuff(spells, 25290, --Blessing of Wisdom
          { isBlessing     = true, default = false,
            singleFamily   = { 19742, 19850, 19852, 19853, 19854, 25290, -- Ranks 1-6
                               27142 }, -- TBC: Rank 7
            singleDuration = blessing_duration, groupDuration = greater_blessing_duration,
            targetClasses  = { "DRUID", "SHAMAN", "PRIEST", "PALADIN" } },
          paladinOnly)
                :Category(self.BLESSING)

  spellDefModule:createAndRegisterBuff(spells, 20914, --Blessing of Sanctuary
          { isBlessing      = true, default = false,
            singleFamily    = { 20911, 20912, 20913, 20914, -- Ranks 1-4
                                27168 }, -- TBC: Rank 5
            reagentRequired = { BOM.ItemId.Paladin.SymbolOfKings },
            singleDuration  = blessing_duration, groupDuration = greater_blessing_duration,
            targetClasses   = BOM_NO_CLASS },
          paladinOnly)
                :Category(self.BLESSING)
  --
  -- GREATER BLESSINGS
  --
  spellDefModule:createAndRegisterBuff(spells, 25898, --Greater Blessing of Kings
          { isBlessing      = true, default = true, singleDuration = greater_blessing_duration,
            reagentRequired = { BOM.ItemId.Paladin.SymbolOfKings },
            targetClasses   = { "MAGE", "HUNTER", "WARLOCK" }, },
          paladinOnly)
                :Category(self.BLESSING)

  spellDefModule:createAndRegisterBuff(spells, 25890, -- Greater Blessing of Light
          { singleFamily    = { 25890, -- Greater Rank 1
                                27145 }, -- TBC: Greater Rank 2
            isBlessing      = true, default = false,
            reagentRequired = { BOM.ItemId.Paladin.SymbolOfKings }, singleDuration = greater_blessing_duration,
            targetClasses   = BOM_NO_CLASS },
          paladinOnly)
                :Category(self.BLESSING)

  spellDefModule:createAndRegisterBuff(spells, 25916, --Greater Blessing of Might
          { isBlessing      = true, default = false,
            singleFamily    = { 25782, 25916, -- Greater Ranks 1-2
                                27141 }, -- TBC: Greater Rank 3
            singleDuration  = greater_blessing_duration,
            reagentRequired = { BOM.ItemId.Paladin.SymbolOfKings },
            targetClasses   = { "WARRIOR", "ROGUE" } },
          paladinOnly)
                :Category(self.BLESSING)

  spellDefModule:createAndRegisterBuff(spells, 25895, --Greater Blessing of Salvation
          { singleFamily    = { 25895 }, isBlessing = true, default = false,
            singleDuration  = greater_blessing_duration,
            reagentRequired = { BOM.ItemId.Paladin.SymbolOfKings },
            targetClasses   = BOM_NO_CLASS },
          paladinOnly)
                :Category(self.BLESSING)

  spellDefModule:createAndRegisterBuff(spells, 25918, --Greater Blessing of Wisdom
          { isBlessing      = true, default = false,
            singleFamily    = { 25894, 25918, -- Greater Ranks 1-2
                                27143 }, -- TBC: Greater Rank 3
            singleDuration  = greater_blessing_duration,
            reagentRequired = { BOM.ItemId.Paladin.SymbolOfKings },
            targetClasses   = { "DRUID", "SHAMAN", "PRIEST", "PALADIN" } },
          paladinOnly)
                :Category(self.BLESSING)

  spellDefModule:createAndRegisterBuff(spells, 25899, --Greater Blessing of Sanctuary
          { isBlessing      = true, default = false,
            singleFamily    = { 25899, -- Greater Rank 1
                                27169 }, -- TBC: Greater Rank 2
            singleDuration  = greater_blessing_duration,
            reagentRequired = { BOM.ItemId.Paladin.SymbolOfKings },
            targetClasses   = BOM_NO_CLASS },
          paladinOnly)
                :Category(self.BLESSING)

  -- END blessings ------
  --
  -- ----------------------------------
  --
  spellDefModule:createAndRegisterBuff(spells, 10293, -- Devotion Aura
          { type         = "aura", default = false,
            singleFamily = { 465, 10290, 643, 10291, 1032, 10292, 10293, -- Rank 1-7
                             27149 } }, -- TBC: Rank 8
          paladinOnly)
                :Category(self.AURA)
  spellDefModule:createAndRegisterBuff(spells, 10301, -- Retribution Aura
          { type         = "aura", default = true,
            singleFamily = { 7294, 10298, 10299, 10300, 10301, -- Ranks 1-5
                             27150 } }, -- TBC: Rank 6
          paladinOnly)
                :Category(self.AURA)
  spellDefModule:createAndRegisterBuff(spells, 19746, --Concentration Aura
          { type = "aura", default = false },
          paladinOnly)
                :Category(self.AURA)
  spellDefModule:createAndRegisterBuff(spells, 19896, -- Shadow Resistance Aura
          { type = "aura", default = false, singleFamily = { 19876, 19895, 19896, -- Rank 1-3
                                                             27151 } }, -- TBC: Rank 4
          paladinOnly)
                :Category(self.AURA)
  spellDefModule:createAndRegisterBuff(spells, 19898, -- Frost Resistance Aura
          { type = "aura", default = false, singleFamily = { 19888, 19897, 19898, -- Rank 1-3
                                                             27152 } }, -- TBC: Rank 4
          paladinOnly)
                :Category(self.AURA)
  spellDefModule:createAndRegisterBuff(spells, 19900, -- Fire Resistance Aura
          { type = "aura", default = false, singleFamily = { 19891, 19899, 19900, -- Rank 1-3
                                                             27153 } }, -- TBC: Rank 4
          paladinOnly)
                :Category(self.AURA)
  spellDefModule:createAndRegisterBuff(spells, 20218, --Sanctity Aura
          { type = "aura", default = false },
          paladinOnly)
                :Category(self.AURA)

  BOM.CrusaderAuraSpell = spellDefModule:createAndRegisterBuff(
          spells, BOM.SpellId.Paladin.CrusaderAura, --TBC: Crusader Aura
          { type       = "aura", default = false, extraText = _t("CRUSADER_AURA_COMMENT"),
            singleMana = 0 },
          paladinOnly)
                                        :Category(self.AURA)

  --
  -- ----------------------------------
  --
  spellDefModule:createAndRegisterBuff(spells, 20773, -- Redemption / Auferstehung
          { type = "resurrection", default = true, singleFamily = { 7328, 10322, 10324, 20772, 20773 } }, paladinOnly)
                :Category(self.CLASS)

  spellDefModule:createAndRegisterBuff(spells, 20164, -- Sanctity seal
          { type = "seal", default = false }, paladinOnly)
                :Category(self.SEAL) -- classic only

  spellDefModule:createAndRegisterBuff(spells, 5502, -- Sense undead
          { type = "tracking", default = false }, paladinOnly)
                :Category(self.TRACKING)

  spellDefModule:createAndRegisterBuff(spells, 20165, -- Seal of Light
          { type         = "seal", default = false,
            singleFamily = { 20165, 20347, 20348, 20349, -- Ranks 1-4
                             27160 } }, -- TBC: Rank 5
          paladinOnly)
                :Category(self.SEAL)
  spellDefModule:createAndRegisterBuff(spells, 20154, -- Seal of Righteousness
          { type         = "seal", default = false,
            singleFamily = { 20154, 20287, 20288, 20289, 20290, 20291, 20292, 20293, -- Ranks 1-8
                             27155 } }, -- TBC: Seal rank 9
          paladinOnly)
                :Category(self.SEAL)
  spellDefModule:createAndRegisterBuff(spells, 20166, -- Seal of Wisdom
          { type = "seal", default = false },
          paladinOnly)
                :Category(self.SEAL)
  spellDefModule:createAndRegisterBuff(spells, 348704, -- TBC: Seal of Vengeance
          { type         = "seal", default = false,
            singleFamily = { 31801, -- TBC: level 70 spell for Blood Elf
                             348704 } }, -- TBC: Base spell for the alliance races
          paladinOnly)
                :Category(self.SEAL)
  spellDefModule:createAndRegisterBuff(spells, 348700, -- TBC: Seal of the Martyr (Draenei, Dwarf, Human)
          { type = "seal", default = false },
          paladinOnly)
                :Category(self.SEAL)
  spellDefModule:createAndRegisterBuff(spells, 31892, -- TBC: Seal of Blood
          { type         = "seal", default = false,
            singleFamily = { 31892, -- TBC: Base Blood Elf spell
                             38008 } }, -- TBC: Alliance version???
          paladinOnly)
                :Category(self.SEAL)
end

---Add WARRIOR spells
function allSpellsModule:SetupWarriorSpells(spells, enchants)
  local warriorOnly = { playerClass = "WARRIOR" }

  spellDefModule:createAndRegisterBuff(spells, 25289, --Battle Shout
          { isOwn        = true, default = true, default = false,
            singleFamily = { 6673, 5242, 6192, 11549, 11550, 11551, 25289, -- Ranks 1-7
                             2048 } }, -- TBC: Rank 8
          warriorOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 2457, --Battle Stance
          { isOwn = true, default = true, default = false, singleId = 2457, shapeshiftFormId = 17 },
          warriorOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 71, --Defensive Stance
          { isOwn = true, default = true, default = false, singleId = 71, shapeshiftFormId = 18 },
          warriorOnly)
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 2458, --Berserker Stance
          { isOwn = true, default = true, default = false, singleId = 2458, shapeshiftFormId = 19 },
          warriorOnly)
                :Category(self.CLASS)
end

---Add ROGUE spells
---@param spells table<string, BomSpellDef>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupRogueSpells(spells, enchants)
  local duration = tbcOrClassic(DURATION_1H, DURATION_30M) -- TBC: Poisons become 1 hour

  spellDefModule:createAndRegisterBuff(spells, 25351, --Deadly Poison
          { item         = tbcOrClassic(22054, 20844),
            items        = { 22054, 22053, -- TBC: Deadly Poison
                             20844, 8985, 8984, 2893, 2892 },
            isConsumable = true, type = "weapon", duration = duration, default = false },
          { playerClass = "ROGUE", minLevel = 2 })
                :Category(self.CLASS)
  enchants[25351] = { 2643, 2642, -- TBC: Deadly Poison
                      2630, 627, 626, 8, 7 } --Deadly Poison

  spellDefModule:createAndRegisterBuff(spells, 11399, --Mind-numbing Poison
          { item     = 9186, items = { 9186, 6951, 5237 }, isConsumable = true, type = "weapon",
            duration = duration, default = false },
          { playerClass = "ROGUE", minLevel = 24 })
                :Category(self.CLASS)
  enchants[11399] = { 643, 23, 35 } --Mind-numbing Poison

  spellDefModule:createAndRegisterBuff(spells, 11340, --Instant Poison
          { item         = tbcOrClassic(21927, 8928),
            items        = { 21927, -- TBC: Instant Poison
                             8928, 8927, 8926, 6950, 6949, 6947 },
            isConsumable = true, type = "weapon", duration = duration, default = false },
          { playerClass = "ROGUE", minLevel = 20 })
                :Category(self.CLASS)
  enchants[11340] = { 2641, -- TBC: Instant Poison
                      625, 624, 623, 325, 324, 323 } --Instant Poison

  spellDefModule:createAndRegisterBuff(spells, 13227, --Wound Poison
          { item         = tbcOrClassic(22055, 10922),
            items        = { 22055, -- TBC: Wound Poison
                             10922, 10921, 10920, 10918 },
            isConsumable = true, type = "weapon", duration = duration, default = false },
          { playerClass = "ROGUE", minLevel = 32 })
                :Category(self.CLASS)
  enchants[13227] = { 2644, -- TBC: Wound Poison
                      706, 705, 704, 703 } --Wound Poison

  spellDefModule:createAndRegisterBuff(spells, 11202, --Crippling Poison
          { item     = 3776, items = { 3776, 3775 }, isConsumable = true, type = "weapon",
            duration = duration, default = false },
          { playerClass = "ROGUE", minLevel = 20 })
                :Category(self.CLASS)
  enchants[11202] = { 603, 22 } --Crippling Poison

  spellDefModule:createAndRegisterBuff(spells, 26785, --TBC: Anesthetic Poison
          { item         = 21835, items = { 21835 },
            isConsumable = true, type = "weapon", duration = duration, default = false },
          { playerClass = "ROGUE", minLevel = 68 })
                :ShowInTBC()
                :Category(self.CLASS)
  enchants[26785] = { 2640, } --TBC: Anesthetic Poison
end

---Add RESOURCE TRACKING spells
---@param spells table<string, BomSpellDef>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupTrackingSpells(spells, enchants)
  tinsert(spells,
          spellDefModule:New(BOM.SpellId.FindHerbs, -- Find Herbs / kräuter
                  { type = "tracking", default = true })
                        :Category(self.TRACKING)
  )
  tinsert(spells,
          spellDefModule:New(BOM.SpellId.FindMinerals, -- Find Minerals / erz
                  { type = "tracking", default = true })
                        :Category(self.TRACKING)
  )
  tinsert(spells,
          spellDefModule:New(2481, -- Find Treasure / Schatzsuche / Zwerge
                  { type = "tracking", default = true })
                        :Category(self.TRACKING)
  )
  tinsert(spells,
          spellDefModule:New(43308, -- Find Fish (TBC daily quest reward)
                  { type = "tracking", default = false })
                        :Category(self.TRACKING)
  )

  return spells
end

---MISC spells applicable to every class
---@param spells table<string, BomSpellDef>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupMiscSpells(spells, enchants)
  return spells
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, BomSpellDef>
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
---@param spells table<string, BomSpellDef>
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
---@param spells table<string, BomSpellDef>
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
---@param spells table<string, BomSpellDef>
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

---@param spells table<string, BomSpellDef>
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

---@param spells table<string, BomSpellDef>
---@param enchants table<string, table<number>>
function allSpellsModule:SetupBattleElixirs(spells, enchants)
  -- Sunwell only
  --tinsert(s, BOM.Class.SpellDef:new(45373, --TBC: Bloodberry Elixir +15 all stats
  --        { item = 34537, isConsumable = true, default = false }))
end

---@param spells table<string, BomSpellDef>
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

---@param spells table<string, BomSpellDef>
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

---@param spells table<string, BomSpellDef>
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

---@param spells table<string, BomSpellDef>
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

  -- Categories ordered for display
  self.buffCategories = {
    self.CLASS, self.BLESSING, self.AURA, self.PET, self.TRACKING, self.SEAL,

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

---All spells known to Buffomat
---Note: you can add your own spell in the "WTF\Account\<accountname>\SavedVariables\buffOmat.lua"
---table CustomSpells
---@return table<number, BomSpellDef> All known spells table (all spells to be scanned)
function allSpellsModule:SetupSpells()
  local spells = {} ---@type table<number, BomSpellDef>
  local enchants = {} ---@type table<number, table<number>>
  self:SetupConstants()

  self:SetupPriestSpells(spells, enchants)
  self:SetupDruidSpells(spells, enchants)
  mageModule:SetupMageSpells(spells, enchants)
  self:SetupShamanSpells(spells, enchants)
  self:SetupWarlockSpells(spells, enchants)
  self:SetupHunterSpells(spells, enchants)
  self:SetupPaladinSpells(spells, enchants)
  self:SetupWarriorSpells(spells, enchants)
  self:SetupRogueSpells(spells, enchants)

  self:SetupTrackingSpells(spells, enchants)
  self:SetupMiscSpells(spells, enchants)

  self:SetupPhysicalDpsConsumables(spells, enchants)
  self:SetupPhysicalDpsBattleElixirs(spells, enchants)
  self:SetupCasterConsumables(spells, enchants)
  self:SetupCasterBattleElixirs(spells, enchants)
  self:SetupCasterGuardianElixirs(spells, enchants)
  self:SetupBattleElixirs(spells, enchants)
  self:SetupGuardianElixirs(spells, enchants)
  self:SetupFlasks(spells, enchants)

  self:SetupItemSpells(spells, enchants)
  self:SetupFood(spells, enchants)

  --Preload items!
  for x, spell in ipairs(spells) do
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

  self.allBuffs = spells
  BOM.AllBuffomatSpells = spells
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

---@return table<number, BomSpellDef>
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
  for _id, buffDef in pairs(BOM.AllBuffomatSpells) do
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
