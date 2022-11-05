local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllConsumesFoodModule
local foodModule = {}
BomModuleManager.allConsumesFoodModule = foodModule

local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffDefModule = BomModuleManager.buffDefinitionModule
local spellIdsModule = BomModuleManager.spellIdsModule

---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function foodModule:SetupFood(allBuffs, enchantments)
  self:_SetupCasterFoodClassic(allBuffs, enchantments)
  self:_SetupPhysicalFoodClassic(allBuffs, enchantments)
  self:_SetupMiscFoodClassic(allBuffs, enchantments)

  self:_SetupCasterFoodTBC(allBuffs, enchantments)
  self:_SetupPhysicalFoodTBC(allBuffs, enchantments)
  self:_SetupMiscFoodTBC(allBuffs, enchantments)

  self:_SetupCasterFoodWotLK(allBuffs, enchantments)
  self:_SetupPhysicalFoodWotLK(allBuffs, enchantments)
  self:_SetupMiscFoodWotLK(allBuffs, enchantments)
end

---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function foodModule:_SetupMiscFoodTBC(allBuffs, enchantments)
  --Well Fed +30 STA +20 SPI
  buffDefModule:tbcConsumable(allBuffs, 33257, { 33052, 27667 })
               :ExtraText(_t("tooltip.buff.stamina"))
               :Category("tbcFood")

  --Well Fed +20 STA +20 SPI
  buffDefModule:tbcConsumable(allBuffs, 35254, { 27651, 30155, 27662, 33025 })
               :ExtraText(_t("tooltip.buff.stamina"))
               :Category("tbcFood")

  --Skyguard Rations: Well Fed +15 STA +15 SPI
  buffDefModule:tbcConsumable(allBuffs, 41030, 32721)
               :ExtraText(_t("tooltip.buff.stamina"))
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category("tbcFood")
end

---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function foodModule:_SetupPhysicalFoodTBC(allBuffs, enchantments)
  -- Warp Burger, Grilled Mudfish, ...
  --Well Fed +20 AGI +20 SPI
  buffDefModule:tbcConsumable(allBuffs, 33261, { 27659, 30358, 27664, 33288, 33293 })
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.buff.agility"))
               :Category("tbcPhysFood")

  --Spicy Hot Talbuk: Well Fed +20 HITRATING +20 SPI
  buffDefModule:tbcConsumable(allBuffs, 43764, 33872)
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.buff.hit"))
               :Category("tbcPhysFood")

  -- Well Fed +20 STR +20 SPI
  buffDefModule:tbcConsumable(allBuffs, 33256, { 27658, 30359 })
               :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
               :ExtraText(_t("tooltip.buff.strength"))
               :Category("tbcPhysFood")

  --Ravager Dog: Well Fed +40 AP +20 SPI
  buffDefModule:tbcConsumable(allBuffs, 33259, 27655)
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.buff.attackPower"))
               :Category("tbcPhysFood")

  -- Charred Bear Kabobs +24 AP
  buffDefModule:tbcConsumable(allBuffs, 46899, 35563)
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.buff.attackPower"))
               :Category("tbcPhysFood")
end

---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function foodModule:_SetupCasterFoodTBC(allBuffs, enchantments)
  -- Well Fed +23 SPELL +20 SPI
  buffDefModule:tbcConsumable(allBuffs, 33263, { 27657, 31673, 27665, 30361 })
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(33264)
               :ExtraText(_t("tooltip.buff.spellPower"))
               :Category("tbcSpellFood")

  -- Blackened Sporefish: Well Fed +8 MP5 +20 STA
  buffDefModule:tbcConsumable(allBuffs, 33265, 27663)
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :ExtraText(_t("tooltip.buff.mp5"))
               :Category("tbcSpellFood")

  -- Golden Fish Sticks: Well Fed +44 HEAL +20 SPI
  buffDefModule:tbcConsumable(allBuffs, 33268, { 27666, 30357 })
               :ExtraText(_t("tooltip.buff.healing"))
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category("tbcSpellFood")

  -- Skullfish Soup +20 Spell Crit/20 Spirit
  buffDefModule:tbcConsumable(allBuffs, 43722, 33825)
               :IgnoreIfHaveBuff(43706) -- Drinking 240 mana/second
               :ExtraText(_t("tooltip.buff.spellCrit"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :Category("tbcSpellFood")
end

---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function foodModule:_SetupCasterFoodClassic(allBuffs, enchantments)
  -- Nightfin Soup +8Mana/5
  buffDefModule:genericConsumable(allBuffs, 18194, 13931)
               :ExtraText(_t("tooltip.buff.mp5"))
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category("classicSpellFood")

  -- Monster Omelette
  buffDefModule:genericConsumable(allBuffs, 19710, 12218)
               :ExtraText(_t("tooltip.buff.spirit"))
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category("classicSpellFood")

  --Blessed Sunfruit Juice +10 SPIRIT
  buffDefModule:genericConsumable(allBuffs, 18141, 13813)
               :ExtraText(_t("tooltip.buff.spirit"))
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category("classicSpellFood")

  --Runn Tum Tuber Surprise
  buffDefModule:genericConsumable(allBuffs, 22730, 18254)
               :Category("classicSpellFood")
end

---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function foodModule:_SetupMiscFoodClassic(allBuffs, enchantments)
  buffDefModule:genericConsumable(allBuffs, 25661, 21023) -- Dirge's Kickin' Chimaerok Chops x
               :Category("classicFood")
end

---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function foodModule:_SetupPhysicalFoodClassic(allBuffs, enchantments)
  --Grilled Squid +10 Agility
  buffDefModule:genericConsumable(allBuffs, 18192, 13928)
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category("classicPhysFood")

  --Smoked Desert Dumplings +Strength
  buffDefModule:genericConsumable(allBuffs, 24799, 20452)
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category("classicPhysFood")

  --Blessed Sunfruit +STR
  buffDefModule:genericConsumable(allBuffs, 18125, 13810)
               :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
               :Category("classicPhysFood")
end

---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function foodModule:_SetupCasterFoodWotLK(allBuffs, enchantments)
  -- Steaming Chicken Soup +25 Stam/25 Spi
  buffDefModule:wotlkConsumable(allBuffs, 53284, 42779)
               :ExtraText(_t("tooltip.buff.spirit"))
               :Category("wotlkSpellFood")

  -- Cuttlesteak 40 Spirit/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57365, 42998)
               :ExtraText(_t("tooltip.buff.spirit"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Cuttlesteak
               :Category("wotlkSpellFood")
  --
  -- Spell Power Food
  --
  -- Shoveltusk Steak +35 Spell/30 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57139, 34749)
               :ExtraText(_t("tooltip.buff.spellPower"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Shoveltusk Steak
               :Category("wotlkSpellFood")

  -- Smoked Salmon +35 Spell/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57097, { 34763, 34749 })
               :ExtraText(_t("tooltip.buff.spellPower") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Smoked Salmon
               :Category("wotlkSpellFood")

  -- Tender Shoveltusk Steak/Firecracker Salmon +46 Spell/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57327, { 34755, 34767 })
               :ExtraText(_t("tooltip.buff.spellPower") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Tender Shoveltusk Steak/Firecracker Salmon
               :Category("wotlkSpellFood")
  --
  -- Mana per 5 Food
  --
  -- Pickled Fangtooth/Rhino Dogs +15 mp5/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57107, { 34765, 34752 })
               :ExtraText(_t("tooltip.buff.mp5") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Pickled Fangtooth/Rhino Dogs
               :Category("wotlkSpellFood")

  -- Mighty Rhino Dogs/Spicy Fried Herring +20 mp5/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57334, { 34758, 42993 })
               :ExtraText(_t("tooltip.buff.mp5") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Mighty Rhino Dogs/Spicy Fried Herring
               :Category("wotlkSpellFood")
end

---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function foodModule:_SetupPhysicalFoodWotLK(allBuffs, enchantments)
  --
  -- Strength Food
  --
  -- Dragonfin Filet +40 Str/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57371, 43000)
               :ExtraText(_t("tooltip.buff.strength"))
               :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Dragonfin Filet
               :Category("wotlkPhysFood")
  --
  -- Agility Food
  --
  -- Blackened Dragonfin +40 Agi/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57367, 42999)
               :ExtraText(_t("tooltip.buff.agility"))
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Blackened Dragonfin
               :Category("wotlkPhysFood")
  --
  -- Attack Power Food
  --
  -- Mammoth Meal +60 AP/30 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57111, 34748)
               :ExtraText(_t("tooltip.buff.attackPower"))
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Mammoth Meal
               :Category("wotlkPhysFood")

  -- Grilled Sculpin +60 AP/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57079, 34762)
               :ExtraText(_t("tooltip.buff.attackPower"))
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Grilled Sculpin
               :Category("wotlkPhysFood")

  -- Mega Mammoth Meal/Poached Northern Sculpin +80 AP/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57325, { 34762, 34766 })
               :ExtraText(_t("tooltip.buff.attackPower") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Mega Mammoth Meal/Poached Northern Sculpin
               :Category("wotlkPhysFood")
  --
  -- Expertise Food
  --
  -- Rhinolicious Wormsteak +40 Expert/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57356, 42994)
               :ExtraText(_t("tooltip.buff.attackPower"))
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Rhinolicious Wormsteak
               :Category("wotlkPhysFood")
  --
  -- Armor Pen Food
  --
  -- Hearty Rhino +40 Armor Pen/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57358, 42995)
               :ExtraText(_t("tooltip.buff.armorPenetration"))
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Hearty Rhino
               :Category("wotlkPhysFood")
end

---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function foodModule:_SetupMiscFoodWotLK(allBuffs, enchantments)
  --
  -- Haste Food
  --
  -- Roasted Worg +30 Haste/30 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57288, 34751)
               :ExtraText(_t("tooltip.buff.haste"))
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Roasted Worg
               :Category("wotlkFood")

  -- Baked Manta Ray +30 Haste/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57102, 42942)
               :ExtraText(_t("tooltip.buff.haste"))
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Baked Manta Ray
               :Category("wotlkFood")

  -- Very Burnt Worg/Imperial Manta Steak +40 Haste/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57332, { 34757, 34769 })
               :ExtraText(_t("tooltip.buff.haste") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Very Burnt Worg/Imperial Manta Steak
               :Category("wotlkFood")
  --
  -- HIT Food
  --
  buffDefModule:wotlkConsumable(allBuffs, 57360, { 34751, 42996 }) -- Worg Tartare/Snapper Extreme +40 Hit/40 Stam
               :ExtraText(_t("tooltip.buff.hit") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Worg Tartare/Snapper Extreme
               :Category("wotlkFood")
  --
  -- Crit Food
  --
  -- Worm Delight 30 Crit/30 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57286, 34750)
               :ExtraText(_t("tooltip.buff.crit"))
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Worm Delight
               :Category("wotlkFood")

  -- Poached Nettlefish 30 Crit/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57100, 34764)
               :ExtraText(_t("tooltip.buff.crit"))
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Poached Nettlefish
               :Category("wotlkFood")

  -- Spicy Blue Nettlefish/Spiced Worm Burger +40 Crit/40 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57329, { 34768, 34756 })
               :ExtraText(_t("tooltip.buff.crit") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Spicy Blue Nettlefish/Spiced Worm Burger
               :Category("wotlkFood")
  --
  -- Combo Meals
  --
  -- Dalaran Clam Chowder/Great Feast +60 ATK/+35 Spell/+30 Stam
  buffDefModule:wotlkConsumable(allBuffs, 57294, { 43268, 34753 })
               :ExtraText(_t("tooltip.buff.comboMealWotlk") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Dalaran Clam Chowder/Great Feast
               :Category("wotlkFood")
  buffDefModule:wotlkConsumable(allBuffs, 57399, 43015) -- Fish Feast +80 ATK/+46 Spell/+40 Stam
               :ExtraText(_t("tooltip.buff.comboMealWotlk") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :IgnoreIfHaveBuff(spellIdsModule.WotlkFood80) -- [Food] While eating Fish Feast
               :Category("wotlkFood")
end