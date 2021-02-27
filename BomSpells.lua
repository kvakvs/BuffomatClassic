local TOCNAME, BOM = ...

---Classes which have a resurrection ability
local ResurrectionClass = { "SHAMAN", "PRIEST", "PALADIN" }

---Classes which have mana bar
local BOM_MANA_CLASSES = { "HUNTER", "WARLOCK", "MAGE", "DRUID", "SHAMAN", "PRIEST", "PALADIN" }
local BOM_SHADOW_CLASSES = { "PRIEST", "WARLOCK" }
local BOM_PHYSICAL_CLASSES = { "HUNTER", "ROGUE", "SHAMAN", "WARRIOR", "DRUID" }

-- Note: you can add your own spell in the "WTF\Account\<accountname>\SavedVariables\buffOmat.lua"
-- table CustomSpells
BOM.AllBuffomatSpells = {
  "PRIEST",

  --debug
  --{singleId=10938, isOwn=true, default=true, ItemLock={8008}}, -- manastone/debug

  ---[[
  { singleId       = 10938, groupId = 21562, default = true, -- Fortitude / seelenstärke
    singleFamily   = { 1243, 1244, 1245, 2791, 10937, 10938 }, groupFamily = { 21562, 21564 },
    singleDuration = 1800, groupDuration = 3600, NeededGroupItem = { 17028, 17029 },
    classes        = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  --]]
  { singleId       = 14819, groupId = 27681, default = true, -- Prayer of Spirit / willenstärke
    singleFamily   = { 14752, 14818, 14819, 27841 },
    singleDuration = 1800, groupDuration = 3600, NeededGroupItem = { 17028, 17029 },
    classes        = { "MAGE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId       = 10958, groupId = 27683, default = false, --Prayer of Shadow / schattenschutz
    singleFamily   = { 976, 10957, 10958 }, NeededGroupItem = { 17028, 17029 },
    singleDuration = 600, groupDuration = 1200,
    classes        = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId       = 6346, default = false, -- fearward
    singleDuration = 600, hasCD = true,
    classes        = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId       = 10901, default = false, -- Powerword:Shild
    singleFamily   = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 },
    singleDuration = 30, hasCD = true,
    classes        = { } },
  { singleId     = 19266, default = true, isOwn = true,
    singleFamily = { 2652, 19261, 19262, 19264, 19265, 19266 } }, -- Touch of Weakness / Berührung der Schwäche
  { singleId     = 10952, default = true, isOwn = true, -- Inner Fire / inneres Feuer
    singleFamily = { 588, 7128, 602, 1006, 10951, 10952 } },
  { singleId     = 19312, default = true, isOwn = true, -- shadowguard
    singleFamily = { 18137, 19308, 19309, 19310, 19311, 19312 } },
  { singleId     = 19293, default = true, isOwn = true, -- Elune's Grace
    singleFamily = { 2651, 19289, 19291, 19292, 19293 } },
  { singleId = 15473, default = false, isOwn = true },

  { singleId     = 20770, cancelForm = true, isResurrection = true, default = true, -- Resurrection / Auferstehung
    singleFamily = { 2006, 2010, 10880, 10881, 20770 } },

  "DRUID",
  { singleId       = 9885, groupId = 21849, cancelForm = true, default = true, --Gabe/Mal der Wildniss
    singleFamily   = { 1126, 5232, 6756, 5234, 8907, 9884, 9885 }, groupFamily = { 21849, 21850 },
    singleDuration = 1800, groupDuration = 3600, NeededGroupItem = { 17021, 17026 },
    classes        = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId       = 9910, cancelForm = true, default = false, --Dornen
    singleFamily   = { 467, 782, 1075, 8914, 9756, 9910 },
    singleDuration = 600,
    classes        = { "WARRIOR", "ROGUE", "DRUID", "SHAMAN", "PALADIN" } },
  { singleId = 16864, isOwn = true, cancelForm = true, default = true }, --omen of clarity
  { singleId     = 17329, isOwn = true, cancelForm = true, default = false, -- Griff der Natur
    hasCD        = true, NeedOutdoors = true,
    singleFamily = { 16689, 16810, 16811, 16812, 16813, 17329 },
  },
  { singleId = 5225, isTracking = true, needForm = CAT_FORM, default = true }, -- search human

  "MAGE",
  { singleId       = 10157, groupId = 23028, default = true, -- arkane intelligenz
    singleFamily   = { 1459, 1460, 1461, 10156, 10157 },
    singleDuration = 1800, groupDuration = 3600, NeededGroupItem = { 17020 },
    classes        = { "MAGE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId       = 10174, default = false, --Dampen Magic
    singleDuration = 600, classes = { },
    singleFamily   = { 604, 8450, 8451, 10173, 10174 } },
  { singleId       = 10170, default = false, --Amplify Magic
    singleDuration = 600, classes = { },
    singleFamily   = { 1008, 8455, 10169, 10170 } },
  { singleId     = 10220, isSeal = true, default = false, -- Ice Armor / eisrüstung
    singleFamily = { 7302, 7320, 10219, 10220 } },
  { singleId     = 7301, isSeal = true, default = false, -- Frost Armor / frostrüstung
    singleFamily = { 168, 7300, 7301 } },
  { singleId     = 22783, isSeal = true, default = false, -- Mage Armor / magische rüstung
    singleFamily = { 6117, 22782, 22783 } },
  { singleId       = 10193, isOwn = true, default = false, --Manaschild - unabhängig von allen.
    singleDuration = 60,
    singleFamily   = { 1463, 8494, 8495, 10191, 10192, 10193 } },
  { singleId       = 13033, isOwn = true, default = false, --ice barrier
    singleDuration = 60,
    singleFamily   = { 11426, 13031, 13032, 13033 } },

  { singleId     = 10053, isOwn = true, default = true, ItemLock = { 5514, 5513, 8007 }, -- manastone
    singleFamily = { 759, 3552, 10053 } },
  { singleId = 10054, isOwn = true, default = true, ItemLock = { 8008 } }, -- manastone


  "SHAMAN",
  { singleId     = 16342, isSeal = true, default = true, singleDuration = 500, --Flametongue
    singleFamily = { 8024, 8027, 8030, 16339, 16341, 16342 } },
  { singleId     = 16356, isSeal = true, default = true, singleDuration = 500, --Frostbrand
    singleFamily = { 8033, 8038, 10456, 16355, 16356 } },
  { singleId     = 16316, isSeal = true, default = true, singleDuration = 500, --Rockbiter
    singleFamily = { 8017, 8018, 8019, 10399, 16314, 16315, 16316 } },
  { singleId     = 16362, isSeal = true, default = true, singleDuration = 500, --Windfury
    singleFamily = { 8232, 8235, 10486, 16362 } },
  { singleId     = 10432, isOwn = true, default = true, -- Lightning Shield / Blitzschlagschild
    singleFamily = { 324, 325, 905, 945, 8134, 10431, 10432 } },
  { singleId     = 20777, isResurrection = true, default = true, -- Resurrection / Auferstehung
    singleFamily = { 2008, 20609, 20610, 20776, 20777 } },

  "WARLOCK",
  { singleId       = 5697, default = false, -- Unending Breath
    singleDuration = 600,
    classes        = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId       = 11743, default = false, -- Große Unsichtbarkeit entdecken
    singleFamily   = { 132, 2970, 11743 },
    singleDuration = 600,
    classes        = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId     = 28610, isOwn = true, default = false, -- Shadow Ward / Schattenzauberschutz
    singleFamily = { 6229, 11739, 11740, 28610 } },
  { singleId     = 11735, isOwn = true, default = false, -- Demon Armor
    singleFamily = { 706, 1086, 11733, 11734, 11735 } },
  { singleId     = 696, isOwn = true, default = false, -- Demon skin
    singleFamily = { 687, 696 } },
  { singleId = 18788, isOwn = true, default = true }, -- Demonic Sacrifice
  { singleId     = 17953, isOwn = true, default = false, ItemLock = { 1254, 13699, 13700, 13701 }, -- Firestone
    singleFamily = { 6366, 17951, 17952, 17953 } },
  { singleId     = 11730, isOwn = true, default = true,
    ItemLock     = { 5512, 19005, 19004, 5511, 19007, 19006, 5509, 19009, 19008, 5510, 19011, 19010,
                     9421, 19013, 19012 }, -- Healtstone
    singleFamily = { 6201, 6202, 5699, 11729, 11730 } },
  { singleId     = 20757, isOwn = true, default = true,
    ItemLock     = { 5232, 16892, 16893, 16895, 16896 }, --Soulstone
    singleFamily = { 693, 20752, 20755, 20756, 20757 } },

  { singleId = 5500, isTracking = true, default = true }, --Sense Demons

  "HUNTER",
  { singleId     = 20906, isOwn = true, default = true, -- Trueshot Aura
    singleFamily = { 19506, 20905, 20906 } },

  { singleId = 13161, isAura = true, default = true }, -- Aspect of the beast
  { singleId     = 25296, isAura = true, default = true, --Aspect of the Hawk
    singleFamily = { 13165, 14318, 14319, 14320, 14321, 14322, 25296 } },
  { singleId = 13163, isAura = true, default = true }, --Aspect of the monkey
  { singleId     = 20190, isAura = true, default = true, --Aspect of the wild
    singleFamily = { 20043, 20190 } },
  { singleId = 5118, isAura = true, default = false }, --Aspect of the Cheetah
  { singleId = 13159, isAura = true, default = false }, --Aspect of the pack

  { singleId = 1494, isTracking = true, default = true }, -- Track Beast
  { singleId = 19878, isTracking = true, default = true }, -- Track Demon
  { singleId = 19879, isTracking = true, default = true }, -- Track Dragonkin
  { singleId = 19880, isTracking = true, default = true }, -- Track Elemental
  { singleId = 19883, isTracking = true, default = true }, -- Track Humanoids
  { singleId = 19882, isTracking = true, default = true }, -- Track Giants / riesen
  { singleId = 19884, isTracking = true, default = true }, -- Track Undead
  { singleId = 19885, isTracking = true, default = true }, -- Track Hidden / verborgenes

  "PALADIN",
  { singleId = 25780, isOwn = true, default = true }, --Righteous Fury

  { singleId       = 20217, groupId = 25898, isBlessing = true, default = true, --Blessing of Kings
    singleDuration = 300, groupDuration = 900, NeededGroupItem = { 21177 },
    classes        = { "MAGE", "HUNTER", "WARLOCK" } },
  { singleId       = 19979, groupId = 25890, isBlessing = true, default = true, --Blessing of Light
    singleFamily   = { 19977, 19978, 19979 }, NeededGroupItem = { 21177 },
    singleDuration = 300, groupDuration = 900,
    classes        = {} },
  { singleId       = 25291, groupId = 25916, isBlessing = true, default = true, --Blessing of Might
    singleFamily   = { 19740, 19834, 19835, 19836, 19837, 19838, 25291 }, groupFamily = { 25782, 25916 },
    singleDuration = 300, groupDuration = 900, NeededGroupItem = { 21177 },
    classes        = { "WARRIOR", "ROGUE" } },
  { singleId       = 1038, groupId = 25895, isBlessing = true, default = true, --Blessing of Salvation
    singleDuration = 300, groupDuration = 900, NeededGroupItem = { 21177 },
    classes        = { } },
  { singleId       = 20914, groupId = 25899, isBlessing = true, default = true, --Blessing of Sanctuary
    singleFamily   = { 20911, 20912, 20913, 20914 }, NeededGroupItem = { 21177 },
    singleDuration = 300, groupDuration = 900,
    classes        = { } },
  { singleId       = 25290, groupId = 25918, isBlessing = true, default = true, --Blessing of Wisdom -
    singleFamily   = { 19742, 19850, 19852, 19853, 19854, 25290 }, groupFamily = { 25894, 25918 },
    singleDuration = 300, groupDuration = 900, NeededGroupItem = { 21177 },
    classes        = { "DRUID", "SHAMAN", "PRIEST", "PALADIN" } },

  { singleId     = 10293, isAura = true, default = true, -- Devotion Aura
    singleFamily = { 465, 10290, 643, 10291, 1032, 10292, 10293 } },
  { singleId     = 10301, isAura = true, default = true, -- Retribution Aura
    singleFamily = { 7294, 10298, 10299, 10300, 10301 } },
  { singleId = 19746, isAura = true, default = true }, --Concentration Aura
  { singleId     = 19896, isAura = true, default = true, -- Shadow Resistance Aura
    singleFamily = { 19876, 19895, 19896 } },
  { singleId     = 19898, isAura = true, default = true, -- Frost Resistance Aura
    singleFamily = { 19888, 19897, 19898 } },
  { singleId     = 19900, isAura = true, default = true, -- Fire Resistance Aura
    singleFamily = { 19891, 19899, 19900 } },
  { singleId = 20218, isAura = true, default = true }, --Sanctity Aura
  { singleId     = 20773, isResurrection = true, default = true, -- Resurrection / Auferstehung
    singleFamily = { 7328, 10322, 10324, 20772, 20773 } },

  { singleId = 20164, isSeal = true, default = false }, -- Sanctity seal
  { singleId = 20165, isSeal = true, default = false }, -- Seal of Light
  { singleId = 20154, isSeal = true, default = false }, -- Seal of Righteousness
  { singleId = 21084, isSeal = true, default = false }, -- Seal of Righteousness
  { singleId = 20166, isSeal = true, default = false }, -- Seal of Wisdom

  { singleId = 5502, isTracking = true, default = true }, -- Sense undead

  "TRACKING",
  { singleId = 2383, isTracking = true, default = true }, -- Find Herbs / kräuter
  { singleId = 2580, isTracking = true, default = true }, -- Find Minerals / erz
  { singleId = 2481, isTracking = true, default = true }, -- Find Treasure / Schatzsuche / Zwerge

  "INFO",
  { singleId     = 432, isInfo = true, default = false, --drink
    singleFamily = { 430, 431, 432, 1133, 1135, 1137, 22734, 25696, 26475, 26261, 29007,
                     26473, 10250, 26402 } },
  { singleId     = 434, isInfo = true, default = false, --essen
    singleFamily = { 10256, 1127, 1129, 22731, 5006, 433, 1131, 18230, 18233, 5007, 24800, 5005,
                     18232, 5004, 435, 434, 18234, 24869, 18229, 25888, 6410, 2639, 24005, 7737,
                     29073, 26260, 26474, 18231, 10257, 26472, 28616, 25700 } },
  { singleId     = 20762, isInfo = true, allowWhisper = true, default = false, --Seelenstein
    singleFamily = { 20707, 20762, 20763, 20765, 20764 } },
  --{singleId=10938, isInfo=true, allowWhisper=true,default=false,	--ausdauer-antworten!
  --	singleFamily={1243,1244,1245,2791,10937,10938}},

  "item",
  --{singleId=10901, item=8766,isBuff=true, default=false}, -- debug schild/tau
  { singleId = 17538, item = 13452, isBuff = true, default = false,
    onlyUsableFor  = BOM_PHYSICAL_CLASSES }, --Elixir of the Mongoose
  { singleId = 24363, item = 20007, isBuff = true, default = false,
    onlyUsableFor  = BOM_MANA_CLASSES }, --Mageblood Potion
  { singleId = 3593, item = 3825, isBuff = true, default = false }, --Elixir of Fortitude
  { singleId = 11348, item = 13445, isBuff = true, default = false }, --Elixir of Superior Defense
  { singleId = 24361, item = 20004, isBuff = true, default = false }, --Major Troll's Blood Potion
  { singleId = 11371, item = 9088, isBuff = true, default = false }, --Gift of Arthas
  { singleId = 11405, item = 9206, isBuff = true, default = false,
    onlyUsableFor  = BOM_PHYSICAL_CLASSES }, --Elixir of Giants
  { singleId = 17539, item = 13454, isBuff = true, default = false,
    onlyUsableFor  = BOM_MANA_CLASSES }, --Greater Arcane Elixir
  { singleId = 11390, item = 9155, isBuff = true, default = false,
    onlyUsableFor  = BOM_MANA_CLASSES }, --Greater Arcane Elixir
  { singleId = 11474, item = 9264, isBuff = true, default = false,
    onlyUsableFor  = BOM_SHADOW_CLASSES }, -- Elixir of Shadow Power
  { singleId = 26276, item = 21546, isBuff = true, default = false,
    onlyUsableFor  = BOM_MANA_CLASSES }, --Elixir of Greater Firepower
  { singleId = 21920, item = 17708, isBuff = true, default = false,
    onlyUsableFor  = { "SHAMAN" } }, --Elixir of Frost Power
  { singleId = 17038, item = 12820, isBuff = true, default = false,
    onlyUsableFor  = BOM_PHYSICAL_CLASSES }, --Winterfall Firewater
  { singleId = 16326, item = 12455, isBuff = true, default = false }, --Juju Ember
  { singleId = 16325, item = 12457, isBuff = true, default = false }, --Juju Chill
  { singleId = 16329, item = 12460, isBuff = true, default = false }, --Juju Might
  { singleId = 16323, item = 12451, isBuff = true, default = false }, --Juju Power
  { singleId = 15233, item = 11564, isBuff = true, default = false }, --Crystal Ward
  { singleId = 15279, item = 11567, isBuff = true, default = false }, --Crystal Spire
  { singleId = 18192, item = 13928, isBuff = true, default = false,
    onlyUsableFor  = BOM_PHYSICAL_CLASSES }, --Grilled Squid x
  { singleId = 24799, item = 20452, isBuff = true, default = false }, --Smoked Desert Dumplings x
  { singleId = 18194, item = 13931, isBuff = true, default = false,
    onlyUsableFor  = BOM_MANA_CLASSES }, --Nightfin Soup x
  { singleId = 22730, item = 18254, isBuff = true, default = false }, --Runn Tum Tuber Surprise x
  { singleId = 19710, item = 12218, isBuff = true, default = false,
    onlyUsableFor  = BOM_MANA_CLASSES }, --Monster Omelet x
  { singleId = 25661, item = 21023, isBuff = true, default = false }, --Dirge's Kickin' Chimaerok Chops x
  { singleId = 18141, item = 13813, isBuff = true, default = false,
    onlyUsableFor  = BOM_MANA_CLASSES }, --Blessed Sunfruit Juice x
  { singleId = 18125, item = 13810, isBuff = true, default = false }, --Blessed Sunfruit x
  { singleId = 22790, item = 18284, isBuff = true, default = false }, --Kreeg's Stout Beatdown
  { singleId = 22789, item = 18269, isBuff = true, default = false }, --Gordok Green Grog
  { singleId = 25804, item = 21151, isBuff = true, default = false }, --Rumsey Rum Black Label

  { singleId = 17549, item = 13461, isBuff = true, default = false }, --Greater Arcane Protection Potion
  { singleId = 17543, item = 13457, isBuff = true, default = false }, --Greater Fire Protection Potion
  { singleId = 17544, item = 13456, isBuff = true, default = false }, --Greater Frost Protection Potion
  { singleId = 17546, item = 13458, isBuff = true, default = false }, --Greater Nature Protection Potion
  { singleId = 17548, item = 13459, isBuff = true, default = false }, --Greater Shadow Protection Potion

  { singleId = 25123, item = 20748, items = { 20748, 20747, 20745 }, isBuff = true,
    isWeapon = true, duration = 1800, default = false,
    onlyUsableFor  = BOM_MANA_CLASSES }, --Brilliant Mana Oil
  { singleId = 25122, item = 20749, items = { 20749, 20746, 20744, 20750 }, isBuff = true,
    isWeapon = true, duration = 1800, default = false,
    onlyUsableFor  = BOM_MANA_CLASSES }, --Brilliant Wizard Oil
  { singleId = 28898, item = 23123, isBuff = true, isWeapon = true,
    duration = 3600, default = false,
    onlyUsableFor  = BOM_MANA_CLASSES }, --Blessed Wizard Oil

  { singleId = 16622, item = 12643, items = { 12643, 7965, 3241, 3240, 3239 }, isBuff = true,
    isWeapon = true, duration = 1800, default = false,
    onlyUsableFor  = BOM_PHYSICAL_CLASSES }, --Weightstone
  { singleId = 16138, item = 12404, items = { 12404, 7964, 2871, 2863, 2862 }, isBuff = true,
    isWeapon = true, duration = 1800, default = false,
    onlyUsableFor  = BOM_PHYSICAL_CLASSES }, --Sharpening Stone
  { singleId = 28891, item = 23122, isBuff = true, isWeapon = true,
    duration = 3600, default = false,
    onlyUsableFor  = BOM_PHYSICAL_CLASSES }, --Consecrated Sharpening Stone
  { singleId = 22756, item = 18262, isBuff = true, isWeapon = true,
    duration = 1800, default = false,
    onlyUsableFor  = BOM_PHYSICAL_CLASSES }, --Elemental Sharpening Stone

  { singleId = 25351, item = 20844, items = { 20844, 8985, 8984, 2893, 2892 }, isBuff = true,
    isWeapon = true, duration = 1800, default = false,
    onlyUsableFor  = { "ROGUE" } }, --Deadly Poison
  { singleId = 11399, item = 9186, items = { 9186, 6951, 5237 }, isBuff = true, isWeapon = true,
    duration = 1800, default = false,
    onlyUsableFor  = { "ROGUE" } }, --Mind-numbing Poison
  { singleId = 11340, item = 8928, items = { 8928, 8927, 8926, 6950, 6949, 6947 }, isBuff = true,
    isWeapon = true, duration = 1800, default = false,
    onlyUsableFor  = { "ROGUE" } }, --Instant Poison
  { singleId = 6650, item = 5654, items = { 5654 }, isBuff = true, isWeapon = true,
    duration = 1800, default = false,
    onlyUsableFor  = { "ROGUE" } }, --Instant Toxin
  { singleId = 13227, item = 10922, items = { 10922, 10921, 10920, 10918 }, isBuff = true,
    isWeapon = true, duration = 1800, default = false,
    onlyUsableFor  = { "ROGUE" } }, --Wound Poison
  { singleId = 11202, item = 3776, items = { 3776, 3775 }, isBuff = true, isWeapon = true,
    duration = 1800, default = false,
    onlyUsableFor  = { "ROGUE" } }, --Crippling Poison
}

--Preload items!
for x, spell in ipairs(BOM.AllBuffomatSpells) do
  if type(spell) == "table" then
    if spell.isBuff then
      GetItemInfo(spell.item)
    end
  end
end

BOM.ItemCache = {
  [18284] = {
    "Kreeg's Stout Beatdown", -- [1]
    "|cff1eff00|Hitem:18284::::::::1:::::::|h[Kreeg's Stout Beatdown]|h|r", -- [2]
    132792, -- [3]
  },
  [13461] = {
    "Greater Arcane Protection Potion", -- [1]
    "|cffffffff|Hitem:13461::::::::1:::::::|h[Greater Arcane Protection Potion]|h|r", -- [2]
    134863, -- [3]
  },
  [12643] = {
    "Dense Weightstone", -- [1]
    "|cffffffff|Hitem:12643::::::::1:::::::|h[Dense Weightstone]|h|r", -- [2]
    135259, -- [3]
  },
  [12455] = {
    "Juju Ember", -- [1]
    "|cffffffff|Hitem:12455::::::::1:::::::|h[Juju Ember]|h|r", -- [2]
    134317, -- [3]
  },
  [13810] = {
    "Blessed Sunfruit", -- [1]
    "|cffffffff|Hitem:13810::::::::1:::::::|h[Blessed Sunfruit]|h|r", -- [2]
    133997, -- [3]
  },
  [8928]  = {
    "Instant Poison VI", -- [1]
    "|cffffffff|Hitem:8928::::::::1:::::::|h[Instant Poison VI]|h|r", -- [2]
    132273, -- [3]
  },
  [12457] = {
    "Juju Chill", -- [1]
    "|cffffffff|Hitem:12457::::::::1:::::::|h[Juju Chill]|h|r", -- [2]
    134311, -- [3]
  },
  [13813] = {
    "Blessed Sunfruit Juice", -- [1]
    "|cffffffff|Hitem:13813::::::::1:::::::|h[Blessed Sunfruit Juice]|h|r", -- [2]
    132803, -- [3]
  },
  [12460] = {
    "Juju Might", -- [1]
    "|cffffffff|Hitem:12460::::::::1:::::::|h[Juju Might]|h|r", -- [2]
    134309, -- [3]
  },
  [3825]  = {
    "Elixir of Fortitude", -- [1]
    "|cffffffff|Hitem:3825::::::::1:::::::|h[Elixir of Fortitude]|h|r", -- [2]
    134823, -- [3]
  },
  [9186]  = {
    "Mind-numbing Poison III", -- [1]
    "|cffffffff|Hitem:9186::::::::1:::::::|h[Mind-numbing Poison III]|h|r", -- [2]
    136066, -- [3]
  },
  [9155]  = {
    "Arcane Elixir", -- [1]
    "|cffffffff|Hitem:9155::::::::1:::::::|h[Arcane Elixir]|h|r", -- [2]
    134810, -- [3]
  },
  [20452] = {
    "Smoked Desert Dumplings", -- [1]
    "|cffffffff|Hitem:20452::::::::1:::::::|h[Smoked Desert Dumplings]|h|r", -- [2]
    134020, -- [3]
  },
  [10922] = {
    "Wound Poison IV", -- [1]
    "|cffffffff|Hitem:10922::::::::1:::::::|h[Wound Poison IV]|h|r", -- [2]
    132274, -- [3]
  },
  [21023] = {
    "Dirge's Kickin' Chimaerok Chops", -- [1]
    "|cffffffff|Hitem:21023::::::::1:::::::|h[Dirge's Kickin' Chimaerok Chops]|h|r", -- [2]
    134021, -- [3]
  },
  [12404] = {
    "Dense Sharpening Stone", -- [1]
    "|cffffffff|Hitem:12404::::::::1:::::::|h[Dense Sharpening Stone]|h|r", -- [2]
    135252, -- [3]
  },
  [21151] = {
    "Rumsey Rum Black Label", -- [1]
    "|cffffffff|Hitem:21151::::::::1:::::::|h[Rumsey Rum Black Label]|h|r", -- [2]
    132791, -- [3]
  },
  [18254] = {
    "Runn Tum Tuber Surprise", -- [1]
    "|cffffffff|Hitem:18254::::::::1:::::::|h[Runn Tum Tuber Surprise]|h|r", -- [2]
    134019, -- [3]
  },
  [13445] = {
    "Elixir of Superior Defense", -- [1]
    "|cffffffff|Hitem:13445::::::::1:::::::|h[Elixir of Superior Defense]|h|r", -- [2]
    134846, -- [3]
  },
  [13457] = {
    "Greater Fire Protection Potion", -- [1]
    "|cffffffff|Hitem:13457::::::::1:::::::|h[Greater Fire Protection Potion]|h|r", -- [2]
    134804, -- [3]
  },
  [12451] = {
    "Juju Power", -- [1]
    "|cffffffff|Hitem:12451::::::::1:::::::|h[Juju Power]|h|r", -- [2]
    134313, -- [3]
  },
  [12218] = {
    "Monster Omelet", -- [1]
    "|cffffffff|Hitem:12218::::::::1:::::::|h[Monster Omelet]|h|r", -- [2]
    133948, -- [3]
  },
  [13931] = {
    "Nightfin Soup", -- [1]
    "|cffffffff|Hitem:13931::::::::1:::::::|h[Nightfin Soup]|h|r", -- [2]
    132804, -- [3]
  },
  [20749] = {
    "Brilliant Wizard Oil", -- [1]
    "|cffffffff|Hitem:20749::::::::1:::::::|h[Brilliant Wizard Oil]|h|r", -- [2]
    134727, -- [3]
  },
  [5654]  = {
    "Instant Toxin", -- [1]
    "|cffffffff|Hitem:5654::::::::1:::::::|h[Instant Toxin]|h|r", -- [2]
    134799, -- [3]
  },
  [18262] = {
    "Elemental Sharpening Stone", -- [1]
    "|cff1eff00|Hitem:18262::::::::1:::::::|h[Elemental Sharpening Stone]|h|r", -- [2]
    135228, -- [3]
  },
  [20844] = {
    "Deadly Poison V", -- [1]
    "|cffffffff|Hitem:20844::::::::1:::::::|h[Deadly Poison V]|h|r", -- [2]
    132290, -- [3]
  },
  [20004] = {
    "Major Troll's Blood Potion", -- [1]
    "|cffffffff|Hitem:20004::::::::1:::::::|h[Major Troll's Blood Potion]|h|r", -- [2]
    134860, -- [3]
  },
  [12820] = {
    "Winterfall Firewater", -- [1]
    "|cffffffff|Hitem:12820::::::::1:::::::|h[Winterfall Firewater]|h|r", -- [2]
    134872, -- [3]
  },
  [20007] = {
    "Mageblood Potion", -- [1]
    "|cffffffff|Hitem:20007::::::::1:::::::|h[Mageblood Potion]|h|r", -- [2]
    134825, -- [3]
  },
  [9264]  = {
    "Elixir of Shadow Power", -- [1]
    "|cffffffff|Hitem:9264::::::::1:::::::|h[Elixir of Shadow Power]|h|r", -- [2]
    134826, -- [3]
  },
  [11564] = {
    "Crystal Ward", -- [1]
    "|cffffffff|Hitem:11564::::::::1:::::::|h[Crystal Ward]|h|r", -- [2]
    134129, -- [3]
  },
  [18269] = {
    "Gordok Green Grog", -- [1]
    "|cff1eff00|Hitem:18269::::::::1:::::::|h[Gordok Green Grog]|h|r", -- [2]
    132790, -- [3]
  },
  [21546] = {
    "Elixir of Greater Firepower", -- [1]
    "|cffffffff|Hitem:21546::::::::1:::::::|h[Elixir of Greater Firepower]|h|r", -- [2]
    134840, -- [3]
  },
  [23122] = {
    "Consecrated Sharpening Stone", -- [1]
    "|cff1eff00|Hitem:23122::::::::1:::::::|h[Consecrated Sharpening Stone]|h|r", -- [2]
    135249, -- [3]
  },
  [23123] = {
    "Blessed Wizard Oil", -- [1]
    "|cff1eff00|Hitem:23123::::::::1:::::::|h[Blessed Wizard Oil]|h|r", -- [2]
    134806, -- [3]
  },
  [13454] = {
    "Greater Arcane Elixir", -- [1]
    "|cffffffff|Hitem:13454::::::::1:::::::|h[Greater Arcane Elixir]|h|r", -- [2]
    134805, -- [3]
  },
  [9088]  = {
    "Gift of Arthas", -- [1]
    "|cffffffff|Hitem:9088::::::::1:::::::|h[Gift of Arthas]|h|r", -- [2]
    134808, -- [3]
  },
  [17708] = {
    "Elixir of Frost Power", -- [1]
    "|cffffffff|Hitem:17708::::::::1:::::::|h[Elixir of Frost Power]|h|r", -- [2]
    134714, -- [3]
  },
  [13928] = {
    "Grilled Squid", -- [1]
    "|cffffffff|Hitem:13928::::::::1:::::::|h[Grilled Squid]|h|r", -- [2]
    133899, -- [3]
  },
  [13456] = {
    "Greater Frost Protection Potion", -- [1]
    "|cffffffff|Hitem:13456::::::::1:::::::|h[Greater Frost Protection Potion]|h|r", -- [2]
    134800, -- [3]
  },
  [13452] = {
    "Elixir of the Mongoose", -- [1]
    "|cffffffff|Hitem:13452::::::::1:::::::|h[Elixir of the Mongoose]|h|r", -- [2]
    134812, -- [3]
  },
  [11567] = {
    "Crystal Spire", -- [1]
    "|cffffffff|Hitem:11567::::::::1:::::::|h[Crystal Spire]|h|r", -- [2]
    134134, -- [3]
  },
  [20748] = {
    "Brilliant Mana Oil", -- [1]
    "|cffffffff|Hitem:20748::::::::1:::::::|h[Brilliant Mana Oil]|h|r", -- [2]
    134722, -- [3]
  },
  [13458] = {
    "Greater Nature Protection Potion", -- [1]
    "|cffffffff|Hitem:13458::::::::1:::::::|h[Greater Nature Protection Potion]|h|r", -- [2]
    134802, -- [3]
  },
  [9206]  = {
    "Elixir of Giants", -- [1]
    "|cffffffff|Hitem:9206::::::::1:::::::|h[Elixir of Giants]|h|r", -- [2]
    134841, -- [3]
  },
  [13459] = {
    "Greater Shadow Protection Potion", -- [1]
    "|cffffffff|Hitem:13459::::::::1:::::::|h[Greater Shadow Protection Potion]|h|r", -- [2]
    134803, -- [3]
  },
  [3776]  = {
    "Crippling Poison II", -- [1]
    "|cffffffff|Hitem:3776::::::::1:::::::|h[Crippling Poison II]|h|r", -- [2]
    134799, -- [3]
  },
}

BOM.ArgentumDawn = {
  spell   = 17670,
  dungeon = { 329, 289 }, --Stratholme/scholomance
}
BOM.Carrot = {
  spell   = 13587,
  dungeon = { 0, 1 }, --Eastern Kingdoms, Kalimdor
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
  [6650]  = { 42 }, --Instant Toxin
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
  --{6948}, -- Hearthstone/Ruhestein
  --{4604}, -- Waldpilz
  --{8079},-- wasser
  { 5232, 16892, 16893, 16895, 16896 }, -- Soulstone/Seelenstein
}
BOM.ItemListSpell = {
  [8079] = 432, -- wasser
  [5232] = 20762, [16892] = 20762, [16893] = 20762, [16895] = 20762, [16896] = 20762, -- Soulstone/Seelenstein
}
BOM.ItemListTarget = {}

-- Note: you can add your own spell in the "WTF\Account\<accountname>\SavedVariables\buffOmat.lua"
-- table CustomCancelBuff
BOM.CancelBuffs = {
  { singleId     = 10901, --Power Word: Shield
    default      = false, -- default no cancel
    singleFamily = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 } },
  { singleId     = 14819, -- Prayer of Spirit / willenstärke
    groupId      = 27681,
    default      = false, -- default no cancel
    singleFamily = { 14752, 14818, 14819, 27841 } },
  { singleId     = 10157, -- Arcane Intelligence
    groupId      = 23028, -- Arcane Brilliance
    default      = false, -- default no cancel
    singleFamily = { 1459, 1460, 1461, 10156, 10157 } },
}

do
  local _, class, _
  UnitClass("unit")
  if class == "HUNTER" then
    tinsert(BOM.CancelBuffs,
            { singleId     = 5118,
              OnlyCombat   = true,
              default      = true,
              singleFamily = { 5118, 13159 } } --Aspect of the Cheetah/of the pack
    )
  end
  if (UnitFactionGroup("player")) ~= "Horde" then
    tinsert(BOM.CancelBuffs,
            { singleId     = 1038, --Blessing of Salvation
              default      = false,
              singleFamily = { 1038, 25895 } }
    )
  end
end

BOM.BuffIgnoreAll = { 4511 }

local ShapeShiftTravel = { 2645, 783 } --Ghost wolf and travel druid
