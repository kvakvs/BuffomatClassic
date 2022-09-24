local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsDeathknightModule
local deathknightModule = BuffomatModule.New("AllSpellsDeathknight") ---@type BomAllSpellsDeathknightModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule

---Add DEATH KNIGHT spells
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function deathknightModule:SetupDeathknightSpells(spells, enchants)
  -- TODO: Tag presence buffs and exclude other buffs from the same family when clicking the UI
  buffDefModule:createAndRegisterBuff(spells, 48266, -- Blood Presence
          { isOwn = true, default = true, singleId = 48266, shapeshiftFormId = 1
          })   :RequirePlayerClass("DEATHKNIGHT")
               :Category(allBuffsModule.CLASS)
  buffDefModule:createAndRegisterBuff(spells, 48263, -- Frost Presence
          { isOwn = true, default = false, singleId = 48263, shapeshiftFormId = 2
          })   :RequirePlayerClass("DEATHKNIGHT")
               :Category(allBuffsModule.CLASS)
  buffDefModule:createAndRegisterBuff(spells, 48265, -- Unholy Presence
          { isOwn = true, default = false, singleId = 48265, shapeshiftFormId = 3
          })   :RequirePlayerClass("DEATHKNIGHT")
               :Category(allBuffsModule.CLASS)
  buffDefModule:createAndRegisterBuff(spells, 57330, -- Horn of Winter
          { default = true, singleId = 57330, singleDuration = allBuffsModule.DURATION_2M, isOwn = true })
               :RequirePlayerClass("DEATHKNIGHT")
               :Category(allBuffsModule.CLASS)
  buffDefModule:createAndRegisterBuff(spells, 49222, -- Bone Shield
          { default = true, singleId = 49222, singleDuration = allBuffsModule.DURATION_5M,
            isOwn   = true, hasCD = true })
               :RequirePlayerClass("DEATHKNIGHT")
               :Category(allBuffsModule.CLASS)
  buffDefModule:createAndRegisterBuff(spells, 46584, --Raise Dead
          { type            = "summon", default = true, isOwn = true,
            reagentRequired = { BOM.Item_Deathknight_CorpseDust },
            creatureFamily  = "Ghoul", creatureType = "Undead",
          })   :RequirePlayerClass("DEATHKNIGHT")
               :Category(allBuffsModule.PET)
end
