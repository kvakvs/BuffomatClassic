local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllConsumesFoodModule
local foodModule = BuffomatModule.New("AllConsumesFood") ---@type BomAllConsumesFoodModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:SetupFood(buffs, enchantments)
  self:_SetupPhysicalFoodClassic(buffs, enchantments)
  self:_SetupPhysicalFoodTBC(buffs, enchantments)
  --self:_SetupPhysicalFoodWotLK(buffs, enchantments)

  self:_SetupCasterFoodClassic(buffs, enchantments)
  self:_SetupCasterFoodTBC(buffs, enchantments)
  --self:_SetupCasterFoodWotLK(buffs, enchantments)

  self:_SetupMiscFoodClassic(buffs, enchantments)
  self:_SetupMiscFoodTBC(buffs, enchantments)
  --self:_SetupMiscFoodWotLK(buffs, enchantments)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupMiscFoodTBC(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 33257, { 33052, 27667 }) --Well Fed +30 STA +20 SPI
               :RequireTBC()
               :ExtraText(_t("tooltip.food.stamina"))
               :Category(allBuffsModule.TBC_FOOD)
  buffDefModule:genericConsumable(buffs, 35254, { 27651, 30155, 27662, 33025 }) --Well Fed +20 STA +20 SPI
               :RequireTBC()
               :ExtraText(_t("tooltip.food.stamina"))
               :Category(allBuffsModule.TBC_FOOD)
  buffDefModule:genericConsumable(buffs, 41030, 32721) --Skyguard Rations: Well Fed +15 STA +15 SPI
               :RequireTBC()
               :ExtraText(_t("tooltip.food.stamina"))
               :ClassOnly(allBuffsModule.BOM_MANA_CLASSES)
               :Category(allBuffsModule.TBC_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupPhysicalFoodTBC(buffs, enchantments)
  -- Warp Burger, Grilled Mudfish, ...
  buffDefModule:genericConsumable(buffs, 33261, { 27659, 30358, 27664, 33288, 33293 }) --Well Fed +20 AGI +20 SPI
               :RequireTBC()
               :ClassOnly(allBuffsModule.BOM_PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.food.agility"))
               :Category(allBuffsModule.TBC_PHYS_FOOD)
  buffDefModule:genericConsumable(buffs, 43764, 33872) --Spicy Hot Talbuk: Well Fed +20 HITRATING +20 SPI
               :RequireTBC()
               :ClassOnly(allBuffsModule.BOM_PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.food.hit"))
               :Category(allBuffsModule.TBC_PHYS_FOOD)
  buffDefModule:genericConsumable(buffs, 33256, { 27658, 30359 }) -- Well Fed +20 STR +20 SPI
               :RequireTBC()
               :ClassOnly(allBuffsModule.BOM_MELEE_CLASSES)
               :ExtraText(_t("tooltip.food.strength"))
               :Category(allBuffsModule.TBC_PHYS_FOOD)
  buffDefModule:genericConsumable(buffs, 33259, 27655) --Ravager Dog: Well Fed +40 AP +20 SPI
               :RequireTBC()
               :ClassOnly(allBuffsModule.BOM_PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.food.attackPower"))
               :Category(allBuffsModule.TBC_PHYS_FOOD)
  buffDefModule:genericConsumable(buffs, 46899, 35563) -- Charred Bear Kabobs +24 AP
               :RequireTBC()
               :ClassOnly(allBuffsModule.BOM_PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.food.attackPower"))
               :Category(allBuffsModule.TBC_PHYS_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupCasterFoodTBC(buffs, enchantments)
  buffDefModule:tbcConsumable(buffs, 33263, { 27657, 31673, 27665, 30361 }) -- Well Fed +23 SPELL +20 SPI
               :RequireTBC()
               :ClassOnly(allBuffsModule.BOM_MANA_CLASSES)
               :ExtraText(_t("tooltip.food.spell"))
               :Category(allBuffsModule.TBC_SPELL_FOOD)
  buffDefModule:genericConsumable(buffs, 33265, 27663) -- Blackened Sporefish: Well Fed +8 MP5 +20 STA
               :RequireTBC()
               :ClassOnly(allBuffsModule.BOM_MANA_CLASSES)
               :ExtraText(_t("tooltip.food.mp5"))
               :Category(allBuffsModule.TBC_SPELL_FOOD)
  buffDefModule:genericConsumable(buffs, 33268, { 27666, 30357 }) -- Golden Fish Sticks: Well Fed +44 HEAL +20 SPI
               :RequireTBC()
               :ExtraText(_t("tooltip.food.healing"))
               :ClassOnly(allBuffsModule.BOM_MANA_CLASSES)
               :Category(allBuffsModule.TBC_SPELL_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupCasterFoodClassic(buffs, enchantments)
  buffDefModule:classicConsumable(buffs, 18194, 13931) -- Nightfin Soup +8Mana/5
               :ExtraText(_t("tooltip.food.mp5"))
               :ClassOnly(allBuffsModule.BOM_MANA_CLASSES)
               :Category(allBuffsModule.CLASSIC_SPELL_FOOD)
  buffDefModule:classicConsumable(buffs, 19710, 12218) -- Monster Omelette
               :ExtraText(_t("tooltip.food.spirit"))
               :ClassOnly(allBuffsModule.BOM_MANA_CLASSES)
               :Category(allBuffsModule.CLASSIC_SPELL_FOOD)
  buffDefModule:createAndRegisterBuff(buffs, 18141, --Blessed Sunfruit Juice +10 SPIRIT
          { item = 13813, isConsumable = true, default = false })
               :ExtraText(_t("tooltip.food.spirit"))
               :ClassOnly(allBuffsModule.BOM_MANA_CLASSES)
               :Category(allBuffsModule.CLASSIC_SPELL_FOOD)
  buffDefModule:classicConsumable(buffs, 22730, 18254) --Runn Tum Tuber Surprise
               :Category(allBuffsModule.CLASSIC_SPELL_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupMiscFoodClassic(buffs, enchantments)
  buffDefModule:classicConsumable(buffs, 25661, 21023) -- Dirge's Kickin' Chimaerok Chops x
               :Category(allBuffsModule.CLASSIC_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupPhysicalFoodClassic(buffs, enchantments)
  buffDefModule:createAndRegisterBuff(buffs, 18192, --Grilled Squid +10 Agility
          { item = 13928, isConsumable = true, default = false })
               :ClassOnly(allBuffsModule.BOM_PHYSICAL_CLASSES)
               :Category(allBuffsModule.CLASSIC_PHYS_FOOD)
  buffDefModule:createAndRegisterBuff(buffs, 24799, --Smoked Desert Dumplings +Strength
          { item = 20452, isConsumable = true, default = false })
               :ClassOnly(allBuffsModule.BOM_PHYSICAL_CLASSES)
               :Category(allBuffsModule.CLASSIC_PHYS_FOOD)
  buffDefModule:classicConsumable(buffs, 18125, 13810) --Blessed Sunfruit +STR
               :ClassOnly(allBuffsModule.BOM_MELEE_CLASSES)
               :Category(allBuffsModule.CLASSIC_PHYS_FOOD)
end
