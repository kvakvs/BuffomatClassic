---@type BuffomatAddon
local TOCNAME, BOM = ...
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
                          "SHAMAN", "PALADIN" }
local BOM_NO_CLASS = { }

---Classes which have a resurrection ability
local BOM_RESURRECT_CLASSES = { "SHAMAN", "PRIEST", "PALADIN" }
BOM.RESURRECT_CLASS = BOM_RESURRECT_CLASSES --used in TaskScan.lua

---Classes which have mana bar
local BOM_MANA_CLASSES = { "HUNTER", "WARLOCK", "MAGE", "DRUID", "SHAMAN", "PRIEST", "PALADIN" }
BOM.MANA_CLASSES = BOM_MANA_CLASSES --used in TaskScan.lua

BOM.CLASSIC_ERA = "Classic"
BOM.TBC_ERA = "TBC"

local BOM_MELEE_CLASSES = { "WARRIOR", "ROGUE", "DRUID", "SHAMAN", "PALADIN" }
local BOM_SHADOW_CLASSES = { "PRIEST", "WARLOCK" }
local BOM_FIRE_CLASSES = { "MAGE", "WARLOCK", "SHAMAN", "HUNTER" }
local BOM_FROST_CLASSES = { "MAGE", "SHAMAN" }
local BOM_PHYSICAL_CLASSES = { "HUNTER", "ROGUE", "SHAMAN", "WARRIOR", "DRUID", "PALADIN" }

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
  local priestOnly = { playerClass = "PRIEST" }

  BOM.Class.SpellDef:scan_spell(spells, 10938, -- Fortitude / Seelenstärke
          { groupId        = 21562, default = true,
            singleFamily   = { 1243, 1244, 1245, 2791, 10937, 10938, -- Ranks 1-6
                               25389 }, -- TBC: Rank 7
            groupFamily    = { 21562, 21564, -- Ranks 1-2
                               25392 }, -- TBC: Rank 3
            singleDuration = DURATION_30M, groupDuration = DURATION_1H, reagentRequired = { 17028, 17029 },
            targetClasses  = BOM_ALL_CLASSES })

  BOM.SpellDef_PrayerOfSpirit = function()
    return BOM.Class.SpellDef:new(14819, -- Divine Spirit / Prayer of Spirit / Willenstärke
            { groupId        = 27681, default = true,
              singleFamily   = { 14752, 14818, 14819, 27841, -- Ranks 1-4
                                 25312 }, -- TBC: Rank 5
              groupFamily    = { 27681, -- Rank 1
                                 32999 }, --- TBC: Rank 2
              singleDuration = DURATION_30M, groupDuration = DURATION_1H, reagentRequired = { 17028, 17029 },
              targetClasses  = BOM_MANA_CLASSES })
  end
  tinsert(spells, BOM.SpellDef_PrayerOfSpirit())

  BOM.Class.SpellDef:scan_spell(spells, 10958, --Shadow Protection / Prayer of Shadow / Schattenschutz
          { groupId         = 27683, default = false, singleDuration = DURATION_10M, groupDuration = 1200,
            singleFamily    = { 976, 10957, 10958, -- Ranks 1-3
                                25433 }, -- TBC: Rank 4
            groupFamily     = { 27683, -- Rank 1
                                39374 }, -- TBC: Rank 2
            reagentRequired = { 17028, 17029 }, targetClasses = BOM_ALL_CLASSES },
          priestOnly)
  BOM.Class.SpellDef:scan_spell(spells, 6346, -- Fear Ward
          { default = false, singleDuration = DURATION_10M, hasCD = true, targetClasses = BOM_ALL_CLASSES })

  BOM.SpellDef_PW_Shield = function()
    return BOM.Class.SpellDef:new(10901, -- Power Word: Shield / Powerword:Shild
            { default        = false,
              singleFamily   = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901, -- Ranks 1-10
                                 25217, 25218 }, -- TBC: Ranks 11-12
              singleDuration = 30, hasCD = true, targetClasses = { } })
  end
  tinsert(spells, BOM.SpellDef_PW_Shield())

  BOM.Class.SpellDef:scan_spell(spells, 19266, -- Touch of Weakness / Berührung der Schwäche
          { default      = true, isOwn = true,
            singleFamily = { 2652, 19261, 19262, 19264, 19265, 19266, -- Ranks 1-6
                             25461 } }, -- TBC: Rank 7
          priestOnly)
  BOM.Class.SpellDef:scan_spell(spells, 10952, -- Inner Fire / inneres Feuer
          { default      = true, isOwn = true,
            singleFamily = { 588, 7128, 602, 1006, 10951, 10952, -- Ranks 1-6
                             25431 } }, -- TBC: Rank 7
          priestOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19312, -- Shadowguard
          { default      = true, isOwn = true,
            singleFamily = { 18137, 19308, 19309, 19310, 19311, 19312, -- Ranks 1-6
                             25477 } }, -- TBC: Rank 7
          priestOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19293, -- Elune's Grace
          { default      = true, isOwn = true,
            singleFamily = { 2651, -- Rank 1 also TBC: The only rank
                             19289, 19291, 19292, 19293 } }, -- Ranks 2-5 (non-TBC)
          priestOnly)
  BOM.Class.SpellDef:scan_spell(spells, 15473, -- Shadow Form
          { default = false, isOwn = true },
          priestOnly)
  BOM.Class.SpellDef:scan_spell(spells, 20770, -- Resurrection / Auferstehung
          { cancelForm   = true, type = "resurrection", default = true,
            singleFamily = { 2006, 2010, 10880, 10881, 20770, -- Ranks 1-5
                             25435 } }, -- TBC: Rank 6
          priestOnly)
end

---Add DRUID spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_druid_spells(spells, enchants)
  local druidOnly = { playerClass = "DRUID" }

  BOM.Class.SpellDef:scan_spell(spells, 9885, --Gift/Mark of the Wild | Gabe/Mal der Wildniss
          { groupId         = 21849, cancelForm = true, default = true,
            singleFamily    = { 1126, 5232, 6756, 5234, 8907, 9884, 9885, -- Ranks 1-7
                                26990 }, -- TBC: Rank 8
            groupFamily     = { 21849, 21850, -- Ranks 1-2
                                26991 }, -- TBC: Rank 3
            singleDuration  = DURATION_30M, groupDuration = DURATION_1H,
            reagentRequired = { 17021, 17026 }, targetClasses = BOM_ALL_CLASSES },
          druidOnly)
  BOM.Class.SpellDef:scan_spell(spells, 9910, --Thorns | Dornen
          { cancelForm     = true, default = false,
            singleFamily   = { 467, 782, 1075, 8914, 9756, 9910, -- Ranks 1-6
                               26992 }, -- TBC: Rank 7
            singleDuration = DURATION_10M, targetClasses = BOM_MELEE_CLASSES },
          druidOnly)
  BOM.Class.SpellDef:scan_spell(spells, 16864, --Omen of Clarity
          { isOwn = true, cancelForm = true, default = true },
          druidOnly)
  BOM.Class.SpellDef:scan_spell(spells, 17329, -- Nature's Grasp | Griff der Natur
          { isOwn        = true, cancelForm = true, default = false,
            hasCD        = true, requiresOutdoors = true,
            singleFamily = { 16689, 16810, 16811, 16812, 16813, 17329, -- Rank 1-6
                             27009 } }, -- TBC: Rank 7
          druidOnly)
  BOM.Class.SpellDef:scan_spell(spells, 33891, --TBC: Tree of life
          { isOwn = true, default = true, default = false, singleId = 33891, shapeshiftFormId = 2 },
          { isTBC = true, playerClass = "DRUID" })

  -- Special code: This will disable herbalism and mining tracking in Cat Form
  BOM.Class.SpellDef:scan_spell(spells, BOM.SpellId.Druid.TrackHumanoids, -- Track Humanoids (Cat Form)
          { type      = "tracking", needForm = CAT_FORM, default = true,
            extraText = L.SpellLabel_TrackHumanoids },
          druidOnly)
end

---Add MAGE spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_mage_spells(spells, enchants)
  local mageOnly = { playerClass = "MAGE" }

  --{singleId=10938, isOwn=true, default=true, lockIfHaveItem={BOM.ItemId.Mage.ManaRuby}}, -- manastone/debug
  BOM.SpellDef_ArcaneIntelligence = function()
    return BOM.Class.SpellDef:new(10157, --Arcane Intellect | Brilliance
            { singleFamily    = { 1459, 1460, 1461, 10156, 10157, -- Ranks 1-5
                                  27126 }, -- TBC: Rank 6
              groupFamily     = { 23028, -- Brilliance Rank 1
                                  27127 }, -- TBC: Brillance Rank 2
              default         = true, singleDuration = DURATION_30M, groupDuration = DURATION_1H,
              reagentRequired = { 17020 }, targetClasses = BOM_MANA_CLASSES })
  end
  tinsert(spells, BOM.SpellDef_ArcaneIntelligence())

  BOM.Class.SpellDef:scan_spell(spells, 10174, --Dampen Magic
          { default      = false, singleDuration = DURATION_10M, targetClasses = { },
            singleFamily = { 604, 8450, 8451, 10173, 10174, -- Ranks 1-5
                             33944 } }, -- TBC: Rank 6
          mageOnly)
  BOM.Class.SpellDef:scan_spell(spells, 10170, --Amplify Magic
          { default      = false, singleDuration = DURATION_10M, targetClasses = { },
            singleFamily = { 1008, 8455, 10169, 10170, -- Ranks 1-4
                             27130, 33946 } }, -- TBC: Ranks 5-6
          mageOnly)
  BOM.Class.SpellDef:scan_spell(spells, 10220, -- Ice Armor / eisrüstung
          { type         = "seal", default = false,
            singleFamily = { 7302, 7320, 10219, 10220, -- Ranks 1-4, levels 30 40 50 60
                             27124 } }, -- TBC: Rank 5, level 69
          mageOnly)
  BOM.Class.SpellDef:scan_spell(spells, 7301, -- Frost Armor / frostrüstung
          { type         = "seal", default = false,
            singleFamily = { 168, 7300, 7301 } }, -- Ranks 1-3, Levels 1, 10, 20
          mageOnly)
  BOM.Class.SpellDef:scan_spell(spells, 30482, -- TBC: Molten Armor
          { type = "seal", default = false, singleFamily = { 30482 } }, -- TBC: Rank 1
          mageOnly)
  BOM.Class.SpellDef:scan_spell(spells, 22783, -- Mage Armor / magische rüstung
          { type         = "seal", default = false,
            singleFamily = { 6117, 22782, 22783, -- Ranks 1-3
                             27125 } }, -- TBC: Rank 4
          mageOnly)
  BOM.Class.SpellDef:scan_spell(spells, 10193, --Mana Shield | Manaschild - unabhängig von allen.
          { isOwn        = true, default = false, singleDuration = 60,
            singleFamily = { 1463, 8494, 8495, 10191, 10192, 10193, -- Ranks 1-6
                             27131 } }, -- TBC: Rank 7
          mageOnly)
  BOM.Class.SpellDef:scan_spell(spells, 13033, --Ice Barrier
          { isOwn        = true, default = false, singleDuration = 60,
            singleFamily = { 11426, 13031, 13032, 13033, -- Ranks 1-4
                             27134, 33405 } }, -- TBC: Ranks 5-6
          mageOnly)

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
    BOM.Class.SpellDef:scan_spell(spells, BOM.SpellId.Mage.ConjureManaEmerald, -- Conjure Mana Stone (Max Rank)
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
                                 BOM.SpellId.Mage.ConjureManaEmerald } },
            mageOnly)
  end
end

---Add SHAMAN spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_shaman_spells(spells, enchants)
  local duration = tbc_or_classic(DURATION_20M, DURATION_10M)
  local enchant_duration = tbc_or_classic(DURATION_30M, DURATION_5M) -- TBC: Shaman enchants become 30min
  local shamanOnly = { playerClass = "SHAMAN" }

  BOM.Class.SpellDef:scan_spell(spells, 16342, --Flametongue Weapon
          { type         = "weapon", isOwn = true, isConsumable = false,
            default      = false, singleDuration = enchant_duration,
            singleFamily = { 8024, 8027, 8030, 16339, 16341, 16342, -- Ranks 1-6
                             25489 } }, -- TBC: Rank 7
          shamanOnly,
          { "shamanEnchant" })
  enchants[16342] = { 3, 4, 5, 523, 1665, 1666, --Flametongue
                      2634 } --TBC: Flametongue 7

  BOM.Class.SpellDef:scan_spell(spells, 16356, --Frostbrand Weapon
          { type         = "weapon", isOwn = true, isConsumable = false,
            default      = false, singleDuration = enchant_duration,
            singleFamily = { 8033, 8038, 10456, 16355, 16356, -- Ranks 1-5
                             25500 } }, -- TBC: Rank 6
          shamanOnly,
          { "shamanEnchant" })
  enchants[16356] = { 2, 12, 524, 1667, 1668, -- Frostbrand
                      2635 } -- TBC: Frostbrand 6

  BOM.Class.SpellDef:scan_spell(spells, 16316, --Rockbiter Weapon
          { type         = "weapon", isOwn = true, isConsumable = false,
            default      = false, singleDuration = enchant_duration,
            singleFamily = { 8017, 8018, 8019, 10399, 16314, 16315, 16316, -- Ranks 1-7
                             25479, 25485 } }, -- TBC: Ranks 8-9
          shamanOnly,
          { "shamanEnchant" })
  -- Note: in TBC all enchantIds for rockbiter have changed
  enchants[16316] = { 1, 6, 29, 503, 504, 683, 1663, 1664, -- Rockbiter, also 504 some special +80 Rockbiter?
                      3040, -- rockbiter 7
                      3023, 3026, 3028, 3031, 3034, 3037, 3040, -- TBC: Rockbiter 1-7
                      2632, 2633 } -- TBC: Rockbiter 8-9

  BOM.Class.SpellDef:scan_spell(spells, 16362, --Windfury Weapon
          { type         = "weapon", isOwn = true, isConsumable = false,
            default      = false, singleDuration = enchant_duration,
            singleFamily = { 8232, 8235, 10486, 16362, -- Ranks 1-4
                             25505 } }, -- TBC: Rank 5
          shamanOnly,
          { "shamanEnchant" })
  enchants[16362] = { 283, 284, 525, 1669, -- Windfury 1-4
                      2636 } -- TBC: Windfury 5

  BOM.Class.SpellDef:scan_spell(spells, 10432, -- Lightning Shield / Blitzschlagschild
          { default      = false, isOwn = true, duration = duration,
            singleFamily = { 324, 325, 905, 945, 8134, 10431, 10432, -- Ranks 1-7
                             25469, 25472 } }, -- TBC: Ranks 8-9
          shamanOnly)

  BOM.Class.SpellDef:scan_spell(spells, 33736, -- TBC: Water Shield 1, 2
          { isOwn = true, default = true, duration = duration, singleFamily = { 24398, 33736 } },
          { playerClass = "SHAMAN", isTBC = true })

  BOM.Class.SpellDef:scan_spell(spells, 20777, -- Ancestral Spirit / Auferstehung
          { type         = "resurrection", default = true,
            singleFamily = { 2008, 20609, 20610, 20776, 20777 } },
          shamanOnly)
end

---Add WARLOCK spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_warlock_spells(spells, enchants)
  local warlockOnly = { playerClass = "WARLOCK" }

  BOM.Class.SpellDef:scan_spell(spells, 5697, -- Unending Breath
          { default = false, singleDuration = DURATION_10M, targetClasses = BOM_ALL_CLASSES },
          warlockOnly)
  BOM.Class.SpellDef:scan_spell(spells, 11743, -- Detect Greater Invisibility | Große Unsichtbarkeit entdecken
          { default        = false, singleFamily = { 132, 2970, 11743 },
            singleDuration = DURATION_10M, targetClasses = BOM_ALL_CLASSES },
          warlockOnly)
  BOM.Class.SpellDef:scan_spell(spells, 28610, -- Shadow Ward / Schattenzauberschutz
          { isOwn = true, default = false, singleFamily = { 6229, 11739, 11740, 28610 } },
          warlockOnly)
  BOM.Class.SpellDef:scan_spell(spells, 28176, -- TBC: Fel Armor
          { isOwn = true, default = false, singleFamily = { 28176, 28189 } }, -- TBC: Rank 1-2
          { isTBC = true, playerClass = "WARLOCK" })
  BOM.Class.SpellDef:scan_spell(spells, 11735, -- Demon Armor
          { isOwn = true, default = false, singleFamily = { 706, 1086, 11733, 11734, 11735, -- Rank 5
                                                            27260 } }, -- TBC: Rank 6
          warlockOnly)
  -- Obsolete at level 20, assuming the player will visit the trainer and at 21
  -- the spell will disappear from Buffomat
  BOM.Class.SpellDef:scan_spell(spells, 696, -- Demon skin
          { isOwn = true, default = false, singleFamily = { 687, 696 } },
          { playerClass = "WARLOCK", maxLevel = 20 })

  BOM.Class.SpellDef:scan_spell(spells, 17953, -- Firestone
          { isOwn          = true, default = false,
            lockIfHaveItem = { 1254, 13699, 13700, 13701,
                               22128 }, -- TBC: Master Firestone
            singleFamily   = { 6366, 17951, 17952, 17953, -- Rank 1-4
                               27250 } }, -- TBC: Rank 5
          warlockOnly)
  BOM.Class.SpellDef:scan_spell(spells, 17728, -- Spellstone
          { isOwn          = true, default = false,
            lockIfHaveItem = { 5522, 13602, 13603, -- "normal", Greater, Major Spellstone
                               22646 }, -- TBC: Master Spellstone
            singleFamily   = { 2362, 17727, 17728, -- Rank 1-3
                               28172 } }, -- TBC: Rank 4
          warlockOnly)
  BOM.Class.SpellDef:scan_spell(spells, 11730, -- Healtstone
          { isOwn          = true, default = true,
            lockIfHaveItem = { 5512, 19005, 19004, 5511, 19007, 19006, 5509, 19009,
                               19008, 5510, 19011, 19010, 9421, 19013, 19012, -- Healthstones (3 talent ranks)
                               22103, 22104, 22105 }, -- TBC: Master Healthstone (3 talent ranks)
            singleFamily   = { 6201, 6202, 5699, 11729, 11730, -- Rank 1-5
                               27230 } },
          warlockOnly) -- TBC: Rank 6
  BOM.Class.SpellDef:scan_spell(spells, 20757, --Soulstone
          { isOwn          = true, default = true,
            lockIfHaveItem = { 5232, 16892, 16893, 16895, 16896,
                               22116 }, -- TBC: Master Soulstone
            singleFamily   = { 693, 20752, 20755, 20756, 20757, -- Ranks 1-5
                               27238 } },
          warlockOnly) -- TBC: Rank 6
  BOM.Class.SpellDef:scan_spell(spells, 5500, --Sense Demons
          { type = "tracking", default = false },
          warlockOnly)

  ------------------------
  -- Pet Management
  ------------------------
  BOM.Class.SpellDef:scan_spell(spells, BOM.SpellId.Warlock.DemonicSacrifice, -- Demonic Sacrifice
          { isOwn = true, default = true, requiresWarlockPet = true },
          warlockOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19028, -- TBC: Soul Link, talent spell 19028, gives buff 25228
          { isOwn              = true, default = true, singleFamily = { 19028, 25228 },
            requiresWarlockPet = true },
          warlockOnly)

  BOM.Class.SpellDef:scan_spell(spells, 688, --Summon Imp
          { type           = "summon", default = true, isOwn = true,
            creatureFamily = "Imp", creatureType = "Demon", sacrificeAuraIds = { 18789 } },
          warlockOnly)

  BOM.Class.SpellDef:scan_spell(spells, 697, --Summon Voidwalker
          { type            = "summon", default = false, isOwn = true,
            reagentRequired = { BOM.ItemId.Warlock.SoulShard },
            creatureFamily  = "Voidwalker", creatureType = "Demon",
            sacrificeAuraIds = { 18790, 1905 } }, -- TBC: Restore 2% hp, and Classic: Shield the warlock
          warlockOnly)

  BOM.Class.SpellDef:scan_spell(spells, 712, --Summon Succubus
          { type            = "summon", default = false, isOwn = true,
            reagentRequired = { BOM.ItemId.Warlock.SoulShard },
            creatureFamily  = "Succubus", creatureType = "Demon", sacrificeAuraIds = { 18791 } },
          warlockOnly)

  BOM.Class.SpellDef:scan_spell(spells, 691, --Summon Felhunter
          { type            = "summon", default = false, isOwn = true,
            reagentRequired = { BOM.ItemId.Warlock.SoulShard },
            creatureFamily  = "Felhunter", creatureType = "Demon", sacrificeAuraIds = { 18792 } },
          warlockOnly)

  BOM.Class.SpellDef:scan_spell(spells, 30146, --Summon Felguard
          { type            = "summon", default = false, isOwn = true,
            reagentRequired = { BOM.ItemId.Warlock.SoulShard },
            creatureFamily  = "Felguard", creatureType = "Demon", sacrificeAuraIds = { 35701 } },
          warlockOnly)
end

---Add HUNTER spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_hunter_spells(spells, enchants)
  local hunterOnly = { playerClass = "HUNTER" }

  BOM.Class.SpellDef:scan_spell(spells, 20906, -- Trueshot Aura
          { isOwn        = true, default = true,
            singleFamily = { 19506, 20905, 20906, -- Ranks 1-3
                             27066 } }, -- TBC: Rank 4
          hunterOnly)

  BOM.Class.SpellDef:scan_spell(spells, 25296, --Aspect of the Hawk
          { type         = "aura", default = true,
            singleFamily = { 13165, 14318, 14319, 14320, 14321, 14322, 25296, -- Rank 1-7
                             27044 } }, -- TBC: Rank 8
          hunterOnly)
  BOM.Class.SpellDef:scan_spell(spells, 13163, --Aspect of the monkey
          { type = "aura", default = false },
          hunterOnly)
  BOM.Class.SpellDef:scan_spell(spells, 34074, -- TBC: Aspect of the Viper
          { type = "aura", default = false },
          { playerClass = "HUNTER", isTBC = true })
  BOM.Class.SpellDef:scan_spell(spells, 20190, --Aspect of the wild
          { type         = "aura", default = false,
            singleFamily = { 20043, 20190, -- Ranks 1-2
                             27045 } }, -- TBC: Rank 3
          hunterOnly)
  BOM.Class.SpellDef:scan_spell(spells, 5118, --Aspect of the Cheetah
          { type = "aura", default = false }, hunterOnly)
  BOM.Class.SpellDef:scan_spell(spells, 13159, --Aspect of the pack
          { type = "aura", default = false }, hunterOnly)
  BOM.Class.SpellDef:scan_spell(spells, 13161, -- Aspect of the beast
          { type = "aura", default = false }, hunterOnly)

  BOM.Class.SpellDef:scan_spell(spells, 1494, -- Track Beast
          { type = "tracking", default = false }, hunterOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19878, -- Track Demon
          { type = "tracking", default = false }, hunterOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19879, -- Track Dragonkin
          { type = "tracking", default = false }, hunterOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19880, -- Track Elemental
          { type = "tracking", default = false }, hunterOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19883, -- Track Humanoids
          { type = "tracking", default = false }, hunterOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19882, -- Track Giants / riesen
          { type = "tracking", default = false }, hunterOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19884, -- Track Undead
          { type = "tracking", default = false }, hunterOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19885, -- Track Hidden / verborgenes
          { type = "tracking", default = false }, hunterOnly)

  -- TODO: Do not use tbc_consumable function, add new flags for pet-buff
  BOM.Class.SpellDef:tbc_consumable(spells, 43771, 33874,
          hunterOnly, "Pet buff +Str",
          { tbcHunterPetBuff = true }) --TBC: Kibler's Bits +20 STR/20 SPI for hunter pet
  BOM.Class.SpellDef:tbc_consumable(spells, 33272, 27656,
          hunterOnly, "Pet buff +Stamina",
          { tbcHunterPetBuff = true }) --TBC: Sporeling Snack +20 STAM/20 SPI for hunter pet
end

---Add PALADIN spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_paladin_spells(spells, enchants)
  local paladinOnly = { playerClass = "PALADIN" }

  BOM.Class.SpellDef:scan_spell(spells, 25780, --Righteous Fury, same in TBC
          { isOwn = true, default = false })

  local blessing_duration = tbc_or_classic(DURATION_10M, DURATION_5M)
  local greater_blessing_duration = tbc_or_classic(DURATION_15M, DURATION_30M)

  --
  -- LESSER BLESSINGS

  BOM.Class.SpellDef:scan_spell(spells, 20217, --Blessing of Kings
          { groupFamily    = { 25898 }, isBlessing = true, default = true,
            singleDuration = blessing_duration, ignoreIfHaveBuff = { 25898 }, -- Greater kings
            targetClasses  = { "MAGE", "HUNTER", "WARLOCK" } },
          paladinOnly)

  BOM.Class.SpellDef:scan_spell(spells, 19979, -- Blessing of Light
          { singleFamily   = { 19977, 19978, 19979, -- Ranks 1-3
                               27144 }, -- TBC: Rank 4
            isBlessing     = true, default = true, ignoreIfHaveBuff = { 21177 }, -- Greater Light
            singleDuration = blessing_duration, groupDuration = greater_blessing_duration,
            targetClasses  = BOM_NO_CLASS },
          paladinOnly)

  BOM.Class.SpellDef:scan_spell(spells, 25291, --Blessing of Might
          { isBlessing     = true, default = true, ignoreIfHaveBuff = { 25782, 25916, 27141 }, -- Greater Might
            singleFamily   = { 19740, 19834, 19835, 19836, 19837, 19838, 25291, -- Ranks 1-7
                               27140 }, -- TBC: Rank 8
            singleDuration = blessing_duration, targetClasses = { "WARRIOR", "ROGUE" } },
          paladinOnly)

  BOM.Class.SpellDef:scan_spell(spells, 1038, --Blessing of Salvation
          { isBlessing    = true, default = true, singleDuration = blessing_duration,
            targetClasses = BOM_NO_CLASS, ignoreIfHaveBuff = { 25895 }, },
          paladinOnly)

  BOM.Class.SpellDef:scan_spell(spells, 25290, --Blessing of Wisdom
          { isBlessing     = true, default = true,
            singleFamily   = { 19742, 19850, 19852, 19853, 19854, 25290, -- Ranks 1-6
                               27142 }, -- TBC: Rank 7
            singleDuration = blessing_duration, groupDuration = greater_blessing_duration,
            targetClasses  = { "DRUID", "SHAMAN", "PRIEST", "PALADIN" } },
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 20914, --Blessing of Sanctuary
          { isBlessing      = true, default = true,
            groupFamily     = { 25899, -- Rank 1
                                27169 }, -- TBC: Rank 2
            singleFamily    = { 20911, 20912, 20913, 20914, -- Ranks 1-4
                                27168 }, -- TBC: Rank 5
            reagentRequired = { 21177 },
            singleDuration  = blessing_duration, groupDuration = greater_blessing_duration,
            targetClasses   = BOM_NO_CLASS },
          paladinOnly)
  --
  -- GREATER BLESSINGS
  --
  BOM.Class.SpellDef:scan_spell(spells, 25898, --Greater Blessing of Kings
          { isBlessing      = true, default = true, singleDuration = greater_blessing_duration,
            reagentRequired = { 21177 }, targetClasses = { "MAGE", "HUNTER", "WARLOCK" }, },
          paladinOnly)

  BOM.Class.SpellDef:scan_spell(spells, 25890, -- Greater Blessing of Light
          { singleFamily    = { 25890, -- Rank 1
                                27145 }, -- TBC: Rank 2
            isBlessing      = true, default = false,
            reagentRequired = { 21177 }, singleDuration = greater_blessing_duration,
            targetClasses   = BOM_NO_CLASS },
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 25916, --Greater Blessing of Might
          { isBlessing      = true, default = false,
            singleFamily    = { 25782, 25916, -- Ranks 1-2
                                27141 }, -- TBC: Rank 3
            singleDuration  = greater_blessing_duration,
            reagentRequired = { 21177 }, targetClasses = { "WARRIOR", "ROGUE" } },
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 25895, --Greater Blessing of Salvation
          { singleFamily    = { 25895 }, isBlessing = true, default = false,
            singleDuration  = greater_blessing_duration,
            reagentRequired = { 21177 }, targetClasses = BOM_NO_CLASS },
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 25918, --Greater Blessing of Wisdom
          { isBlessing      = true, default = false,
            singleFamily    = { 25894, 25918, -- Ranks 1-2
                                27143 }, -- TBC: Rank 3
            singleDuration  = greater_blessing_duration,
            reagentRequired = { 21177 }, targetClasses = { "DRUID", "SHAMAN", "PRIEST", "PALADIN" } },
          paladinOnly)

  -- END ------
  --
  -- ----------------------------------
  --
  BOM.Class.SpellDef:scan_spell(spells, 10293, -- Devotion Aura
          { type         = "aura", default = false,
            singleFamily = { 465, 10290, 643, 10291, 1032, 10292, 10293, -- Rank 1-7
                             27149 } }, -- TBC: Rank 8
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 10301, -- Retribution Aura
          { type         = "aura", default = true,
            singleFamily = { 7294, 10298, 10299, 10300, 10301, -- Ranks 1-5
                             27150 } }, -- TBC: Rank 6
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19746, --Concentration Aura
          { type = "aura", default = false },
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19896, -- Shadow Resistance Aura
          { type = "aura", default = false, singleFamily = { 19876, 19895, 19896, -- Rank 1-3
                                                             27151 } }, -- TBC: Rank 4
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19898, -- Frost Resistance Aura
          { type = "aura", default = false, singleFamily = { 19888, 19897, 19898, -- Rank 1-3
                                                             27152 } }, -- TBC: Rank 4
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 19900, -- Fire Resistance Aura
          { type = "aura", default = false, singleFamily = { 19891, 19899, 19900, -- Rank 1-3
                                                             27153 } }, -- TBC: Rank 4
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 20218, --Sanctity Aura
          { type = "aura", default = false },
          paladinOnly)
  --
  -- ----------------------------------
  --
  BOM.Class.SpellDef:scan_spell(spells, 20773, -- Redemption / Auferstehung
          { type = "resurrection", default = true, singleFamily = { 7328, 10322, 10324, 20772, 20773 } },
          paladinOnly)

  BOM.Class.SpellDef:scan_spell(spells, 20164, -- Sanctity seal
          { type = "seal", default = false },
          { playerClass = "PALADIN", isTBC = false })

  BOM.Class.SpellDef:scan_spell(spells, 5502, -- Sense undead
          { type = "tracking", default = false },
          paladinOnly)

  BOM.Class.SpellDef:scan_spell(spells, 20165, -- Seal of Light
          { type         = "seal", default = false,
            singleFamily = { 20165, 20347, 20348, 20349, -- Ranks 1-4
                             27160 } }, -- TBC: Rank 5
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 20154, -- Seal of Righteousness
          { type         = "seal", default = false,
            singleFamily = { 20154, 20287, 20288, 20289, 20290, 20291, 20292, 20293, -- Ranks 1-8
                             27155 } }, -- TBC: Seal rank 9
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 20166, -- Seal of Wisdom
          { type = "seal", default = false },
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 348704, -- TBC: Seal of Vengeance
          { type         = "seal", default = false,
            singleFamily = { 31801, -- TBC: level 70 spell for Blood Elf
                             348704 } }, -- TBC: Base spell for the alliance races
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 348700, -- TBC: Seal of the Martyr (Draenei, Dwarf, Human)
          { type = "seal", default = false },
          paladinOnly)
  BOM.Class.SpellDef:scan_spell(spells, 31892, -- TBC: Seal of Blood
          { type         = "seal", default = false,
            singleFamily = { 31892, -- TBC: Base Blood Elf spell
                             38008 } }, -- TBC: Alliance version???
          paladinOnly)
end

---Add WARRIOR spells
local function bom_setup_warrior_spells(spells, enchants)
  local warriorOnly = { playerClass = "WARRIOR" }

  BOM.Class.SpellDef:scan_spell(spells, 25289, --Battle Shout
          { isOwn        = true, default = true, default = false,
            singleFamily = { 6673, 5242, 6192, 11549, 11550, 11551, 25289, -- Ranks 1-7
                             2048 } }, -- TBC: Rank 8
          warriorOnly)
  BOM.Class.SpellDef:scan_spell(spells, 2457, --Battle Stance
          { isOwn = true, default = true, default = false, singleId = 2457, shapeshiftFormId = 17 },
          warriorOnly)
  BOM.Class.SpellDef:scan_spell(spells, 71, --Defensive Stance
          { isOwn = true, default = true, default = false, singleId = 71, shapeshiftFormId = 18 },
          warriorOnly)
  BOM.Class.SpellDef:scan_spell(spells, 2458, --Berserker Stance
          { isOwn = true, default = true, default = false, singleId = 2458, shapeshiftFormId = 19 },
          warriorOnly)
end

---Add ROGUE spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_rogue_spells(spells, enchants)
  local duration = tbc_or_classic(DURATION_1H, DURATION_30M) -- TBC: Poisons become 1 hour

  BOM.Class.SpellDef:scan_spell(spells, 25351, --Deadly Poison
          { item         = tbc_or_classic(22054, 20844),
            items        = { 22054, 22053, -- TBC: Deadly Poison
                             20844, 8985, 8984, 2893, 2892 },
            isConsumable = true, type = "weapon", duration = duration, default = false },
          { playerClass = "ROGUE", minLevel = 2 })
  enchants[25351] = { 2643, 2642, -- TBC: Deadly Poison
                      2630, 627, 626, 8, 7 } --Deadly Poison

  BOM.Class.SpellDef:scan_spell(spells, 11399, --Mind-numbing Poison
          { item     = 9186, items = { 9186, 6951, 5237 }, isConsumable = true, type = "weapon",
            duration = duration, default = false },
          { playerClass = "ROGUE", minLevel = 24 })
  enchants[11399] = { 643, 23, 35 } --Mind-numbing Poison

  BOM.Class.SpellDef:scan_spell(spells, 11340, --Instant Poison
          { item         = tbc_or_classic(21927, 8928),
            items        = { 21927, -- TBC: Instant Poison
                             8928, 8927, 8926, 6950, 6949, 6947 },
            isConsumable = true, type = "weapon", duration = duration, default = false },
          { playerClass = "ROGUE", minLevel = 20 })
  enchants[11340] = { 2641, -- TBC: Instant Poison
                      625, 624, 623, 325, 324, 323 } --Instant Poison

  BOM.Class.SpellDef:scan_spell(spells, 13227, --Wound Poison
          { item         = tbc_or_classic(22055, 10922),
            items        = { 22055, -- TBC: Wound Poison
                             10922, 10921, 10920, 10918 },
            isConsumable = true, type = "weapon", duration = duration, default = false },
          { playerClass = "ROGUE", minLevel = 32 })
  enchants[13227] = { 2644, -- TBC: Wound Poison
                      706, 705, 704, 703 } --Wound Poison

  BOM.Class.SpellDef:scan_spell(spells, 11202, --Crippling Poison
          { item     = 3776, items = { 3776, 3775 }, isConsumable = true, type = "weapon",
            duration = duration, default = false },
          { playerClass = "ROGUE", minLevel = 20 })
  enchants[11202] = { 603, 22 } --Crippling Poison

  BOM.Class.SpellDef:scan_spell(spells, 26785, --TBC: Anesthetic Poison
          { item         = 21835, items = { 21835 },
            isConsumable = true, type = "weapon", duration = duration, default = false },
          { playerClass = "ROGUE", isTBC = true, minLevel = 68 })
  enchants[26785] = { 2640, } --TBC: Anesthetic Poison
end

---Add RESOURCE TRACKING spells
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_tracking_spells(spells, enchants)
  tinsert(spells, BOM.Class.SpellDef:new(BOM.SpellId.FindHerbs, -- Find Herbs / kräuter
          { type = "tracking", default = true }))
  tinsert(spells, BOM.Class.SpellDef:new(BOM.SpellId.FindMinerals, -- Find Minerals / erz
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
  --tinsert(spells, BOM.Class.SpellDef:new(20762, --Soulstone | Seelenstein
  --        { isInfo       = true, allowWhisper = true, default = false,
  --          singleFamily = { 20707, 20762, 20763, 20765, 20764 } }))
  return spells
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_phys_dps_battle_elixirs(spells, enchants)
  BOM.Class.SpellDef:scan_spell(spells, 28497, --TBC: Elixir of Major Agility +35 AGI +20 CRIT
          { item          = 22831, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.TBC_ERA },
          { isTBC = true })
  BOM.Class.SpellDef:scan_spell(spells, 38954, --TBC: Fel Strength Elixir +90AP -10 STA
          { item          = 31679, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.TBC_ERA },
          { isTBC = true })
  BOM.Class.SpellDef:scan_spell(spells, 28490, --TBC: Elixir of Major Strength +35 STR
          { item          = 22824, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.TBC_ERA },
          { isTBC = true })
  BOM.Class.SpellDef:scan_spell(spells, 33720, --TBC: Onslaught Elixir +60 AP
          { item          = 28102, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.TBC_ERA },
          { isTBC = true })
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_phys_dps_guardian_elixirs(spells, enchants)
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_phys_dps_buffs(spells, enchants)
  BOM.Class.SpellDef:scan_spell(spells, 17538, --Elixir of the Mongoose
          { item          = 13452, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.CLASSIC_ERA })
  BOM.Class.SpellDef:scan_spell(spells, 11334, --Elixir of Greater Agility
          { item          = 9187, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.CLASSIC_ERA })
  BOM.Class.SpellDef:scan_spell(spells, 11405, --Elixir of Giants
          { item          = 9206, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.CLASSIC_ERA })
  BOM.Class.SpellDef:scan_spell(spells, 17038, --Winterfall Firewater
          { item          = 12820, isConsumable = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.CLASSIC_ERA })
  BOM.Class.SpellDef:scan_spell(spells, 16329, --Juju Might +40AP
          { item          = 12460, isConsumable = true, default = false,
            consumableEra = BOM.CLASSIC_ERA })
  BOM.Class.SpellDef:scan_spell(spells, 16323, --Juju Power +30Str
          { item = 12451, isConsumable = true, default = false, consumableEra = BOM.CLASSIC_ERA })

  --
  -- Weightstones for blunt weapons
  --
  BOM.Class.SpellDef:scan_spell(spells, 16622, --Weightstone
          { item         = 12643, items = { 12643, 7965, 3241, 3240, 3239 },
            isConsumable = true, type = "weapon", duration = DURATION_30M,
            default      = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.CLASSIC_ERA })
  enchants[16622] = { 1703, 484, 21, 20, 19 } -- Weightstone

  BOM.Class.SpellDef:scan_spell(spells, 34340, --TBC: Adamantite Weightstone +12 BLUNT +14 CRIT
          { item    = 28421, items = { 28421 }, isConsumable = true, type = "weapon", duration = DURATION_1H,
            default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.TBC_ERA },
          { isTBC = true })
  enchants[34340] = { 2955 } --TBC: Adamantite Weightstone (Weight Weapon)

  BOM.Class.SpellDef:scan_spell(spells, 34339, --TBC: Fel Weightstone +12 BLUNT
          { item    = 28420, items = { 28420 }, isConsumable = true, type = "weapon", duration = DURATION_1H,
            default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.TBC_ERA },
          { isTBC = true })
  enchants[34339] = { 2954 } --TBC: Fel Weightstone (Weighted +12)


  --
  -- Sharpening Stones for sharp weapons
  --
  BOM.Class.SpellDef:scan_spell(spells, 16138, --Sharpening Stone
          { item          = 12404, items = { 12404, 7964, 2871, 2863, 2862 },
            isConsumable  = true, type = "weapon", duration = DURATION_30M, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.CLASSIC_ERA })
  enchants[16138] = { 1643, 483, 14, 13, 40 } --Sharpening Stone
  BOM.Class.SpellDef:scan_spell(spells, 28891, --Consecrated Sharpening Stone
          { item     = 23122, isConsumable = true, type = "weapon",
            duration = DURATION_1H, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.CLASSIC_ERA })
  enchants[28891] = { 2684 } --Consecrated Sharpening Stone
  BOM.Class.SpellDef:scan_spell(spells, 22756, --Elemental Sharpening Stone
          { item     = 18262, isConsumable = true, type = "weapon",
            duration = DURATION_30M, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.CLASSIC_ERA })
  enchants[22756] = { 2506 } --Elemental Sharpening Stone

  BOM.Class.SpellDef:scan_spell(spells, 29453, --TBC: Adamantite Sharpening Stone +12 WEAPON +14 CRIT
          { item    = 23529, items = { 23529 }, isConsumable = true, type = "weapon", duration = DURATION_1H,
            default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.TBC_ERA },
          { isTBC = true })
  BOM.Class.SpellDef:scan_spell(spells, 29452, --TBC: Fel Sharpening Stone +12 WEAPON
          { item    = 23528, items = { 23528 }, isConsumable = true, type = "weapon", duration = DURATION_1H,
            default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES, consumableEra = BOM.TBC_ERA },
          { isTBC = true })
  enchants[29452] = { 2712 } --TBC: Fel Sharpening Stone (Sharpened +12)
  enchants[29453] = { 2713 } --TBC: Adamantite Sharpening Stone (Sharpened +14 Crit, +12)

  --
  -- Food (pre TBC)
  --
  BOM.Class.SpellDef:scan_spell(spells, 18192, --Grilled Squid +10 Agility
          { item          = 13928, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES,
            consumableEra = BOM.CLASSIC_ERA },
          { isTBC = false }) -- hide in TBC
  BOM.Class.SpellDef:scan_spell(spells, 24799, --Smoked Desert Dumplings +Strength
          { item          = 20452, isConsumable = true, default = false, onlyUsableFor = BOM_PHYSICAL_CLASSES,
            consumableEra = BOM.CLASSIC_ERA },
          { isTBC = false }) -- hide in TBC
  BOM.Class.SpellDef:classic_consumable(spells, 18125, 13810, --Blessed Sunfruit +STR
          { playerClass = BOM_MELEE_CLASSES })
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_caster_battle_elixirs(spells, enchants)
  -- Not visible in Classic
  BOM.Class.SpellDef:tbc_consumable(spells, 28273, 22710, --TBC: Bloodthistle (Belf only)
          { playerRace = "BloodElf", playerClass = BOM_MANA_CLASSES },
          "+10 spell")

  BOM.Class.SpellDef:tbc_consumable(spells, 28509, 22840) --TBC: Elixir of Major Mageblood +16 mp5
  BOM.Class.SpellDef:tbc_consumable(spells, 28503, 22835, --TBC: Elixir of Major Shadow Power +55 SHADOW
          { playerClass = BOM_SHADOW_CLASSES })
  BOM.Class.SpellDef:tbc_consumable(spells, 28501, 22833, --TBC: Elixir of Major Firepower +55 FIRE
          { playerClass = BOM_FIRE_CLASSES })
  BOM.Class.SpellDef:tbc_consumable(spells, 28493, 22827, --TBC: Elixir of Major Frost Power +55 FROST
          { playerClass = BOM_FROST_CLASSES })
  BOM.Class.SpellDef:tbc_consumable(spells, 28491, 22825, --TBC: Elixir of Healing Power +50 HEAL
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:tbc_consumable(spells, 33721, 28103, --TBC: Adept's Elixir +24 SPELL, +24 SPELLCRIT
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:tbc_consumable(spells, 39627, 32067, --TBC: Elixir of Draenic Wisdom +30 SPI
          { playerClass = BOM_MANA_CLASSES })

  -- Visible in TBC but marked as Classic consumables
  BOM.Class.SpellDef:classic_consumable(spells, 24363, 20007, --Mageblood Potion
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:classic_consumable(spells, 17539, 13454, --Greater Arcane Elixir
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:classic_consumable(spells, 11390, 9155, --Greater Arcane Elixir
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:classic_consumable(spells, 11474, 9264, -- Elixir of Shadow Power
          { playerClass = BOM_SHADOW_CLASSES })
  BOM.Class.SpellDef:classic_consumable(spells, 26276, 21546, --Elixir of Greater Firepower
          { playerClass = BOM_FIRE_CLASSES })
  BOM.Class.SpellDef:classic_consumable(spells, 21920, 17708, --Elixir of Frost Power
          { playerClass = BOM_FROST_CLASSES })
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_caster_guardian_elixirs(spells, enchants)
  BOM.Class.SpellDef:tbc_consumable(spells, 28514, 22848)--TBC: Elixir of Empowerment, -30 TARGET RESIST
end

---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_caster_buffs(spells, enchants)
  BOM.Class.SpellDef:classic_consumable(spells, 18194, 13931, --Nightfin Soup +8Mana/5
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:classic_consumable(spells, 19710, 12218, --Monster Omelette
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:scan_spell(spells, 18141, --Blessed Sunfruit Juice +10 SPIRIT
          { item          = 13813, isConsumable = true, default = false, onlyUsableFor = BOM_MANA_CLASSES,
            consumableEra = BOM.CLASSIC_ERA },
          { isTBC = false }) -- hide in TBC

  BOM.Class.SpellDef:scan_spell(spells, 28017, --Superior Wizard Oil +42 SPELL
          { item = 22522, items = { 22522 }, isConsumable = true,
            type = "weapon", duration = DURATION_1H, default = false, onlyUsableFor = BOM_MANA_CLASSES },
          { isTBC = true })

  BOM.Class.SpellDef:scan_spell(spells, 25123, --Minor, Lesser, Brilliant Mana Oil
          { item     = 20748, isConsumable = true, type = "weapon",
            items    = { 20748, 20747, 20745, -- Minor, Lesser, Brilliant Mana Oil
                         22521 }, -- TBC: Superior Mana Oil
            duration = DURATION_30M, default = false, onlyUsableFor = BOM_MANA_CLASSES })
  enchants[25123] = { 2624, 2625, 2629, -- Minor, Lesser, Brilliant Mana Oil (enchant)
                      2677 } -- TBC: Superior Mana Oil (enchant)

  BOM.Class.SpellDef:scan_spell(spells, 25122, -- Wizard Oil
          { item     = 20749, isConsumable = true, type = "weapon",
            items    = { 20749, 20746, 20744, 20750, --Minor, Lesser, "regular", Brilliant Wizard Oil
                         22522 }, -- TBC: Superior Wizard Oil
            duration = DURATION_30M, default = false, onlyUsableFor = BOM_MANA_CLASSES })
  enchants[25122] = { 2623, 2626, 2627, 2628, --Minor, Lesser, "regular", Brilliant Wizard Oil (enchant)
                      2678 }, -- TBC: Superior Wizard Oil (enchant)

  BOM.Class.SpellDef:scan_spell(spells, 28898, --Blessed Wizard Oil
          { item     = 23123, isConsumable = true, type = "weapon",
            duration = DURATION_1H, default = false, onlyUsableFor = BOM_MANA_CLASSES })
  enchants[28898] = { 2685 } --Blessed Wizard Oil
end

---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_battle_elixirs(spells, enchants)
  -- Sunwell only
  --tinsert(s, BOM.Class.SpellDef:new(45373, --TBC: Bloodberry Elixir +15 all stats
  --        { item = 34537, isConsumable = true, default = false }))
  BOM.Class.SpellDef:tbc_consumable(spells, 33726, 28104) --TBC: Elixir of Mastery +15 all stats
end

---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_guardian_elixirs(spells, enchants)
  BOM.Class.SpellDef:tbc_consumable(spells, 28502, 22834) --TBC: Elixir of Major Defense +550 ARMOR
  BOM.Class.SpellDef:tbc_consumable(spells, 39628, 32068) --TBC: Elixir of Ironskin +30 RESIL
  BOM.Class.SpellDef:tbc_consumable(spells, 39625, 32062) --TBC: Elixir of Major Fortitude +250 HP and 10 HP/5
  BOM.Class.SpellDef:tbc_consumable(spells, 39626, 32063) --TBC: Earthen Elixir -20 ALL DMG TAKEN

  BOM.Class.SpellDef:classic_consumable(spells, 3593, 3825) --Elixir of Fortitude
  BOM.Class.SpellDef:classic_consumable(spells, 11348, 13445) --Elixir of Superior Defense
  BOM.Class.SpellDef:classic_consumable(spells, 24361, 20004) --Major Troll's Blood Potion
  BOM.Class.SpellDef:classic_consumable(spells, 11371, 9088) --Gift of Arthas
  BOM.Class.SpellDef:classic_consumable(spells, 16326, 12455) --Juju Ember +15FR
  BOM.Class.SpellDef:classic_consumable(spells, 16325, 12457) --Juju Chill +15FrostR

  BOM.Class.SpellDef:classic_consumable(spells, 22730, 18254) --Runn Tum Tuber Surprise
  BOM.Class.SpellDef:classic_consumable(spells, 25661, 21023) --Dirge's Kickin' Chimaerok Chops x
  BOM.Class.SpellDef:classic_consumable(spells, 22790, 18284, --Kreeg's Stout Beatdown
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:classic_consumable(spells, 22789, 18269) --Gordok Green Grog
  BOM.Class.SpellDef:classic_consumable(spells, 25804, 21151) --Rumsey Rum Black Label

  BOM.Class.SpellDef:classic_consumable(spells, 17549, 13461) --Greater Arcane Protection Potion
  BOM.Class.SpellDef:classic_consumable(spells, 17543, 13457) --Greater Fire Protection Potion
  BOM.Class.SpellDef:classic_consumable(spells, 17544, 13456) --Greater Frost Protection Potion
  BOM.Class.SpellDef:classic_consumable(spells, 17546, 13458) --Greater Nature Protection Potion
  BOM.Class.SpellDef:classic_consumable(spells, 17548, 13459) --Greater Shadow Protection Potion

  BOM.Class.SpellDef:tbc_consumable(spells, 28536, 22845) --Major Arcane Protection Potion (crafted and cauldron 32840)
  BOM.Class.SpellDef:tbc_consumable(spells, 28511, 22841) --Major Fire Protection Potion (crafted and cauldron 32846)
  BOM.Class.SpellDef:tbc_consumable(spells, 28512, 22842) --Major Frost Protection Potion (crafted and cauldron 32847)
  BOM.Class.SpellDef:tbc_consumable(spells, 28513, 22844) --Major Nature Protection Potion (crafted and cauldron 32844)
  BOM.Class.SpellDef:tbc_consumable(spells, 28537, 22846) --Major Shadow Protection Potion (crafted and cauldron 32845)
  BOM.Class.SpellDef:tbc_consumable(spells, 28538, 22847) --Major Holy Protection Potion (crafted)
end

---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_item_spells(spells, enchants)
  BOM.Class.SpellDef:classic_consumable(spells, 15233, 11564) --Crystal Ward
  BOM.Class.SpellDef:classic_consumable(spells, 15279, 11567) --Crystal Spire +12 THORNS
  BOM.Class.SpellDef:classic_consumable(spells, 15231, 11563) --Crystal Force +30 SPI
end

---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_food(spells, enchants)
  BOM.Class.SpellDef:tbc_consumable(spells, 33257, { 33052, 27667 }, --Well Fed +30 STA +20 SPI
          nil, L.TooltipSimilarFoods)

  BOM.Class.SpellDef:tbc_consumable(spells, 35254, { 27651, 30155, 27662, 33025 }, --Well Fed +20 STA +20 SPI
          nil, L.TooltipSimilarFoods)
  --BOM.Class.SpellDef:tbc_consumable(spells, 35272, { 27660, 31672, 33026 }) --Well Fed +20 STA +20 SPI

  -- Warp Burger, Grilled Mudfish, ...
  BOM.Class.SpellDef:tbc_consumable(spells, 33261, { 27659, 30358, 27664, 33288, 33293 }, --Well Fed +20 AGI +20 SPI
          { playerClass = BOM_PHYSICAL_CLASSES }, L.TooltipSimilarFoods)
  BOM.Class.SpellDef:tbc_consumable(spells, 43764, 33872, --Spicy Hot Talbuk: Well Fed +20 HITRATING +20 SPI
          { playerClass = BOM_PHYSICAL_CLASSES })
  BOM.Class.SpellDef:tbc_consumable(spells, 33256, { 27658, 30359 }, -- Well Fed +20 STR +20 SPI
          { playerClass = BOM_MELEE_CLASSES }, L.TooltipSimilarFoods)
  BOM.Class.SpellDef:tbc_consumable(spells, 33259, 27655) --Ravager Dog: Well Fed +40 AP +20 SPI
  BOM.Class.SpellDef:tbc_consumable(spells, 46899, 35563, --Charred Bear Kabobs +24 AP
          { playerClass = BOM_PHYSICAL_CLASSES })

  BOM.Class.SpellDef:tbc_consumable(spells, 41030, 32721, --Skyguard Rations: Well Fed +15 STA +15 SPI
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:tbc_consumable(spells, 33263, { 27657, 31673, 27665, 30361 }, --Well Fed +23 SPELL +20 SPI
          { playerClass = BOM_MANA_CLASSES },
          L.TooltipSimilarFoods)
  BOM.Class.SpellDef:tbc_consumable(spells, 33265, 27663, --Blackened Sporefish: Well Fed +8 MP5 +20 STA
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:tbc_consumable(spells, 33268, { 27666, 30357 }, --Golden Fish Sticks: Well Fed +44 HEAL +20 SPI
          { playerClass = BOM_MANA_CLASSES },
          L.TooltipSimilarFoods)
end

---@param spells table<string, SpellDef>
---@param enchants table<string, table<number>>
local function bom_setup_flasks(spells, enchants)
  BOM.Class.SpellDef:tbc_consumable(spells, 28540, 22866, --TBC: Flask of Pure Death +80 SHADOW +80 FIRE +80 FROST
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:tbc_consumable(spells, 28520, 22854, --TBC: Flask of Relentless Assault +120 AP
          { playerClass = BOM_PHYSICAL_CLASSES })
  BOM.Class.SpellDef:tbc_consumable(spells, 28521, 22861, --TBC: Flask of Blinding Light +80 ARC +80 HOLY +80 NATURE
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:tbc_consumable(spells, 28518, 22851) --TBC: Flask of Fortification +500 HP +10 DEF RATING
  BOM.Class.SpellDef:tbc_consumable(spells, 28519, 22853) --TBC: Flask of Mighty Restoration +25 MP/5
  BOM.Class.SpellDef:tbc_consumable(spells, 42735, 33208) --TBC: Flask of Chromatic Wonder +35 ALL RESIST +18 ALL STATS

  -- TODO: Shattrath Flask of... (SSC and Tempest Keep only)
  -- TODO: Unstable Flask of... (Blade's Edge and Gruul's Lair only)

  BOM.Class.SpellDef:classic_consumable(spells, 17628, 13512, --Flask of Supreme Power +70 SPELL
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:classic_consumable(spells, 17626, 13510) --Flask of the Titans +400 HP
  BOM.Class.SpellDef:classic_consumable(spells, 17627, 13511, --Flask of Distilled Wisdom +65 INT
          { playerClass = BOM_MANA_CLASSES })
  BOM.Class.SpellDef:classic_consumable(spells, 17629, 13513) --Flask of Chromatic Resistance

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
  bom_setup_battle_elixirs(spells, enchants)
  bom_setup_guardian_elixirs(spells, enchants)
  bom_setup_flasks(spells, enchants)

  bom_setup_item_spells(spells, enchants)
  bom_setup_food(spells, enchants)

  --Preload items!
  for x, spell in ipairs(spells) do
    if spell.isConsumable then
      BOM.GetItemInfo(spell.item)
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

  ---@param icon number
  ---@param id number Item ID
  local function makeItem(id, name, color, icon)
    local link = "|cff" .. color .. "|Hitem:" .. tostring(id) .. "::::::::1:::::::|h[" .. name .. "]|h|r"
    tinsert(s, { itemName = name,
                 itemLink = link,
                 itemIcon = icon })
  end
  local W = LE_ITEM_QUALITY_COMMON
  local G = LE_ITEM_QUALITY_UNCOMMON
  makeItem(18284, "Kreeg's Stout Beatdown", G, 132792)
  makeItem(13461, "Greater Arcane Protection Potion", W, 134863)
  makeItem(12643, "Dense Weightstone", W, 135259)
  makeItem(12455, "Juju Ember", W, 134317)
  makeItem(13810, "Blessed Sunfruit", W, 133997)
  makeItem(8928, "Instant Poison VI", W, 132273)
  makeItem(12457, "Juju Chill", W, 134311)
  makeItem(13813, "Blessed Sunfruit Juice", W, 132803)
  makeItem(12460, "Juju Might", W, 134309)
  makeItem(3825, "Elixir of Fortitude", W, 134823)
  makeItem(9186, "Mind-numbing Poison III", W, 136066)
  makeItem(9155, "Arcane Elixir", W, 134810)
  makeItem(20452, "Smoked Desert Dumplings", W, 134020)

  if BOM.TBC then
    makeItem(22055, "Wound Poison V", W, 132274)
    makeItem(21835, "Anesthetic Poison", W, 132274)
    makeItem(28420, "Fel Weightstone", W, 132274)
    makeItem(28421, "Adamantite Weightstone", W, 132274)
    makeItem(23528, "Fel Sharpening Stone", W, 132274)
    makeItem(23529, "Adamantite Sharpening Stone", W, 132274)
  else
    makeItem(10922, "Wound Poison IV", W, 132274)
  end

  makeItem(21023, "Dirge's Kickin' Chimaerok Chops", W, 134021)
  makeItem(12404, "Dense Sharpening Stone", W, 135252)
  makeItem(21151, "Rumsey Rum Black Label", W, 132791)
  makeItem(18254, "Runn Tum Tuber Surprise", W, 134019)
  makeItem(13445, "Elixir of Superior Defense", W, 134846)
  makeItem(13457, "Greater Fire Protection Potion", W, 134804)
  makeItem(12451, "Juju Power", W, 134313)
  makeItem(12218, "Monster Omelet", W, 133948)
  makeItem(13931, "Nightfin Soup", W, 132804)
  makeItem(20749, "Brilliant Wizard Oil", W, 134727)
  makeItem(5654, "Instant Toxin", W, 134799)
  makeItem(18262, "Elemental Sharpening Stone", G, 135228)

  if BOM.TBC then
    makeItem(22054, "Deadly Poison VII", W, 132290)
    makeItem(22521, "Superior Mana Oil", W, 134727)
    makeItem(22522, "Superior Wizard Oil", W, 134727)
  else
    makeItem(20844, "Deadly Poison V", W, 132290)
  end

  makeItem(20004, "Major Troll's Blood Potion", W, 134860)
  makeItem(12820, "Winterfall Firewater", W, 134872)
  makeItem(20007, "Mageblood Potion", W, 134825)
  makeItem(9264, "Elixir of Shadow Power", W, 134826)
  makeItem(11564, "Crystal Ward", W, 134129)
  makeItem(18269, "Gordok Green Grog", G, 132790)
  makeItem(21546, "Elixir of Greater Firepower", W, 134840)
  makeItem(23122, "Consecrated Sharpening Stone", G, 135249)
  makeItem(23123, "Blessed Wizard Oil", G, 134806)
  makeItem(13454, "Greater Arcane Elixir", W, 134805)
  makeItem(9088, "Gift of Arthas", W, 134808)
  makeItem(17708, "Elixir of Frost Power", W, 134714)
  makeItem(13928, "Grilled Squid", W, 133899)
  makeItem(13456, "Greater Frost Protection Potion", W, 134800)
  makeItem(13452, "Elixir of the Mongoose", W, 134812)

  -- Ungoro Crystal items
  makeItem(11564, "Crystal Ward", W, 134129)
  makeItem(11567, "Crystal Spire", W, 134134)
  makeItem(11563, "Crystal Force", W, 134088)

  makeItem(20748, "Brilliant Mana Oil", W, 134722)
  makeItem(13458, "Greater Nature Protection Potion", W, 134802)
  makeItem(9206, "Elixir of Giants", W, 134841)
  makeItem(13459, "Greater Shadow Protection Potion", W, 134803)
  makeItem(3776, "Crippling Poison II", W, 134799)

  BOM.ItemCache = s
end

BOM.ArgentumDawn = {
  itemIds = {
    12846, -- Simple AD trinket
    13209, -- Seal of the Dawn +81 AP
    19812, -- Rune of the Dawn +48 SPELL
    23206, -- Mark of the Chamption +150 AP
    23207, -- Mark of the Chamption +85 SPELL
  },
  --spells = {
  --  17670, -- Simple AD trinket
  --  23930, -- Seal of the Dawn +81 AP
  --  24198, -- Rune of the Dawn +48 SPELL
  --  29112, -- Mark of the Chamption +150 AP
  --  29113, -- Mark of the Chamption +85 SPELL
  --},
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
  --spells  = {
  --  13587, -- Classic: Carrot on a Stick
  --  48776, -- TBC: Riding Crop +10%
  --  48403, -- TBC: Druid "Charm of Swift Flight" +10%
  --},
  --Allow Riding Speed trinkets in:
  zoneId  = { 0, 1, 530, -- Eastern Kingdoms, Kalimdor, Outland
              30, -- Alterac Valley
              529, -- Arathi Basin,
              489, -- Warsong Gulch
              566, 968, -- TBC: Eye of the Storm
              1672, 1505, 572 }, -- TBC: Blade's Edge Arena, Nagrand Arena, Ruins of Lordaeron
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
