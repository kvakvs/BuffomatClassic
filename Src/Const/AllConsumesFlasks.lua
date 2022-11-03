local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllConsumesFlasksModule
local flasksModule = {}
BomModuleManager.allConsumesFlasksModule = flasksModule

local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffDefModule = BomModuleManager.buffDefinitionModule

---FLASKS
---@param allBuffs BomAllBuffsTable A list of buffs (not dictionary)
---@param enchantments table<number, number[]> Key is spell id, value is list of enchantment ids
function flasksModule:SetupFlasks(allBuffs, enchantments)
  self:_SetupFlasksClassic(allBuffs, enchantments)
  self:_SetupFlasksTBC(allBuffs, enchantments)
  self:_SetupFlasksWotLK(allBuffs, enchantments)
end

---@param allBuffs BomAllBuffsTable A list of buffs (not dictionary)
---@param enchantments table<number, number[]> Key is spell id, value is list of enchantment ids
function flasksModule:_SetupFlasksClassic(allBuffs, enchantments)
  buffDefModule:genericConsumable(allBuffs, 17628, 13512) --Flask of Supreme Power +70 SPELL
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :ExtraText(_t("tooltip.buff.spellPower"))
               :Category(allBuffsModule.CLASSIC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  buffDefModule:genericConsumable(allBuffs, 17626, 13510) --Flask of the Titans +400 HP
               :ExtraText(_t("tooltip.buff.maxHealth"))
               :Category(allBuffsModule.CLASSIC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  buffDefModule:genericConsumable(allBuffs, 17627, 13511) --Flask of Distilled Wisdom +65 INT
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :ExtraText(_t("tooltip.buff.intellect"))
               :Category(allBuffsModule.CLASSIC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  buffDefModule:genericConsumable(allBuffs, 17629, 13513) --Flask of Chromatic Resistance
               :ExtraText(_t("tooltip.buff.allResist"))
               :Category(allBuffsModule.CLASSIC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)
end

---@param allBuffs BomAllBuffsTable A list of buffs (not dictionary)
---@param enchantments table<number, number[]> Key is spell id, value is list of enchantment ids
function flasksModule:_SetupFlasksTBC(allBuffs, enchantments)
  buffDefModule:tbcConsumable(allBuffs, 28540, 22866) --TBC: Flask of Pure Death +80 SHADOW +80 FIRE +80 FROST
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.spellPower"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :Category(allBuffsModule.TBC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  buffDefModule:genericConsumable(allBuffs, 28521, 22861) --TBC: Flask of Blinding Light +80 ARC +80 HOLY +80 NATURE
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.spellPower"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :Category(allBuffsModule.TBC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  buffDefModule:genericConsumable(allBuffs, 28520, 22854) --TBC: Flask of Relentless Assault +120 AP
               :RequireTBC()
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.buff.attackPower"))
               :Category(allBuffsModule.TBC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  buffDefModule:genericConsumable(allBuffs, 28518, 22851) --TBC: Flask of Fortification +500 HP +10 DEF RATING
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.maxHealth"))
               :Category(allBuffsModule.TBC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  buffDefModule:genericConsumable(allBuffs, 28519, 22853) --TBC: Flask of Mighty Restoration +25 MP/5
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.mp5"))
               :Category(allBuffsModule.TBC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  buffDefModule:genericConsumable(allBuffs, 42735, 33208) --TBC: Flask of Chromatic Wonder +35 ALL RESIST +18 ALL STATS
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.allResist"))
               :Category(allBuffsModule.TBC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  --
  -- Shattrath Flasks...
  --
  buffDefModule:genericConsumable(allBuffs, 46837, 35716) --TBC: Shattrath Flask of Pure Death +80 SHADOW +80 FIRE +80 FROST
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.spellPower"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :Category(allBuffsModule.TBC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  buffDefModule:genericConsumable(allBuffs, 46839, 35717) --TBC: Shattrath Flask of Blinding Light +80 ARC +80 HOLY +80 NATURE
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.spellPower"))
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :Category(allBuffsModule.TBC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  buffDefModule:genericConsumable(allBuffs, 41608, 32901) --TBC: Shattrath Flask of Relentless Assault +120 AP
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.attackPower"))
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.TBC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  buffDefModule:genericConsumable(allBuffs, 41609, 32898) --TBC: Shattrath Flask of Fortification +500 HP +10 DEF RATING
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.maxHealth"))
               :Category(allBuffsModule.TBC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  buffDefModule:genericConsumable(allBuffs, 41610, 32899) --TBC: Shattrath Flask of Mighty Restoration +25 MP/5
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.mp5"))
               :Category(allBuffsModule.TBC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  buffDefModule:genericConsumable(allBuffs, 41611, 32900, --TBC: Shattrath Flask of Supreme Power +70 SPELL
          { playerClass = allBuffsModule.MANA_CLASSES })
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.spellPower"))
               :Category(allBuffsModule.TBC_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)
end

---@param allBuffs BomAllBuffsTable A list of buffs (not dictionary)
---@param enchantments table<number, number[]> Key is spell id, value is list of enchantment ids
function flasksModule:_SetupFlasksWotLK(allBuffs, enchantments)
  buffDefModule:genericConsumable(allBuffs, 53760, 46377) --WotLK: Flask of Endless Rage +180 AP
               :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :ExtraText(_t("tooltip.buff.attackPower"))
               :RequireWotLK()
               :Category(allBuffsModule.WOTLK_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)
  buffDefModule:genericConsumable(allBuffs, 53755, 46376) --WotLK: Flask of the Frost Wyrm +125 Spell
               :ExtraText(_t("tooltip.buff.spellPower"))
               :RequireWotLK()
               :RequirePlayerClass(allBuffsModule.SPELL_CLASSES)
               :Category(allBuffsModule.WOTLK_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)
  buffDefModule:genericConsumable(allBuffs, 53758, 46379) --WotLK: Flask of the Stoneblood +1300 HP
               :ExtraText(_t("tooltip.buff.maxHealth"))
               :RequireWotLK()
               :Category(allBuffsModule.WOTLK_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)
  buffDefModule:genericConsumable(allBuffs, 54212, 46378) --WotLK: Flask of Pure Mojo +45 MP5
               :RequireWotLK()
               :ExtraText(_t("tooltip.buff.mp5"))
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :Category(allBuffsModule.WOTLK_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)
  --
  -- Lesser Flasks
  --
  buffDefModule:genericConsumable(allBuffs, 53752, 40079) --WotLK: Lesser Flask of Toughness +RESIL
               :ExtraText(_t("tooltip.buff.resilience"))
               :RequireWotLK()
               :Category(allBuffsModule.WOTLK_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)
  buffDefModule:genericConsumable(allBuffs, 62380, 44939) --WotLK: Lesser Flask of Resistance +RESIST
               :ExtraText(_t("tooltip.buff.allResist"))
               :RequireWotLK()
               :Category(allBuffsModule.WOTLK_FLASK)
               :ElixirType(allBuffsModule.ELIX_FLASK)

  ---- Alchemist self-flask: Flask of the North 67016...19
  --buffDefModule:genericConsumable(buffs, 67016, 47499) --WotLK: Flask of the North
  --             :ExtraText(_t("tooltip.buff.alchemistOnly"))
  --             :RequireWotLK()
  --             :Category(allBuffsModule.WOTLK_FLASK)
  --             :ElixirType(allBuffsModule.ELIX_FLASK)
end
