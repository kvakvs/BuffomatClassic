local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllConsumesScrollsModule
local scrollsModule = BuffomatModule.New("AllConsumesScrolls") ---@type BomAllConsumesScrollsModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule

---SCROLLS
---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function scrollsModule:SetupScrolls(buffs, enchantments)
  --
  -- Scrolls
  --
  buffDefModule:createAndRegisterBuff(buffs, 33077, --TBC: Scroll of Agility V
          { item           = 27498, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = allBuffsModule.DURATION_30M, playerClass = allBuffsModule.BOM_PHYSICAL_CLASSES })
                :RequireTBC()
                :Category(allBuffsModule.SCROLL)
  buffDefModule:createAndRegisterBuff(buffs, 12174, --Scroll of Agility IV
          { item           = 10309, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = allBuffsModule.DURATION_30M, playerClass = allBuffsModule.BOM_PHYSICAL_CLASSES, })
                :Category(allBuffsModule.SCROLL)
  buffDefModule:createAndRegisterBuff(buffs, 8117, --Scroll of Agility III
          { item           = 4425, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = allBuffsModule.DURATION_30M, playerClass = allBuffsModule.BOM_PHYSICAL_CLASSES, })
                :Category(allBuffsModule.SCROLL)

  buffDefModule:createAndRegisterBuff(buffs, 33082, --TBC: Scroll of Strength V
          { item           = 27503, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = allBuffsModule.DURATION_30M, playerClass = allBuffsModule.BOM_MELEE_CLASSES })
                :RequireTBC()
                :Category(allBuffsModule.SCROLL)
  buffDefModule:createAndRegisterBuff(buffs, 12179, --Scroll of Strength IV
          { item           = 10310, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = allBuffsModule.DURATION_30M, playerClass = allBuffsModule.BOM_MELEE_CLASSES, })
                :Category(allBuffsModule.SCROLL)
  buffDefModule:createAndRegisterBuff(buffs, 8120, --Scroll of Strength III
          { item           = 4426, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = allBuffsModule.DURATION_30M, playerClass = allBuffsModule.BOM_MELEE_CLASSES, })
                :Category(allBuffsModule.SCROLL)

  buffDefModule:createAndRegisterBuff(buffs, 33079, --TBC: Scroll of Protection V
          { item           = 27500, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = allBuffsModule.DURATION_30M })
                :RequireTBC()
                :Category(allBuffsModule.SCROLL)
  buffDefModule:createAndRegisterBuff(buffs, 12175, --Scroll of Protection IV
          { item           = 10305, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = allBuffsModule.DURATION_30M, })
                :Category(allBuffsModule.SCROLL)

  buffDefModule:createAndRegisterBuff(buffs, 12177, --Scroll of Spirit IV
          { item           = 10306, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = allBuffsModule.DURATION_30M, playerClass = allBuffsModule.BOM_MANA_CLASSES })
                :Category(allBuffsModule.SCROLL)
  buffDefModule:createAndRegisterBuff(buffs, 33080, --Scroll of Spirit V
          { item           = 27501, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = allBuffsModule.DURATION_30M, playerClass = allBuffsModule.BOM_MANA_CLASSES })
                :RequireTBC()
                :Category(allBuffsModule.SCROLL)

end