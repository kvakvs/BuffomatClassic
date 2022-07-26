local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllConsumesFoodModule
local foodModule = BuffomatModule.New("AllConsumesFood") ---@type BomAllConsumesFoodModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:SetupFood(buffs, enchantments)
  self:_SetupCasterFoodClassic(buffs, enchantments)
  self:_SetupPhysicalFoodClassic(buffs, enchantments)
  self:_SetupMiscFoodClassic(buffs, enchantments)

  self:_SetupCasterFoodTBC(buffs, enchantments)
  self:_SetupPhysicalFoodTBC(buffs, enchantments)
  self:_SetupMiscFoodTBC(buffs, enchantments)

  self:_SetupCasterFoodWotLK(buffs, enchantments)
  self:_SetupPhysicalFoodWotLK(buffs, enchantments)
  self:_SetupMiscFoodWotLK(buffs, enchantments)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupMiscFoodTBC(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 33257, { 33052, 27667 }) --Well Fed +30 STA +20 SPI
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.stamina"))
               :Category(allBuffsModule.TBC_FOOD)
  buffDefModule:genericConsumable(buffs, 35254, { 27651, 30155, 27662, 33025 }) --Well Fed +20 STA +20 SPI
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.stamina"))
               :Category(allBuffsModule.TBC_FOOD)
  buffDefModule:genericConsumable(buffs, 41030, 32721) --Skyguard Rations: Well Fed +15 STA +15 SPI
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.stamina"))
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.TBC_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupPhysicalFoodTBC(buffs, enchantments)
  -- Warp Burger, Grilled Mudfish, ...
  buffDefModule:genericConsumable(buffs, 33261, { 27659, 30358, 27664, 33288, 33293 }) --Well Fed +20 AGI +20 SPI
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.buff.agility"))
               :Category(allBuffsModule.TBC_PHYS_FOOD)
  buffDefModule:genericConsumable(buffs, 43764, 33872) --Spicy Hot Talbuk: Well Fed +20 HITRATING +20 SPI
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.buff.hit"))
               :Category(allBuffsModule.TBC_PHYS_FOOD)
  buffDefModule:genericConsumable(buffs, 33256, { 27658, 30359 }) -- Well Fed +20 STR +20 SPI
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
               :ExtraText(_t("tooltip.buff.strength"))
               :Category(allBuffsModule.TBC_PHYS_FOOD)
  buffDefModule:genericConsumable(buffs, 33259, 27655) --Ravager Dog: Well Fed +40 AP +20 SPI
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.buff.attackPower"))
               :Category(allBuffsModule.TBC_PHYS_FOOD)
  buffDefModule:genericConsumable(buffs, 46899, 35563) -- Charred Bear Kabobs +24 AP
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.buff.attackPower"))
               :Category(allBuffsModule.TBC_PHYS_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupCasterFoodTBC(buffs, enchantments)
  buffDefModule:tbcConsumable(buffs, 33263, { 27657, 31673, 27665, 30361 }) -- Well Fed +23 SPELL +20 SPI
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(33264)
               :ExtraText(_t("tooltip.buff.spellPower"))
               :Category(allBuffsModule.TBC_SPELL_FOOD)
  buffDefModule:genericConsumable(buffs, 33265, 27663) -- Blackened Sporefish: Well Fed +8 MP5 +20 STA
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :ExtraText(_t("tooltip.buff.mp5"))
               :Category(allBuffsModule.TBC_SPELL_FOOD)
  buffDefModule:genericConsumable(buffs, 33268, { 27666, 30357 }) -- Golden Fish Sticks: Well Fed +44 HEAL +20 SPI
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.healing"))
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.TBC_SPELL_FOOD)
  buffDefModule:genericConsumable(buffs, 33268, 33825) -- Skullfish Soup +20 Spell Crit/20 Spirit
               :RequireTBC()
               :IgnoreIfHaveBuff(43706) -- Drinking 240 mana/second
               :ExtraText(_t("tooltip.buff.spellCrit"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :Category(allBuffsModule.TBC_SPELL_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupCasterFoodClassic(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 18194, 13931) -- Nightfin Soup +8Mana/5
               :ExtraText(_t("tooltip.buff.mp5"))
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.CLASSIC_SPELL_FOOD)
  buffDefModule:genericConsumable(buffs, 19710, 12218) -- Monster Omelette
               :ExtraText(_t("tooltip.buff.spirit"))
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.CLASSIC_SPELL_FOOD)
  buffDefModule:createAndRegisterBuff(buffs, 18141, --Blessed Sunfruit Juice +10 SPIRIT
          { item = 13813, isConsumable = true, default = false })
               :ExtraText(_t("tooltip.buff.spirit"))
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.CLASSIC_SPELL_FOOD)
  buffDefModule:genericConsumable(buffs, 22730, 18254) --Runn Tum Tuber Surprise
               :Category(allBuffsModule.CLASSIC_SPELL_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupMiscFoodClassic(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 25661, 21023) -- Dirge's Kickin' Chimaerok Chops x
               :Category(allBuffsModule.CLASSIC_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupPhysicalFoodClassic(buffs, enchantments)
  buffDefModule:createAndRegisterBuff(buffs, 18192, --Grilled Squid +10 Agility
          { item = 13928, isConsumable = true, default = false })
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.CLASSIC_PHYS_FOOD)
  buffDefModule:createAndRegisterBuff(buffs, 24799, --Smoked Desert Dumplings +Strength
          { item = 20452, isConsumable = true, default = false })
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.CLASSIC_PHYS_FOOD)
  buffDefModule:genericConsumable(buffs, 18125, 13810) --Blessed Sunfruit +STR
               :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
               :Category(allBuffsModule.CLASSIC_PHYS_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupCasterFoodWotLK(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 53284, 42779) -- Steaming Chicken Soup +25 Stam/25 Spi
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.spirit"))
               :Category(allBuffsModule.WOTLK_SPELL_FOOD)
  buffDefModule:genericConsumable(buffs, 57365, 42998) -- Cuttlesteak 40 Spirit/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.spirit"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Cuttlesteak
               :Category(allBuffsModule.WOTLK_SPELL_FOOD)
  --
  -- Spell Power Food
  --
  buffDefModule:genericConsumable(buffs, 57139, 34749) -- Shoveltusk Steak +35 Spell/30 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.spellPower"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Shoveltusk Steak
               :Category(allBuffsModule.WOTLK_SPELL_FOOD)
  buffDefModule:genericConsumable(buffs, 57097, { 34763, 34749 }) -- Smoked Salmon +35 Spell/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.spellPower") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Smoked Salmon
               :Category(allBuffsModule.WOTLK_SPELL_FOOD)
  buffDefModule:genericConsumable(buffs, 57327, { 34755, 34767 }) -- Tender Shoveltusk Steak/Firecracker Salmon +46 Spell/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.spellPower") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Tender Shoveltusk Steak/Firecracker Salmon
               :Category(allBuffsModule.WOTLK_SPELL_FOOD)
  --
  -- Mana per 5 Food
  --
  buffDefModule:genericConsumable(buffs, 57107, { 34765, 34752 }) -- Pickled Fangtooth/Rhino Dogs +15 mp5/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.mp5") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Pickled Fangtooth/Rhino Dogs
               :Category(allBuffsModule.WOTLK_SPELL_FOOD)
  buffDefModule:genericConsumable(buffs, 57334, { 34758, 42993 }) -- Mighty Rhino Dogs/Spicy Fried Herring +20 mp5/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.mp5") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Mighty Rhino Dogs/Spicy Fried Herring
               :Category(allBuffsModule.WOTLK_SPELL_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupPhysicalFoodWotLK(buffs, enchantments)
  --
  -- Strength Food
  --
  buffDefModule:genericConsumable(buffs, 57371, 43000) -- Dragonfin Filet +40 Str/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.strength"))
               :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Dragonfin Filet
               :Category(allBuffsModule.WOTLK_PHYS_FOOD)
  --
  -- Agility Food
  --
  buffDefModule:genericConsumable(buffs, 57367, 42999) -- Blackened Dragonfin +40 Agi/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.agility"))
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Blackened Dragonfin
               :Category(allBuffsModule.WOTLK_PHYS_FOOD)
  --
  -- Attack Power Food
  --
  buffDefModule:genericConsumable(buffs, 57111, 34748) -- Mammoth Meal +60 AP/30 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.attackPower"))
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Mammoth Meal
               :Category(allBuffsModule.WOTLK_PHYS_FOOD)
  buffDefModule:genericConsumable(buffs, 57079, 34762) -- Grilled Sculpin +60 AP/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.attackPower"))
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Grilled Sculpin
               :Category(allBuffsModule.WOTLK_PHYS_FOOD)
  buffDefModule:genericConsumable(buffs, 57325, { 34762, 34766 }) -- Mega Mammoth Meal/Poached Northern Sculpin +80 AP/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.attackPower") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Mega Mammoth Meal/Poached Northern Sculpin
               :Category(allBuffsModule.WOTLK_PHYS_FOOD)
  --
  -- Expertise Food
  --
  buffDefModule:genericConsumable(buffs, 57356, 42994) -- Rhinolicious Wormsteak +40 Expert/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.attackPower"))
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Rhinolicious Wormsteak
               :Category(allBuffsModule.WOTLK_PHYS_FOOD)
  --
  -- Armor Pen Food
  --
  buffDefModule:genericConsumable(buffs, 57358, 42995) -- Hearty Rhino +40 Armor Pen/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.armorPenetration"))
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Hearty Rhino
               :Category(allBuffsModule.WOTLK_PHYS_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function foodModule:_SetupMiscFoodWotLK(buffs, enchantments)
  --
  -- Haste Food
  --
  buffDefModule:genericConsumable(buffs, 57288, 34751) -- Roasted Worg +30 Haste/30 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.haste"))
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Roasted Worg
               :Category(allBuffsModule.WOTLK_FOOD)
  buffDefModule:genericConsumable(buffs, 57102, 42942) -- Baked Manta Ray +30 Haste/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.haste"))
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Baked Manta Ray
               :Category(allBuffsModule.WOTLK_FOOD)
  buffDefModule:genericConsumable(buffs, 57332, { 34757, 34769 }) -- Very Burnt Worg/Imperial Manta Steak +40 Haste/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.haste") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Very Burnt Worg/Imperial Manta Steak
               :Category(allBuffsModule.WOTLK_FOOD)
  --
  -- HIT Food
  --
  buffDefModule:genericConsumable(buffs, 57360, { 34751, 42996 }) -- Worg Tartare/Snapper Extreme +40 Hit/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.hit") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Worg Tartare/Snapper Extreme
               :Category(allBuffsModule.WOTLK_FOOD)
  --
  -- Crit Food
  --
  buffDefModule:genericConsumable(buffs, 57286, 34750) -- Worm Delight 30 Crit/30 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.crit"))
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Worm Delight
               :Category(allBuffsModule.WOTLK_FOOD)
  buffDefModule:genericConsumable(buffs, 57100, 34764) -- Poached Nettlefish 30 Crit/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.crit"))
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Poached Nettlefish
               :Category(allBuffsModule.WOTLK_FOOD)
  buffDefModule:genericConsumable(buffs, 57329, { 34768, 34756 }) -- Spicy Blue Nettlefish/Spiced Worm Burger +40 Crit/40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.crit") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Spicy Blue Nettlefish/Spiced Worm Burger
               :Category(allBuffsModule.WOTLK_FOOD)
  --
  -- Combo Meals
  --
  buffDefModule:genericConsumable(buffs, 57294, { 43268, 34753 }) -- Dalaran Clam Chowder/Great Feast +60 ATK/+35 Spell/+30 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.comboMealWotlk") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Dalaran Clam Chowder/Great Feast
               :Category(allBuffsModule.WOTLK_FOOD)
  buffDefModule:genericConsumable(buffs, 57399, 43015) -- Fish Feast +80 ATK/+46 Spell/+40 Stam
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.comboMealWotlk") .. " " .. _t("tooltip.food.multipleFoodItems"))
               :IgnoreIfHaveBuff(BOM.SpellId.WotlkFood80) -- [Food] While eating Fish Feast
               :Category(allBuffsModule.WOTLK_FOOD)
end