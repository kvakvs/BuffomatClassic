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
local BOM_PHYSICAL_CLASSES = { "HUNTER", "ROGUE", "SHAMAN", "WARRIOR", "DRUID" }

---Add PRIEST spells
local function bom_setup_priest_spells(s)
  tinsert(s, BOM.SpellDef:new(10938, -- Fortitude / Seelenstärke
          { groupId         = 21562, default = true,
            singleFamily    = { 1243, 1244, 1245, 2791, 10937, 10938 },
            groupFamily     = { 21562, 21564 },
            singleDuration  = 1800,
            groupDuration   = 3600,
            NeededGroupItem = { 17028, 17029 },
            classes         = BOM_ALL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(14819, -- Prayer of Spirit / Willenstärke
          { groupId        = 27681, default = true,
            singleFamily   = { 14752, 14818, 14819, 27841 },
            singleDuration = 1800, groupDuration = 3600, NeededGroupItem = { 17028, 17029 },
            classes        = BOM_MANA_CLASSES }))
  tinsert(s, BOM.SpellDef:new(10958, --Prayer of Shadow / Schattenschutz
          { groupId        = 27683, default = false,
            singleFamily   = { 976, 10957, 10958 }, NeededGroupItem = { 17028, 17029 },
            singleDuration = 600, groupDuration = 1200,
            classes        = BOM_ALL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(6346, -- Fear Ward
          { default = false, singleDuration = 600, hasCD = true, classes = BOM_ALL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(10901, -- Power Word: Shield / Powerword:Shild
          { default        = false,
            singleFamily   = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 },
            singleDuration = 30, hasCD = true,
            classes        = { } }))
  tinsert(s, BOM.SpellDef:new(19266, -- Touch of Weakness / Berührung der Schwäche
          { default      = true, isOwn = true,
            singleFamily = { 2652, 19261, 19262, 19264, 19265, 19266 } }))
  tinsert(s, BOM.SpellDef:new(10952, -- Inner Fire / inneres Feuer
          { default      = true, isOwn = true,
            singleFamily = { 588, 7128, 602, 1006, 10951, 10952 } }))
  tinsert(s, BOM.SpellDef:new(19312, -- Shadowguard
          { default      = true, isOwn = true,
            singleFamily = { 18137, 19308, 19309, 19310, 19311, 19312 } }))
  tinsert(s, BOM.SpellDef:new(19293, -- Elune's Grace
          { default      = true, isOwn = true,
            singleFamily = { 2651, 19289, 19291, 19292, 19293 } }))
  tinsert(s, BOM.SpellDef:new(15473, -- Shadow Form
          { default = false, isOwn = true }))
  tinsert(s, BOM.SpellDef:new(20770, -- Resurrection / Auferstehung
          { cancelForm = true, isResurrection = true,
            default    = true, singleFamily = { 2006, 2010, 10880, 10881, 20770 } }))

  return s
end

---Add DRUID spells
local function bom_setup_druid_spells(s)
  tinsert(s, BOM.SpellDef:new(9885, --Gift/Mark of the Wild | Gabe/Mal der Wildniss
          { groupId         = 21849, cancelForm = true, default = true,
            singleFamily    = { 1126, 5232, 6756, 5234, 8907, 9884, 9885 },
            groupFamily     = { 21849, 21850 }, singleDuration = 1800, groupDuration = 3600,
            NeededGroupItem = { 17021, 17026 }, classes = BOM_ALL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(9910, --Thorns | Dornen
          { cancelForm     = true, default = false,
            singleFamily   = { 467, 782, 1075, 8914, 9756, 9910 },
            singleDuration = 600, classes = BOM_MELEE_CLASSES }))
  tinsert(s, BOM.SpellDef:new(16864, --omen of clarity
          { isOwn = true, cancelForm = true, default = true }))
  tinsert(s, BOM.SpellDef:new(17329, -- Nature's Grasp | Griff der Natur
          { isOwn        = true, cancelForm = true, default = false,
            hasCD        = true, NeedOutdoors = true,
            singleFamily = { 16689, 16810, 16811, 16812, 16813, 17329 } }))
  tinsert(s, BOM.SpellDef:new(5225, -- Track Humanoids (Cat Form)
          { isTracking = true, needForm = CAT_FORM, default = true }))

  return s
end

---Add MAGE spells
local function bom_setup_mage_spells(s)
  --{singleId=10938, isOwn=true, default=true, ItemLock={8008}}, -- manastone/debug
  tinsert(s, BOM.SpellDef:new(10157, --Arcane Intellect | Brilliance
          { groupId        = 23028, default = true,
            singleFamily   = { 1459, 1460, 1461, 10156, 10157 },
            singleDuration = 1800, groupDuration = 3600, NeededGroupItem = { 17020 },
            classes        = BOM_MANA_CLASSES }))
  tinsert(s, BOM.SpellDef:new(10174, --Dampen Magic
          { default      = false, singleDuration = 600, classes = { },
            singleFamily = { 604, 8450, 8451, 10173, 10174 } }))
  tinsert(s, BOM.SpellDef:new(10170, --Amplify Magic
          { default      = false, singleDuration = 600, classes = { },
            singleFamily = { 1008, 8455, 10169, 10170 } }))
  tinsert(s, BOM.SpellDef:new(10220, -- Ice Armor / eisrüstung
          { isSeal = true, default = false, singleFamily = { 7302, 7320, 10219, 10220 } }))
  tinsert(s, BOM.SpellDef:new(7301, -- Frost Armor / frostrüstung
          { isSeal = true, default = false, singleFamily = { 168, 7300, 7301 } }))
  tinsert(s, BOM.SpellDef:new(22783, -- Mage Armor / magische rüstung
          { isSeal = true, default = false, singleFamily = { 6117, 22782, 22783 } }))
  tinsert(s, BOM.SpellDef:new(10193, --Manaschild - unabhängig von allen.
          { isOwn        = true, default = false, singleDuration = 60,
            singleFamily = { 1463, 8494, 8495, 10191, 10192, 10193 } }))
  tinsert(s, BOM.SpellDef:new(13033, --ice barrier
          { isOwn        = true, default = false, singleDuration = 60,
            singleFamily = { 11426, 13031, 13032, 13033 } }))
  tinsert(s, BOM.SpellDef:new(10053, -- manastone
          { isOwn        = true, default = true, ItemLock = { 5514, 5513, 8007 },
            singleFamily = { 759, 3552, 10053 } }))
  tinsert(s, BOM.SpellDef:new(10054, -- manastone
          { isOwn = true, default = true, ItemLock = { 8008 } }))

  return s
end

---Add SHAMAN spells
local function bom_setup_shaman_spells(s)
  tinsert(s, BOM.SpellDef:new(16342, --Flametongue Weapon
          { isSeal       = true, default = true, singleDuration = 500,
            singleFamily = { 8024, 8027, 8030, 16339, 16341, 16342 } }))
  tinsert(s, BOM.SpellDef:new(16356, --Frostbrand Weapon
          { isSeal       = true, default = true, singleDuration = 500,
            singleFamily = { 8033, 8038, 10456, 16355, 16356 } }))
  tinsert(s, BOM.SpellDef:new(16316, --Rockbiter Weapon
          { isSeal       = true, default = true, singleDuration = 500,
            singleFamily = { 8017, 8018, 8019, 10399, 16314, 16315, 16316 } }))
  tinsert(s, BOM.SpellDef:new(16362, --Windfury Weapon
          { isSeal       = true, default = true, singleDuration = 500,
            singleFamily = { 8232, 8235, 10486, 16362 } }))
  tinsert(s, BOM.SpellDef:new(10432, -- Lightning Shield / Blitzschlagschild
          { isOwn        = true, default = true,
            singleFamily = { 324, 325, 905, 945, 8134, 10431, 10432 } }))
  tinsert(s, BOM.SpellDef:new(20777, -- Resurrection / Auferstehung
          { isResurrection = true, default = true,
            singleFamily   = { 2008, 20609, 20610, 20776, 20777 } }))

  return s
end

---Add WARLOCK spells
local function bom_setup_warlock_spells(s)
  tinsert(s, BOM.SpellDef:new(5697, -- Unending Breath
          { default = false, singleDuration = 600, classes = BOM_ALL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(11743, -- Detect Greater Invisibility | Große Unsichtbarkeit entdecken
          { default        = false, singleFamily = { 132, 2970, 11743 },
            singleDuration = 600, classes = BOM_ALL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(28610, -- Shadow Ward / Schattenzauberschutz
          { isOwn = true, default = false, singleFamily = { 6229, 11739, 11740, 28610 } }))
  tinsert(s, BOM.SpellDef:new(11735, -- Demon Armor
          { isOwn = true, default = false, singleFamily = { 706, 1086, 11733, 11734, 11735 } }))
  tinsert(s, BOM.SpellDef:new(696, -- Demon skin (Low Level)
          { isOwn = true, default = false, singleFamily = { 687, 696 } }))
  tinsert(s, BOM.SpellDef:new(18788, -- Demonic Sacrifice
          { isOwn = true, default = true }))
  tinsert(s, BOM.SpellDef:new(17953, -- Firestone
          { isOwn        = true, default = false, ItemLock = { 1254, 13699, 13700, 13701 },
            singleFamily = { 6366, 17951, 17952, 17953 } }))
  tinsert(s, BOM.SpellDef:new(11730, -- Healtstone
          { isOwn        = true, default = true,
            ItemLock     = { 5512, 19005, 19004, 5511, 19007, 19006, 5509, 19009,
                             19008, 5510, 19011, 19010, 9421, 19013, 19012 },
            singleFamily = { 6201, 6202, 5699, 11729, 11730 } }))
  tinsert(s, BOM.SpellDef:new(20757, --Soulstone
          { isOwn        = true, default = true,
            ItemLock     = { 5232, 16892, 16893, 16895, 16896 },
            singleFamily = { 693, 20752, 20755, 20756, 20757 } }))
  tinsert(s, BOM.SpellDef:new(5500, --Sense Demons
          { isTracking = true, default = true }))

  return s
end

---Add HUNTER spells
local function bom_setup_hunter_spells(s)
  tinsert(s, BOM.SpellDef:new(20906, -- Trueshot Aura
          { isOwn = true, default = true, singleFamily = { 19506, 20905, 20906 } }))

  tinsert(s, BOM.SpellDef:new(25296, --Aspect of the Hawk
          { isAura       = true, default = true,
            singleFamily = { 13165, 14318, 14319, 14320, 14321, 14322, 25296 } }))
  tinsert(s, BOM.SpellDef:new(13163, --Aspect of the monkey
          { isAura = true, default = false }))
  tinsert(s, BOM.SpellDef:new(20190, --Aspect of the wild
          { isAura       = true, default = false,
            singleFamily = { 20043, 20190 } }))
  tinsert(s, BOM.SpellDef:new(5118, --Aspect of the Cheetah
          { isAura = true, default = false }))
  tinsert(s, BOM.SpellDef:new(13159, --Aspect of the pack
          { isAura = true, default = false }))
  tinsert(s, BOM.SpellDef:new(13161, -- Aspect of the beast
          { isAura = true, default = false }))
  tinsert(s, BOM.SpellDef:new(1494, -- Track Beast
          { isTracking = true, default = false }))
  tinsert(s, BOM.SpellDef:new(19878, -- Track Demon
          { isTracking = true, default = false }))
  tinsert(s, BOM.SpellDef:new(19879, -- Track Dragonkin
          { isTracking = true, default = false }))
  tinsert(s, BOM.SpellDef:new(19880, -- Track Elemental
          { isTracking = true, default = false }))
  tinsert(s, BOM.SpellDef:new(19883, -- Track Humanoids
          { isTracking = true, default = false }))
  tinsert(s, BOM.SpellDef:new(19882, -- Track Giants / riesen
          { isTracking = true, default = false }))
  tinsert(s, BOM.SpellDef:new(19884, -- Track Undead
          { isTracking = true, default = false }))
  tinsert(s, BOM.SpellDef:new(19885, -- Track Hidden / verborgenes
          { isTracking = true, default = false }))

  return s
end

---Add PALADIN spells
local function bom_setup_paladin_spells(s)
  tinsert(s, BOM.SpellDef:new(25780, --Righteous Fury
          { isOwn = true, default = true }))
  tinsert(s, BOM.SpellDef:new(20217, --Blessing of Kings
          { groupId        = 25898, isBlessing = true, default = true,
            singleDuration = 300, groupDuration = 900, NeededGroupItem = { 21177 },
            classes        = { "MAGE", "HUNTER", "WARLOCK" } }))
  tinsert(s, BOM.SpellDef:new(19979, --Blessing of Light
          { groupId        = 25890, isBlessing = true, default = true,
            singleFamily   = { 19977, 19978, 19979 }, NeededGroupItem = { 21177 },
            singleDuration = 300, groupDuration = 900,
            classes        = {} }))
  tinsert(s, BOM.SpellDef:new(25291, --Blessing of Might
          { groupId        = 25916, isBlessing = true, default = true,
            singleFamily   = { 19740, 19834, 19835, 19836, 19837, 19838, 25291 }, groupFamily = { 25782, 25916 },
            singleDuration = 300, groupDuration = 900, NeededGroupItem = { 21177 },
            classes        = { "WARRIOR", "ROGUE" } }))
  tinsert(s, BOM.SpellDef:new(1038, --Blessing of Salvation
          { groupId        = 25895, isBlessing = true, default = true,
            singleDuration = 300, groupDuration = 900, NeededGroupItem = { 21177 },
            classes        = { } }))
  tinsert(s, BOM.SpellDef:new(20914, --Blessing of Sanctuary
          { groupId        = 25899, isBlessing = true, default = true,
            singleFamily   = { 20911, 20912, 20913, 20914 }, NeededGroupItem = { 21177 },
            singleDuration = 300, groupDuration = 900,
            classes        = { } }))
  tinsert(s, BOM.SpellDef:new(25290, --Blessing of Wisdom -
          { groupId        = 25918, isBlessing = true, default = true,
            singleFamily   = { 19742, 19850, 19852, 19853, 19854, 25290 }, groupFamily = { 25894, 25918 },
            singleDuration = 300, groupDuration = 900, NeededGroupItem = { 21177 },
            classes        = { "DRUID", "SHAMAN", "PRIEST", "PALADIN" } }))
  tinsert(s, BOM.SpellDef:new(10293, -- Devotion Aura
          { isAura       = true, default = true,
            singleFamily = { 465, 10290, 643, 10291, 1032, 10292, 10293 } }))
  tinsert(s, BOM.SpellDef:new(10301, -- Retribution Aura
          { isAura       = true, default = true,
            singleFamily = { 7294, 10298, 10299, 10300, 10301 } }))
  tinsert(s, BOM.SpellDef:new(19746, --Concentration Aura
          { isAura = true, default = true }))
  tinsert(s, BOM.SpellDef:new(19896, -- Shadow Resistance Aura
          { isAura       = true, default = true,
            singleFamily = { 19876, 19895, 19896 } }))
  tinsert(s, BOM.SpellDef:new(19898, -- Frost Resistance Aura
          { isAura       = true, default = true,
            singleFamily = { 19888, 19897, 19898 } }))
  tinsert(s, BOM.SpellDef:new(19900, -- Fire Resistance Aura
          { isAura       = true, default = true,
            singleFamily = { 19891, 19899, 19900 } }))
  tinsert(s, BOM.SpellDef:new(20218, --Sanctity Aura
          { isAura = true, default = true }))
  tinsert(s, BOM.SpellDef:new(20773, -- Redemption / Auferstehung
          { isResurrection = true, default = true,
            singleFamily   = { 7328, 10322, 10324, 20772, 20773 } }))
  tinsert(s, BOM.SpellDef:new(20164, -- Sanctity seal
          { isSeal = true, default = false }))
  tinsert(s, BOM.SpellDef:new(20165, -- Seal of Light
          { isSeal = true, default = false }))
  tinsert(s, BOM.SpellDef:new(20154, -- Seal of Righteousness
          { isSeal = true, default = false }))
  tinsert(s, BOM.SpellDef:new(21084, -- Seal of Righteousness
          { isSeal = true, default = false }))
  tinsert(s, BOM.SpellDef:new(20166, -- Seal of Wisdom
          { isSeal = true, default = false }))
  tinsert(s, BOM.SpellDef:new(5502, -- Sense undead
          { isTracking = true, default = true }))

  return s
end

---Add WARRIOR spells
local function bom_setup_warrior_spells(s)
  tinsert(s, BOM.SpellDef:new(25289, --Battle Shout
          { isOwn        = true, default = true,
            singleFamily = { 6673, 5242, 6192, 11549, 11550, 11551, 25289 },
            default      = false }))
  return s
end

---Add ROGUE spells
local function bom_setup_rogue_spells(s)
  tinsert(s, BOM.SpellDef:new(25351, --Deadly Poison
          { item          = 20844, items = { 20844, 8985, 8984, 2893, 2892 }, isBuff = true,
            isWeapon      = true, duration = 1800, default = false,
            onlyUsableFor = { "ROGUE" } }))
  tinsert(s, BOM.SpellDef:new(11399, --Mind-numbing Poison
          { item     = 9186, items = { 9186, 6951, 5237 }, isBuff = true, isWeapon = true,
            duration = 1800, default = false, onlyUsableFor = { "ROGUE" } }))
  tinsert(s, BOM.SpellDef:new(11340, --Instant Poison
          { item          = 8928, items = { 8928, 8927, 8926, 6950, 6949, 6947 }, isBuff = true,
            isWeapon      = true, duration = 1800, default = false,
            onlyUsableFor = { "ROGUE" } }))
  tinsert(s, BOM.SpellDef:new(13227, --Wound Poison
          { item          = 10922, items = { 10922, 10921, 10920, 10918 }, isBuff = true,
            isWeapon      = true, duration = 1800, default = false,
            onlyUsableFor = { "ROGUE" } }))
  tinsert(s, BOM.SpellDef:new(11202, --Crippling Poison
          { item     = 3776, items = { 3776, 3775 }, isBuff = true, isWeapon = true,
            duration = 1800, default = false, onlyUsableFor = { "ROGUE" } }))
  return s
end

---Add RESOURCE TRACKING spells
local function bom_setup_tracking_spells(s)
  if not BOM.TBC then
    -- TBC tracking works differently
    tinsert(s, BOM.SpellDef:new(2383, -- Find Herbs / kräuter
            { isTracking = true, default = true }))
    tinsert(s, BOM.SpellDef:new(2580, -- Find Minerals / erz
            { isTracking = true, default = true }))
    tinsert(s, BOM.SpellDef:new(2481, -- Find Treasure / Schatzsuche / Zwerge
            { isTracking = true, default = true }))
  end
  return s
end

---MISC spells applicable to every class
local function bom_setup_misc_spells(s)
  tinsert(s, BOM.SpellDef:new(432, -- Water | drink
          { isInfo       = true, default = false,
            singleFamily = { 430, 431, 432, 1133, 1135, 1137, 22734, 25696, 26475, 26261, 29007,
                             26473, 10250, 26402 } }))
  tinsert(s, BOM.SpellDef:new(434, -- Food | essen
          { isInfo       = true, default = false,
            singleFamily = { 10256, 1127, 1129, 22731, 5006, 433, 1131, 18230, 18233, 5007, 24800, 5005,
                             18232, 5004, 435, 434, 18234, 24869, 18229, 25888, 6410, 2639, 24005, 7737,
                             29073, 26260, 26474, 18231, 10257, 26472, 28616, 25700 } }))
  tinsert(s, BOM.SpellDef:new(20762, --Soulstone | Seelenstein
          { isInfo       = true, allowWhisper = true, default = false,
            singleFamily = { 20707, 20762, 20763, 20765, 20764 } }))
  --{singleId=10938, isInfo=true, allowWhisper=true,default=false,	--ausdauer-antworten!
  --	singleFamily={1243,1244,1245,2791,10937,10938}},
  return s
end

---ITEMS, applicable to most of the classes, self buffs, containers to open etc
local function bom_setup_item_spells(s)
  tinsert(s, BOM.SpellDef:new(17538, --Elixir of the Mongoose
          { item          = 13452, isBuff = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(11334, --Elixir of Greater Agility
          { item          = 9187, isBuff = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(24363, --Mageblood Potion
          { item          = 20007, isBuff = true, default = false,
            onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(s, BOM.SpellDef:new(3593, --Elixir of Fortitude
          { item = 3825, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(11348, --Elixir of Superior Defense
          { item = 13445, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(24361, --Major Troll's Blood Potion
          { item = 20004, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(11371, --Gift of Arthas
          { item = 9088, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(11405, --Elixir of Giants
          { item          = 9206, isBuff = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(17539, --Greater Arcane Elixir
          { item          = 13454, isBuff = true, default = false,
            onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(s, BOM.SpellDef:new(11390, --Greater Arcane Elixir
          { item          = 9155, isBuff = true, default = false,
            onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(s, BOM.SpellDef:new(11474, -- Elixir of Shadow Power
          { item          = 9264, isBuff = true, default = false,
            onlyUsableFor = BOM_SHADOW_CLASSES }))
  tinsert(s, BOM.SpellDef:new(26276, --Elixir of Greater Firepower
          { item          = 21546, isBuff = true, default = false,
            onlyUsableFor = { "MAGE", "WARLOCK", "SHAMAN" } }))
  tinsert(s, BOM.SpellDef:new(21920, --Elixir of Frost Power
          { item          = 17708, isBuff = true, default = false,
            onlyUsableFor = { "SHAMAN", "MAGE" } }))
  tinsert(s, BOM.SpellDef:new(17038, --Winterfall Firewater
          { item          = 12820, isBuff = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(16326, --Juju Ember +15FR
          { item = 12455, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(16325, --Juju Chill +15FrostR
          { item = 12457, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(16329, --Juju Might +40AP
          { item = 12460, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(16323, --Juju Power +30Str
          { item = 12451, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(15233, --Crystal Ward
          { item = 11564, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(15279, --Crystal Spire
          { item = 11567, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(18192, --Grilled Squid +10 Agility
          { item          = 13928, isBuff = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(24799, --Smoked Desert Dumplings +Strength
          { item          = 20452, isBuff = true, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(18194, --Nightfin Soup +Mana/5
          { item          = 13931, isBuff = true, default = false,
            onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(s, BOM.SpellDef:new(22730, --Runn Tum Tuber Surprise
          { item = 18254, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(19710, --Monster Omelette
          { item          = 12218, isBuff = true, default = false,
            onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(s, BOM.SpellDef:new(25661, --Dirge's Kickin' Chimaerok Chops x
          { item = 21023, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(18141, --Blessed Sunfruit Juice +Strength
          { item          = 13813, isBuff = true, default = false,
            onlyUsableFor = BOM_MELEE_CLASSES }))
  tinsert(s, BOM.SpellDef:new(18125, --Blessed Sunfruit +Spirit
          { item          = 13810, isBuff = true, default = false,
            onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(s, BOM.SpellDef:new(22790, --Kreeg's Stout Beatdown
          { item          = 18284, isBuff = true, default = false,
            onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(s, BOM.SpellDef:new(22789, --Gordok Green Grog
          { item = 18269, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(25804, --Rumsey Rum Black Label
          { item = 21151, isBuff = true, default = false }))

  tinsert(s, BOM.SpellDef:new(17549, --Greater Arcane Protection Potion
          { item = 13461, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(17543, --Greater Fire Protection Potion
          { item = 13457, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(17544, --Greater Frost Protection Potion
          { item = 13456, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(17546, --Greater Nature Protection Potion
          { item = 13458, isBuff = true, default = false }))
  tinsert(s, BOM.SpellDef:new(17548, --Greater Shadow Protection Potion
          { item = 13459, isBuff = true, default = false }))

  tinsert(s, BOM.SpellDef:new(25123, --Brilliant|Lesser|Minor Mana Oil
          { item          = 20748, items = { 20748, 20747, 20745 }, isBuff = true,
            isWeapon      = true, duration = 1800, default = false,
            onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(s, BOM.SpellDef:new(25122, --Brilliant|Lesser|Minor Wizard Oil
          { item          = 20749, items = { 20749, 20746, 20744, 20750 },
            isBuff        = true, isWeapon = true, duration = 1800, default = false,
            onlyUsableFor = BOM_MANA_CLASSES }))
  tinsert(s, BOM.SpellDef:new(28898, --Blessed Wizard Oil
          { item          = 23123, isBuff = true, isWeapon = true,
            duration      = 3600, default = false,
            onlyUsableFor = BOM_MANA_CLASSES }))

  tinsert(s, BOM.SpellDef:new(16622, --Weightstone
          { item          = 12643, items = { 12643, 7965, 3241, 3240, 3239 },
            isBuff        = true, isWeapon = true, duration = 1800, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(16138, --Sharpening Stone
          { item          = 12404, items = { 12404, 7964, 2871, 2863, 2862 },
            isBuff        = true, isWeapon = true, duration = 1800, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(28891, --Consecrated Sharpening Stone
          { item          = 23122, isBuff = true, isWeapon = true,
            duration      = 3600, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  tinsert(s, BOM.SpellDef:new(22756, --Elemental Sharpening Stone
          { item          = 18262, isBuff = true, isWeapon = true,
            duration      = 1800, default = false,
            onlyUsableFor = BOM_PHYSICAL_CLASSES }))
  return s
end

---All spells known to Buffomat
---Note: you can add your own spell in the "WTF\Account\<accountname>\SavedVariables\buffOmat.lua"
---table CustomSpells
---@return table - all known spells table (all spells to be scanned)
function BOM.SetupSpells()
  local s = {}

  s = bom_setup_priest_spells(s)
  s = bom_setup_druid_spells(s)
  s = bom_setup_mage_spells(s)
  s = bom_setup_shaman_spells(s)
  s = bom_setup_warlock_spells(s)
  s = bom_setup_hunter_spells(s)
  s = bom_setup_paladin_spells(s)
  s = bom_setup_warrior_spells(s)
  s = bom_setup_rogue_spells(s)

  s = bom_setup_tracking_spells(s)
  s = bom_setup_misc_spells(s)
  s = bom_setup_item_spells(s)

  --Preload items!
  for x, spell in ipairs(s) do
    if spell.isBuff then
      GetItemInfo(spell.item)
    end
  end

  return s
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
  make_item(10922, "Wound Poison IV", W, 132274)
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
  make_item(20844, "Deadly Poison V", W, 132290)
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
end

BOM.ArgentumDawn = {
  spell   = 17670,
  dungeon = { 329, 289, 533, 535 }, --Stratholme/scholomance; Naxxramas LK 10/25
}
BOM.Carrot = {
  spell   = 13587,
  dungeon = { 0, 1 }, --Allow Carrot in Eastern Kingdoms, Kalimdor
}

BOM.EnchantList = {--weapon-echantment to spellid
  [16342] = { 3, 4, 5, 523, 1665, 1666 }, --Flametongue
  [16356] = { 2, 12, 524, 1667, 1668 }, --Frostbrand
  [16316] = { 1, 6, 29, 503, 683, 1663, 1664 }, --Rockbiter
  [16362] = { 283, 284, 525, 1669 }, --Windfury
  [25123] = { 2629, 2625, 2624 }, --Brilliant Mana Oil
  [25122] = { 2628, 2626, 2623, 2627 }, --Brilliant Wizard Oil
  [16622] = { 1703, 484, 21, 20, 19 }, -- Weightstone
  [28891] = { 2684 }, --Consecrated Sharpening Stone
  [22756] = { 2506 }, --Elemental Sharpening Stone
  [16138] = { 1643, 483, 14, 13, 40 }, --Sharpening Stone
  [28898] = { 2685 }, --Blessed Wizard Oil
  [25351] = { 2630, 627, 626, 8, 7 }, --Deadly Poison
  [11399] = { 643, 23, 35 }, --Mind-numbing Poison
  [11340] = { 625, 624, 623, 325, 324, 323 }, --Instant Poison
  --[6650]  = { 42 }, --Instant Toxin - not available to players
  [13227] = { 706, 705, 704, 703 }, --Wound Poison
  [11202] = { 603, 22 }, --Crippling Poison
  --[]={},--
  --[]={},--
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

BOM.EnchantToSpell = {}
for dest, list in pairs(BOM.EnchantList) do
  for i, id in ipairs(list) do
    BOM.EnchantToSpell[id] = dest
  end
end

BOM.ItemList = {
  --{6948}, -- Hearthstone | Ruhestein
  --{4604}, -- Forest Mushroom | Waldpilz
  --{8079},-- Water | wasser
  { 5232, 16892, 16893, 16895, 16896 }, -- Soulstone/Seelenstein
}
BOM.ItemListSpell = {
  [8079] = 432, -- Water | Wasser
  [5232] = 20762, [16892] = 20762, [16893] = 20762, [16895] = 20762, [16896] = 20762, -- Soulstone | Seelenstein
}
BOM.ItemListTarget = {}

function BOM.SetupCancelBuffs()
  -- Note: you can add your own spell in the "WTF\Account\<accountname>\SavedVariables\buffOmat.lua"
  -- table CustomCancelBuff
  local s = {
    BOM.SpellDef:new(10901, --Power Word: Shield
            { default      = false, -- default no cancel
              singleFamily = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899,
                               10900, 10901 } }),
    BOM.SpellDef:new(14819, -- Prayer of Spirit / willenstärke
            { groupId      = 27681, default = false, -- default no cancel
              singleFamily = { 14752, 14818, 14819, 27841 } }),
    BOM.SpellDef:new(10157, -- Arcane Intelligence
            { groupId      = 23028, -- Arcane Brilliance
              default      = false, -- default no cancel
              singleFamily = { 1459, 1460, 1461, 10156, 10157 } }),
  }

  do
    local _, class, _ = UnitClass("unit")
    if class == "HUNTER" then
      tinsert(s, BOM.SpellDef:new(5118, --Aspect of the Cheetah/of the pack
              { OnlyCombat = true, default = true, singleFamily = { 5118, 13159 } }))
    end

    if (UnitFactionGroup("player")) ~= "Horde" then
      tinsert(s, BOM.SpellDef:new(1038, --Blessing of Salvation
              { default = false, singleFamily = { 1038, 25895 } }))
    end
  end
  return s
end

BOM.BuffIgnoreAll = { 4511 }

local ShapeShiftTravel = { 2645, 783 } --Ghost wolf and travel druid
