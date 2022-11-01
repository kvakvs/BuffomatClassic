local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllConsumesOtherModule
local otherModule = {}
BomModuleManager.allConsumesOtherModule = otherModule

local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffDefModule = BomModuleManager.buffDefinitionModule

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
  buffDefModule:createAndRegisterBuff(buffs, 17038, --Winterfall Firewater
          { item = 12820, isConsumable = true, default = false
          })   :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.CLASSIC_PHYS_BUFF)
  buffDefModule:createAndRegisterBuff(buffs, 16329, --Juju Might +40AP
          { item = 12460, isConsumable = true, default = false
          })   :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.CLASSIC_PHYS_BUFF)
  buffDefModule:createAndRegisterBuff(buffs, 16323, --Juju Power +30Str
          { item = 12451, isConsumable = true, default = false
          })   :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
               :Category(allBuffsModule.CLASSIC_PHYS_BUFF)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function otherModule:_SetupCasterConsumablesTBC(buffs, enchantments)
  -- Not visible in Classic
  buffDefModule:tbcConsumable(buffs, 28273, 22710, --TBC: Bloodthistle (Belf only)
          { playerRace = "BloodElf"
          })   :RequirePlayerClass(allBuffsModule.SPELL_CLASSES) -- RequireRace
               :RequireTBC()
               :ExtraText(_t("tooltip.buff.spellPower"))
               :Category(allBuffsModule.TBC_FOOD)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function otherModule:_SetupMiscConsumablesClassic(buffs, enchantments)
  buffDefModule:genericConsumable(buffs, 16326, 12455) --Juju Ember +15FR
               :ExtraText(_t("tooltip.buff.fireResist"))
               :Category(allBuffsModule.CLASSIC_BUFF)
  buffDefModule:genericConsumable(buffs, 16325, 12457) --Juju Chill +15FrostR
               :ExtraText(_t("tooltip.buff.frostResist"))
               :Category(allBuffsModule.CLASSIC_BUFF)
  buffDefModule:genericConsumable(buffs, 22790, 18284) --Kreeg's Stout Beatdown +SPI minus INT
               :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
               :ExtraText(_t("tooltip.alcohol.spirit"))
               :Category(allBuffsModule.CLASSIC_FOOD)
  buffDefModule:genericConsumable(buffs, 22789, 18269) --Gordok Green Grog +STA
               :ExtraText(_t("tooltip.alcohol.stamina"))
               :Category(allBuffsModule.CLASSIC_FOOD)
  buffDefModule:genericConsumable(buffs, 25804, 21151) --Rumsey Rum Black Label
               :ExtraText(_t("tooltip.alcohol.stamina"))
               :Category(allBuffsModule.CLASSIC_FOOD)
  buffDefModule:genericConsumable(buffs, 15233, 11564) --Crystal Ward
               :Category(allBuffsModule.CLASSIC_BUFF)
  buffDefModule:genericConsumable(buffs, 15279, 11567) --Crystal Spire +12 THORNS
               :Category(allBuffsModule.CLASSIC_BUFF)
  buffDefModule:genericConsumable(buffs, 15231, 11563) --Crystal Force +30 SPI
               :ExtraText(_t("tooltip.buff.spirit"))
               :Category(allBuffsModule.CLASSIC_BUFF)
end
