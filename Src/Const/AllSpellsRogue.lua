local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsRogueModule
local rogueModule = {}
BomModuleManager.allSpellsRogueModule = rogueModule

local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffDefModule = BomModuleManager.buffDefinitionModule

---Add ROGUE spells
---@param allBuffs BomBuffDefinition[]
---@param enchants BomEnchantmentsMapping
function rogueModule:SetupRogueSpells(allBuffs, enchants)
  local duration = allBuffsModule.TbcOrClassic(allBuffsModule.DURATION_1H, allBuffsModule.DURATION_30M) -- TBC: Poisons become 1 hour

  --Deadly Poison
  -- item         = allBuffsModule.ExpansionChoice(20844, 22054, 43233),
  buffDefModule:createAndRegisterBuff(allBuffs, 25351, nil)
               :CreatesOrProvidedByItem({ 22054, 22053, -- TBC: Deadly Poison
                                          20844, 8985, 8984, 2893, 2892,
                                          43232, 43233 }) -- WotLK: Deadly Poison 8-9
               :IsConsumable(true)
               :BuffType("weapon")
               :SingleDuration(duration)
               :IsDefault(false)
               :MinLevel(2)
               :RequirePlayerClass("ROGUE")
               :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[25351] = { 2643, 2642, -- TBC: Deadly Poison
                      2630, 627, 626, 8, 7, --Deadly Poison
                      3770, 3771 } -- WotLK: Deadly Poison 8, 9

  --Mind-numbing Poison
  buffDefModule:createAndRegisterBuff(allBuffs, 11399, nil)
               :CreatesOrProvidedByItem({ 9186, 6951, 5237 })
               :IsConsumable(true)
               :BuffType("weapon")
               :SingleDuration(duration)
               :IsDefault(false)
               :MinLevel(24)
               :HideInWotLK()
               :RequirePlayerClass("ROGUE")
               :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[11399] = { 643, 23, 35 } -- Mind-numbing Poison (also WotLK: enchantment 35)

  --Instant Poison
  buffDefModule:createAndRegisterBuff(allBuffs, 11340, nil)
               :CreatesOrProvidedByItem({ 21927, -- TBC: Instant Poison
                                          8928, 8927, 8926, 6950, 6949, 6947, -- Instant Poison 2-7
                                          43230, 43231 }) -- WotLK: Instant Poison 8-9
               :IsConsumable(true)
               :BuffType("weapon")
               :SingleDuration(duration)
               :IsDefault(false)
               :MinLevel(20)
               :RequirePlayerClass("ROGUE")
               :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[11340] = { 2641, -- TBC: Instant Poison
                      625, 624, 623, 325, 324, 323, --Instant Poison
                      3768, 3769 } -- WotLK: Instant Poison 8, 9

  --Wound Poison
  buffDefModule:createAndRegisterBuff(allBuffs, 13227, nil)
               :CreatesOrProvidedByItem({ 22055, -- TBC: Wound Poison
                                          10922, 10921, 10920, 10918,
                                          43234, 43235 }) -- WotLK: Wound Poison 6, 7
               :IsConsumable(true)
               :BuffType("weapon")
               :SingleDuration(duration)
               :IsDefault(false)
               :MinLevel(32)
               :RequirePlayerClass("ROGUE")
               :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[13227] = { 2644, -- TBC: Wound Poison
                      706, 705, 704, 703, --Wound Poison
                      3772, 3773 } -- WotLK: Wound Poison 6, 7

  --Crippling Poison
  buffDefModule:createAndRegisterBuff(allBuffs, 11202, nil)
               :CreatesOrProvidedByItem({ 3776, 3775 })
               :IsConsumable(true)
               :BuffType("weapon")
               :SingleDuration(duration)
               :IsDefault(false)
               :MinLevel(20)
               :RequirePlayerClass("ROGUE")
               :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[11202] = { 603, 22 } --Crippling Poison

  --TBC: Anesthetic Poison
  buffDefModule:createAndRegisterBuff(allBuffs, 26785, nil)
               :CreatesOrProvidedByItem({ 21835, 43237 })
               :IsConsumable(true)
               :BuffType("weapon")
               :SingleDuration(duration)
               :IsDefault(false)
               :MinLevel(68)
               :RequirePlayerClass("ROGUE")
               :RequireTBC()
               :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[26785] = { 2640, --TBC: Anesthetic Poison
                      3774 } -- WotLK: Anesthetic 2
end
