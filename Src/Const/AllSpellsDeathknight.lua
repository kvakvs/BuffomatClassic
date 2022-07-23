local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsDeathknightModule
local deathknightModule = BuffomatModule.New("AllSpellsDeathknight") ---@type BomAllSpellsDeathknightModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allSpellsModule = BuffomatModule.Import("AllSpells") ---@type BomAllSpellsModule
local spellDefModule = BuffomatModule.Import("SpellDef") ---@type BomSpellDefModule

---Add DEATH KNIGHT spells
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function deathknightModule:SetupDeathknightSpells(spells, enchants)
  -- TODO: Tag presence buffs and exclude other buffs from the same family when clicking the UI
  spellDefModule:createAndRegisterBuff(spells, 48266, -- Blood Presence
          { isOwn = true, default = true, default = false, singleId = 48266, shapeshiftFormId = 1
          })    :ClassOnly("DEATHKNIGHT")
                :Category(allSpellsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 48263, -- Frost Presence
          { isOwn = true, default = true, default = false, singleId = 48263, shapeshiftFormId = 2
          })    :ClassOnly("DEATHKNIGHT")
                :Category(allSpellsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 48265, -- Unholy Presence
          { isOwn = true, default = true, default = false, singleId = 48265, shapeshiftFormId = 3
          })    :ClassOnly("DEATHKNIGHT")
                :Category(allSpellsModule.CLASS)
end
