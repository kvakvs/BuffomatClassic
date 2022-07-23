local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllConsumesOtherModule
local otherModule = BuffomatModule.New("AllConsumesOther") ---@type BomAllConsumesOtherModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local spellDefModule = BuffomatModule.Import("SpellDef") ---@type BomSpellDefModule

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function otherModule:SetupOtherConsumables(buffs, enchantments)
  self:_SetupPhysicalConsumablesClassic(buffs, enchantments)
  --self:_SetupPhysicalConsumablesTBC(buffs, enchantments)
  --self:_SetupPhysicalConsumablesWotLK(buffs, enchantments)

  --self:_SetupCasterConsumablesClassic(buffs, enchantments)
  self:_SetupCasterConsumablesTBC(buffs, enchantments)
  --self:_SetupCasterConsumablesWotLK(buffs, enchantments)

  self:_SetupMiscConsumablesClassic(buffs, enchantments)
  --self:_SetupMiscConsumablesTBC(buffs, enchantments)
  --self:_SetupMiscConsumablesWotLK(buffs, enchantments)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function otherModule:_SetupPhysicalConsumablesClassic(buffs, enchantments)
  spellDefModule:createAndRegisterBuff(buffs, 17038, --Winterfall Firewater
          { item          = 12820, isConsumable = true, default = false,
            onlyUsableFor = allBuffsModule.BOM_PHYSICAL_CLASSES, })
                :Category(allBuffsModule.CLASSIC_PHYS_BUFF)
  spellDefModule:createAndRegisterBuff(buffs, 16329, --Juju Might +40AP
          { item        = 12460, isConsumable = true, default = false,
            playerClass = allBuffsModule.BOM_PHYSICAL_CLASSES, })
                :Category(allBuffsModule.CLASSIC_PHYS_BUFF)
  spellDefModule:createAndRegisterBuff(buffs, 16323, --Juju Power +30Str
          { item        = 12451, isConsumable = true, default = false,
            playerClass = allBuffsModule.BOM_PHYSICAL_CLASSES, })
                :Category(allBuffsModule.CLASSIC_PHYS_BUFF)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function otherModule:_SetupCasterConsumablesTBC(buffs, enchantments)
  -- Not visible in Classic
  spellDefModule:tbcConsumable(buffs, 28273, 22710, --TBC: Bloodthistle (Belf only)
          { playerRace = "BloodElf", playerClass = allBuffsModule.BOM_MANA_CLASSES },
          "+10 spell"
  )             :ShowInTBC()
                :Category(allBuffsModule.TBC_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function otherModule:_SetupMiscConsumablesClassic(buffs, enchantments)
  spellDefModule:classicConsumable(buffs, 16326, 12455, --Juju Ember +15FR
          nil)
                :Category(allBuffsModule.CLASSIC_BUFF)

  spellDefModule:classicConsumable(buffs, 16325, 12457, --Juju Chill +15FrostR
          nil)
                :Category(allBuffsModule.CLASSIC_BUFF)

  spellDefModule:classicConsumable(buffs, 22790, 18284, --Kreeg's Stout Beatdown
          { playerClass = allBuffsModule.BOM_MANA_CLASSES })
                :Category(allBuffsModule.CLASSIC_FOOD)
  spellDefModule:classicConsumable(buffs, 22789, 18269, --Gordok Green Grog
          nil)
                :Category(allBuffsModule.CLASSIC_FOOD)
  spellDefModule:classicConsumable(buffs, 25804, 21151, --Rumsey Rum Black Label
          nil)
                :Category(allBuffsModule.CLASSIC_FOOD)

  spellDefModule:classicConsumable(buffs, 15233, 11564, --Crystal Ward
          nil)
                :Category(allBuffsModule.CLASSIC_BUFF)

  spellDefModule:classicConsumable(buffs, 15279, 11567, --Crystal Spire +12 THORNS
          nil)
                :Category(allBuffsModule.CLASSIC_BUFF)

  spellDefModule:classicConsumable(buffs, 15231, 11563, --Crystal Force +30 SPI
          nil)
                :Category(allBuffsModule.CLASSIC_BUFF)
end