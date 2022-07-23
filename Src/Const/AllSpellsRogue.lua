local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsRogueModule
local rogueModule = BuffomatModule.New("AllSpellsRogue") ---@type BomAllSpellsRogueModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule

---Add ROGUE spells
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function rogueModule:SetupRogueSpells(spells, enchants)
  local duration = allBuffsModule.TbcOrClassic(allBuffsModule.DURATION_1H, allBuffsModule.DURATION_30M) -- TBC: Poisons become 1 hour

  buffDefModule:createAndRegisterBuff(spells, 25351, --Deadly Poison
          { item         = allBuffsModule.ExpansionChoice(20844, 22054, 43233),
            items        = { 22054, 22053, -- TBC: Deadly Poison
                             20844, 8985, 8984, 2893, 2892,
                             43232, 43233 }, -- WotLK: Deadly Poison 8-9
            isConsumable = true, type = "weapon", duration = duration, default = false },
          { minLevel = 2 }
  )             :ClassOnly("ROGUE")
                :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[25351] = { 2643, 2642, -- TBC: Deadly Poison
                      2630, 627, 626, 8, 7 } --Deadly Poison

  buffDefModule:createAndRegisterBuff(spells, 11399, --Mind-numbing Poison
          { item     = 9186, items = { 9186, 6951, 5237 }, isConsumable = true, type = "weapon",
            duration = duration, default = false },
          { minLevel = 24 }
  )             :HideInWotLK()
                :ClassOnly("ROGUE")
                :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[11399] = { 643, 23, 35 } --Mind-numbing Poison

  buffDefModule:createAndRegisterBuff(spells, 11340, --Instant Poison
          { item         = allBuffsModule.TbcOrClassic(21927, 8928),
            items        = { 21927, -- TBC: Instant Poison
                             8928, 8927, 8926, 6950, 6949, 6947, -- Instant Poison 2-7
                             43230, 43231 }, -- WotLK: Instant Poison 8-9
            isConsumable = true, type = "weapon", duration = duration, default = false },
          { minLevel = 20 }
  )             :ClassOnly("ROGUE")
                :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[11340] = { 2641, -- TBC: Instant Poison
                      625, 624, 623, 325, 324, 323 } --Instant Poison

  buffDefModule:createAndRegisterBuff(spells, 13227, --Wound Poison
          { item         = allBuffsModule.TbcOrClassic(22055, 10922),
            items        = { 22055, -- TBC: Wound Poison
                             10922, 10921, 10920, 10918 },
            isConsumable = true, type = "weapon", duration = duration, default = false },
          { minLevel = 32 }
  )             :ClassOnly("ROGUE")
                :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[13227] = { 2644, -- TBC: Wound Poison
                      706, 705, 704, 703 } --Wound Poison

  buffDefModule:createAndRegisterBuff(spells, 11202, --Crippling Poison
          { item     = 3776, items = { 3776, 3775 }, isConsumable = true, type = "weapon",
            duration = duration, default = false },
          { minLevel = 20 }
  )             :HideInWotLK()
                :ClassOnly("ROGUE")
                :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[11202] = { 603, 22 } --Crippling Poison

  buffDefModule:createAndRegisterBuff(spells, 26785, --TBC: Anesthetic Poison
          { item         = 21835, items = { 21835 },
            isConsumable = true, type = "weapon", duration = duration, default = false },
          { minLevel = 68 }
  )             :ClassOnly("ROGUE")
                :RequireTBC()
                :Category(allBuffsModule.CLASS_WEAPON_ENCHANTMENT)
  enchants[26785] = { 2640, } --TBC: Anesthetic Poison
end
