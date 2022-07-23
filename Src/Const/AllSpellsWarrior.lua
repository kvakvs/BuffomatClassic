local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsWarriorModule
local warriorModule = BuffomatModule.New("AllSpellsWarrior") ---@type BomAllSpellsWarriorModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allSpellsModule = BuffomatModule.Import("AllSpells") ---@type BomAllSpellsModule
local spellDefModule = BuffomatModule.Import("SpellDef") ---@type BomSpellDefModule

---Add WARRIOR spells
function warriorModule:SetupWarriorSpells(spells, enchants)
  spellDefModule:createAndRegisterBuff(spells, 25289, --Battle Shout
          { isOwn        = true, default = true, default = false,
            singleFamily = { 6673, 5242, 6192, 11549, 11550, 11551, 25289, -- Battle Shout 1-7
                             2048, -- TBC: Battle Shout 8
                             47436 } -- WotLK: Battle Shout 9
          })    :ClassOnly("WARRIOR")
                :Category(allSpellsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 2457, --Battle Stance
          { isOwn = true, default = true, default = false, singleId = 2457, shapeshiftFormId = 17
          })    :ClassOnly("WARRIOR")
                :Category(allSpellsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 71, --Defensive Stance
          { isOwn = true, default = true, default = false, singleId = 71, shapeshiftFormId = 18
          })    :ClassOnly("WARRIOR")
                :Category(allSpellsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 2458, --Berserker Stance
          { isOwn = true, default = true, default = false, singleId = 2458, shapeshiftFormId = 19
          })    :ClassOnly("WARRIOR")
                :Category(allSpellsModule.CLASS)
end
