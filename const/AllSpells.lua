---@type BuffomatAddon
local TOCNAME, BOM = ...

local BOM_ALL_CLASSES = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "PRIEST", "WARLOCK",
                          "SHAMAN", "PALADIN" }

---Classes which have a resurrection ability
local BOM_RESURRECT_CLASSES = { "SHAMAN", "PRIEST", "PALADIN" }
BOM.RESURRECT_CLASS = BOM_RESURRECT_CLASSES --used in BomScan.lua

---Classes which have mana bar
local BOM_MANA_CLASSES = { "HUNTER", "WARLOCK", "MAGE", "DRUID", "SHAMAN", "PRIEST", "PALADIN" }
BOM.MANA_CLASSES = BOM_MANA_CLASSES --used in BomScan.lua

local BOM_MELEE_CLASSES = { "WARRIOR", "ROGUE", "DRUID", "SHAMAN", "PALADIN" }
local BOM_SHADOW_CLASSES = { "PRIEST", "WARLOCK" }
local BOM_FIRE_CLASSES = { "MAGE", "WARLOCK", "SHAMAN", "HUNTER" }
local BOM_FROST_CLASSES = { "MAGE", "SHAMAN" }
local BOM_PHYSICAL_CLASSES = { "HUNTER", "ROGUE", "SHAMAN", "WARRIOR", "DRUID" }

local DURATION_1H = 3600
local DURATION_30M = 1800
local DURATION_20M = 1200
local DURATION_15M = 900
local DURATION_10M = 600
local DURATION_5M = 300

--- From 2 choices return TBC if BOM.TBC is true, otherwise return classic
local function tbc_or_classic(tbc, classic)
  if BOM.TBC then
    return tbc
  end
  return classic
end

---Add PRIEST spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_priest_spells(spells, enchants)
  tinsert(spells, BOM.Class.SpellDef:new(10938, -- Fortitude / Seelenstärke
          { groupId        = 21562, default = true,
            singleFamily   = { 1243, 1244, 1245, 2791, 10937, 10938, -- Ranks 1-6
                               25389 }, -- TBC: Rank 7
            groupFamily    = { 21562, 21564, -- Ranks 1-2
                               25392 }, -- TBC: Rank 3
            singleDuration = DURATION_30M, groupDuration = DURATION_1H, reagentRequired = { 17028, 17029 },
            classes        = BOM_ALL_CLASSES }))

  BOM.SpellDef_PrayerOfSpirit = function()
    return BOM.Class.SpellDef:new(14819, -- Divine Spirit / Prayer of Spirit / Willenstärke
            { groupId        = 27681, default = true,
              singleFamily   = { 14752, 14818, 14819, 27841, -- Ranks 1-4
                                 25312 }, -- TBC: Rank 5
              groupFamily    = { 27681, -- Rank 1
                                 32999 }, --- TBC: Rank 2
              singleDuration = DURATION_30M, groupDuration = DURATION_1H, reagentRequired = { 17028, 17029 },
              classes        = BOM_MANA_CLASSES })
  end
  tinsert(spells, BOM.SpellDef_PrayerOfSpirit())

  tinsert(spells, BOM.Class.SpellDef:new(10958, --Shadow Protection / Prayer of Shadow / Schattenschutz
          { groupId         = 27683, default = false, singleDuration = DURATION_10M, groupDuration = 1200,
            singleFamily    = { 976, 10957, 10958, -- Ranks 1-3
                                25433 }, -- TBC: Rank 4
            groupFamily     = { 27683, -- Rank 1
                                39374 }, -- TBC: Rank 2
            reagentRequired = { 17028, 17029 }, classes = BOM_ALL_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(6346, -- Fear Ward
          { default = false, singleDuration = DURATION_10M, hasCD = true, classes = BOM_ALL_CLASSES }))

  BOM.SpellDef_PW_Shield = function()
    return BOM.Class.SpellDef:new(10901, -- Power Word: Shield / Powerword:Shild
            { default        = false,
              singleFamily   = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901, -- Ranks 1-10
                                 25217, 25218 }, -- TBC: Ranks 11-12
              singleDuration = 30, hasCD = true, classes = { } })
  end
  tinsert(spells, BOM.SpellDef_PW_Shield())

  tinsert(spells, BOM.Class.SpellDef:new(19266, -- Touch of Weakness / Berührung der Schwäche
          { default      = true, isOwn = true,
            singleFamily = { 2652, 19261, 19262, 19264, 19265, 19266, -- Ranks 1-6
                             25461 } })) -- TBC: Rank 7
  tinsert(spells, BOM.Class.SpellDef:new(10952, -- Inner Fire / inneres Feuer
          { default      = true, isOwn = true,
            singleFamily = { 588, 7128, 602, 1006, 10951, 10952, -- Ranks 1-6
                             25431 } })) -- TBC: Rank 7
  tinsert(spells, BOM.Class.SpellDef:new(19312, -- Shadowguard
          { default      = true, isOwn = true,
            singleFamily = { 18137, 19308, 19309, 19310, 19311, 19312, -- Ranks 1-6
                             25477 } })) -- TBC: Rank 7
  tinsert(spells, BOM.Class.SpellDef:new(19293, -- Elune's Grace
          { default      = true, isOwn = true,
            singleFamily = { 2651, -- Rank 1 also TBC: The only rank
                             19289, 19291, 19292, 19293 } })) -- Ranks 2-5 (non-TBC)
  tinsert(spells, BOM.Class.SpellDef:new(15473, -- Shadow Form
          { default = false, isOwn = true }))
  tinsert(spells, BOM.Class.SpellDef:new(20770, -- Resurrection / Auferstehung
          { cancelForm   = true, type = "resurrection", default = true,
            singleFamily = { 2006, 2010, 10880, 10881, 20770, -- Ranks 1-5
                             25435 } })) -- TBC: Rank 6
end

---Add DRUID spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_druid_spells(spells, enchants)
  tinsert(spells, BOM.Class.SpellDef:new(9885, --Gift/Mark of the Wild | Gabe/Mal der Wildniss
          { groupId         = 21849, cancelForm = true, default = true,
            singleFamily    = { 1126, 5232, 6756, 5234, 8907, 9884, 9885, -- Ranks 1-7
                                26990 }, -- TBC: Rank 8
            groupFamily     = { 21849, 21850, -- Ranks 1-2
                                26991 }, -- TBC: Rank 3
            singleDuration  = DURATION_30M, groupDuration = DURATION_1H,
            reagentRequired = { 17021, 17026 }, classes = BOM_ALL_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(9910, --Thorns | Dornen
          { cancelForm     = true, default = false,
            singleFamily   = { 467, 782, 1075, 8914, 9756, 9910, -- Ranks 1-6
                               26992 }, -- TBC: Rank 7
            singleDuration = DURATION_10M, classes = BOM_MELEE_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(16864, --omen of clarity
          { isOwn = true, cancelForm = true, default = true }))
  tinsert(spells, BOM.Class.SpellDef:new(17329, -- Nature's Grasp | Griff der Natur
          { isOwn        = true, cancelForm = true, default = false,
            hasCD        = true, requiresOutdoors = true,
            singleFamily = { 16689, 16810, 16811, 16812, 16813, 17329, -- Rank 1-6
                             27009 } })) -- TBC: Rank 7
  if BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(33891, --TBC: Tree of life
            { isOwn = true, default = true, default = false, singleId = 33891, shapeshiftFormId = 2 }))
  end

  tinsert(spells, BOM.Class.SpellDef:new(5225, -- Track Humanoids (Cat Form)
          { type = "tracking", needForm = CAT_FORM, default = true }))
end

---Add MAGE spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_mage_spells(spells, enchants)
  --{singleId=10938, isOwn=true, default=true, lockIfHaveItem={BOM.ItemId.Mage.ManaRuby}}, -- manastone/debug
  BOM.SpellDef_ArcaneIntelligence = function()
    return BOM.Class.SpellDef:new(10157, --Arcane Intellect | Brilliance
            { singleFamily    = { 1459, 1460, 1461, 10156, 10157, -- Ranks 1-5
                                  27126 }, -- TBC: Rank 6
              groupFamily     = { 23028, -- Brilliance Rank 1
                                  27127 }, -- TBC: Brillance Rank 2
              default         = true, singleDuration = DURATION_30M, groupDuration = DURATION_1H,
              reagentRequired = { 17020 }, classes = BOM_MANA_CLASSES })
  end
  tinsert(spells, BOM.SpellDef_ArcaneIntelligence())

  tinsert(spells, BOM.Class.SpellDef:new(10174, --Dampen Magic
          { default      = false, singleDuration = DURATION_10M, classes = { },
            singleFamily = { 604, 8450, 8451, 10173, 10174, -- Ranks 1-5
                             33944 } })) -- TBC: Rank 6
  tinsert(spells, BOM.Class.SpellDef:new(10170, --Amplify Magic
          { default      = false, singleDuration = DURATION_10M, classes = { },
            singleFamily = { 1008, 8455, 10169, 10170, -- Ranks 1-4
                             27130, 33946 } })) -- TBC: Ranks 5-6
  tinsert(spells, BOM.Class.SpellDef:new(10220, -- Ice Armor / eisrüstung
          { type         = "seal", default = false,
            singleFamily = { 7302, 7320, 10219, 10220, -- Ranks 1-4, levels 30 40 50 60
                             27124 } })) -- TBC: Rank 5, level 69
  tinsert(spells, BOM.Class.SpellDef:new(7301, -- Frost Armor / frostrüstung
          { type         = "seal", default = false,
            singleFamily = { 168, 7300, 7301 } })) -- Ranks 1-3, Levels 1, 10, 20
  tinsert(spells, BOM.Class.SpellDef:new(30482, -- TBC: Molten Armor
          { type = "seal", default = false, singleFamily = { 30482 } })) -- TBC: Rank 1
  tinsert(spells, BOM.Class.SpellDef:new(22783, -- Mage Armor / magische rüstung
          { type         = "seal", default = false,
            singleFamily = { 6117, 22782, 22783, -- Ranks 1-3
                             27125 } })) -- TBC: Rank 4
  tinsert(spells, BOM.Class.SpellDef:new(10193, --Mana Shield | Manaschild - unabhängig von allen.
          { isOwn        = true, default = false, singleDuration = 60,
            singleFamily = { 1463, 8494, 8495, 10191, 10192, 10193, -- Ranks 1-6
                             27131 } })) -- TBC: Rank 7
  tinsert(spells, BOM.Class.SpellDef:new(13033, --Ice Barrier
          { isOwn        = true, default = false, singleDuration = 60,
            singleFamily = { 11426, 13031, 13032, 13033, -- Ranks 1-4
                             27134, 33405 } })) -- TBC: Ranks 5-6

  if UnitLevel("player") >= 58 then
    -- Conjure separate mana gems of 3 kinds
    tinsert(spells, BOM.Class.SpellDef:conjure_item(BOM.SpellId.Mage.ConjureManaEmerald, BOM.ItemId.Mage.ManaEmerald))
    tinsert(spells, BOM.Class.SpellDef:conjure_item(BOM.SpellId.Mage.ConjureManaRuby, BOM.ItemId.Mage.ManaRuby))
    if UnitLevel("player") < 68 then
      -- Players > 68 will not be interested in Citrine
      tinsert(spells, BOM.Class.SpellDef:conjure_item(BOM.SpellId.Mage.ConjureManaCitrine, BOM.ItemId.Mage.ManaCitrine))
    end
  else
    -- For < 58 - Have generic conjuration of 1 gem (only max rank)
    tinsert(spells, BOM.Class.SpellDef:new(BOM.SpellId.Mage.ConjureManaEmerald, -- Conjure Mana Stone (Max Rank)
            { isOwn          = true, default = true,
              lockIfHaveItem = { BOM.ItemId.Mage.ManaAgate,
                                 BOM.ItemId.Mage.ManaJade,
                                 BOM.ItemId.Mage.ManaCitrine,
                                 BOM.ItemId.Mage.ManaRuby,
                                 BOM.ItemId.Mage.ManaEmerald },
              singleFamily   = { BOM.SpellId.Mage.ConjureManaAgate,
                                 BOM.SpellId.Mage.ConjureManaJade,
                                 BOM.SpellId.Mage.ConjureManaCitrine,
                                 BOM.SpellId.Mage.ConjureManaRuby,
                                 BOM.SpellId.Mage.ConjureManaEmerald } }))
  end
end

---Add SHAMAN spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_shaman_spells(spells, enchants)
  local duration = tbc_or_classic(DURATION_20M, DURATION_10M)
  local enchant_duration = tbc_or_classic(DURATION_10M, DURATION_5M) -- TBC: Poisons become 1 hour

  tinsert(spells, BOM.Class.SpellDef:new(16342, --Flametongue Weapon
          { type         = "weapon", isOwn = true, isConsumable = false, default = false, singleDuration = enchant_duration,
            singleFamily = { 8024, 8027, 8030, 16339, 16341, 16342, -- Ranks 1-6
                             25489 } })) -- TBC: Rank 7
  enchants[16342] = { 3, 4, 5, 523, 1665, 1666, --Flametongue
                      2634 } --TBC: Flametongue 7

  tinsert(spells, BOM.Class.SpellDef:new(16356, --Frostbrand Weapon
          { type         = "weapon", isOwn = true, isConsumable = false, default = false, singleDuration = enchant_duration,
            singleFamily = { 8033, 8038, 10456, 16355, 16356, -- Ranks 1-5
                             25500 } })) -- TBC: Rank 6
  enchants[16356] = { 2, 12, 524, 1667, 1668, -- Frostbrand
                      2635 } -- TBC: Frostbrand 6

  tinsert(spells, BOM.Class.SpellDef:new(16316, --Rockbiter Weapon
          { type         = "weapon", isOwn = true, isConsumable = false, default = false, singleDuration = enchant_duration,
            singleFamily = { 8017, 8018, 8019, 10399, 16314, 16315, 16316, -- Ranks 1-7
                             25479, 25485 } })) -- TBC: Ranks 8-9
  enchants[16316] = { 1, 6, 29, 503, 683, 1663, 1664, -- Rockbiter
                      2632, 2633 } -- TBC: Rockbiter 8-9

  tinsert(spells, BOM.Class.SpellDef:new(16362, --Windfury Weapon
          { type         = "weapon", isOwn = true, isConsumable = false, default = false, singleDuration = enchant_duration,
            singleFamily = { 8232, 8235, 10486, 16362, -- Ranks 1-4
                             25505 } })) -- TBC: Rank 5
  enchants[16362] = { 283, 284, 525, 1669, -- Windfury 1-4
                      2636 } -- TBC: Windfury 5

  tinsert(spells, BOM.Class.SpellDef:new(10432, -- Lightning Shield / Blitzschlagschild
          { default      = false, isOwn = true, duration = duration,
            singleFamily = { 324, 325, 905, 945, 8134, 10431, 10432, -- Ranks 1-7
                             25469, 25472 } })) -- TBC: Ranks 8-9

  if BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(33736, -- TBC: Water Shield 1, 2
            { isOwn = true, default = true, duration = duration, singleFamily = { 24398, 33736 } }))
  end

  tinsert(spells, BOM.Class.SpellDef:new(20777, -- Ancestral Spirit / Auferstehung
          { type         = "resurrection", default = true,
            singleFamily = { 2008, 20609, 20610, 20776, 20777 } }))
end

---Add WARLOCK spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_warlock_spells(spells, enchants)
  tinsert(spells, BOM.Class.SpellDef:new(5697, -- Unending Breath
          { default = false, singleDuration = DURATION_10M, classes = BOM_ALL_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(11743, -- Detect Greater Invisibility | Große Unsichtbarkeit entdecken
          { default        = false, singleFamily = { 132, 2970, 11743 },
            singleDuration = DURATION_10M, classes = BOM_ALL_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(28610, -- Shadow Ward / Schattenzauberschutz
          { isOwn = true, default = false, singleFamily = { 6229, 11739, 11740, 28610 } }))
  tinsert(spells, BOM.Class.SpellDef:new(11735, -- Demon Armor
          { isOwn = true, default = false, singleFamily = { 706, 1086, 11733, 11734, 11735, -- Rank 5
                                                            27260 } })) -- TBC: Rank 6
  tinsert(spells, BOM.Class.SpellDef:new(696, -- Demon skin (Low Level)
          { isOwn = true, default = false, singleFamily = { 687, 696 } }))
  tinsert(spells, BOM.Class.SpellDef:new(18788, -- Demonic Sacrifice
          { isOwn = true, default = true }))
  tinsert(spells, BOM.Class.SpellDef:new(17953, -- Firestone
          { isOwn          = true, default = false,
            lockIfHaveItem = { 1254, 13699, 13700, 13701,
                               22128 }, -- TBC: Master Firestone
            singleFamily   = { 6366, 17951, 17952, 17953, -- Rank 1-4
                               27250 } })) -- TBC: Rank 5
  tinsert(spells, BOM.Class.SpellDef:new(11730, -- Healtstone
          { isOwn          = true, default = true,
            lockIfHaveItem = { 5512, 19005, 19004, 5511, 19007, 19006, 5509, 19009,
                               19008, 5510, 19011, 19010, 9421, 19013, 19012, -- Healthstones (3 talent ranks)
                               22103, 22104, 22105 }, -- TBC: Master Healthstone (3 talent ranks)
            singleFamily   = { 6201, 6202, 5699, 11729, 11730, -- Rank 1-5
                               27230 } })) -- TBC: Rank 6
  tinsert(spells, BOM.Class.SpellDef:new(20757, --Soulstone
          { isOwn          = true, default = true,
            lockIfHaveItem = { 5232, 16892, 16893, 16895, 16896,
                               22116 }, -- TBC: Master Soulstone
            singleFamily   = { 693, 20752, 20755, 20756, 20757, -- Ranks 1-5
                               27238 } })) -- TBC: Rank 6
  tinsert(spells, BOM.Class.SpellDef:new(5500, --Sense Demons
          { type = "tracking", default = false }))
end

---Add HUNTER spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_hunter_spells(spells, enchants)
  tinsert(spells, BOM.Class.SpellDef:new(20906, -- Trueshot Aura
          { isOwn        = true, default = true,
            singleFamily = { 19506, 20905, 20906, -- Ranks 1-3
                             27066 } })) -- TBC: Rank 4

  tinsert(spells, BOM.Class.SpellDef:new(25296, --Aspect of the Hawk
          { type         = "aura", default = true,
            singleFamily = { 13165, 14318, 14319, 14320, 14321, 14322, 25296, -- Rank 1-7
                             27044 } })) -- TBC: Rank 8
  tinsert(spells, BOM.Class.SpellDef:new(13163, --Aspect of the monkey
          { type = "aura", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(34074, -- TBC: Aspect of the Viper
          { type = "aura", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(20190, --Aspect of the wild
          { type         = "aura", default = false,
            singleFamily = { 20043, 20190, -- Ranks 1-2
                             27045 } })) -- TBC: Rank 3
  tinsert(spells, BOM.Class.SpellDef:new(5118, --Aspect of the Cheetah
          { type = "aura", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(13159, --Aspect of the pack
          { type = "aura", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(13161, -- Aspect of the beast
          { type = "aura", default = false }))

  tinsert(spells, BOM.Class.SpellDef:new(1494, -- Track Beast
          { type = "tracking", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(19878, -- Track Demon
          { type = "tracking", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(19879, -- Track Dragonkin
          { type = "tracking", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(19880, -- Track Elemental
          { type = "tracking", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(19883, -- Track Humanoids
          { type = "tracking", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(19882, -- Track Giants / riesen
          { type = "tracking", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(19884, -- Track Undead
          { type = "tracking", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(19885, -- Track Hidden / verborgenes
          { type = "tracking", default = false }))
end

---Add PALADIN spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_paladin_spells(spells, enchants)
  tinsert(spells, BOM.Class.SpellDef:new(25780, --Righteous Fury, same in TBC
          { isOwn = true, default = false }))

  local blessing_duration = tbc_or_classic(DURATION_10M, DURATION_5M)
  local greater_blessing_duration = tbc_or_classic(DURATION_15M, DURATION_30M)
  tinsert(spells, BOM.Class.SpellDef:new(20217, --Blessing of Kings
          { groupId         = 25898, isBlessing = true, default = true,
            singleDuration  = blessing_duration, groupDuration = greater_blessing_duration,
            reagentRequired = { 21177 }, classes = { "MAGE", "HUNTER", "WARLOCK" } }))
  tinsert(spells, BOM.Class.SpellDef:new(19979, --Blessing of Light
          { groupFamily     = { 25890, -- Rank 1
                                27145 }, -- TBC: Rank 2
            singleFamily    = { 19977, 19978, 19979, -- Ranks 1-3
                                27144 }, -- TBC: Rank 4
            isBlessing      = true, default = true,
            reagentRequired = { 21177 }, singleDuration = blessing_duration,
            groupDuration   = greater_blessing_duration, classes = {} }))
  tinsert(spells, BOM.Class.SpellDef:new(25291, --Blessing of Might
          { isBlessing      = true, default = true,
            singleFamily    = { 19740, 19834, 19835, 19836, 19837, 19838, 25291, -- Ranks 1-7
                                27140 }, -- TBC: Rank 8
            groupFamily     = { 25782, 25916, -- Ranks 1-2
                                27141 }, -- TBC: Rank 3
            singleDuration  = blessing_duration, groupDuration = greater_blessing_duration,
            reagentRequired = { 21177 }, classes = { "WARRIOR", "ROGUE" } }))
  tinsert(spells, BOM.Class.SpellDef:new(1038, --Blessing of Salvation
          { groupId         = 25895, isBlessing = true, default = true,
            singleDuration  = blessing_duration, groupDuration = greater_blessing_duration,
            reagentRequired = { 21177 }, classes = { } }))
  tinsert(spells, BOM.Class.SpellDef:new(20914, --Blessing of Sanctuary
          { isBlessing      = true, default = true,
            groupFamily     = { 25899, -- Rank 1
                                27169 }, -- TBC: Rank 2
            singleFamily    = { 20911, 20912, 20913, 20914, -- Ranks 1-4
                                27168 }, -- TBC: Rank 5
            reagentRequired = { 21177 },
            singleDuration  = blessing_duration, groupDuration = greater_blessing_duration,
            classes         = { } }))
  tinsert(spells, BOM.Class.SpellDef:new(25290, --Blessing of Wisdom
          { isBlessing      = true, default = true,
            singleFamily    = { 19742, 19850, 19852, 19853, 19854, 25290, -- Ranks 1-6
                                27142 }, -- TBC: Rank 7
            groupFamily     = { 25894, 25918, -- Ranks 1-2
                                27143 }, -- TBC: Rank 3
            singleDuration  = blessing_duration, groupDuration = greater_blessing_duration,
            reagentRequired = { 21177 }, classes = { "DRUID", "SHAMAN", "PRIEST", "PALADIN" } }))

  tinsert(spells, BOM.Class.SpellDef:new(10293, -- Devotion Aura
          { type         = "aura", default = false,
            singleFamily = { 465, 10290, 643, 10291, 1032, 10292, 10293, -- Rank 1-7
                             27149 } })) -- TBC: Rank 8
  tinsert(spells, BOM.Class.SpellDef:new(10301, -- Retribution Aura
          { type         = "aura", default = true,
            singleFamily = { 7294, 10298, 10299, 10300, 10301, -- Ranks 1-5
                             27150 } })) -- TBC: Rank 6
  tinsert(spells, BOM.Class.SpellDef:new(19746, --Concentration Aura
          { type = "aura", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(19896, -- Shadow Resistance Aura
          { type = "aura", default = false, singleFamily = { 19876, 19895, 19896, -- Rank 1-3
                                                             27151 } })) -- TBC: Rank 4
  tinsert(spells, BOM.Class.SpellDef:new(19898, -- Frost Resistance Aura
          { type = "aura", default = false, singleFamily = { 19888, 19897, 19898, -- Rank 1-3
                                                             27152 } })) -- TBC: Rank 4
  tinsert(spells, BOM.Class.SpellDef:new(19900, -- Fire Resistance Aura
          { type = "aura", default = false, singleFamily = { 19891, 19899, 19900, -- Rank 1-3
                                                             27153 } })) -- TBC: Rank 4
  tinsert(spells, BOM.Class.SpellDef:new(20218, --Sanctity Aura
          { type = "aura", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(20773, -- Redemption / Auferstehung
          { type = "resurrection", default = true, singleFamily = { 7328, 10322, 10324, 20772, 20773 } }))

  if not BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(20164, -- Sanctity seal
            { type = "seal", default = false }))
  end
  tinsert(spells, BOM.Class.SpellDef:new(5502, -- Sense undead
          { type = "tracking", default = false }))

  tinsert(spells, BOM.Class.SpellDef:new(20165, -- Seal of Light
          { type         = "seal", default = false,
            singleFamily = { 20165, 20347, 20348, 20349, -- Ranks 1-4
                             27160 } })) -- TBC: Rank 5
  tinsert(spells, BOM.Class.SpellDef:new(20154, -- Seal of Righteousness
          { type         = "seal", default = false,
            singleFamily = { 20154, 20287, 20288, 20289, 20290, 20291, 20292, 20293, -- Ranks 1-8
                             27155 } })) -- TBC: Seal rank 9
  tinsert(spells, BOM.Class.SpellDef:new(20166, -- Seal of Wisdom
          { type = "seal", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(348704, -- TBC: Seal of Vengeance
          { type         = "seal", default = false,
            singleFamily = { 31801, -- TBC: level 70 spell for Blood Elf
                             348704 } })) -- TBC: Base spell for the alliance races
  tinsert(spells, BOM.Class.SpellDef:new(348700, -- TBC: Seal of the Martyr (Draenei, Dwarf, Human)
          { type = "seal", default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(31892, -- TBC: Seal of Blood
          { type         = "seal", default = false,
            singleFamily = { 31892, -- TBC: Base Blood Elf spell
                             38008 } })) -- TBC: Alliance version???
end

---Add WARRIOR spells
local function bom_setup_warrior_spells(spells, enchants)
  tinsert(spells, BOM.Class.SpellDef:new(25289, --Battle Shout
          { isOwn        = true, default = true, default = false,
            singleFamily = { 6673, 5242, 6192, 11549, 11550, 11551, 25289, -- Ranks 1-7
                             2048 } })) -- TBC: Rank 8
  tinsert(spells, BOM.Class.SpellDef:new(2457, --Battle Stance
          { isOwn = true, default = true, default = false, singleId = 2457, shapeshiftFormId = 17 }))
  tinsert(spells, BOM.Class.SpellDef:new(71, --Defensive Stance
          { isOwn = true, default = true, default = false, singleId = 71, shapeshiftFormId = 18 }))
  tinsert(spells, BOM.Class.SpellDef:new(2458, --Berserker Stance
          { isOwn = true, default = true, default = false, singleId = 2458, shapeshiftFormId = 19 }))
end

---Add ROGUE spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_rogue_spells(spells, enchants)
  local duration = tbc_or_classic(DURATION_1H, DURATION_30M) -- TBC: Poisons become 1 hour

  tinsert(spells, BOM.Class.SpellDef:new(25351, --Deadly Poison
          { item         = tbc_or_classic(22054, 20844),
            items        = { 22054, 22053, -- TBC: Deadly Poison
                             20844, 8985, 8984, 2893, 2892 },
            isConsumable = true, type = "weapon", duration = duration, default = false, onlyUsableFor = { "ROGUE" } }))
  enchants[25351] = { 2643, 2642, -- TBC: Deadly Poison
                      2630, 627, 626, 8, 7 } --Deadly Poison

  tinsert(spells, BOM.Class.SpellDef:new(11399, --Mind-numbing Poison
          { item     = 9186, items = { 9186, 6951, 5237 }, isConsumable = true, type = "weapon",
            duration = duration, default = false, onlyUsableFor = { "ROGUE" } }))
  enchants[11399] = { 643, 23, 35 } --Mind-numbing Poison

  tinsert(spells, BOM.Class.SpellDef:new(11340, --Instant Poison
          { item         = tbc_or_classic(21927, 8928),
            items        = { 21927, -- TBC: Instant Poison
                             8928, 8927, 8926, 6950, 6949, 6947 },
            isConsumable = true, type = "weapon", duration = duration, default = false, onlyUsableFor = { "ROGUE" } }))
  enchants[11340] = { 2641, -- TBC: Instant Poison
                      625, 624, 623, 325, 324, 323 } --Instant Poison

  tinsert(spells, BOM.Class.SpellDef:new(13227, --Wound Poison
          { item         = tbc_or_classic(22055, 10922),
            items        = { 22055, -- TBC: Wound Poison
                             10922, 10921, 10920, 10918 },
            isConsumable = true, type = "weapon", duration = duration, default = false, onlyUsableFor = { "ROGUE" } }))
  enchants[13227] = { 2644, -- TBC: Wound Poison
                      706, 705, 704, 703 } --Wound Poison

  tinsert(spells, BOM.Class.SpellDef:new(11202, --Crippling Poison
          { item     = 3776, items = { 3776, 3775 }, isConsumable = true, type = "weapon",
            duration = duration, default = false, onlyUsableFor = { "ROGUE" } }))
  enchants[11202] = { 603, 22 } --Crippling Poison

  if BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(26785, --TBC: Anesthetic Poison
            { item         = 21835, items = { 21835 },
              isConsumable = true, type = "weapon", duration = duration, default = false, onlyUsableFor = { "ROGUE" } }))
    enchants[26785] = { 2640, } --TBC: Anesthetic Poison
  end
end

---Add RESOURCE TRACKING spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_tracking_spells(spells, enchants)
  tinsert(spells, BOM.Class.SpellDef:new(2383, -- Find Herbs / kräuter
          { type = "tracking", default = true }))
  tinsert(spells, BOM.Class.SpellDef:new(2580, -- Find Minerals / erz
          { type = "tracking", default = true }))
  tinsert(spells, BOM.Class.SpellDef:new(2481, -- Find Treasure / Schatzsuche / Zwerge
          { type = "tracking", default = true }))

  return spells
end

---MISC spells applicable to every class
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_misc_spells(spells, enchants)
  -- TODO: TBC drink and food spells
  --tinsert(s, BOM.Class.SpellDef:new(432, -- Water | drink
  --        { isInfo       = true, default = false,
  --          singleFamily = { 430, 431, 432, 1133, 1135, 1137, 22734, 25696, 26475, 26261, 29007,
  --                           26473, 10250, 26402,
  --            -- TBC: Drink
  --                           34291, 34062, 22018, 27089 } }))
  --tinsert(s, BOM.Class.SpellDef:new(434, -- Food | essen
  --        { isInfo       = true, default = false,
  --          singleFamily = { 10256, 1127, 1129, 22731, 5006, 433, 1131, 18230, 18233, 5007, 24800, 5005,
  --                           18232, 5004, 435, 434, 18234, 24869, 18229, 25888, 6410, 2639, 24005, 7737,
  --                           29073, 26260, 26474, 18231, 10257, 26472, 28616, 25700,
  --            -- TBC: Food
  --                           34062, 22019 } }))
  tinsert(spells, BOM.Class.SpellDef:new(20762, --Soulstone | Seelenstein
          { isInfo       = true, allowWhisper = true, default = false,
            singleFamily = { 20707, 20762, 20763, 20765, 20764 } }))
  return spells
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_phys_dps_battle_elixirs(spells, enchants)
  if BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(28497, --TBC: Elixir of Major Agility +35 AGI +20 CRIT
            { item = 22831, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(38954, --TBC: Fel Strength Elixir +90AP -10 STA
            { item = 31679, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(28490, --TBC: Elixir of Major Strength +35 STR
            { item = 22824, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(33720, --TBC: Onslaught Elixir +60 AP
            { item = 28102, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  end -- END TBC
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_phys_dps_guardian_elixirs(spells, enchants)
  if BOM.TBC then
  end -- END TBC
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_phys_dps_buffs(spells, enchants)
  tinsert(spells, BOM.Class.SpellDef:new(17538, --Elixir of the Mongoose
          { item = 13452, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(11334, --Elixir of Greater Agility
          { item = 9187, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(11405, --Elixir of Giants
          { item = 9206, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(17038, --Winterfall Firewater
          { item = 12820, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(16329, --Juju Might +40AP
          { item = 12460, isConsumable = true, default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(16323, --Juju Power +30Str
          { item = 12451, isConsumable = true, default = false }))

  --
  -- Weightstones for blunt weapons
  --
  tinsert(spells, BOM.Class.SpellDef:new(16622, --Weightstone
          { item         = 12643, items = { 12643, 7965, 3241, 3240, 3239 },
            isConsumable = true, type = "weapon", duration = DURATION_30M,
            default      = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  enchants[16622] = { 1703, 484, 21, 20, 19 } -- Weightstone

  if BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(34340, --TBC: Adamantite Weightstone +12 BLUNT +14 CRIT
            { item    = 28421, items = { 28421 }, isConsumable = true, type = "weapon", duration = DURATION_1H,
              default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
    enchants[34340] = { 2955 } --TBC: Adamantite Weightstone (Weight Weapon)

    tinsert(spells, BOM.Class.SpellDef:new(34339, --TBC: Fel Weightstone +12 BLUNT
            { item    = 28420, items = { 28420 }, isConsumable = true, type = "weapon", duration = DURATION_1H,
              default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
    enchants[34339] = { 2954 } --TBC: Fel Weightstone (Weighted +12)
  end

  --
  -- Sharpening Stones for sharp weapons
  --
  tinsert(spells, BOM.Class.SpellDef:new(16138, --Sharpening Stone
          { item         = 12404, items = { 12404, 7964, 2871, 2863, 2862 },
            isConsumable = true, type = "weapon", duration = DURATION_30M, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  enchants[16138] = { 1643, 483, 14, 13, 40 } --Sharpening Stone
  tinsert(spells, BOM.Class.SpellDef:new(28891, --Consecrated Sharpening Stone
          { item     = 23122, isConsumable = true, type = "weapon",
            duration = DURATION_1H, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  enchants[28891] = { 2684 } --Consecrated Sharpening Stone
  tinsert(spells, BOM.Class.SpellDef:new(22756, --Elemental Sharpening Stone
          { item     = 18262, isConsumable = true, type = "weapon",
            duration = DURATION_30M, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  enchants[22756] = { 2506 } --Elemental Sharpening Stone

  if BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(29453, --TBC: Adamantite Sharpening Stone +12 WEAPON +14 CRIT
            { item    = 23529, items = { 23529 }, isConsumable = true, type = "weapon", duration = DURATION_1H,
              default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(29452, --TBC: Fel Sharpening Stone +12 WEAPON
            { item    = 23528, items = { 23528 }, isConsumable = true, type = "weapon", duration = DURATION_1H,
              default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
    enchants[29452] = { 2712 } --TBC: Fel Sharpening Stone (Sharpened +12)
    enchants[29453] = { 2713 } --TBC: Adamantite Sharpening Stone (Sharpened +14 Crit, +12)
  end -- TBC sharpening and runes

  --
  -- Food (pre TBC)
  --
  if not BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(18192, --Grilled Squid +10 Agility
            { item = 13928, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(24799, --Smoked Desert Dumplings +Strength
            { item = 20452, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(18141, --Blessed Sunfruit Juice +Strength
            { item = 13813, isConsumable = true, default = false, onlyUsableFor = BOM_MELEE_CLASSES }))
  end -- Disable old food in TBC
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_caster_battle_elixirs(spells, enchants)
  if BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(28509, --TBC: Elixir of Major Mageblood +16 mp5
            { item = 22840, isConsumable = true, default = false }))
    tinsert(spells, BOM.Class.SpellDef:new(28503, --TBC: Elixir of Major Shadow Power +55 SHADOW
            { item = 22835, isConsumable = true, default = false, onlyUsableFor = BOM_SHADOW_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(28501, --TBC: Elixir of Major Firepower +55 FIRE
            { item = 22833, isConsumable = true, default = false, onlyUsableFor = BOM_FIRE_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(28493, --TBC: Elixir of Major Frost Power +55 FROST
            { item = 22827, isConsumable = true, default = false, onlyUsableFor = BOM_FROST_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(28491, --TBC: Elixir of Healing Power +50 HEAL
            { item = 22825, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(33721, --TBC: Adept's Elixir +24 SPELL, +24 SPELLCRIT
            { item = 28103, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(39627, --TBC: Elixir of Draenic Wisdom +30 SPI
            { item = 32067, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
  end -- END TBC

  tinsert(spells, BOM.Class.SpellDef:new(24363, --Mageblood Potion
          { item = 20007, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(17539, --Greater Arcane Elixir
          { item = 13454, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(11390, --Greater Arcane Elixir
          { item = 9155, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(11474, -- Elixir of Shadow Power
          { item = 9264, isConsumable = true, default = false, onlyUsableFor = BOM_SHADOW_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(26276, --Elixir of Greater Firepower
          { item = 21546, isConsumable = true, default = false, onlyUsableFor = BOM_FIRE_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(21920, --Elixir of Frost Power
          { item = 17708, isConsumable = true, default = false, onlyUsableFor = BOM_FROST_CLASSES }))
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_caster_guardian_elixirs(spells, enchants)
  if BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(28514, --TBC: Elixir of Empowerment, -30 TARGET RESIST
            { item = 22848, isConsumable = true, default = false }))
  end -- END TBC
end

---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_caster_buffs(spells, enchants)
  if not BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(18194, --Nightfin Soup +Mana/5
            { item = 13931, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(19710, --Monster Omelette
            { item = 12218, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(18125, --Blessed Sunfruit +Spirit
            { item = 13810, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
  end -- Disable old food in TBC

  if BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(28017, --Superior Wizard Oil +42 SPELL
            { item = 22522, items = { 22522 }, isConsumable = true,
              type = "weapon", duration = DURATION_1H, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
    --tinsert(spells, BOM.Class.SpellDef:new(28013, --Superior Mana Oil +14 mp5
    --        { item     = 22521, items = { 22521 }, isConsumable = true,
    --          type = "weapon", duration = DURATION_1H, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
  end -- end TBC weapon enchants

  tinsert(spells, BOM.Class.SpellDef:new(25123, --Minor, Lesser, Brilliant Mana Oil
          { item     = 20748, isConsumable = true, type = "weapon",
            items    = { 20748, 20747, 20745, -- Minor, Lesser, Brilliant Mana Oil
                         22521 }, -- TBC: Superior Mana Oil
            duration = DURATION_30M, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
  enchants[25123] = { 2624, 2625, 2629, -- Minor, Lesser, Brilliant Mana Oil (enchant)
                      2677 } -- TBC: Superior Mana Oil (enchant)

  tinsert(spells, BOM.Class.SpellDef:new(25122, -- Wizard Oil
          { item     = 20749, isConsumable = true, type = "weapon",
            items    = { 20749, 20746, 20744, 20750, --Minor, Lesser, "regular", Brilliant Wizard Oil
                         22522 }, -- TBC: Superior Wizard Oil
            duration = DURATION_30M, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
  enchants[25122] = { 2623, 2626, 2627, 2628, --Minor, Lesser, "regular", Brilliant Wizard Oil (enchant)
                      2678 }, -- TBC: Superior Wizard Oil (enchant)

  tinsert(spells, BOM.Class.SpellDef:new(28898, --Blessed Wizard Oil
          { item     = 23123, isConsumable = true, type = "weapon",
            duration = DURATION_1H, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
  enchants[28898] = { 2685 } --Blessed Wizard Oil
end

---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_battle_elixirs(spells, enchants)
  if BOM.TBC then
    -- Sunwell only
    --tinsert(s, BOM.Class.SpellDef:new(45373, --TBC: Bloodberry Elixir +15 all stats
    --        { item = 34537, isConsumable = true, default = false }))
    tinsert(spells, BOM.Class.SpellDef:new(33726, --TBC: Elixir of Mastery +15 all stats
            { item = 28104, isConsumable = true, default = false }))
  end -- END TBC
end

---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_guardian_elixirs(spells, enchants)
  if BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(28502, --TBC: Elixir of Major Defense +550 ARMOR
            { item = 22834, isConsumable = true, default = false }))
    tinsert(spells, BOM.Class.SpellDef:new(39628, --TBC: Elixir of Ironskin +30 RESIL
            { item = 32068, isConsumable = true, default = false }))
    tinsert(spells, BOM.Class.SpellDef:new(39625, --TBC: Elixir of Major Fortitude +250 HP and 10 HP/5
            { item = 32062, isConsumable = true, default = false }))
    tinsert(spells, BOM.Class.SpellDef:new(39626, --TBC: Earthen Elixir -20 ALL DMG TAKEN
            { item = 32063, isConsumable = true, default = false }))
  end -- END TBC

  tinsert(spells, BOM.Class.SpellDef:new(3593, --Elixir of Fortitude
          { item = 3825, isConsumable = true, default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(11348, --Elixir of Superior Defense
          { item = 13445, isConsumable = true, default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(24361, --Major Troll's Blood Potion
          { item = 20004, isConsumable = true, default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(11371, --Gift of Arthas
          { item = 9088, isConsumable = true, default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(16326, --Juju Ember +15FR
          { item = 12455, isConsumable = true, default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(16325, --Juju Chill +15FrostR
          { item = 12457, isConsumable = true, default = false }))

  if not BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(22730, --Runn Tum Tuber Surprise
            { item = 18254, isConsumable = true, default = false }))
    tinsert(spells, BOM.Class.SpellDef:new(25661, --Dirge's Kickin' Chimaerok Chops x
            { item = 21023, isConsumable = true, default = false }))
    tinsert(spells, BOM.Class.SpellDef:new(22790, --Kreeg's Stout Beatdown
            { item          = 18284, isConsumable = true, default = false,
              onlyUsableFor = BOM_MANA_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(22789, --Gordok Green Grog
            { item = 18269, isConsumable = true, default = false }))
    tinsert(spells, BOM.Class.SpellDef:new(25804, --Rumsey Rum Black Label
            { item = 21151, isConsumable = true, default = false }))
  end -- Disable old food in TBC

  tinsert(spells, BOM.Class.SpellDef:new(17549, --Greater Arcane Protection Potion
          { item = 13461, isConsumable = true, default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(17543, --Greater Fire Protection Potion
          { item = 13457, isConsumable = true, default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(17544, --Greater Frost Protection Potion
          { item = 13456, isConsumable = true, default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(17546, --Greater Nature Protection Potion
          { item = 13458, isConsumable = true, default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(17548, --Greater Shadow Protection Potion
          { item = 13459, isConsumable = true, default = false }))
end

---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_item_spells(spells, enchants)
  if not BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(15233, --Crystal Ward
            { item = 11564, isConsumable = true, default = false }))
    tinsert(spells, BOM.Class.SpellDef:new(15279, --Crystal Spire
            { item = 11567, isConsumable = true, default = false }))
  end -- Disable old food in TBC
end

---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_flasks(spells, enchants)
  if BOM.TBC then
    tinsert(spells, BOM.Class.SpellDef:new(28540, --TBC: Flask of Pure Death +80 SHADOW +80 FIRE +80 FROST
            { item = 22866, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(28520, --TBC: Flask of Relentless Assault +120 AP
            { item = 22854, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(28521, --TBC: Flask of Blinding Light +80 ARC +80 HOLY +80 NATURE
            { item = 22861, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
    tinsert(spells, BOM.Class.SpellDef:new(28518, --TBC: Flask of Fortification +500 HP +10 DEF RATING
            { item = 22851, isConsumable = true, default = false }))
    tinsert(spells, BOM.Class.SpellDef:new(28519, --TBC: Flask of Mighty Restoration +25 MP/5
            { item = 22853, isConsumable = true, default = false }))
    tinsert(spells, BOM.Class.SpellDef:new(42735, --TBC: Flask of Chromatic Wonder +35 ALL RESIST +18 ALL STATS
            { item = 33208, isConsumable = true, default = false }))
    -- TODO: Shattrath Flask of... (SSC and Tempest Keep only)
    -- TODO: Unstable Flask of... (Blade's Edge and Gruul's Lair only)
  end

  tinsert(spells, BOM.Class.SpellDef:new(17628, --Flask of Supreme Power +70 SPELL
          { item = 13512, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(17626, --Flask of the Titans +400 HP
          { item = 13510, isConsumable = true, default = false }))
  tinsert(spells, BOM.Class.SpellDef:new(17627, --Flask of Distilled Wisdom +65 INT
          { item = 13511, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(spells, BOM.Class.SpellDef:new(17629, --Flask of Chromatic Resistance
          { item = 13513, isConsumable = true, default = false }))
end

---All spells known to Buffomat
---Note: you can add your own spell in the "WTF\Account\<accountname>\SavedVariables\buffOmat.lua"
---table CustomSpells
---@return table<number, SpellDef> All known spells table (all spells to be scanned)
function BOM.SetupSpells()
  local spells = {} ---@type table<number, SpellDef>
  local enchants = {} ---@type table<number, table<number>>

  bom_setup_priest_spells(spells, enchants)
  bom_setup_druid_spells(spells, enchants)
  bom_setup_mage_spells(spells, enchants)
  bom_setup_shaman_spells(spells, enchants)
  bom_setup_warlock_spells(spells, enchants)
  bom_setup_hunter_spells(spells, enchants)
  bom_setup_paladin_spells(spells, enchants)
  bom_setup_warrior_spells(spells, enchants)
  bom_setup_rogue_spells(spells, enchants)
  bom_setup_tracking_spells(spells, enchants)
  bom_setup_misc_spells(spells, enchants)
  bom_setup_phys_dps_buffs(spells, enchants)
  bom_setup_phys_dps_battle_elixirs(spells, enchants)
  bom_setup_phys_dps_guardian_elixirs(spells, enchants)
  bom_setup_caster_buffs(spells, enchants)
  bom_setup_caster_battle_elixirs(spells, enchants)
  bom_setup_caster_guardian_elixirs(spells, enchants)
  bom_setup_item_spells(spells, enchants)
  bom_setup_battle_elixirs(spells, enchants)
  bom_setup_guardian_elixirs(spells, enchants)
  bom_setup_flasks(spells, enchants)

  --Preload items!
  for x, spell in ipairs(spells) do
    if spell.isConsumable then
      GetItemInfo(spell.item)
    end
  end

  BOM.EnchantToSpell = {}
  for dest, list in pairs(enchants) do
    for i, id in ipairs(list) do
      BOM.EnchantToSpell[id] = dest
    end
  end

  BOM.AllBuffomatSpells = spells
  BOM.EnchantList = enchants
end


--TODO: This can be calculated from AllSpells spell ids
function BOM.SetupItemCache()
  local s = {}
  local function make_item(id, name, color, x)
    tinsert(s, {
      name, -- [1]
      "|cff" .. color .. "|Hitem:" .. tostring(id) .. "::::::::1:::::::|h[" .. name .. "]|h|r", -- [2]
      x, -- [3]
    })
  end
  local W = LE_ITEM_QUALITY_COMMON
  local G = LE_ITEM_QUALITY_UNCOMMON
  make_item(18284, "Kreeg's Stout Beatdown", G, 132792)
  make_item(13461, "Greater Arcane Protection Potion", W, 134863)
  make_item(12643, "Dense Weightstone", W, 135259)
  make_item(12455, "Juju Ember", W, 134317)
  make_item(13810, "Blessed Sunfruit", W, 133997)
  make_item(8928, "Instant Poison VI", W, 132273)
  make_item(12457, "Juju Chill", W, 134311)
  make_item(13813, "Blessed Sunfruit Juice", W, 132803)
  make_item(12460, "Juju Might", W, 134309)
  make_item(3825, "Elixir of Fortitude", W, 134823)
  make_item(9186, "Mind-numbing Poison III", W, 136066)
  make_item(9155, "Arcane Elixir", W, 134810)
  make_item(20452, "Smoked Desert Dumplings", W, 134020)

  if BOM.TBC then
    make_item(22055, "Wound Poison V", W, 132274)
    make_item(21835, "Anesthetic Poison", W, 132274)
    make_item(28420, "Fel Weightstone", W, 132274)
    make_item(28421, "Adamantite Weightstone", W, 132274)
    make_item(23528, "Fel Sharpening Stone", W, 132274)
    make_item(23529, "Adamantite Sharpening Stone", W, 132274)
  else
    make_item(10922, "Wound Poison IV", W, 132274)
  end

  make_item(21023, "Dirge's Kickin' Chimaerok Chops", W, 134021)
  make_item(12404, "Dense Sharpening Stone", W, 135252)
  make_item(21151, "Rumsey Rum Black Label", W, 132791)
  make_item(18254, "Runn Tum Tuber Surprise", W, 134019)
  make_item(13445, "Elixir of Superior Defense", W, 134846)
  make_item(13457, "Greater Fire Protection Potion", W, 134804)
  make_item(12451, "Juju Power", W, 134313)
  make_item(12218, "Monster Omelet", W, 133948)
  make_item(13931, "Nightfin Soup", W, 132804)
  make_item(20749, "Brilliant Wizard Oil", W, 134727)
  make_item(5654, "Instant Toxin", W, 134799)
  make_item(18262, "Elemental Sharpening Stone", G, 135228)

  if BOM.TBC then
    make_item(22054, "Deadly Poison VII", W, 132290)
    make_item(22521, "Superior Mana Oil", W, 134727)
    make_item(22522, "Superior Wizard Oil", W, 134727)
  else
    make_item(20844, "Deadly Poison V", W, 132290)
  end

  make_item(20004, "Major Troll's Blood Potion", W, 134860)
  make_item(12820, "Winterfall Firewater", W, 134872)
  make_item(20007, "Mageblood Potion", W, 134825)
  make_item(9264, "Elixir of Shadow Power", W, 134826)
  make_item(11564, "Crystal Ward", W, 134129)
  make_item(18269, "Gordok Green Grog", G, 132790)
  make_item(21546, "Elixir of Greater Firepower", W, 134840)
  make_item(23122, "Consecrated Sharpening Stone", G, 135249)
  make_item(23123, "Blessed Wizard Oil", G, 134806)
  make_item(13454, "Greater Arcane Elixir", W, 134805)
  make_item(9088, "Gift of Arthas", W, 134808)
  make_item(17708, "Elixir of Frost Power", W, 134714)
  make_item(13928, "Grilled Squid", W, 133899)
  make_item(13456, "Greater Frost Protection Potion", W, 134800)
  make_item(13452, "Elixir of the Mongoose", W, 134812)
  make_item(11567, "Crystal Spire", W, 134134)
  make_item(20748, "Brilliant Mana Oil", W, 134722)
  make_item(13458, "Greater Nature Protection Potion", W, 134802)
  make_item(9206, "Elixir of Giants", W, 134841)
  make_item(13459, "Greater Shadow Protection Potion", W, 134803)
  make_item(3776, "Crippling Poison II", W, 134799)

  BOM.ItemCache = s
end

BOM.ArgentumDawn = {
  spell   = 17670,
  dungeon = { 329, 289, 533, 535 }, --Stratholme/scholomance; Naxxramas LK 10/25
}
BOM.Carrot = {
  spell   = 13587,
  dungeon = { 0, 1 }, --Allow Carrot in Eastern Kingdoms, Kalimdor
}

BOM.BuffExchangeId = { -- comine-spell-ids to new one
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
  [8079] = 432, -- Water | Wasser
  [5232] = 20762, [16892] = 20762, [16893] = 20762, [16895] = 20762, [16896] = 20762, -- Soulstone | Seelenstein
}
BOM.ItemListTarget = {}

---@return table<number, SpellDef>
function BOM.SetupCancelBuffs()
  -- Note: you can add your own spell in the "WTF\Account\<accountname>\SavedVariables\buffOmat.lua"
  -- table CustomCancelBuff
  local s = {
    BOM.SpellDef_PW_Shield(),
    BOM.SpellDef_PrayerOfSpirit(),
    BOM.SpellDef_ArcaneIntelligence(),
  }

  do
    local _, class, _ = UnitClass("unit")
    if class == "HUNTER" then
      tinsert(s, BOM.Class.SpellDef:new(5118, --Aspect of the Cheetah/of the pack
              { OnlyCombat = true, default = true, singleFamily = { 5118, 13159 } }))
    end

    if (UnitFactionGroup("player")) ~= "Horde" or BOM.TBC then
      tinsert(s, BOM.Class.SpellDef:new(1038, --Blessing of Salvation
              { default = false, singleFamily = { 1038, 25895 } }))
    end
  end

  BOM.CancelBuffs = s
end

-- Having this buff on target excludes the target (phaseshifted imp for example)
BOM.BuffIgnoreAll = {
  4511 -- Phase Shift (imp)
}

local ShapeShiftTravel = { 2645, 783 } --Ghost wolf and travel druid
