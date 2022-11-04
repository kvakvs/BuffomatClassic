local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsWarlockModule
local warlockModule = {}
BomModuleManager.allSpellsWarlockModule = warlockModule

local allBuffsModule = BomModuleManager.allBuffsModule
local buffDefModule = BomModuleManager.buffDefinitionModule
local spellIdsModule = BomModuleManager.spellIdsModule

---Add WARLOCK spells
---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function warlockModule:SetupWarlockSpells(allBuffs, enchantments)
  -- Unending Breath
  buffDefModule:createAndRegisterBuff(allBuffs, 5697, nil)
               :IsDefault(false)
               :SingleDuration(allBuffsModule.DURATION_10M)
               :RequirePlayerClass("WARLOCK")
               :DefaultTargetClasses(allBuffsModule.BOM_ALL_CLASSES)
               :Category(allBuffsModule.CLASS)

  -- Detect Greater Invisibility | Große Unsichtbarkeit entdecken
  buffDefModule:createAndRegisterBuff(allBuffs, 132, nil)
               :IsDefault(false)
               :SingleFamily({ 132, -- Detect Invisibility
                               2970, 11743 }) -- Some other stuff
               :SingleDuration(allBuffsModule.DURATION_10M)
               :RequirePlayerClass("WARLOCK")
               :DefaultTargetClasses(allBuffsModule.BOM_ALL_CLASSES)
               :Category(allBuffsModule.CLASS)

  -- Shadow Ward / Schattenzauberschutz
  buffDefModule:createAndRegisterBuff(allBuffs, 28610, nil)
               :IsOwn(true)
               :IsDefault(false)
               :SingleFamily({ 6229, 11739, 11740, 28610, -- Shadow Ward 1-4
                               47890, 47891 }) -- WotLK: Shadow Ward 5-6
               :RequirePlayerClass("WARLOCK")
               :Category(allBuffsModule.CLASS)

  -- TBC: Fel Armor
  buffDefModule:createAndRegisterBuff(allBuffs, 28176, nil)
               :IsOwn(true)
               :IsDefault(false)
               :SingleFamily({ 28176, 28189, -- TBC: Fel Armor 1-2
                               47892, 47893 }) -- WotLK: Fel Armor 3-4
               :RequirePlayerClass("WARLOCK")
               :RequireTBC()
               :Category(allBuffsModule.CLASS)

  -- Demon Skin / Demon Armor
  buffDefModule:createAndRegisterBuff(allBuffs, 11735, nil)
               :IsOwn(true)
               :IsDefault(false)
               :SingleFamily({ 687, 696, -- Demon Skin 1-2
                               706, 1086, 11733, 11734, 11735, -- Demon Armor 5
                               27260, -- TBC: Demon Armor 6
                               47793, 47889 }) -- WotLK: Demon Armor 7-8
               :RequirePlayerClass("WARLOCK")
               :Category(allBuffsModule.CLASS)

  if BOM.HaveWotLK then
    -- Create Firesone
    buffDefModule:createAndRegisterBuff(allBuffs, spellIdsModule.Warlock_CreateFirestone7, nil)
                 :IsOwn(true)
                 :IsDefault(true)
                 :LockIfHaveItem({ itemIdsModule.Warlock_Firestone1,
                                   itemIdsModule.Warlock_Firestone2,
                                   itemIdsModule.Warlock_Firestone3,
                                   itemIdsModule.Warlock_Firestone4,
                                   itemIdsModule.Warlock_Firestone5,
                                   itemIdsModule.Warlock_Firestone6,
                                   itemIdsModule.Warlock_Firestone7 })
                 :SingleFamily({ spellIdsModule.Warlock_CreateFirestone1,
                                 spellIdsModule.Warlock_CreateFirestone2,
                                 spellIdsModule.Warlock_CreateFirestone3,
                                 spellIdsModule.Warlock_CreateFirestone4,
                                 spellIdsModule.Warlock_CreateFirestone5,
                                 spellIdsModule.Warlock_CreateFirestone6,
                                 spellIdsModule.Warlock_CreateFirestone7 })
                 :RequirePlayerClass("WARLOCK")
                 :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
    -- Firestone
    buffDefModule:createAndRegisterBuff(allBuffs, 60220, nil)
                 :BuffCreatesItem({ itemIdsModule.Warlock_Firestone1,
                                    itemIdsModule.Warlock_Firestone2,
                                    itemIdsModule.Warlock_Firestone3,
                                    itemIdsModule.Warlock_Firestone4,
                                    itemIdsModule.Warlock_Firestone5,
                                    itemIdsModule.Warlock_Firestone6,
                                    itemIdsModule.Warlock_Firestone7 })
                 :IsConsumable(true)
                 :BuffType("weapon")
                 :IsDefault(false)
                 :SingleDuration(allBuffsModule.DURATION_1H)
                 :RequirePlayerClass("WARLOCK")
                 :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
    enchantments[60220] = { 3609, 3610, 3611, 3612, 3597, 3613, 3614 } -- WotLK: Firestone 1-7
  else
    -- in WotLK firestone becomes a 5-charges conjured weapon enchantment item
    buffDefModule:createAndRegisterBuff(allBuffs, 17953, -- Firestone
            { isOwn          = true, default = false,
              lockIfHaveItem = { 1254, 13699, 13700, 13701,
                                 22128 }, -- TBC: Master Firestone
              singleFamily   = { 6366, 17951, 17952, 17953, -- Rank 1-4
                                 27250 } } -- TBC: Rank 5
    )            :RequirePlayerClass("WARLOCK")
                 :Category(allBuffsModule.CLASS)
  end

  if BOM.HaveWotLK then
    buffDefModule:createAndRegisterBuff(allBuffs, spellIdsModule.Warlock_CreateSpellstone6, -- Conjure Mana Stone (Max Rank)
            { isOwn          = true, default = true,
              lockIfHaveItem = { itemIdsModule.Warlock_Spellstone1,
                                 itemIdsModule.Warlock_Spellstone2,
                                 itemIdsModule.Warlock_Spellstone3,
                                 itemIdsModule.Warlock_Spellstone4,
                                 itemIdsModule.Warlock_Spellstone5,
                                 itemIdsModule.Warlock_Spellstone6 },
              singleFamily   = { spellIdsModule.Warlock_CreateSpellstone1,
                                 spellIdsModule.Warlock_CreateSpellstone2,
                                 spellIdsModule.Warlock_CreateSpellstone3,
                                 spellIdsModule.Warlock_CreateSpellstone4,
                                 spellIdsModule.Warlock_CreateSpellstone5,
                                 spellIdsModule.Warlock_CreateSpellstone6 }
            })   :RequirePlayerClass("WARLOCK")
                 :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
    buffDefModule:createAndRegisterBuff(allBuffs, 55194, -- Spellstone
            { item    = itemIdsModule.Warlock_Spellstone6, isConsumable = true, type = "weapon",
              items   = { itemIdsModule.Warlock_Spellstone1,
                          itemIdsModule.Warlock_Spellstone2,
                          itemIdsModule.Warlock_Spellstone3,
                          itemIdsModule.Warlock_Spellstone4,
                          itemIdsModule.Warlock_Spellstone5,
                          itemIdsModule.Warlock_Spellstone6 },
              default = false, singleDuration = allBuffsModule.DURATION_1H,
            })   :RequirePlayerClass("WARLOCK")
                 :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
    enchantments[55194] = {
      3615, 3616, 3617, 3618, 3619, 3620
    } -- WotLK: Spellstone 1-6 enchantIds
  else
    -- in WotLK spellstone becomes a 5-charges conjured weapon enchantment item
    buffDefModule:createAndRegisterBuff(allBuffs, 17728, -- Spellstone
            { isOwn          = true, default = false,
              lockIfHaveItem = { 5522, 13602, 13603, -- "normal", Greater, Major Spellstone
                                 22646 }, -- TBC: Master Spellstone
              singleFamily   = { 2362, 17727, 17728, -- Rank 1-3
                                 28172 }  -- TBC: Rank 4
            })   :RequirePlayerClass("WARLOCK")
                 :Category(allBuffsModule.CLASS)
  end

  buffDefModule:createAndRegisterBuff(allBuffs, 11730, -- Healthstone
          { isOwn          = true, default = true,
            lockIfHaveItem = { 5512, 19005, 19004,
                               5511, 19007, 19006,
                               5509, 19009, 19008,
                               5510, 19011, 19010,
                               9421, 19013, 19012, -- Healthstones (3 talent ranks)
                               22103, 22104, 22105, -- TBC: Master Healthstone (3 talent ranks)
                               36889, 36890, 36891, -- WotLK: Demonic Healthstone (3 talent ranks)
                               36892, 36893, 36894 }, -- WotLK: Fel Healthstone (3 talent ranks)
            singleFamily   = { 6201, 6202, 5699, 11729, 11730, -- Healthstone 1-5
                               27230, -- TBC: Healthstone 6
                               47871, 47878 }  -- WotLK: Demonic and Fel Healthstone (rank 7-8)
          })   :RequirePlayerClass("WARLOCK")
               :Category(allBuffsModule.CLASS)

  buffDefModule:createAndRegisterBuff(allBuffs, 20757, --Soulstone
          { isOwn          = true, default = true,
            lockIfHaveItem = { 5232, 16892, 16893, 16895, 16896,
                               22116, -- TBC: Master Soulstone
                               36895 }, -- WotLK: Demonic Soulstone
            singleFamily   = { 693, 20752, 20755, 20756, 20757, -- Ranks 1-5
                               27238, -- TBC: Rank 6
                               47884 } -- WotLK: Rank 7
          })   :RequirePlayerClass("WARLOCK")
               :Category(allBuffsModule.CLASS)

  buffDefModule:createAndRegisterBuff(allBuffs, 5500, --Sense Demons
          { type = "tracking", default = false
          })   :RequirePlayerClass("WARLOCK")
               :Category(self.TRACKING) ------------------------ -- Pet Management ------------------------ buffDefModule:createAndRegisterBuff(allBuffs, spellIdsModule.Warlock_DemonicSacrifice, -- Demonic Sacrifice { isOwn = true, default = true, requiresWarlockPet = true }
  )                                     :RequirePlayerClass("WARLOCK")
  :HideInWotLK()
  :Category(allBuffsModule.PET)
  buffDefModule:createAndRegisterBuff(allBuffs, 19028, -- TBC: Soul Link, talent spell 19028, gives buff 25228
  { isOwn = true, default = true, singleFamily = { 19028, 25228 },
  requiresWarlockPet = true
  }):RequirePlayerClass("WARLOCK")
  :Category(allBuffsModule.PET)

  buffDefModule:createAndRegisterBuff(allBuffs, 688, --Summon Imp
  { type = "summon", default = true, isOwn = true,
  creatureFamily = "Imp", creatureType = "Demon", sacrificeAuraIds = { 18789 }
  }):RequirePlayerClass("WARLOCK")
  :Category(allBuffsModule.PET)

  buffDefModule:createAndRegisterBuff(allBuffs, 697, --Summon Voidwalker
  { type = "summon", default = false, isOwn = true,
  reagentRequired = { itemIdsModule.Warlock_SoulShard },
  creatureFamily = "Voidwalker", creatureType = "Demon",
  sacrificeAuraIds = { 18790, 1905 }  -- TBC: Restore 2% hp, and Classic: Shield the warlock
  }):RequirePlayerClass("WARLOCK")
  :Category(allBuffsModule.PET)

  buffDefModule:createAndRegisterBuff(allBuffs, 712, --Summon Succubus
  { type = "summon", default = false, isOwn = true,
  reagentRequired = { itemIdsModule.Warlock_SoulShard },
  creatureFamily = "Succubus", creatureType = "Demon", sacrificeAuraIds = { 18791 }
  }):RequirePlayerClass("WARLOCK")
  :Category(allBuffsModule.PET)

  buffDefModule:createAndRegisterBuff(allBuffs, 713, --Summon Incubus (TBC)
  { type = "summon", default = false, isOwn = true,
  reagentRequired = { itemIdsModule.Warlock_SoulShard },
  creatureFamily = "Incubus", creatureType = "Demon", sacrificeAuraIds = { 18791 }
  }):RequirePlayerClass("WARLOCK")
  :Category(allBuffsModule.PET)

  buffDefModule:createAndRegisterBuff(allBuffs, 691, --Summon Felhunter
  { type = "summon", default = false, isOwn = true,
  reagentRequired = { itemIdsModule.Warlock_SoulShard },
  creatureFamily = "Felhunter", creatureType = "Demon", sacrificeAuraIds = { 18792 }
  }):RequirePlayerClass("WARLOCK")
  :Category(allBuffsModule.PET)

  buffDefModule:createAndRegisterBuff(allBuffs, 30146, --Summon Felguard
  { type = "summon", default = false, isOwn = true,
  reagentRequired = { itemIdsModule.Warlock_SoulShard },
  creatureFamily = "Felguard", creatureType = "Demon", sacrificeAuraIds = { 35701 }
  }):RequirePlayerClass("WARLOCK")
  :Category(allBuffsModule.PET)
end
