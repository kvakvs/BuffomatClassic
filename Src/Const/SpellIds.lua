--- Spell IDS given reasonable names
local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomSpellIdsModule
local spellIdsModule = BomModuleManager.spellIdsModule ---@type BomSpellIdsModule

spellIdsModule.ClassicFood = --[[---@type WowSpellId[] ]]  {
  6410, 433, 5004, 7737, -- Level 0-5 food
  25700, 25702, 25886, 25888, -- Level 10 food
  434, 2639, 5005, -- Level 15 food, better food and buff food
  435, 24869, -- Level 25 food and buff food
  1127, 5007, 18229, 18230, 18231, 18232, 18233, 26472, 26474, -- Level 35 food (including buff food)
  1129, 10256, 29008, -- Level 45 food, buff food, better food
  1131, 10257, 18234, 22731, 24005, 24704, 24800, 25695, 26260, 26401, 28616, 29073, -- Level 55 food
  25660, -- 55 Dirge's kickin' chimaerok chops
}
spellIdsModule.TBCFood = --[[---@type WowSpellId[] ]] {
  28616, 29073, 33253, 33260, 33266, 33269, 43777, 46898, -- Level 65 eating
  33255, 33258, 33262, 33264, 33725, 35270, 35271, 40745, 40768, 41030, 43763, 45618, 46812, -- Level 75 eating
}
spellIdsModule.WotLKFood = --[[---@type WowSpellId[] ]] {
  61829, -- Level 75 eating
  45548, -- Level 80 eating
}

spellIdsModule.Mage_ConjureManaSapphire = 42985
spellIdsModule.Mage_ConjureManaEmerald = 27101
spellIdsModule.Mage_ConjureManaRuby = 10054
spellIdsModule.Mage_ConjureManaCitrine = 10053
spellIdsModule.Mage_ConjureManaJade = 3552
spellIdsModule.Mage_ConjureManaAgate = 759

spellIdsModule.Warlock_DemonicSacrifice = 18788
spellIdsModule.Warlock_CreateSpellstone6 = 47888 -- WotLK
spellIdsModule.Warlock_CreateSpellstone5 = 47886 -- WotLK
spellIdsModule.Warlock_CreateSpellstone4 = 28172
spellIdsModule.Warlock_CreateSpellstone3 = 17728
spellIdsModule.Warlock_CreateSpellstone2 = 17727
spellIdsModule.Warlock_CreateSpellstone1 = 2362
spellIdsModule.Warlock_CreateFirestone1 = 6366
spellIdsModule.Warlock_CreateFirestone2 = 17951
spellIdsModule.Warlock_CreateFirestone3 = 17952
spellIdsModule.Warlock_CreateFirestone4 = 17953
spellIdsModule.Warlock_CreateFirestone5 = 27250
spellIdsModule.Warlock_CreateFirestone6 = 60219
spellIdsModule.Warlock_CreateFirestone7 = 60220

spellIdsModule.Priest_SpiritTap = 15271

spellIdsModule.Druid_TrackHumanoids = 5225

spellIdsModule.Paladin_CrusaderAura = 32223

spellIdsModule.FindHerbs = 2383
spellIdsModule.FindMinerals = 2580
spellIdsModule.FindTreasure = 2481
spellIdsModule.FindFish = 43308

spellIdsModule.Shaman_Flametongue6 = 16342
