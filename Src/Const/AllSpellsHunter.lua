local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsHunterModule
local hunterModule = {}
BomModuleManager.allSpellsHunterModule = hunterModule

local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffDefModule = BomModuleManager.buffDefinitionModule

---Add HUNTER spells
---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function hunterModule:SetupHunterSpells(allBuffs, enchantments)
  self:_SetupHunterSpellsTBC(allBuffs, enchantments)
  self:_SetupPetBuffs(allBuffs, enchantments)
end

---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function hunterModule:_SetupHunterSpellsTBC(allBuffs, enchantments)
  -- Trueshot Aura
  buffDefModule:createAndRegisterBuff(allBuffs, 20906, nil)
               :IsOwn(true)
               :IsDefault(true)
               :SingleFamily({ 19506, 20905, 20906, -- Trueshot Aura 1-3, WotLK: Trueshot Aura
                               27066 })  -- TBC: Trueshot Aura 4
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.AURA)

  -- Aspect of the Hawk
  buffDefModule:createAndRegisterBuff(allBuffs, 25296, nil)
               :BuffType("aura")
               :IsDefault(true)
               :SingleFamily({ 13165, 14318, 14319, 14320, 14321, 14322, 25296, -- Aspect of the Hawk 1-7
                               27044, -- TBC: Aspect of the Hawk 8
                               61846, 61847 }) -- WotLK: Aspect of the Dragonhawk 1-2
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.CLASS)

  --Aspect of the monkey
  buffDefModule:createAndRegisterBuff(allBuffs, 13163, nil)
               :BuffType("aura")
               :IsDefault(false)
               :MaxLevel(74) -- Superceded by Aspect of the Dragonhawk
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.CLASS)

  -- TBC: Aspect of the Viper
  buffDefModule:createAndRegisterBuff(allBuffs, 34074, nil)
               :BuffType("aura")
               :IsDefault(false)
               :RequirePlayerClass("HUNTER")
               :RequireTBC()
               :Category(allBuffsModule.CLASS)

  -- Aspect of the Wild
  buffDefModule:createAndRegisterBuff(allBuffs, 20190, nil)
               :BuffType("aura")
               :IsDefault(false)
               :SingleFamily({ 20043, 20190, -- Aspect of the Wild 1-2
                               27045, -- TBC: Aspect of the Wild 3
                               49071 }) -- WotLK: Aspect of the Wild 4
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.AURA)
  --Aspect of the Cheetah
  buffDefModule:createAndRegisterBuff(allBuffs, 5118, nil)
               :BuffType("aura")
               :IsDefault(false)
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.CLASS)
  --Aspect of the Pack
  buffDefModule:createAndRegisterBuff(allBuffs, 13159, nil)
               :BuffType("aura")
               :IsDefault(false)
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.AURA)
  -- Aspect of the Beast
  buffDefModule:createAndRegisterBuff(allBuffs, 13161, nil)
               :BuffType("aura")
               :IsDefault(false)
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.CLASS)

  -- Track Beast
  buffDefModule:createAndRegisterBuff(allBuffs, 1494, nil)
               :BuffType("aura")
               :IsDefault(false)
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)

  -- Track Demon
  buffDefModule:createAndRegisterBuff(allBuffs, 19878, nil)
               :BuffType("aura")
               :IsDefault(false)
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)

  -- Track Dragonkin
  buffDefModule:createAndRegisterBuff(allBuffs, 19879, nil)
               :BuffType("aura")
               :IsDefault(false)
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)

  -- Track Elemental
  buffDefModule:createAndRegisterBuff(allBuffs, 19880, nil)
               :BuffType("aura")
               :IsDefault(false)
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)

  -- Track Humanoids
  buffDefModule:createAndRegisterBuff(allBuffs, 19883, nil)
               :BuffType("aura")
               :IsDefault(false)
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)

  -- Track Giants / riesen
  buffDefModule:createAndRegisterBuff(allBuffs, 19882, nil)
               :BuffType("aura")
               :IsDefault(false)
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)

  -- Track Undead
  buffDefModule:createAndRegisterBuff(allBuffs, 19884, nil)
               :BuffType("aura")
               :IsDefault(false)
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)

  -- Track Hidden / verborgenes
  buffDefModule:createAndRegisterBuff(allBuffs, 19885, nil)
               :BuffType("aura")
               :IsDefault(false)
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)
end

---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function hunterModule:_SetupPetBuffs(allBuffs, enchantments)
  -- TODO: Do not use tbc_consumable function, add new flags for pet-buff
  buffDefModule:genericConsumable(allBuffs, 65247, 33874)
               :RequireTBC()
               :HunterPetFood()
               :Category(allBuffsModule.PET)
  buffDefModule:genericConsumable(allBuffs, 33272, 27656)
               :RequireTBC()
               :HunterPetFood()
               :ExtraText(_t("tooltip.buff.petStrength"))
               :Category(allBuffsModule.PET)
  buffDefModule:genericConsumable(allBuffs, 43771, 43005)
               :RequireWotLK()
               :HunterPetFood()
               :ExtraText(_t("tooltip.buff.petStrength"))
               :Category(allBuffsModule.PET)
  --buffDefModule:genericConsumable(buffs, 43771, 43005) -- WotLK: Spiced Mammoth Treats +30 Str/30 Stam for pet
  --             :RequireWotLK()
  --             :HunterPetFood()
  --             :ExtraText(_t("tooltip.buff.petStrength"))
  --             :RequirePlayerClass("HUNTER")
  --             :Category(allBuffsModule.PET)
end
