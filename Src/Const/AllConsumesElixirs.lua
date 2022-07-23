local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllConsumesElixirsModule
local elixirsModule = BuffomatModule.New("AllConsumesElixirs") ---@type BomAllConsumesElixirsModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule

---ELIXIRS
---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function elixirsModule:SetupElixirs(buffs, enchantments)
  self:_SetupBattleCasterElixirsClassic(buffs, enchantments)
  self:_SetupBattlePhysicalElixirsClassic(buffs, enchantments)
  self:_SetupGuardianElixirsClassic(buffs, enchantments)

  self:_SetupBattleCasterElixirsTBC(buffs, enchantments)
  self:_SetupBattlePhysicalElixirsTBC(buffs, enchantments)
  self:_SetupGuardianElixirsTBC(buffs, enchantments)

  self:_SetupBattleElixirsWotLK(buffs, enchantments)
  self:_SetupBattleCasterElixirsWotLK(buffs, enchantments)
  self:_SetupBattlePhysicalElixirsWotLK(buffs, enchantments)
  self:_SetupGuardianElixirsWotLK(buffs, enchantments)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function elixirsModule:_SetupBattleCasterElixirsTBC(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 28509, 22840) --TBC: Elixir of Major Mageblood +16 mp5
               :RequireTBC()
               :Category(allBuffsModule.TBC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 28503, 22835) --TBC: Elixir of Major Shadow Power +55 SHADOW
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.BOM_SHADOW_CLASSES)
               :Category(allBuffsModule.TBC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 28501, 22833) --TBC: Elixir of Major Firepower +55 FIRE
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.FIRE_CLASSES)
               :Category(allBuffsModule.TBC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 28493, 22827) --TBC: Elixir of Major Frost Power +55 FROST
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.FROST_CLASSES)
               :Category(allBuffsModule.TBC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 28491, 22825) --TBC: Elixir of Healing Power +50 HEAL
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.TBC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 33721, 28103) --TBC: Adept's Elixir +24 SPELL, +24 SPELLCRIT
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :Category(allBuffsModule.TBC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function elixirsModule:_SetupBattleCasterElixirsClassic(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 17539, 13454) --Greater Arcane Elixir
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :Category(allBuffsModule.CLASSIC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 11390, 9155) -- Arcane Elixir
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :Category(allBuffsModule.CLASSIC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 11474, 9264) -- Elixir of Shadow Power
               :RequirePlayerClass(allBuffsModule.BOM_SHADOW_CLASSES)
               :Category(allBuffsModule.CLASSIC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 26276, 21546) --Elixir of Greater Firepower
               :RequirePlayerClass(allBuffsModule.FIRE_CLASSES)
               :Category(allBuffsModule.CLASSIC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 21920, 17708) --Elixir of Frost Power
               :RequirePlayerClass(allBuffsModule.FROST_CLASSES)
               :Category(allBuffsModule.CLASSIC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function elixirsModule:_SetupBattlePhysicalElixirsClassic(buffs, enchantments)
  buffDefModule:createAndRegisterBuff(buffs, 17538, --Elixir of the Mongoose
          { item = 13452, isConsumable = true, default = false })
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.CLASSIC_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:createAndRegisterBuff(buffs, 11334, --Elixir of Greater Agility
          { item = 9187, isConsumable = true, default = false })
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.CLASSIC_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:createAndRegisterBuff(buffs, 11405, --Elixir of Giants
          { item = 9206, isConsumable = true, default = false })
               :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
               :Category(allBuffsModule.CLASSIC_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function elixirsModule:_SetupBattlePhysicalElixirsTBC(buffs, enchantments)
  buffDefModule:createAndRegisterBuff(buffs, 28497, --TBC: Elixir of Major Agility +35 AGI +20 CRIT
          { item = 22831, isConsumable = true, default = false })
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.TBC_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:createAndRegisterBuff(buffs, 38954, --TBC: Fel Strength Elixir +90AP -10 STA
          { item = 31679, isConsumable = true, default = false })
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.TBC_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:createAndRegisterBuff(buffs, 28490, --TBC: Elixir of Major Strength +35 STR
          { item = 22824, isConsumable = true, default = false })
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
               :Category(allBuffsModule.TBC_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:createAndRegisterBuff(buffs, 33720, --TBC: Onslaught Elixir +60 AP
          { item = 28102, isConsumable = true, default = false })
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.TBC_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function elixirsModule:_SetupBattleCasterElixirsWotLK(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 33721, 40070) -- WotLK: Spellpower Elixir +58 SPELL
               :RequireWotLK()
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :Category(allBuffsModule.WOTLK_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function elixirsModule:_SetupBattlePhysicalElixirsWotLK(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 60344, 44329) -- WotLK: Elixir of Expertise +45
               :RequireWotLK()
               :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
               :Category(allBuffsModule.WOTLK_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 60341, 44327) -- WotLK: Elixir of Deadly Strikes +45 Crit
               :RequireWotLK()
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.WOTLK_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 53746, 40068) -- WotLK: Wrath Elixir +90 AP
               :RequireWotLK()
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.WOTLK_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 60345, 44330) -- WotLK: Elixir of Armor Piercing +45 ARP
               :RequireWotLK()
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.WOTLK_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 28497, 39666) -- WotLK: Elixir of Mighty Agility +45 AGI
               :RequireWotLK()
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.WOTLK_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 53748, 40073) -- WotLK: Elixir of Mighty Strength +50 STR
               :RequireWotLK()
               :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
               :Category(allBuffsModule.WOTLK_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function elixirsModule:_SetupGuardianElixirsTBC(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 39627, 32067) --TBC: Elixir of Draenic Wisdom +30 SPI
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.TBC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 28514, 22848) --TBC: Elixir of Empowerment, -30 TARGET RESIST
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :Category(allBuffsModule.TBC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 17535, 13447) --TBC: Elixir of the Sages +18 INT/+18 SPI
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.CLASSIC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 33726, 28104) --TBC: Elixir of Mastery +15 all stats
               :RequireTBC()
               :Category(allBuffsModule.TBC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 28502, 22834) --TBC: Elixir of Major Defense +550 ARMOR
               :RequireTBC()
               :Category(allBuffsModule.TBC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 39628, 32068) --TBC: Elixir of Ironskin +30 RESIL
               :RequireTBC()
               :Category(allBuffsModule.TBC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 39625, 32062) --TBC: Elixir of Major Fortitude +250 HP and 10 HP/5
               :RequireTBC()
               :Category(allBuffsModule.TBC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 39626, 32063) --TBC: Earthen Elixir -20 ALL DMG TAKEN
               :RequireTBC()
               :Category(allBuffsModule.TBC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function elixirsModule:_SetupGuardianElixirsClassic(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 24363, 20007) -- Mageblood Potion
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.CLASSIC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 11396, 9179) --Elixir of Greater Intellect +25
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.TBC_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:classicConsumable(buffs, 3593, 3825) --Elixir of Fortitude
               :Category(allBuffsModule.CLASSIC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:classicConsumable(buffs, 11348, 13445) --Elixir of Superior Defense
               :Category(allBuffsModule.CLASSIC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:classicConsumable(buffs, 24361, 20004) --Major Troll's Blood Potion
               :Category(allBuffsModule.CLASSIC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:classicConsumable(buffs, 11371, 9088) --Gift of Arthas
               :Category(allBuffsModule.CLASSIC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:classicConsumable(buffs, 17549, 13461) --Greater Arcane Protection Potion
               :HideInTBC() -- Becomes a 2-min potion buff
               :Category(allBuffsModule.CLASSIC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:classicConsumable(buffs, 17543, 13457) --Greater Fire Protection Potion
               :HideInTBC() -- Becomes a 2-min potion buff
               :Category(allBuffsModule.CLASSIC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:classicConsumable(buffs, 17544, 13456) --Greater Frost Protection Potion
               :HideInTBC() -- Becomes a 2-min potion buff
               :Category(allBuffsModule.CLASSIC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:classicConsumable(buffs, 17546, 13458) --Greater Nature Protection Potion
               :HideInTBC() -- Becomes a 2-min potion buff
               :Category(allBuffsModule.CLASSIC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:classicConsumable(buffs, 17548, 13459) --Greater Shadow Protection Potion
               :HideInTBC() -- Becomes a 2-min potion buff
               :Category(allBuffsModule.CLASSIC_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)

  if false then
    --
    -- 2min potion buff not real elixirs
    --
    buffDefModule:tbcConsumable(buffs, 28536, 22845) --Major Arcane Protection Potion (crafted and cauldron 32840)
                 :RequireTBC()
                 :Category(allBuffsModule.TBC_ELIXIR)
                 :ElixirType(allBuffsModule.ELIX_GUARDIAN)
    buffDefModule:tbcConsumable(buffs, 28511, 22841) --Major Fire Protection Potion (crafted and cauldron 32846)
                 :RequireTBC()
                 :Category(allBuffsModule.TBC_ELIXIR)
                 :ElixirType(allBuffsModule.ELIX_GUARDIAN)
    buffDefModule:tbcConsumable(buffs, 28512, 22842) --Major Frost Protection Potion (crafted and cauldron 32847)
                 :RequireTBC()
                 :Category(allBuffsModule.TBC_ELIXIR)
                 :ElixirType(allBuffsModule.ELIX_GUARDIAN)
    buffDefModule:tbcConsumable(buffs, 28513, 22844) --Major Nature Protection Potion (crafted and cauldron 32844)
                 :RequireTBC()
                 :Category(allBuffsModule.TBC_ELIXIR)
                 :ElixirType(allBuffsModule.ELIX_GUARDIAN)
    buffDefModule:tbcConsumable(buffs, 28537, 22846) --Major Shadow Protection Potion (crafted and cauldron 32845)
                 :RequireTBC()
                 :Category(allBuffsModule.TBC_ELIXIR)
                 :ElixirType(allBuffsModule.ELIX_GUARDIAN)
    buffDefModule:tbcConsumable(buffs, 28538, 22847) --Major Holy Protection Potion (crafted)
                 :RequireTBC()
                 :Category(allBuffsModule.TBC_ELIXIR)
                 :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  end
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function elixirsModule:_SetupGuardianElixirsWotLK(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 53747, 40072) --WotLK: Elixir of Spirit +50
               :RequireWotLK()
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.WOTLK_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 53764, 40109) --WotLK: Elixir of Mighty Mageblood +30 MP5
               :RequireWotLK()
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.WOTLK_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 53763, 40097) --WotLK: Elixir of Protection +800 Armor
               :RequireWotLK()
               :Category(allBuffsModule.WOTLK_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 53751, 40078) --WotLK: Elixir of Mighty Fortitude +350 HP and 20 HP/5
               :RequireWotLK()
               :Category(allBuffsModule.WOTLK_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 60343, 44328) --WotLK: Elixir of Mighty Defense +45 DEFR
               :RequireWotLK()
               :Category(allBuffsModule.WOTLK_PHYS_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 60347, 44332) --WotLK: Elixir of Mighty Thoughts +45 INT
               :RequireWotLK()
               :Category(allBuffsModule.WOTLK_SPELL_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function elixirsModule:_SetupBattleElixirsWotLK(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 53749, 40076) --WotLK: Guru's Elixir +20 All Stats
               :RequireWotLK()
               :Category(allBuffsModule.WOTLK_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_GUARDIAN)
  buffDefModule:genericConsumable(buffs, 60346, 44331) --WotLK: Elixir of Lightning Speed +45 Haste
               :RequireWotLK()
               :Category(allBuffsModule.WOTLK_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
  buffDefModule:genericConsumable(buffs, 60340, 44325) --WotLK: Elixir of Accuracy +45 HIT
               :RequireWotLK()
               :Category(allBuffsModule.WOTLK_ELIXIR)
               :ElixirType(allBuffsModule.ELIX_BATTLE)
end
