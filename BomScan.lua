local TOCNAME, BOM = ...
local L = setmetatable({}, { __index = function(t, k)
  if BOM.L and BOM.L[k] then
    return BOM.L[k]
  else
    return "[" .. k .. "]"
  end
end })

local ResurrectionClass = { "SHAMAN", "PRIEST", "PALADIN" }
local ManaClass = { "HUNTER", "WARLOCK", "MAGE", "DRUID", "SHAMAN", "PRIEST", "PALADIN" }
local MAXMANA = 999999

BOM.ProfileNames = { "solo", "group", "raid", "battleground" }

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
  [8928] = {
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
  [3825] = {
    "Elixir of Fortitude", -- [1]
    "|cffffffff|Hitem:3825::::::::1:::::::|h[Elixir of Fortitude]|h|r", -- [2]
    134823, -- [3]
  },
  [9186] = {
    "Mind-numbing Poison III", -- [1]
    "|cffffffff|Hitem:9186::::::::1:::::::|h[Mind-numbing Poison III]|h|r", -- [2]
    136066, -- [3]
  },
  [9155] = {
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
  [5654] = {
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
  [9264] = {
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
  [9088] = {
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
  [9206] = {
    "Elixir of Giants", -- [1]
    "|cffffffff|Hitem:9206::::::::1:::::::|h[Elixir of Giants]|h|r", -- [2]
    134841, -- [3]
  },
  [13459] = {
    "Greater Shadow Protection Potion", -- [1]
    "|cffffffff|Hitem:13459::::::::1:::::::|h[Greater Shadow Protection Potion]|h|r", -- [2]
    134803, -- [3]
  },
  [3776] = {
    "Crippling Poison II", -- [1]
    "|cffffffff|Hitem:3776::::::::1:::::::|h[Crippling Poison II]|h|r", -- [2]
    134799, -- [3]
  },
}

BOM.ArgentumDawn = {
  spell = 17670,
  dungeon = { 329, 289 }, --Stratholme/scholomance
}
BOM.Carrot = {
  spell = 13587,
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
  [6650] = { 42 }, --Instant Toxin
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
  --{6948},--Ruhestein
  --{4604},--Waldpilz
  --{8079},-- wasser
  { 5232, 16892, 16893, 16895, 16896 }, -- Seelenstein
}
BOM.ItemListSpell = {
  [8079] = 432, -- wasser
  [5232] = 20762, [16892] = 20762, [16893] = 20762, [16895] = 20762, [16896] = 20762, -- Seelenstein
}
BOM.ItemListTarget = {}

-- Note: you can add your own spell in the "WTF\Account\<accountname>\SavedVariables\buffOmat.lua"
-- table CustomCancelBuff
BOM.CancelBuffs = {
  { singleId = 10901, default = false, --Powerword:Shild
    singleFamily = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 } },

  --{singleId=10952, OnlyCombat=true, default=true, --demo
  --	singleFamily={588,7128,602,1006,10951,10952}},

}
do
  local _, class, _
  UnitClass("unit")
  if class == "HUNTER" then
    tinsert(BOM.CancelBuffs,
            { singleId = 5118, OnlyCombat = true, default = true, --Aspect of the Cheetah--Aspect of the pack
              singleFamily = { 5118, 13159 } }
    )
  end
  if (UnitFactionGroup("player")) ~= "Horde" then
    tinsert(BOM.CancelBuffs,
            { singleId = 1038, default = false, --Blessing of Salvation
              singleFamily = { 1038, 25895 } }
    )
  end
end

BOM.BuffIgnoreAll = { 4511 }

local ShapeShiftTravel = { 2645, 783 }--Ghost wolf and travel druid

-- Note: you can add your own spell in the "WTF\Account\<accountname>\SavedVariables\buffOmat.lua"
-- table CustomSpells
BOM.SpellList = {
  "PRIEST",

  --debug
  --{singleId=10938, isOwn=true, default=true, ItemLock={8008}}, -- manastone/debug

  ---[[
  { singleId = 10938, groupId = 21562, default = true, -- seelenstärke
    singleFamily = { 1243, 1244, 1245, 2791, 10937, 10938 }, groupFamily = { 21562, 21564 },
    singleDuration = 1800, groupDuration = 3600, NeededGroupItem = { 17028, 17029 },
    classes = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  --]]
  { singleId = 14819, groupId = 27681, default = true, -- willenstärke
    singleFamily = { 14752, 14818, 14819, 27841 },
    singleDuration = 1800, groupDuration = 3600, NeededGroupItem = { 17028, 17029 },
    classes = { "MAGE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId = 10958, groupId = 27683, default = false, --schattenschutz
    singleFamily = { 976, 10957, 10958 }, NeededGroupItem = { 17028, 17029 },
    singleDuration = 600, groupDuration = 1200,
    classes = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId = 6346, default = false, -- fearward
    singleDuration = 600, hasCD = true,
    classes = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId = 10901, default = false, -- Powerword:Shild
    singleFamily = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 },
    singleDuration = 30, hasCD = true,
    classes = { } },
  { singleId = 19266, default = true, isOwn = true,
    singleFamily = { 2652, 19261, 19262, 19264, 19265, 19266 } }, --Berührung der Schwäche
  { singleId = 10952, default = true, isOwn = true, --inneres Feuer
    singleFamily = { 588, 7128, 602, 1006, 10951, 10952 } },
  { singleId = 19312, default = true, isOwn = true, --shadowguard
    singleFamily = { 18137, 19308, 19309, 19310, 19311, 19312 } },
  { singleId = 19293, default = true, isOwn = true, --Elune's Grace
    singleFamily = { 2651, 19289, 19291, 19292, 19293 } },
  { singleId = 15473, default = false, isOwn = true },

  { singleId = 20770, cancelForm = true, isResurrection = true, default = true, --Auferstehung
    singleFamily = { 2006, 2010, 10880, 10881, 20770 } },

  "DRUID",
  { singleId = 9885, groupId = 21849, cancelForm = true, default = true, --Gabe/Mal der Wildniss
    singleFamily = { 1126, 5232, 6756, 5234, 8907, 9884, 9885 }, groupFamily = { 21849, 21850 },
    singleDuration = 1800, groupDuration = 3600, NeededGroupItem = { 17021, 17026 },
    classes = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId = 9910, cancelForm = true, default = false, --Dornen
    singleFamily = { 467, 782, 1075, 8914, 9756, 9910 },
    singleDuration = 600,
    classes = { "WARRIOR", "ROGUE", "DRUID", "SHAMAN", "PALADIN" } },
  { singleId = 16864, isOwn = true, cancelForm = true, default = true }, --omen of clarity
  { singleId = 17329, isOwn = true, cancelForm = true, default = false, -- Griff der Natur
    hasCD = true, NeedOutdoors = true,
    singleFamily = { 16689, 16810, 16811, 16812, 16813, 17329 },
  },
  { singleId = 5225, isTracking = true, needForm = CAT_FORM, default = true }, -- search human

  "MAGE",
  { singleId = 10157, groupId = 23028, default = true, -- arkane intelligenz
    singleFamily = { 1459, 1460, 1461, 10156, 10157 },
    singleDuration = 1800, groupDuration = 3600, NeededGroupItem = { 17020 },
    classes = { "MAGE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId = 10174, default = false, --Dampen Magic
    singleDuration = 600, classes = { },
    singleFamily = { 604, 8450, 8451, 10173, 10174 } },
  { singleId = 10170, default = false, --Amplify Magic
    singleDuration = 600, classes = { },
    singleFamily = { 1008, 8455, 10169, 10170 } },
  { singleId = 10220, isSeal = true, default = false, -- Ice Armor / eisrüstung
    singleFamily = { 7302, 7320, 10219, 10220 } },
  { singleId = 7301, isSeal = true, default = false, -- Frost Armor / frostrüstung
    singleFamily = { 168, 7300, 7301 } },
  { singleId = 22783, isSeal = true, default = false, -- Mage Armor / magische rüstung
    singleFamily = { 6117, 22782, 22783 } },
  { singleId = 10193, isOwn = true, default = false, --Manaschild - unabhängig von allen.
    singleDuration = 60,
    singleFamily = { 1463, 8494, 8495, 10191, 10192, 10193 } },
  { singleId = 13033, isOwn = true, default = false, --ice barrier
    singleDuration = 60,
    singleFamily = { 11426, 13031, 13032, 13033 } },

  { singleId = 10053, isOwn = true, default = true, ItemLock = { 5514, 5513, 8007 }, -- manastone
    singleFamily = { 759, 3552, 10053 } },
  { singleId = 10054, isOwn = true, default = true, ItemLock = { 8008 } }, -- manastone


  "SHAMAN",
  { singleId = 16342, isSeal = true, default = true, singleDuration = 500, --Flametongue
    singleFamily = { 8024, 8027, 8030, 16339, 16341, 16342 } },
  { singleId = 16356, isSeal = true, default = true, singleDuration = 500, --Frostbrand
    singleFamily = { 8033, 8038, 10456, 16355, 16356 } },
  { singleId = 16316, isSeal = true, default = true, singleDuration = 500, --Rockbiter
    singleFamily = { 8017, 8018, 8019, 10399, 16314, 16315, 16316 } },
  { singleId = 16362, isSeal = true, default = true, singleDuration = 500, --Windfury
    singleFamily = { 8232, 8235, 10486, 16362 } },
  { singleId = 10432, isOwn = true, default = true, -- Lightning Shield / Blitzschlagschild
    singleFamily = { 324, 325, 905, 945, 8134, 10431, 10432 } },
  { singleId = 20777, isResurrection = true, default = true, -- Resurrection / Auferstehung
    singleFamily = { 2008, 20609, 20610, 20776, 20777 } },

  "WARLOCK",
  { singleId = 5697, default = false, -- Unending Breath
    singleDuration = 600,
    classes = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId = 11743, default = false, -- Große Unsichtbarkeit entdecken
    singleFamily = { 132, 2970, 11743 },
    singleDuration = 600,
    classes = { "WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN" } },
  { singleId = 28610, isOwn = true, default = false, --Schattenzauberschutz
    singleFamily = { 6229, 11739, 11740, 28610 } },
  { singleId = 11735, isOwn = true, default = false, -- Demon Armor
    singleFamily = { 706, 1086, 11733, 11734, 11735 } },
  { singleId = 696, isOwn = true, default = false, -- Demon skin
    singleFamily = { 687, 696 } },
  { singleId = 18788, isOwn = true, default = true }, -- Demonic Sacrifice
  { singleId = 17953, isOwn = true, default = false, ItemLock = { 1254, 13699, 13700, 13701 }, -- Firestone
    singleFamily = { 6366, 17951, 17952, 17953 } },
  { singleId = 11730, isOwn = true, default = true, ItemLock = { 5512, 19005, 19004, 5511, 19007, 19006, 5509, 19009, 19008, 5510, 19011, 19010, 9421, 19013, 19012 }, -- Healtstone
    singleFamily = { 6201, 6202, 5699, 11729, 11730 } },
  { singleId = 20757, isOwn = true, default = true, ItemLock = { 5232, 16892, 16893, 16895, 16896 }, --Soulstone
    singleFamily = { 693, 20752, 20755, 20756, 20757 } },

  { singleId = 5500, isTracking = true, default = true }, --Sense Demons

  "HUNTER",
  { singleId = 20906, isOwn = true, default = true, -- Trueshot Aura
    singleFamily = { 19506, 20905, 20906 } },

  { singleId = 13161, isAura = true, default = true }, -- Aspect of the beast
  { singleId = 25296, isAura = true, default = true, --Aspect of the Hawk
    singleFamily = { 13165, 14318, 14319, 14320, 14321, 14322, 25296 } },
  { singleId = 13163, isAura = true, default = true }, --Aspect of the monkey
  { singleId = 20190, isAura = true, default = true, --Aspect of the wild
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

  { singleId = 20217, groupId = 25898, isBlessing = true, default = true, --Blessing of Kings
    singleDuration = 300, groupDuration = 900, NeededGroupItem = { 21177 },
    classes = { "MAGE", "HUNTER", "WARLOCK" } },
  { singleId = 19979, groupId = 25890, isBlessing = true, default = true, --Blessing of Light
    singleFamily = { 19977, 19978, 19979 }, NeededGroupItem = { 21177 },
    singleDuration = 300, groupDuration = 900,
    classes = {} },
  { singleId = 25291, groupId = 25916, isBlessing = true, default = true, --Blessing of Might
    singleFamily = { 19740, 19834, 19835, 19836, 19837, 19838, 25291 }, groupFamily = { 25782, 25916 },
    singleDuration = 300, groupDuration = 900, NeededGroupItem = { 21177 },
    classes = { "WARRIOR", "ROGUE" } },
  { singleId = 1038, groupId = 25895, isBlessing = true, default = true, --Blessing of Salvation
    singleDuration = 300, groupDuration = 900, NeededGroupItem = { 21177 },
    classes = { } },
  { singleId = 20914, groupId = 25899, isBlessing = true, default = true, --Blessing of Sanctuary
    singleFamily = { 20911, 20912, 20913, 20914 }, NeededGroupItem = { 21177 },
    singleDuration = 300, groupDuration = 900,
    classes = { } },
  { singleId = 25290, groupId = 25918, isBlessing = true, default = true, --Blessing of Wisdom -
    singleFamily = { 19742, 19850, 19852, 19853, 19854, 25290 }, groupFamily = { 25894, 25918 },
    singleDuration = 300, groupDuration = 900, NeededGroupItem = { 21177 },
    classes = { "DRUID", "SHAMAN", "PRIEST", "PALADIN" } },

  { singleId = 10293, isAura = true, default = true, -- Devotion Aura
    singleFamily = { 465, 10290, 643, 10291, 1032, 10292, 10293 } },
  { singleId = 10301, isAura = true, default = true, -- Retribution Aura
    singleFamily = { 7294, 10298, 10299, 10300, 10301 } },
  { singleId = 19746, isAura = true, default = true }, --Concentration Aura
  { singleId = 19896, isAura = true, default = true, -- Shadow Resistance Aura
    singleFamily = { 19876, 19895, 19896 } },
  { singleId = 19898, isAura = true, default = true, -- Frost Resistance Aura
    singleFamily = { 19888, 19897, 19898 } },
  { singleId = 19900, isAura = true, default = true, -- Fire Resistance Aura
    singleFamily = { 19891, 19899, 19900 } },
  { singleId = 20218, isAura = true, default = true }, --Sanctity Aura
  { singleId = 20773, isResurrection = true, default = true, -- Resurrection / Auferstehung
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
  { singleId = 432, isInfo = true, default = false, --drink
    singleFamily = { 430, 431, 432, 1133, 1135, 1137, 22734, 25696, 26475, 26261, 29007, 26473, 10250, 26402 } },
  { singleId = 434, isInfo = true, default = false, --essen
    singleFamily = { 10256, 1127, 1129, 22731, 5006, 433, 1131, 18230, 18233, 5007, 24800, 5005, 18232, 5004, 435, 434, 18234, 24869, 18229, 25888, 6410, 2639, 24005, 7737, 29073, 26260, 26474, 18231, 10257, 26472, 28616, 25700 } },
  { singleId = 20762, isInfo = true, allowWispher = true, default = false, --Seelenstein
    singleFamily = { 20707, 20762, 20763, 20765, 20764 } },
  --{singleId=10938, isInfo=true, allowWispher=true,default=false,	--ausdauer-antworten!
  --	singleFamily={1243,1244,1245,2791,10937,10938}},

  "item",
  --{singleId=10901, item=8766,isBuff=true, default=false}, -- debug schild/tau
  { singleId = 17538, item = 13452, isBuff = true, default = false }, --Elixir of the Mongoose
  { singleId = 24363, item = 20007, isBuff = true, default = false }, --Mageblood Potion
  { singleId = 3593, item = 3825, isBuff = true, default = false }, --Elixir of Fortitude
  { singleId = 11348, item = 13445, isBuff = true, default = false }, --Elixir of Superior Defense
  { singleId = 24361, item = 20004, isBuff = true, default = false }, --Major Troll's Blood Potion
  { singleId = 11371, item = 9088, isBuff = true, default = false }, --Gift of Arthas
  { singleId = 11405, item = 9206, isBuff = true, default = false }, --Elixir of Giants
  { singleId = 17539, item = 13454, isBuff = true, default = false }, --Greater Arcane Elixir
  { singleId = 11390, item = 9155, isBuff = true, default = false }, --Greater Arcane Elixir
  { singleId = 11474, item = 9264, isBuff = true, default = false }, -- Elixir of Shadow Power
  { singleId = 26276, item = 21546, isBuff = true, default = false }, --Elixir of Greater Firepower
  { singleId = 21920, item = 17708, isBuff = true, default = false }, --Elixir of Frost Power
  { singleId = 17038, item = 12820, isBuff = true, default = false }, --Winterfall Firewater
  { singleId = 16326, item = 12455, isBuff = true, default = false }, --Juju Ember
  { singleId = 16325, item = 12457, isBuff = true, default = false }, --Juju Chill
  { singleId = 16329, item = 12460, isBuff = true, default = false }, --Juju Might
  { singleId = 16323, item = 12451, isBuff = true, default = false }, --Juju Power
  { singleId = 15233, item = 11564, isBuff = true, default = false }, --Crystal Ward
  { singleId = 15279, item = 11567, isBuff = true, default = false }, --Crystal Spire
  { singleId = 18192, item = 13928, isBuff = true, default = false }, --Grilled Squid x
  { singleId = 24799, item = 20452, isBuff = true, default = false }, --Smoked Desert Dumplings x
  { singleId = 18194, item = 13931, isBuff = true, default = false }, --Nightfin Soup x
  { singleId = 22730, item = 18254, isBuff = true, default = false }, --Runn Tum Tuber Surprise x
  { singleId = 19710, item = 12218, isBuff = true, default = false }, --Monster Omelet x
  { singleId = 25661, item = 21023, isBuff = true, default = false }, --Dirge's Kickin' Chimaerok Chops x
  { singleId = 18141, item = 13813, isBuff = true, default = false }, --Blessed Sunfruit Juice x
  { singleId = 18125, item = 13810, isBuff = true, default = false }, --Blessed Sunfruit x
  { singleId = 22790, item = 18284, isBuff = true, default = false }, --Kreeg's Stout Beatdown
  { singleId = 22789, item = 18269, isBuff = true, default = false }, --Gordok Green Grog
  { singleId = 25804, item = 21151, isBuff = true, default = false }, --Rumsey Rum Black Label
  { singleId = 17549, item = 13461, isBuff = true, default = false }, --Greater Arcane Protection Potion
  { singleId = 17543, item = 13457, isBuff = true, default = false }, --Greater Fire Protection Potion
  { singleId = 17544, item = 13456, isBuff = true, default = false }, --Greater Frost Protection Potion
  { singleId = 17546, item = 13458, isBuff = true, default = false }, --Greater Nature Protection Potion
  { singleId = 17548, item = 13459, isBuff = true, default = false }, --Greater Shadow Protection Potion
  { singleId = 25123, item = 20748, items = { 20748, 20747, 20745 }, isBuff = true, isWeapon = true, duration = 1800, default = false }, --Brilliant Mana Oil
  { singleId = 25122, item = 20749, items = { 20749, 20746, 20744, 20750 }, isBuff = true, isWeapon = true, duration = 1800, default = false }, --Brilliant Wizard Oil
  { singleId = 28898, item = 23123, isBuff = true, isWeapon = true, duration = 3600, default = false }, --Blessed Wizard Oil
  { singleId = 16622, item = 12643, items = { 12643, 7965, 3241, 3240, 3239 }, isBuff = true, isWeapon = true, duration = 1800, default = false }, --Weightstone

  { singleId = 16138, item = 12404, items = { 12404, 7964, 2871, 2863, 2862 }, isBuff = true, isWeapon = true, duration = 1800, default = false }, --Sharpening Stone

  { singleId = 28891, item = 23122, isBuff = true, isWeapon = true, duration = 3600, default = false }, --Consecrated Sharpening Stone
  { singleId = 22756, item = 18262, isBuff = true, isWeapon = true, duration = 1800, default = false }, --Elemental Sharpening Stone

  { singleId = 25351, item = 20844, items = { 20844, 8985, 8984, 2893, 2892 }, isBuff = true, isWeapon = true, duration = 1800, default = false }, --Deadly Poison
  { singleId = 11399, item = 9186, items = { 9186, 6951, 5237 }, isBuff = true, isWeapon = true, duration = 1800, default = false }, --Mind-numbing Poison
  { singleId = 11340, item = 8928, items = { 8928, 8927, 8926, 6950, 6949, 6947 }, isBuff = true, isWeapon = true, duration = 1800, default = false }, --Instant Poison
  { singleId = 6650, item = 5654, items = { 5654 }, isBuff = true, isWeapon = true, duration = 1800, default = false }, --Instant Toxin
  { singleId = 13227, item = 10922, items = { 10922, 10921, 10920, 10918 }, isBuff = true, isWeapon = true, duration = 1800, default = false }, --Wound Poison
  { singleId = 11202, item = 3776, items = { 3776, 3775 }, isBuff = true, isWeapon = true, duration = 1800, default = false }, --Crippling Poison
}


--Preload items!
for x, spell in ipairs(BOM.SpellList) do
  if type(spell) == "table" then
    if spell.isBuff then
      GetItemInfo(spell.item)
    end
  end
end

function BOM.CancelBuff(list)
  local ret = false
  if not InCombatLockdown() and list then
    for i = 1, 40 do
      --name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId,
      local _, _, _, _, _, _, source, _, _, spellId = UnitBuff("player", i, "CANCELABLE")
      if tContains(list, spellId) then
        ret = true
        BOM.CancelBuffSource = source or "player"
        CancelUnitBuff("player", i)
        break
      end
    end
  end
  return ret
end

function BOM.CancelShapeShift()
  return BOM.CancelBuff(ShapeShiftTravel)
end

BOM.CachedHasItems = {}
function BOM.HasItem(list, cd)
  local key = list[1] .. (cd and "CD" or "")
  local x = BOM.CachedHasItems[key]
  if not x then
    BOM.CachedHasItems[key] = {}
    x = BOM.CachedHasItems[key]
    x.a = false
    x.d = 0

    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
      for slot = 1, GetContainerNumSlots(bag) do
        --local itemID = GetContainerItemID(bag,slot)
        local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)

        if tContains(list, itemID) then
          if cd then
            x.a, x.b, x.c = true, bag, slot
            x.d = x.d + itemCount

          else
            x.a = true
            return true
          end
        end
      end
    end
  end

  if cd and x.b and x.c then
    local startTime, _, _ = GetContainerItemCooldown(x.b, x.c)
    if (startTime or 0) == 0 then
      return x.a, x.b, x.c, x.d
    else
      return false, x.b, x.c, x.d
    end
  end

  return x.a
end

BOM.WipeCachedItems = true

local _GetItemListCached = {}
function BOM.GetItemList()

  if BOM.WipeCachedItems then
    wipe(_GetItemListCached)
    BOM.WipeCachedItems = false

    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
      for slot = 1, GetContainerNumSlots(bag) do
        --local itemID = GetContainerItemID(bag,slot)

        local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)

        for iList, list in ipairs(BOM.ItemList) do
          if tContains(list, itemID) then
            tinsert(_GetItemListCached, { Index = iList, ID = itemID, CD = { }, Link = itemLink, Bag = bag, Slot = slot, Texture = icon })
          end
        end

        if lootable and BOM.DB.OpenLootable then
          local locked = false
          for i, text in ipairs(BOM.Tool.ScanToolTip("SetBagItem", bag, slot)) do
            if text == LOCKED then
              locked = true
              break
            end
          end
          if not locked then
            tinsert(_GetItemListCached, { Index = 0, ID = itemID, CD = nil, Link = itemLink, Bag = bag, Slot = slot, Lootable = true, Texture = icon })
          end

        end

      end
    end
  end

  --Update CD
  for i, items in ipairs(_GetItemListCached) do
    if items.CD then
      items.CD = { GetContainerItemCooldown(items.Bag, items.Slot) }
    end
  end

  return _GetItemListCached
end

local function SpellLinkFormat(spellId, icon, name, rank)
  --local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell)
  if spellId == nil then
    return "NIL SPELLID"
  else
    rank = rank or "MISSING RANK"
    name = name or "MISSING NAME"
    icon = icon or "MISSING ICON"
    if rank ~= "" then
      rank = "(" .. rank .. ")"
    end
    rank = ""
    return "|Hspell:" .. spellId .. "|h|r |cff71d5ff" .. string.format(BOM.TxtEscapeIcon, icon) .. name .. rank .. "|r|h"
  end
end
local function SpellLink(spell)
  local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell)
  --print ("GETLINK",spell,name,rank,icon,castTime,minRange,maxRange,spellId)
  return SpellLinkFormat(spellId, icon, name)
end

local SpellsIncluded
function BOM.GetSpells()
  for i, profil in ipairs(BOM.ProfileNames) do
    BOM.DBChar[profil].Spell = BOM.DBChar[profil].Spell or {}
    BOM.DBChar[profil].CancelBuff = BOM.DBChar[profil].CancelBuff or {}
    BOM.DBChar[profil].Spell[BOM.BLESSINGID] = BOM.DBChar[profil].Spell[BOM.BLESSINGID] or {}
  end

  if not SpellsIncluded then
    SpellsIncluded = true
    for x, entry in ipairs(BomSharedState.CustomSpells) do
      tinsert(BOM.SpellList, BOM.Tool.CopyTable(entry))
    end
    for x, entry in ipairs(BomSharedState.CustomCancelBuff) do
      tinsert(BOM.CancelBuff, BOM.Tool.CopyTable(entry))
    end
  end

  BOM.Spells = {}
  BOM.cancelForm = {}
  BOM.AllSpellIds = {}
  BOM.SpellIdtoConfig = {}
  BOM.SpellIdIsSingle = {}
  BOM.ConfigToSpell = {}

  BOM.DB.Cache = BOM.DB.Cache or {}
  BOM.DB.Cache.Item = BOM.DB.Cache.Item or {}

  if BOM.ArgentumDawn.Link == nil or BOM.Carrot.Link == nil then
    do
      local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(BOM.ArgentumDawn.spell)
      BOM.ArgentumDawn.Link = SpellLinkFormat(spellId, icon, name, rank)
      name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(BOM.Carrot.spell)
      BOM.Carrot.Link = SpellLinkFormat(spellId, icon, name, rank)
    end
  end

  for i, spell in ipairs(BOM.CancelBuffs) do

    -- save "ConfigID"
    spell.ConfigID = spell.ConfigID or spell.singleId
    if spell.singleFamily then
      for sindex, sID in ipairs(spell.singleFamily) do
        BOM.SpellIdtoConfig[sID] = spell.ConfigID
      end
    end

    -- GetSpellNames and set default duration
    local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell.singleId)
    spell.single = name
    rank = GetSpellSubtext(spell.singleId) or ""
    spell.singleLink = SpellLinkFormat(spellId, icon, name, rank)
    spell.Icon = icon

    BOM.Tool.iMerge(BOM.AllSpellIds, spell.singleFamily)

    for i, profil in ipairs(BOM.ProfileNames) do
      if BOM.DBChar[profil].CancelBuff[spell.ConfigID] == nil then
        BOM.DBChar[profil].CancelBuff[spell.ConfigID] = {}
        BOM.DBChar[profil].CancelBuff[spell.ConfigID].Enable = spell.default or false
      end
    end
  end

  for i, spell in ipairs(BOM.SpellList) do

    if type(spell) == "table" then

      -- save "ConfigID"
      spell.ConfigID = spell.ConfigID or spell.singleId
      spell.SkipList = {}
      BOM.ConfigToSpell[spell.ConfigID] = spell

      -- get highest rank and store SpellID=ConfigID
      if spell.singleFamily then
        for sindex, sID in ipairs(spell.singleFamily) do
          BOM.SpellIdtoConfig[sID] = spell.ConfigID
          BOM.SpellIdIsSingle[sID] = true
          BOM.ConfigToSpell[sID] = spell
          if IsSpellKnown(sID) then
            spell.singleId = sID
          end
        end
      end
      if spell.singleId then
        BOM.SpellIdtoConfig[spell.singleId] = spell.ConfigID
        BOM.SpellIdIsSingle[spell.singleId] = true
        BOM.ConfigToSpell[spell.singleId] = spell
      end
      if spell.groupFamily then
        for sindex, sID in ipairs(spell.groupFamily) do
          BOM.SpellIdtoConfig[sID] = spell.ConfigID
          BOM.ConfigToSpell[sID] = spell
          if IsSpellKnown(sID) then
            spell.groupId = sID
          end
        end
      end
      if spell.groupId then
        BOM.SpellIdtoConfig[spell.groupId] = spell.ConfigID
        BOM.ConfigToSpell[spell.groupId] = spell
      end

      -- GetSpellNames and set default duration
      if spell.singleId and not spell.isBuff then
        local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell.singleId)
        spell.single = name
        rank = GetSpellSubtext(spell.singleId) or ""
        spell.singleLink = SpellLinkFormat(spellId, icon, name, rank)
        spell.Icon = icon
        if spell.isTracking then
          spell.TrackingIcon = icon
        end
        if not spell.isInfo and not spell.isBuff and spell.singleDuration and BOM.DB.Duration[name] == nil and IsSpellKnown(spell.singleId) then
          BOM.DB.Duration[name] = spell.singleDuration
        end
      end
      if spell.groupId then
        local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell.groupId)
        spell.group = name
        rank = GetSpellSubtext(spell.groupId) or ""
        spell.groupLink = SpellLinkFormat(spellId, icon, name, rank)
        if spell.groupDuration and BOM.DB.Duration[name] == nil and IsSpellKnown(spell.groupId) then
          BOM.DB.Duration[name] = spell.groupDuration
        end
      end

      -- has Spell? Manacost?
      local add
      if IsSpellKnown(spell.singleId) then
        add = true
        spell.singleMana = 0
        local cost = GetSpellPowerCost(spell.single)
        if type(cost) == "table" then
          for i = 1, #cost do
            if cost[i] and cost[i].name == "MANA" then
              spell.singleMana = cost[i].cost or 0
            end
          end
        end
      end
      if spell.group and IsSpellKnown(spell.groupId) then
        add = true
        spell.groupMana = 0
        local cost = GetSpellPowerCost(spell.group)
        if type(cost) == "table" then
          for i = 1, #cost do
            if cost[i] and cost[i].name == "MANA" then
              spell.groupMana = cost[i].cost or 0
            end
          end
        end
      end

      if spell.isBuff then
        if not spell.isScanned then
          local itemName, itemLink, _, _, _, _, _, _, _, itemIcon, _, _, _, _, _, _, _ = GetItemInfo(spell.item)
          if (not itemName or not itemLink or not itemIcon) and BOM.DB.Cache.Item[spell.item] then
            itemName, itemLink, itemIcon = unpack(BOM.DB.Cache.Item[spell.item])
          elseif (not itemName or not itemLink or not itemIcon) and BOM.ItemCache[spell.item] then
            itemName, itemLink, itemIcon = unpack(BOM.ItemCache[spell.item])
          end
          if itemName and itemLink and itemIcon then
            add = true
            spell.single = itemName
            spell.singleLink = string.format(BOM.TxtEscapeIcon, itemIcon) .. itemLink
            spell.Icon = itemIcon
            spell.isScanned = true

            BOM.DB.Cache.Item[spell.item] = {
              itemName, itemLink, itemIcon
            }
          else
            print(BOM.MSGPREFIX, "Item not found!", spell.single, spell.singleId, spell.item, "x", BOM.ItemCache[spell.item])
          end
        else
          add = true
        end

        if spell.items == nil then
          spell.items = { spell.item }
        end

      end

      if spell.isInfo then
        add = true
      end

      -- Add
      if add then
        tinsert(BOM.Spells, spell)
        BOM.Tool.iMerge(BOM.AllSpellIds, spell.singleFamily, spell.groupFamily, spell.singleId, spell.groupId)

        if spell.cancelForm then
          BOM.Tool.iMerge(BOM.cancelForm, spell.singleFamily, spell.groupFamily, spell.singleId, spell.groupId)
        end

        --setDefaultValues!
        for i, profil in ipairs(BOM.ProfileNames) do

          if BOM.DBChar[profil].Spell[spell.ConfigID] == nil then
            BOM.DBChar[profil].Spell[spell.ConfigID] = {}
            BOM.DBChar[profil].Spell[spell.ConfigID].Class = BOM.DBChar[profil].Spell[spell.ConfigID].Class or {}
            BOM.DBChar[profil].Spell[spell.ConfigID].ForcedTarget = BOM.DBChar[profil].Spell[spell.ConfigID].ForcedTarget or {}

            BOM.DBChar[profil].Spell[spell.ConfigID].Enable = spell.default or false

            if BOM.SpellHasClasses(spell) then
              local SelfCast = true
              BOM.DBChar[profil].Spell[spell.ConfigID].SelfCast = false
              for ci, class in ipairs(BOM.Tool.Classes) do
                BOM.DBChar[profil].Spell[spell.ConfigID].Class[class] = tContains(spell.classes, class)
                SelfCast = BOM.DBChar[profil].Spell[spell.ConfigID].Class[class] and false or SelfCast
              end
              BOM.DBChar[profil].Spell[spell.ConfigID].ForcedTarget = {}
              BOM.DBChar[profil].Spell[spell.ConfigID].SelfCast = SelfCast
            end
          else
            BOM.DBChar[profil].Spell[spell.ConfigID].Class = BOM.DBChar[profil].Spell[spell.ConfigID].Class or {}
            BOM.DBChar[profil].Spell[spell.ConfigID].ForcedTarget = BOM.DBChar[profil].Spell[spell.ConfigID].ForcedTarget or {}

          end

        end
      end
    end
  end
  --BOM.DBChar.DEBUGOUT=txt
end

local MemberCache = {}

local function GetMember(unitid, NameGroup, NameRole)

  local name = (UnitFullName(unitid))
  if name == nil then
    return nil
  end

  local group = NameGroup and NameGroup[name] or 1
  local isTank = NameRole and (NameRole[name] == "MAINTANK") or false

  local guid = UnitGUID(unitid)
  local _, class, link
  if guid then
    _, class = GetPlayerInfoByGUID(guid)
    if class then
      link = BOM.Tool.IconClass[class] .. "|Hunit:" .. guid .. ":" .. name .. "|h|c" .. RAID_CLASS_COLORS[class].colorStr .. name .. "|r|h"
    else
      class = ""
      link = string.format(BOM.TxtEscapeIcon, BOM.IconPet) .. name
    end
  else
    class = ""
    link = string.format(BOM.TxtEscapeIcon, BOM.IconPet) .. name
  end

  MemberCache[unitid] = MemberCache[unitid] or {}
  member = MemberCache[unitid]
  member.distance = 100000
  member.unitId = unitid
  member.name = name
  member.group = group
  member.hasResurrection = member.hasResurrection or false
  member.class = class
  member.link = link
  member.isTank = isTank
  member.buffs = member.buffs or {}

  return member
end

local savedParty, savedPlayerMember
local function NumMember()
  local countTo
  local prefix
  local count
  if IsInRaid() then
    countTo = 40
    prefix = "raid"
    count = 0
  else
    countTo = 4
    prefix = "group"
    if UnitPlayerOrPetInParty("pet") then
      count = 2
    else
      count = 1
    end
  end

  for i = 1, countTo do
    if UnitPlayerOrPetInParty(prefix .. i) then
      count = count + 1
      if UnitPlayerOrPetInParty(prefix .. "pet" .. i) then
        count = count + 1
      end
    end
  end

  return count
end

function BOM.GetPartyMembers()
  -- and buffs

  local party
  local playerMember


  -- check if stored party is correct!
  if not BOM.PartyUpdateNeeded and savedParty ~= nil and savedPlayerMember ~= nil then

    if #savedParty == NumMember() + (BOM.SaveTargetName and 1 or 0) then
      local ok = true
      for i, member in ipairs(savedParty) do
        local name = (UnitFullName(member.unitId))
        if name ~= member.name then
          ok = false
          break
        end
      end
      if ok then
        party = savedParty
        playerMember = savedPlayerMember
      end
    end
  end

  -- read party data
  if party == nil or playerMember == nil then
    party = {}

    if IsInRaid() then
      local NameGroup = {}
      local NameRole = {}

      for raidIndex = 1, 40 do
        local name, rank, subgroup, level, class, fileName,
        zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(raidIndex)

        if name then
          name = BOM.Tool.Split(name, "-")[1]
          NameGroup[name] = subgroup
          NameRole[name] = role
        end
      end

      for raidIndex = 1, 40 do
        local member = GetMember("raid" .. raidIndex, NameGroup, NameRole)
        if member then
          if UnitIsUnit(member.unitId, "player") then
            playerMember = member
          end
          tinsert(party, member)

          member = GetMember("raidpet" .. raidIndex)
          if member then
            member.group = 9
            member.class = "pet"
            tinsert(party, member)
          end
        end
      end

    else
      local member
      for groupIndex = 1, 4 do
        member = GetMember("party" .. groupIndex)
        if member then
          tinsert(party, member)
        end
        member = GetMember("partypet" .. groupIndex)
        if member then
          member.group = 9
          member.class = "pet"
          tinsert(party, member)
        end
      end
      playerMember = GetMember("player")
      tinsert(party, playerMember)
      member = GetMember("pet")
      if member then
        member.group = 9
        member.class = "pet"
        tinsert(party, member)
      end
    end

    if BOM.DB.BuffTarget and UnitExists("target") and UnitCanCooperate("player", "target") and UnitIsPlayer("target") and not UnitPlayerOrPetInParty("target") and not UnitPlayerOrPetInRaid("target") then
      local member = GetMember("target")
      if member then
        member.group = 9
        tinsert(party, member)
      end
    end

    savedParty = party
    savedPlayerMember = playerMember

    -- Cleanup BOM.PlayerBuffs
    for name, val in pairs(BOM.PlayerBuffs) do
      local ok = false
      for i, member in ipairs(party) do
        if member.name == name then
          ok = true
        end
      end
      if ok == false then
        BOM.PlayerBuffs[name] = nil
      end
    end

    BOM.ForceUpdate = true -- always read all buffs on new party!

  end

  BOM.PartyUpdateNeeded = false

  BOM.SomeBodyGhost = false
  local zonePlayer = C_Map.GetBestMapForUnit("player")

  if IsAltKeyDown() then
    BOM.DeclineHasResurrection = true
    BOM.ClearSkip()
  end

  for i, member in ipairs(party) do
    member.isSameZone = (C_Map.GetBestMapForUnit(member.unitId) == zonePlayer) or member.isGhost or member.unitId == "target"
    if not member.isDead or BOM.DeclineHasResurrection then
      member.hasResurrection = false
      member.distance = BOM.Tool.UnitDistanceSquared(member.unitId)
    else
      member.hasResurrection = UnitHasIncomingResurrection(member.unitId) or member.hasResurrection
    end

    if BOM.ForceUpdate then
      member.isPlayer = (member == playerMember)
      member.isDead = UnitIsDeadOrGhost(member.unitId) and not UnitIsFeignDeath(member.unitId)
      member.isGhost = UnitIsGhost(member.unitId)
      member.isConnected = UnitIsConnected(member.unitId)

      member.NeedBuff = true

      wipe(member.buffs)

      BOM.SomeBodyGhost = BOM.SomeBodyGhost or member.isGhost

      if member.isDead then
        BOM.PlayerBuffs[member.name] = nil
      else
        member.hasArgentumDawn = false
        member.hasCarrot = false
        local buffIndex = 0
        repeat
          buffIndex = buffIndex + 1

          local name, icon, count, debuffType, duration, expirationTime, source, isStealable,
          nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = BOM.UnitAura(member.unitId, buffIndex, "HELPFUL")

          spellId = BOM.SpellToSpell[spellId] or spellId

          if spellId then
            if tContains(BOM.BuffIgnoreAll, spellId) then
              wipe(member.buffs)
              member.NeedBuff = false
              break
            end

            if spellId == BOM.ArgentumDawn.spell then
              member.hasArgentumDawn = true
            end

            if spellId == BOM.Carrot.spell then
              member.hasCarrot = true
            end

            if tContains(BOM.AllSpellIds, spellId) then
              member.buffs[BOM.SpellIdtoConfig[spellId]] = {
                ["duration"] = duration,
                ["expirationTime"] = expirationTime,
                ["source"] = source,
                ["isSingle"] = BOM.SpellIdIsSingle[spellId],
              }
            end
          end

        until (not name)
      end
    end
  end

  -- weapon-buffs
  -- Clear old
  local OldMainHandBuff = playerMember.MainHandBuff
  local OldOffHandBuff = playerMember.OffHandBuff

  local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()
  if hasMainHandEnchant and mainHandEnchantID and BOM.EnchantToSpell[mainHandEnchantID] then
    local configId = BOM.EnchantToSpell[mainHandEnchantID]
    local duration
    if BOM.ConfigToSpell[ConfigID] and BOM.ConfigToSpell[ConfigID].singleDuration then
      duration = BOM.ConfigToSpell[ConfigID].singleDuration
    else
      duration = 300
    end

    playerMember.buffs[configId] = {
      ["duration"] = duration,
      ["expirationTime"] = GetTime() + mainHandExpiration / 1000,
      ["source"] = "player",
      ["isSingle"] = true,
    }
    playerMember.MainHandBuff = configId
  else
    playerMember.MainHandBuff = nil
  end

  if hasOffHandEnchant and offHandEnchantId and BOM.EnchantToSpell[offHandEnchantId] then
    local configId = BOM.EnchantToSpell[offHandEnchantId]
    local duration
    if BOM.ConfigToSpell[ConfigID] and BOM.ConfigToSpell[ConfigID].singleDuration then
      duration = BOM.ConfigToSpell[ConfigID].singleDuration
    else
      duration = 300
    end

    playerMember.buffs[-configId] = {
      ["duration"] = duration,
      ["expirationTime"] = GetTime() + offHandExpiration / 1000,
      ["source"] = "player",
      ["isSingle"] = true,
    }
    playerMember.OffHandBuff = configId
  else
    playerMember.OffHandBuff = nil
  end

  if OldMainHandBuff ~= playerMember.MainHandBuff then
    BOM.ForceUpdate = true
  end

  if OldOffHandBuff ~= playerMember.OffHandBuff then
    BOM.ForceUpdate = true
  end

  BOM.DeclineHasResurrection = false

  return party, playerMember
end

function BOM.GetNeedBuff(party, spell, playerMember)
  spell.NeedMember = spell.NeedMember or {}
  spell.NeedGroup = spell.NeedGroup or {}
  spell.DeathGroup = spell.DeathGroup or {}
  wipe(spell.NeedGroup)
  wipe(spell.NeedMember)
  wipe(spell.DeathGroup)
  local SomeBodyDeath = false

  if not BOM.CurrentProfile.Spell[spell.ConfigID].Enable then
    --nothing!
  elseif spell.isWeapon then
    if (BOM.CurrentProfile.Spell[spell.ConfigID].MainHandEnable and playerMember.MainHandBuff == nil) or (BOM.CurrentProfile.Spell[spell.ConfigID].OffHandEnable and playerMember.OffHandBuff == nil) then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.isBuff then
    if not playerMember.buffs[spell.ConfigID] then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.isInfo then
    spell.playerActiv = false
    for i, member in ipairs(party) do
      if member.buffs[spell.ConfigID] then
        tinsert(spell.NeedMember, member)
        if member.isPlayer then
          spell.playerActiv = true
          spell.wasPlayerActiv = true
          spell.buffSource = member.buffs[spell.ConfigID].source
        end

        if UnitIsUnit("player", member.buffs[spell.ConfigID].source or "") then
          BOM.ItemListTarget[spell.ConfigID] = member.name
        end

      end
    end
  elseif spell.isOwn then
    if not playerMember.isDead then
      if spell.ItemLock then
        if IsSpellKnown(spell.singleId) and not (BOM.HasItem(spell.ItemLock)) then
          tinsert(spell.NeedMember, playerMember)
        end
      elseif not (playerMember.buffs[spell.ConfigID] and BOM.TimeCheck(playerMember.buffs[spell.ConfigID].expirationTime, playerMember.buffs[spell.ConfigID].duration)) then
        tinsert(spell.NeedMember, playerMember)
      end
    end

  elseif spell.isResurrection then
    for i, member in ipairs(party) do
      if member.isDead and not member.hasResurrection and member.isConnected and member.group ~= 9 and (not BOM.DB.SameZone or member.isSameZone) then
        tinsert(spell.NeedMember, member)
      end
    end

  elseif spell.isTracking then
    if GetTrackingTexture() ~= spell.TrackingIcon and (BOM.ForceTracking == nil or BOM.ForceTracking == spell.TrackingIcon) then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.isAura then
    if BOM.ActivAura ~= spell.ConfigID and (BOM.CurrentProfile.LastAura == nil or BOM.CurrentProfile.LastAura == spell.ConfigID) then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.isSeal then
    if BOM.ActivSeal ~= spell.ConfigID and (BOM.CurrentProfile.LastSeal == nil or BOM.CurrentProfile.LastSeal == spell.ConfigID) then
      tinsert(spell.NeedMember, playerMember)
    end

  elseif spell.isBlessing then
    for i, member in ipairs(party) do
      local ok = false
      local notGroup = false

      if BOM.CurrentProfile.Spell[BOM.BLESSINGID][member.name] == spell.ConfigID or
              (member.isTank and BOM.CurrentProfile.Spell[spell.ConfigID].Class["tank"] and not BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast) then
        ok = true
        notGroup = true

      elseif BOM.CurrentProfile.Spell[BOM.BLESSINGID][member.name] == nil then
        if BOM.CurrentProfile.Spell[spell.ConfigID].Class[member.class] and (not IsInRaid() or BOM.WatchGroup[member.group]) and not BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast then
          ok = true
        end
        if BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast and UnitIsUnit(member.unitId, "player") then
          ok = true
        end
      end

      if member.NeedBuff and ok and member.isConnected and (not BOM.DB.SameZone or member.isSameZone) then
        local found = false

        if member.isDead then
          if member.group ~= 9 and member.class ~= "pet" then
            SomeBodyDeath = true
            spell.DeathGroup[member.class] = true
          end
        elseif member.buffs[spell.ConfigID] then
          found = BOM.TimeCheck(member.buffs[spell.ConfigID].expirationTime, member.buffs[spell.ConfigID].duration)
        end

        if not found then
          tinsert(spell.NeedMember, member)
          if not notGroup then
            spell.NeedGroup[member.class] = (spell.NeedGroup[member.class] or 0) + 1
          end
        elseif not notGroup and BOM.DB.ReplaceSingle and member.buffs[spell.ConfigID] and member.buffs[spell.ConfigID].isSingle then
          spell.NeedGroup[member.class] = (spell.NeedGroup[member.class] or 0) + 1
        end

      end
    end

  else
    --spells
    for i, member in ipairs(party) do
      local ok = false

      if BOM.CurrentProfile.Spell[spell.ConfigID].Class[member.class] and (not IsInRaid() or BOM.WatchGroup[member.group]) and not BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast then
        ok = true
      end
      if BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast and UnitIsUnit(member.unitId, "player") then
        ok = true
      end
      if BOM.CurrentProfile.Spell[spell.ConfigID].ForcedTarget[member.name] then
        ok = true
      end
      if member.isTank and BOM.CurrentProfile.Spell[spell.ConfigID].Class["tank"] and not BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast then
        ok = true
      end

      if member.NeedBuff and ok and member.isConnected and (not BOM.DB.SameZone or member.isSameZone) then
        local found = false

        if member.isDead then
          SomeBodyDeath = true
          spell.DeathGroup[member.group] = true

        elseif member.buffs[spell.ConfigID] then
          found = BOM.TimeCheck(member.buffs[spell.ConfigID].expirationTime, member.buffs[spell.ConfigID].duration)
        end

        if not found then
          tinsert(spell.NeedMember, member)
          spell.NeedGroup[member.group] = (spell.NeedGroup[member.group] or 0) + 1
        elseif BOM.DB.ReplaceSingle and member.buffs[spell.ConfigID] and member.buffs[spell.ConfigID].isSingle then
          spell.NeedGroup[member.group] = (spell.NeedGroup[member.group] or 0) + 1
        end


      end
    end
  end

  -- Check Spell CD
  if spell.hasCD and #spell.NeedMember > 0 then
    local startTime, duration = GetSpellCooldown(spell.singleId)
    if duration ~= 0 then
      wipe(spell.NeedGroup)
      wipe(spell.NeedMember)
      wipe(spell.DeathGroup)
      startTime = startTime + duration
      if BOM.MinTimer > startTime then
        BOM.MinTimer = startTime
      end
      SomeBodyDeath = false
    end
  end

  return SomeBodyDeath
end

function BOM.UpdateMacro(member, spellId, command)
  if (GetMacroInfo(BOM.MACRONAME)) == nil then
    local perAccount, perChar = GetNumMacros()
    local isChar = nil
    if perChar < MAX_CHARACTER_MACROS then
      isChar = 1
    elseif perAccount >= MAX_ACCOUNT_MACROS then
      print(BOM.MSGPREFIX .. L.MsgNeedOneMacroSlot)
      return
    end
    --print ("generate macro",isChar)
    CreateMacro(BOM.MACRONAME, BOM.Icon, "", isChar)
  end

  local macroText, icon
  if member and spellId then

    --Downgrade-Check
    local spell = BOM.ConfigToSpell[spellId]
    local rank = ""
    if spell == nil then
      print("NIL SPELL:", spellId)
    end
    if BOM.DB.UseRank or member.unitId == "target" then
      local level = UnitLevel(member.unitId)
      if spell and level ~= nil and level > 0 then
        local x
        if spell.singleFamily and tContains(spell.singleFamily, spellId) then
          x = spell.singleFamily
        elseif spell.groupFamily and tContains(spell.groupFamily, spellId) then
          x = spell.groupFamily
        end
        if x then
          local newSpellId
          --print("Dodowngrade",spell.DownGrade[member.name])
          for i, id in ipairs(x) do
            --print(id)
            if BOM.DB.SpellGreatherEqualThan[id] == nil or BOM.DB.SpellGreatherEqualThan[id] < level then
              newSpellId = id
            else
              break
            end
            if id == spellId then
              break
            end
            --print(newSpellId,spellId,"Set")
          end
          spellId = newSpellId or spellId
        end
      end
      rank = GetSpellSubtext(spellId) or ""
      if rank ~= "" then
        rank = "(" .. rank .. ")"
      end
      --prsint("Use",GetSpellInfo(spellId),rank,spellId)
    end

    BOM.ERRSpellId = spellId
    local name = GetSpellInfo(spellId)

    macroText = "#showtooltip\n/bom update\n" ..
            (tContains(BOM.cancelForm, spellId) and "/cancelform [nocombat]\n" or "") ..
            "/bom _checkforerror\n" ..
            "/cast [@" .. member.unitId .. ",nocombat]" .. name .. rank .. "\n"
    icon = BOM.Icon
  else
    macroText = "#showtooltip\n/bom update\n"
    if command then
      macroText = macroText .. command
    end
    icon = BOM.IconOff
  end

  EditMacro(BOM.MACRONAME, nil, icon, macroText)
  BOM.MinimapButton.SetTexture("Interface\\ICONS\\" .. icon)
end

local function GetGroupInRange(SpellName, party, groupNb, spell)
  local minDist
  local ret = nil
  for i, member in ipairs(party) do
    if member.group == groupNb then
      if not (IsSpellInRange(SpellName, member.unitId) == 1 or member.isDead) then
        if member.distance > 2000 then
          return nil
        end
      elseif (minDist == nil or member.distance < minDist) and not tContains(spell.SkipList, member.name) then
        minDist = member.distance
        ret = member
      end
    end
  end
  return ret
end
local function GetClassInRange(SpellName, party, class, spell)
  local minDist
  local ret = nil
  for i, member in ipairs(party) do
    if member.class == class then
      if member.isDead then
        return nil
      elseif not (IsSpellInRange(SpellName, member.unitId) == 1) then
        if member.distance > 2000 then
          return nil
        end
      elseif (minDist == nil or member.distance < minDist) and not tContains(spell.SkipList, member.name) then
        minDist = member.distance
        ret = member
      end
    end
  end
  return ret
end

function BOM.TimeCheck(ti, duration)
  if ti == nil or duration == nil or ti == 0 or duration == 0 then
    return true
  end
  local dif
  if duration <= 60 then
    dif = BOM.DB.Time60
  elseif duration <= 300 then
    dif = BOM.DB.Time300
  elseif duration <= 600 then
    dif = BOM.DB.Time600
  elseif duration <= 1800 then
    dif = BOM.DB.Time1800
  else
    dif = BOM.DB.Time3600
  end
  if dif + GetTime() < ti then
    ti = ti - dif
    if ti < BOM.MinTimer then
      BOM.MinTimer = ti
    end
    return true
  end

  return false
end

local displayCache = {}
local display = {}
local displayInfo = {}
local displayI
local function AddDisplay(text, distance, isInfo)
  displayI = displayI + 1
  displayCache[displayI] = displayCache[displayI] or {}
  displayCache[displayI][1] = text
  displayCache[displayI][2] = distance
  if not isInfo then
    tinsert(display, displayCache[displayI])
  else
    tinsert(displayInfo, displayCache[displayI])
  end
end
local function ClearDisplay()
  BuffOmat_ListTab_MessageFrame:Clear()
  displayI = 0
  wipe(display)
  wipe(displayInfo)
end

local function OutputDisplay()
  table.sort(display, function(a, b)
    return a[2] > b[2] or (a[2] == b[2] and a[1] > b[1])
  end)
  table.sort(displayInfo, function(a, b)
    return a[1] > b[1]
  end)

  for i, txt in ipairs(displayInfo) do
    BuffOmat_ListTab_MessageFrame:AddMessage(txt[1])
  end
  for i, txt in ipairs(display) do
    BuffOmat_ListTab_MessageFrame:AddMessage(txt[1])
  end
end

local cast = {}
local PlayerMana
local function CatchSpell(cost, id, link, member, spell)
  if cost > PlayerMana then
    return
  end

  if not spell.isResurrection and member.isDead then
    return
  elseif cast.Spell and not spell.isTracking then
    if cast.Spell.isTracking then
      return
    elseif spell.isResurrection then
      if cast.Spell.isResurrection then
        if (tContains(ResurrectionClass, cast.Member.class) and not tContains(ResurrectionClass, member.class)) or
                (tContains(ManaClass, cast.Member.class) and not tContains(ManaClass, member.class)) or
                (not cast.Member.isGhost and member.isGhost) or
                (cast.Member.distance < member.distance) then
          return
        end
      end
    else
      if (BOM.DB.SelfFirst and cast.Member.isPlayer and not member.isPlayer) or (cast.Member.group ~= 9 and member.group == 9) then
        --print(cast.Link,"-",link,"1")
        return
      elseif (not BOM.DB.SelfFirst or (cast.Member.isPlayer == member.isPlayer)) and ((cast.Member.group == 9) == (member.group == 9)) and cast.manaCost > cost then
        --print(cast.Link,"-",link,"2")
        return
      else
        --print(cast.Link,"-",link,"3")
        --print(not BOM.DB.SelfFirst or (cast.Member.isPlayer==member.isPlayer))
        --print(((cast.Member.group==9) == (member.group==9)))
        --print(cast.manaCost>cost)

      end
    end
  end

  cast.manaCost = cost
  cast.SpellId = id
  cast.Link = link
  cast.Member = member
  cast.Spell = spell

end
local function ClearSpell()
  cast.manaCost = -1
  cast.SpellId = nil
  cast.Member = nil
  cast.Spell = nil
  cast.Link = nil
end
function BOM.UpdateScan()
  if BOM.Spells == nil then
    return
  end

  if BOM.InLoading then
    --print("INLOADING!")
    return
  end

  BOM.MinTimer = GetTime() + 36000 -- 10 hours

  ClearDisplay()
  BOM.RepeatUpdate = false

  if InCombatLockdown() then
    BOM.ForceUpdate = false
    BOM.CheckForError = false
    BuffOmat_ListTab_Button:SetText(L.MsgCombat)
    --BuffOmat_ListTab_Button:Disable() combatlock -imposible!
    return
  end
  if UnitIsDeadOrGhost("player") then
    BOM.ForceUpdate = false
    BOM.CheckForError = false
    BOM.UpdateMacro()
    BuffOmat_ListTab_Button:SetText(L.MsgDead)
    BuffOmat_ListTab_Button:Disable()
    BOM.AutoClose()
    return
  end


  --local slowdown=GetTime()
  --repeat
  --until (GetTime()-slowdown>0.016)

  --[[
	function sleep(s)
		local ntime =debugprofilestop()+s
		repeat until debugprofilestop() > ntime
	end
	sleep(160)
	--]]


  --Choose Profile
  local inInstance, instanceType = IsInInstance()
  local InDisabled

  local chooseProfile = "solo"
  if IsInRaid() then
    chooseProfile = "raid"
  elseif IsInGroup() then
    chooseProfile = "group"
  end

  if instanceType == "pvp" or instanceType == "arena" then
    InDisabled = not BOM.DB.InPVP
    chooseProfile = "battleground"

  elseif instanceType == "party" or instanceType == "raid" or instanceType == "scenario" then
    InDisabled = not BOM.DB.InInstance
  else
    InDisabled = not BOM.DB.InWorld
  end

  if BOM.ForceProfile then
    chooseProfile = BOM.ForceProfile
  end

  if not BOM.DBChar.UseProfiles then
    chooseProfile = "solo"
  end

  if BOM.CurrentProfile ~= BOM.DBChar[chooseProfile] then
    BOM.CurrentProfile = BOM.DBChar[chooseProfile]
    BOM.UpdateSpellsTab()
    BuffOmat_MainWindow_Title:SetText(string.format(BOM.TxtEscapeIcon, BOM.FullIcon) .. " " .. BOM.Title .. " - " .. L["profile_" .. chooseProfile])
    BOM.ForceUpdate = true
  end

  if InDisabled then
    BOM.CheckForError = false
    BOM.ForceUpdate = false
    BOM.UpdateMacro()
    BuffOmat_ListTab_Button:SetText(L.MsgDisabled)
    BuffOmat_ListTab_Button:Disable()
    BOM.AutoClose()
    return
  end

  local party, playerMember = BOM.GetPartyMembers()

  if BOM.ForceUpdate then
    --reset tracking
    BOM.ForceTracking = nil
    for i, spell in ipairs(BOM.Spells) do
      if spell.isTracking then
        if BOM.CurrentProfile.Spell[spell.ConfigID].Enable then
          if spell.needForm ~= nil then
            if GetShapeshiftFormID() == spell.needForm and BOM.ForceTracking ~= spell.TrackingIcon then
              BOM.ForceTracking = spell.TrackingIcon
              BOM.UpdateSpellsTab()
            end
          elseif GetTrackingTexture() == spell.TrackingIcon and BOM.DBChar.LastTracking ~= spell.TrackingIcon then
            BOM.DBChar.LastTracking = spell.TrackingIcon
            BOM.UpdateSpellsTab()
          end
        else
          if BOM.DBChar.LastTracking == spell.TrackingIcon and BOM.DBChar.LastTracking ~= nil then
            BOM.DBChar.LastTracking = nil
            BOM.UpdateSpellsTab()
          end
        end
      end
    end
    if BOM.ForceTracking == nil then
      BOM.ForceTracking = BOM.DBChar.LastTracking
    end

    --find activ aura / seal
    BOM.ActivAura = nil
    BOM.ActivSeal = nil

    for i, spell in ipairs(BOM.Spells) do
      if playerMember.buffs[spell.ConfigID] then
        if spell.isAura then
          if (BOM.ActivAura == nil and BOM.LastAura == spell.ConfigID) or UnitIsUnit(playerMember.buffs[spell.ConfigID].source, "player") then
            if BOM.TimeCheck(playerMember.buffs[spell.ConfigID].expirationTime, playerMember.buffs[spell.ConfigID].duration) then
              BOM.ActivAura = spell.ConfigID
            end
          end
        elseif spell.isSeal then
          if UnitIsUnit(playerMember.buffs[spell.ConfigID].source, "player") then
            if BOM.TimeCheck(playerMember.buffs[spell.ConfigID].expirationTime, playerMember.buffs[spell.ConfigID].duration) then
              BOM.ActivSeal = spell.ConfigID
            end
          end
        end
      end
    end

    --reset aura/seal
    for i, spell in ipairs(BOM.Spells) do
      if spell.isAura then
        if BOM.CurrentProfile.Spell[spell.ConfigID].Enable then
          if BOM.ActivAura == spell.ConfigID and BOM.CurrentProfile.LastAura ~= spell.ConfigID then
            BOM.CurrentProfile.LastAura = spell.ConfigID
            BOM.UpdateSpellsTab()
          end
        else
          if BOM.CurrentProfile.LastAura == spell.ConfigID and BOM.CurrentProfile.LastAura ~= nil then
            BOM.CurrentProfile.LastAura = nil
            BOM.UpdateSpellsTab()
          end
        end
      elseif spell.isSeal then
        if BOM.CurrentProfile.Spell[spell.ConfigID].Enable then
          if BOM.ActivSeal == spell.ConfigID and BOM.CurrentProfile.LastSeal ~= spell.ConfigID then
            BOM.CurrentProfile.LastSeal = spell.ConfigID
            BOM.UpdateSpellsTab()
          end
        else
          if BOM.CurrentProfile.LastSeal == spell.ConfigID and BOM.CurrentProfile.LastSeal ~= nil then
            BOM.CurrentProfile.LastSeal = nil
            BOM.UpdateSpellsTab()
          end
        end
      end
    end

    -- who needs a buff!
    local SomeBodyDeath = false
    for i, spell in ipairs(BOM.Spells) do
      SomeBodyDeath = BOM.GetNeedBuff(party, spell, playerMember) or SomeBodyDeath
    end
    BOM.OldSomeBodyDeath = SomeBodyDeath
  else
    SomeBodyDeath = BOM.OldSomeBodyDeath
  end


  -- cancel buffs
  for i, spell in ipairs(BOM.CancelBuffs) do
    if BOM.CurrentProfile.CancelBuff[spell.ConfigID].Enable and not spell.OnlyCombat then
      if playerMember.buffs[spell.ConfigID] then
        print(BOM.MSGPREFIX, string.format(L.MsgCancelBuff, spell.singleLink or spell.single, UnitName(playerMember.buffs[spell.ConfigID].source or "") or ""))
        BOM.CancelBuff(spell.singleFamily)
      end
    end
  end

  -- fill list and find cast
  PlayerMana = UnitPower("player", 0) or 0--mana
  BOM.ManaLimit = UnitPowerMax("player", 0) or 0

  ClearSpell()

  local BagCommand
  local BagTitel
  BOM.ScanModifier = false

  local inRange = false

  for spellIndex, spell in ipairs(BOM.Spells) do

    if spell.isInfo and BOM.CurrentProfile.Spell[spell.ConfigID].Wispher then
      if spell.wasPlayerActiv and not spell.playerActiv then
        spell.wasPlayerActiv = false
        local name = UnitName(spell.buffSource or "")
        if name then
          SendChatMessage(BOM.MSGPREFIX .. string.format(L.MsgSpellExpired, spell.single), "WHISPER", nil, name)
        end
      end
    end

    if BOM.CurrentProfile.Spell[spell.ConfigID].Enable and (spell.needForm == nil or GetShapeshiftFormID() == spell.needForm) then

      if #spell.NeedMember > 0 and not spell.isInfo and not spell.isBuff then
        if spell.singleMana < BOM.ManaLimit and spell.singleMana > PlayerMana then
          BOM.ManaLimit = spell.singleMana
        end
        if spell.groupMana and spell.groupMana < BOM.ManaLimit and spell.groupMana > PlayerMana then
          BOM.ManaLimit = spell.groupMana
        end
      end

      if spell.isWeapon then
        if #spell.NeedMember > 0 then
          local ok, bag, slot, count = BOM.HasItem(spell.items, true)
          count = count or 0
          if ok then
            local texture, _, _, _, _, _, itemLink, _, _, _ = GetContainerItemInfo(bag, slot)

            if BOM.CurrentProfile.Spell[spell.ConfigID].OffHandEnable and playerMember.OffHandBuff == nil then
              if BOM.DB.DontUseConsumables and not IsModifierKeyDown() then
                AddDisplay(string.format(BOM.TxtEscapeIcon, texture) .. itemLink .. "x" .. count .. " (" .. L.TTOffHand .. ")", playerMember.distance, true)
              else
                BagTitel = string.format(BOM.TxtEscapeIcon, texture) .. itemLink .. "x" .. count .. " (" .. L.TTOffHand .. ")"
                BagCommand = "/use " .. bag .. " " .. slot .. "\n/use 17" -- offhand
                AddDisplay(BagTitel, playerMember.distance, true)
              end
            end
            if BOM.CurrentProfile.Spell[spell.ConfigID].MainHandEnable and playerMember.MainHandBuff == nil then
              if BOM.DB.DontUseConsumables and not IsModifierKeyDown() then
                AddDisplay(string.format(BOM.TxtEscapeIcon, texture) .. itemLink .. "x" .. count .. " (" .. L.TTMainHand .. ")", playerMember.distance, true)
              else
                BagTitel = string.format(BOM.TxtEscapeIcon, texture) .. itemLink .. "x" .. count .. " (" .. L.TTMainHand .. ")"
                BagCommand = "/use " .. bag .. " " .. slot .. "\n/use 16" -- mainhand
                AddDisplay(BagTitel, playerMember.distance, true)
              end
            end
            BOM.ScanModifier = BOM.DB.DontUseConsumables
          else
            AddDisplay(spell.single .. "x" .. count, playerMember.distance, true)
          end
        end

      elseif spell.isBuff then
        if #spell.NeedMember > 0 then
          local ok, bag, slot, count = BOM.HasItem(spell.items, true)
          count = count or 0
          --print(ok, bag,slot)
          if ok then
            local texture, _, _, _, _, _, itemLink, _, _, _ = GetContainerItemInfo(bag, slot)
            if BOM.DB.DontUseConsumables and not IsModifierKeyDown() then
              AddDisplay(string.format(BOM.TxtEscapeIcon, texture) .. itemLink .. "x" .. count, playerMember.distance, true)
            else
              BagTitel = string.format(BOM.TxtEscapeIcon, texture) .. itemLink .. "x" .. count
              BagCommand = "/use " .. bag .. " " .. slot
              AddDisplay(BagTitel, playerMember.distance, true)
            end
            BOM.ScanModifier = BOM.DB.DontUseConsumables
          else
            AddDisplay(spell.single .. "x" .. count, playerMember.distance, true)
          end
        end

      elseif spell.isInfo then
        if #spell.NeedMember then
          for memberIndex, member in ipairs(spell.NeedMember) do
            AddDisplay(string.format(L["MsgBuffSingle"], member.link, spell.singleLink), member.distance, true)
          end
        end

      elseif spell.isTracking then
        if #spell.NeedMember > 0 then
          if not BOM.PlayerCasting then
            CastSpellByID(spell.singleId)
          else
            AddDisplay(string.format(L["MsgBuffSingle"], playerMember.name, spell.single), playerMember.name)
          end
        end

      elseif (spell.isOwn or spell.isTracking or spell.isAura or spell.isSeal) then
        if #spell.NeedMember > 0 then
          if (not spell.NeedOutdoors or IsOutdoors()) and not tContains(spell.SkipList, member.name) then
            AddDisplay(string.format(L["MsgBuffSingle"], playerMember.link, spell.singleLink), playerMember.name)
            inRange = true

            CatchSpell(spell.singleMana, spell.singleId, spell.singleLink, playerMember, spell)
          else
            AddDisplay(string.format(L["MsgBuffSingle"], playerMember.name, spell.single), playerMember.name)
          end
        end

      elseif spell.isResurrection then
        local clearskip = true
        for memberIndex, member in ipairs(spell.NeedMember) do
          if not tContains(spell.SkipList, member.name) then
            clearskip = false
            break
          end
        end
        if clearskip then
          wipe(spell.SkipList)
        end

        for memberIndex, member in ipairs(spell.NeedMember) do
          if not tContains(spell.SkipList, member.name) then
            BOM.RepeatUpdate = true
            local isInRange = (IsSpellInRange(spell.single, member.unitId) == 1) and not tContains(spell.SkipList, member.name)

            if isInRange then
              inRange = true
              AddDisplay(string.format(L["MsgBuffSingle"], member.link, spell.singleLink), member.name)
            else
              AddDisplay(string.format(L["MsgBuffSingle"], member.name, spell.single), member.name)
            end

            if isInRange or (BOM.DB.ResGhost and member.isGhost) then
              CatchSpell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)
            end
          end
        end

      elseif spell.isBlessing then
        --Group buff
        local ok, bag, slot, count
        if spell.NeededGroupItem then
          ok, bag, slot, count = BOM.HasItem(spell.NeededGroupItem, true)
        end
        if type(count) == "number" then
          count = " x" .. count .. " "
        else
          count = ""
        end
        if spell.groupMana ~= nil and not BOM.DB.NoGroupBuff then
          for i, groupIndex in ipairs(BOM.Tool.Classes) do
            if spell.NeedGroup[groupIndex] and spell.NeedGroup[groupIndex] >= BOM.DB.MinBlessing then
              BOM.RepeatUpdate = true
              local Group = GetClassInRange(spell.group, spell.NeedMember, groupIndex, spell)
              if Group == nil then
                Group = GetClassInRange(spell.group, party, groupIndex, spell)
              end

              if Group ~= nil and (not spell.DeathGroup[member.group] or not BOM.DB.DeathBlock) then
                AddDisplay(string.format(L["MsgBuffGroup"], "|c" .. RAID_CLASS_COLORS[groupIndex].colorStr .. BOM.Tool.ClassName[groupIndex] .. "|r", (spell.groupLink or spell.group)) .. count, "!" .. groupIndex)
                inRange = true

                CatchSpell(spell.groupMana, spell.groupId, spell.groupLink, Group, spell)

              else
                AddDisplay(string.format(L["MsgBuffGroup"], BOM.Tool.ClassName[groupIndex], spell.group .. count), "!" .. groupIndex)
              end

            end
          end
        end

        -- SINGLE BUFF
        for memberIndex, member in ipairs(spell.NeedMember) do

          if not member.isDead and spell.singleMana ~= nil and (BOM.DB.NoGroupBuff or spell.groupMana == nil or member.class == "pet" or spell.NeedGroup[member.class] == nil or spell.NeedGroup[member.class] < BOM.DB.MinBlessing) then

            if not member.isPlayer then
              BOM.RepeatUpdate = true
            end

            local add = ""
            if BOM.CurrentProfile.Spell[BOM.BLESSINGID][member.name] ~= nil then
              add = string.format(BOM.TxtEscapePicture, BOM.IconTargetOn)
            end

            local isInRange = (IsSpellInRange(spell.single, member.unitId) == 1) and not tContains(spell.SkipList, member.name)
            if isInRange then
              AddDisplay(string.format(L["MsgBuffSingle"], add .. member.link, spell.singleLink), member.name)
              inRange = true

              CatchSpell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)

            else
              AddDisplay(string.format(L["MsgBuffSingle"], add .. member.name, spell.single), member.name)
            end


          end
        end

      else
        local ok, bag, slot, count
        if spell.NeededGroupItem then
          ok, bag, slot, count = BOM.HasItem(spell.NeededGroupItem, true)
        end
        if type(count) == "number" then
          count = " x" .. count .. " "
        else
          count = ""
        end
        --Group buff
        if spell.groupMana ~= nil and not BOM.DB.NoGroupBuff then
          for groupIndex = 1, 8 do
            if spell.NeedGroup[groupIndex] and spell.NeedGroup[groupIndex] >= BOM.DB.MinBuff then
              BOM.RepeatUpdate = true
              local Group = GetGroupInRange(spell.group, spell.NeedMember, groupIndex, spell)
              if Group == nil then
                Group = GetGroupInRange(spell.group, party, groupIndex, spell)
              end

              if Group ~= nil and (not spell.DeathGroup[groupIndex] or not BOM.DB.DeathBlock) then
                AddDisplay(string.format(L["MsgBuffGroup"], groupIndex, (spell.groupLink or spell.group) .. count), "!" .. groupIndex)
                inRange = true

                CatchSpell(spell.groupMana, spell.groupId, spell.groupLink, Group, spell)

              else
                AddDisplay(string.format(L["MsgBuffGroup"], groupIndex, spell.group .. count), "!" .. groupIndex)
              end

            end
          end
        end
        -- SINGLE BUFF
        for memberIndex, member in ipairs(spell.NeedMember) do

          if not member.isDead and spell.singleMana ~= nil and (BOM.DB.NoGroupBuff or spell.groupMana == nil or member.group == 9 or spell.NeedGroup[member.group] == nil or spell.NeedGroup[member.group] < BOM.DB.MinBuff) then

            if not member.isPlayer then
              BOM.RepeatUpdate = true
            end

            local add = ""
            if BOM.CurrentProfile.Spell[spell.ConfigID].ForcedTarget[member.name] then
              add = string.format(BOM.TxtEscapePicture, BOM.IconTargetOn)
            end

            local isInRange = (IsSpellInRange(spell.single, member.unitId) == 1) and not tContains(spell.SkipList, member.name)
            if isInRange then
              AddDisplay(string.format(L["MsgBuffSingle"], add .. member.link, spell.singleLink), member.name)
              inRange = true

              CatchSpell(spell.singleMana, spell.singleId, spell.singleLink, member, spell)

            else
              AddDisplay(string.format(L["MsgBuffSingle"], add .. member.name, spell.single), member.name)
            end

          end
        end

      end
    end
  end

  --BuffOmat_ListTab_MessageFrame:AddMessage(" ")

  -- check argent dawn
  do
    local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
    if BOM.DB.ArgentumDawn then
      if playerMember.hasArgentumDawn ~= tContains(BOM.ArgentumDawn.dungeon, instanceID) then
        AddDisplay(BOM.ArgentumDawn.Link, playerMember.distance, true)
      end
    end
    if BOM.DB.Carrot then
      if playerMember.hasCarrot and not tContains(BOM.Carrot.dungeon, instanceID) then
        AddDisplay(BOM.Carrot.Link, playerMember.distance, true)
      end
    end
  end

  --enchantment on weapons
  local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()
  if BOM.DB.MainHand and not hasMainHandEnchant then
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))
    if link then
      AddDisplay(link, playerMember.distance, true)
    end
  end
  if BOM.DB.SecondaryHand and not hasOffHandEnchant then
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("SECONDARYHANDSLOT"))
    if link then
      AddDisplay(link, playerMember.distance, true)
    end
  end

  --itemcheck
  local ItemList = BOM.GetItemList()
  for i, item in ipairs(ItemList) do
    local ok = false
    local target = nil
    if item.CD then
      if (item.CD[1] or 0) ~= 0 then
        local ti = item.CD[1] + item.CD[2] - GetTime() + 1
        if ti < BOM.MinTimer then
          BOM.MinTimer = ti
        end
      elseif item.Link then
        ok = true
        if BOM.ItemListSpell[item.ID] then
          if BOM.ItemListTarget[BOM.ItemListSpell[item.ID]] then
            target = BOM.ItemListTarget[BOM.ItemListSpell[item.ID]]
          end
        end

      end
    elseif item.Lootable then
      ok = true
    end

    if ok then
      BagTitel = string.format(BOM.TxtEscapeIcon, item.Texture) .. item.Link .. (target and (" @" .. target) or "")
      BagCommand = (target and ("/target " .. target .. "/n") or "") .. "/use " .. item.Bag .. " " .. item.Slot
      AddDisplay(BagTitel, playerMember.distance, true)

      if BOM.DB.DontUseConsumables and not IsModifierKeyDown() then
        BagCommand = nil
        BagTitel = nil
      end
      BOM.ScanModifier = BOM.DB.DontUseConsumables

    end
  end

  if #display > 0 or #displayInfo > 0 then
    BOM.AutoOpen()
    --BuffOmat_ListTab_MessageFrame:AddMessage(string.format(L["MsgNextCast"],castMember.link or castMember.name,castLink or castSpell))

  else
    BOM.AutoClose()
  end

  OutputDisplay()

  BOM.ForceUpdate = false

  if BOM.PlayerCasting then
    BuffOmat_ListTab_Button:SetText(L.MsgBusy)
    BOM.UpdateMacro()
    BuffOmat_ListTab_Button:Disable()
    --BOM.RepeatUpdate=true

  elseif cast.Member and cast.SpellId then
    BuffOmat_ListTab_Button:SetText(string.format(L["MsgNextCast"], cast.Link, cast.Member.link))

    BOM.UpdateMacro(cast.Member, cast.SpellId)
    local cdtest = GetSpellCooldown(cast.SpellId) or 0
    if cdtest ~= 0 then
      BOM.CheckCoolDown = cast.SpellId
      BuffOmat_ListTab_Button:Disable()
    else
      BuffOmat_ListTab_Button:Enable()
    end

    BOM.ERRSpell = cast.Spell
    BOM.ERRMember = cast.Member

    --BOM.RepeatUpdate=true
  else
    if #display == 0 then
      BuffOmat_ListTab_Button:SetText(L.MsgEmpty)
      --BOM.RepeatUpdate=false
      for spellIndex, spell in ipairs(BOM.Spells) do
        if #spell.SkipList > 0 then
          wipe(spell.SkipList)
        end
      end

    else
      if SomeBodyDeath and BOM.DB.DeathBlock then
        BuffOmat_ListTab_Button:SetText(L.MsgSomebodyDead)
      else
        --BuffOmat_ListTab_Button:SetText(L.MsgNoSpell)
        if inRange then
          BuffOmat_ListTab_Button:SetText(ERR_OUT_OF_MANA)
        else
          BuffOmat_ListTab_Button:SetText(ERR_SPELL_OUT_OF_RANGE)
          local skipreset = false
          for spellIndex, spell in ipairs(BOM.Spells) do
            if #spell.SkipList > 0 then
              skipreset = true
              wipe(spell.SkipList)
            end
          end
          if skipreset then
            BOM.FastUpdateTimer()
            BOM.ForceUpdate = true
          end

        end

      end
      --BOM.RepeatUpdate=true
    end
    if BagTitel then
      BuffOmat_ListTab_Button:SetText(BagTitel)
    end
    BuffOmat_ListTab_Button:Enable()
    BOM.UpdateMacro(nil, nil, BagCommand)
  end

end

function BOM.ADDSKIP()
  if BOM.ERRSpell and BOM.ERRSpell.SkipList and BOM.ERRMember then
    tinsert(BOM.ERRSpell.SkipList, BOM.ERRMember.name)
    BOM.FastUpdateTimer()
    BOM.ForceUpdate = true
  end
end
function BOM.DownGrade()
  if BOM.ERRSpell and BOM.ERRSpell.SkipList and BOM.ERRMember then
    --print("downgrade",BOM.ERRSpellId)
    local level = UnitLevel(BOM.ERRMember.unitId)
    if level ~= nil and level > -1 then
      if BOM.DB.SpellGreatherEqualThan[BOM.ERRSpellId] == nil or BOM.DB.SpellGreatherEqualThan[BOM.ERRSpellId] < level then
        BOM.DB.SpellGreatherEqualThan[BOM.ERRSpellId] = level
        BOM.FastUpdateTimer()
        BOM.ForceUpdate = true
        print(BOM.MSGPREFIX, string.format(L.MsgDownGrade, BOM.ERRSpell.single, BOM.ERRMember.name))
      elseif BOM.DB.SpellGreatherEqualThan[BOM.ERRSpellId] >= level then
        BOM.ADDSKIP()
      end
    else
      BOM.ADDSKIP()
    end
  end
end

function BOM.ClearSkip()
  for spellIndex, spell in ipairs(BOM.Spells) do
    if spell.SkipList then
      wipe(spell.SkipList)
    end
  end
end

function BOM.BattleCancelBuffs()
  if BOM.Spells == nil or BOM.CurrentProfile == nil then
    return
  end
  for i, spell in ipairs(BOM.CancelBuffs) do
    if BOM.CurrentProfile.CancelBuff[spell.ConfigID].Enable and BOM.CancelBuff(spell.singleFamily) then
      print(BOM.MSGPREFIX, string.format(L.MsgCancelBuff, spell.singleLink or spell.single, UnitName(BOM.CancelBuffSource) or ""))
    end
  end
end

function BOM.SpellHasClasses(spell)
  return not (spell.isBuff or spell.isOwn or spell.isResurrection or spell.isSeal or spell.isTracking or spell.isAura or spell.isInfo)
end
-- 0 0 1