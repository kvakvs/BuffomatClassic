local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsShamanModule
local shamanModule = BuffomatModule.New("AllSpellsShaman") ---@type BomAllSpellsShamanModule

--local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule

---Add SHAMAN spells
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function shamanModule:SetupShamanSpells(spells, enchants)
  local duration = allBuffsModule.TbcOrClassic(allBuffsModule.DURATION_20M, allBuffsModule.DURATION_10M)
  local enchantmentDuration = allBuffsModule.TbcOrClassic(allBuffsModule.DURATION_30M, allBuffsModule.DURATION_5M) -- TBC: Shaman enchants become 30min

  buffDefModule:createAndRegisterBuff(spells, 16342, -- Flametongue Weapon
          { type         = "weapon", isOwn = true, isConsumable = false,
            default      = false, singleDuration = enchantmentDuration,
            singleFamily = { 8024, 8027, 8030, 16339, 16341, 16342, -- Flametongue Weapon 1-6
                             25489, -- TBC: Flametongue Weapon 7
                             58785, 58789, 58790 } } -- WotLK: Flametongue Weapon 8-10
  )             :Seal()
                :RequirePlayerClass("SHAMAN")
                :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[16342] = { 3, 4, 5, 523, 1665, 1666, -- Flametongue 1-6
                      2634, -- TBC: Flametongue 7
                      3779, 3780, 3781 } -- WotLK: Flametongue 8-10

  buffDefModule:createAndRegisterBuff(spells, 16356, -- Frostbrand Weapon
          { type         = "weapon", isOwn = true, isConsumable = false,
            default      = false, singleDuration = enchantmentDuration,
            singleFamily = { 8033, 8038, 10456, 16355, 16356, -- Frostbrand Weapon 1-5
                             25500, -- TBC: Frostbrand Weapon 6
                             58794, 58795, 58796 } } -- WotLK: Frostbrand Weapon 7-9
  )             :Seal()
                :RequirePlayerClass("SHAMAN")
                :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[16356] = { 2, 12, 524, 1667, 1668, -- Frostbrand
                      2635, -- TBC: Frostbrand 6
                      3782, 3783, 3784 } -- WotLK: Frostbrand 7-9

  buffDefModule:createAndRegisterBuff(spells, 16316, -- Rockbiter Weapon (Classic and TBC)
          { type         = "weapon", isOwn = true, isConsumable = false,
            default      = false, singleDuration = enchantmentDuration,
            singleFamily = { 8017, 8018, 8019, 10399, 16314, 16315, 16316, -- Ranks 1-7
                             25479, 25485 } } -- TBC: Ranks 8-9
  )             :Seal()
                :RequirePlayerClass("SHAMAN")
                :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)

  -- Note: in TBC all enchantIds for rockbiter have changed
  enchants[16316] = { 1, 6, 29, 503, 504, 683, 1663, 1664, -- Rockbiter, also 504 some special +80 Rockbiter?
                      3040, -- rockbiter 7
                      3023, 3026, 3028, 3031, 3034, 3037, 3040, -- TBC: Rockbiter 1-7
                      2632, 2633 } -- TBC: Rockbiter 8-9

  buffDefModule:createAndRegisterBuff(spells, 16362, -- Windfury Weapon
          { type         = "weapon", isOwn = true, isConsumable = false,
            default      = false, singleDuration = enchantmentDuration,
            singleFamily = { 8232, 8235, 10486, 16362, -- Windfury Weapon 1-4
                             25505, -- TBC: Windfury Weapon 5
                             58801, 58803, 58804 } } -- WotLK: Windfury Weapon 6-8
  )             :Seal()
                :RequirePlayerClass("SHAMAN")
                :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[16362] = { 283, 284, 525, 1669, -- Windfury 1-4
                      2636, -- TBC: Windfury 5
                      3785, 3786, 3787 } -- WotLK: Windfury 6-8

  buffDefModule:createAndRegisterBuff(spells, 51730, -- WotLK: Earthliving Weapon
          { type         = "weapon", isOwn = true, isConsumable = false,
            default      = false, singleDuration = enchantmentDuration,
            singleFamily = { 51730, 51988, 51991, 51992, 51993, 51994 } } -- WotLK: Earthliving Weapon 1-6
  )             :Seal()
                :RequirePlayerClass("SHAMAN")
                :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[51730] = { 3345, 3346, 3347, 3348, 3349, 3350 } -- WotLK: Earthliving 1-6

  buffDefModule:createAndRegisterBuff(spells, 10432, -- Lightning Shield / Blitzschlagschild
          { default      = false, isOwn = true, duration = duration,
            singleFamily = { 324, 325, 905, 945, 8134, 10431, 10432, -- Lightning Shield 1-7
                             25469, 25472, -- TBC: Lightning Shield 8-9
                             49280, 49281 } } -- WotLK: Lightning Shield 10-11
  )             :RequirePlayerClass("SHAMAN")
                :Category(allBuffsModule.CLASS)

  buffDefModule:createAndRegisterBuff(spells, 33736, -- TBC: Water Shield 1, 2
          { isOwn        = true, default = true, duration = duration,
            singleFamily = { 52127, 52129, 52131, 52134, 52136, 52138, -- WotLK: Water Shield 1-6
                             24398, 33736, -- TBC: Water Shield 1-2, or WotLK: Water Shield 7-8
                             57960 } -- WotLK: Water Shield 9
          })    :RequirePlayerClass("SHAMAN")
                :RequireTBC()
                :Category(allBuffsModule.CLASS)

  buffDefModule:createAndRegisterBuff(spells, 20777, -- Ancestral Spirit / Auferstehung
          { type         = "resurrection", default = true,
            singleFamily = { 2008, 20609, 20610, 20776, 20777, -- Ancestral Spirit 1-5
                             25590, -- TBC: Ancestral Spirit 6
                             49277 } -- WotLK: Ancestral Spirit 7
          })    :RequirePlayerClass("SHAMAN")
                :Category(allBuffsModule.CLASS)
end
