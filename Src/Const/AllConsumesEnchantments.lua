local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllConsumesEnchantmentsModule
local enchantmentsModule = BuffomatModule.New("AllConsumesEnchantments") ---@type BomAllConsumesEnchantmentsModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule

---SCROLLS
---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function enchantmentsModule:SetupEnchantments(buffs, enchantments)
  self:_SetupPhysicalEnchantments(buffs, enchantments)
  self:_SetupCasterEnchantments(buffs, enchantments)
  self:_SetupOtherEnchantments(buffs, enchantments)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function enchantmentsModule:_SetupCasterEnchantments(buffs, enchantments)
  --if BOM.HaveTBC then
  --  buffDefModule:createAndRegisterBuff(buffs, 28017, --Superior Wizard Oil +42 SPELL
  --          { item = 22522, items = { 22522 }, isConsumable = true,
  --            type = "weapon", duration = allBuffsModule.DURATION_1H, default = false
  --          })   :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
  --               :Category(allBuffsModule.WEAPON_ENCHANTMENT)
  --end
  buffDefModule:createAndRegisterBuff(buffs, 25123, --Minor, Lesser, Brilliant Mana Oil
          { item     = 20748, isConsumable = true, type = "weapon",
            items    = { 20748, 20747, 20745, -- Minor, Lesser, Brilliant Mana Oil
                         22521, -- TBC: Superior Mana Oil
                         36899 }, -- WotLK: Exceptional Mana Oil
            duration = allBuffsModule.DURATION_30M, default = false
          })   :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.WEAPON_ENCHANTMENT)
  enchantments[25123] = { 2624, 2625, 2629, -- Minor, Lesser, Brilliant Mana Oil (enchantment)
                          2677, -- TBC: Superior Mana Oil (enchantment)
                          3298 } -- WotLK: Exceptional Mana Oil (enchantment)

  buffDefModule:createAndRegisterBuff(buffs, 25122, -- Wizard Oil
          { item     = 20749, isConsumable = true, type = "weapon",
            items    = { 20749, 20746, 20744, 20750, --Minor, Lesser, "regular", Brilliant Wizard Oil
                         22522, -- TBC: Superior Wizard Oil
                         36900 }, -- WotLK: Exceptional Wizard Oil
            duration = allBuffsModule.DURATION_30M, default = false
          })   :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :Category(allBuffsModule.WEAPON_ENCHANTMENT)
  enchantments[25122] = { 2623, 2626, 2627, 2628, --Minor, Lesser, "regular", Brilliant Wizard Oil (enchantment)
                          2678, -- TBC: Superior Wizard Oil (enchantment)
                          3299 } -- WotLK: Exceptional Wizard Oil (enchantment)

  buffDefModule:createAndRegisterBuff(buffs, 28898, --Blessed Wizard Oil
          { item     = 23123, isConsumable = true, type = "weapon",
            duration = allBuffsModule.DURATION_1H, default = false
          })   :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.WEAPON_ENCHANTMENT)
  enchantments[28898] = { 2685 } --Blessed Wizard Oil
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function enchantmentsModule:_SetupPhysicalEnchantments(buffs, enchantments)
  --
  -- Weightstones for blunt weapons
  --
  buffDefModule:createAndRegisterBuff(buffs, 16622, --Weightstone
          { item         = 12643, items = { 12643, 7965, 3241, 3240, 3239 },
            isConsumable = true, type = "weapon", duration = allBuffsModule.DURATION_30M,
            default      = false
          })   :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.WEAPON_ENCHANTMENT)
  enchantments[16622] = { 1703, 484, 21, 20, 19 } -- Weightstone

  buffDefModule:createAndRegisterBuff(buffs, 34340, --TBC: Adamantite Weightstone +12 BLUNT +14 CRIT
          { item     = 28421, items = { 28421 }, isConsumable = true, type = "weapon",
            duration = allBuffsModule.DURATION_1H, default = false,
          })   :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :RequireTBC()
               :Category(allBuffsModule.WEAPON_ENCHANTMENT)
  enchantments[34340] = { 2955 } --TBC: Adamantite Weightstone (Weight Weapon)

  buffDefModule:createAndRegisterBuff(buffs, 34339, --TBC: Fel Weightstone +12 BLUNT
          { item     = 28420, items = { 28420 }, isConsumable = true, type = "weapon",
            duration = allBuffsModule.DURATION_1H, default = false
          })   :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :RequireTBC()
               :Category(allBuffsModule.WEAPON_ENCHANTMENT)
  enchantments[34339] = { 2954 } --TBC: Fel Weightstone (Weighted +12)

  --
  -- Sharpening Stones for sharp weapons
  --
  buffDefModule:createAndRegisterBuff(buffs, 16138, --Sharpening Stone
          { item         = 12404, items = { 12404, 7964, 2871, 2863, 2862 },
            isConsumable = true, type = "weapon", duration = allBuffsModule.DURATION_30M, default = false,
          })   :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.WEAPON_ENCHANTMENT)
  enchantments[16138] = { 1643, 483, 14, 13, 40 } --Sharpening Stone

  buffDefModule:createAndRegisterBuff(buffs, 28891, --Consecrated Sharpening Stone
          { item     = 23122, isConsumable = true, type = "weapon",
            duration = allBuffsModule.DURATION_1H, default = false
          })   :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.WEAPON_ENCHANTMENT)
  enchantments[28891] = { 2684 } --Consecrated Sharpening Stone

  buffDefModule:createAndRegisterBuff(buffs, 22756, --Elemental Sharpening Stone
          { item     = 18262, isConsumable = true, type = "weapon",
            duration = allBuffsModule.DURATION_30M, default = false
          })   :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.WEAPON_ENCHANTMENT)
  enchantments[22756] = { 2506 } --Elemental Sharpening Stone

  buffDefModule:createAndRegisterBuff(buffs, 29453, --TBC: Adamantite Sharpening Stone +12 WEAPON +14 CRIT
          { item     = 23529, items = { 23529 }, isConsumable = true, type = "weapon",
            duration = allBuffsModule.DURATION_1H, default = false
          })   :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :RequireTBC()
               :Category(allBuffsModule.WEAPON_ENCHANTMENT)

  buffDefModule:createAndRegisterBuff(buffs, 29452, --TBC: Fel Sharpening Stone +12 WEAPON
          { item     = 23528, items = { 23528 }, isConsumable = true, type = "weapon",
            duration = allBuffsModule.DURATION_1H, default = false
          })   :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :RequireTBC()
               :Category(allBuffsModule.WEAPON_ENCHANTMENT)
  enchantments[29452] = { 2712 } --TBC: Fel Sharpening Stone (Sharpened +12)
  enchantments[29453] = { 2713 } --TBC: Adamantite Sharpening Stone (Sharpened +14 Crit, +12)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function enchantmentsModule:_SetupOtherEnchantments(buffs, enchantments)
  -- Rune of Warding
  --
  buffDefModule:createAndRegisterBuff(buffs, 32282, --TBC: Greater Rune of Warding
          { item           = 25521, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = allBuffsModule.DURATION_1H, targetClasses = allBuffsModule.BOM_ALL_CLASSES,
          })   :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
               :Category(allBuffsModule.WEAPON_ENCHANTMENT)
end
