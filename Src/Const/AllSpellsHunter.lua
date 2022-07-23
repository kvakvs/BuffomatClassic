local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsHunterModule
local hunterModule = BuffomatModule.New("AllSpellsHunter") ---@type BomAllSpellsHunterModule

--local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allSpellsModule = BuffomatModule.Import("AllSpells") ---@type BomAllSpellsModule
local spellDefModule = BuffomatModule.Import("SpellDef") ---@type BomSpellDefModule

---Add HUNTER spells
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function hunterModule:SetupHunterSpells(spells, enchants)
  spellDefModule:createAndRegisterBuff(spells, 20906, -- Trueshot Aura
          { isOwn        = true, default = true,
            singleFamily = { 19506, 20905, 20906, -- Trueshot Aura 1-3, WotLK: Trueshot Aura
                             27066 }  -- TBC: Trueshot Aura 4
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.AURA)

  spellDefModule:createAndRegisterBuff(spells, 25296, -- Aspect of the Hawk
          { type         = "aura", default = true,
            singleFamily = { 13165, 14318, 14319, 14320, 14321, 14322, 25296, -- Aspect of the Hawk 1-7
                             27044, -- TBC: Aspect of the Hawk 8
                             61846, 61847 } -- WotLK: Aspect of the Dragonhawk 1-2
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 13163, --Aspect of the monkey
          { type = "aura", default = false
          })    :MaxLevel(74) -- Superceded by Aspect of the Dragonhawk
                :ClassOnly("HUNTER")
                :Category(allSpellsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 34074, -- TBC: Aspect of the Viper
          { type = "aura", default = false
          })    :ClassOnly("HUNTER")
                :ShowInTBC()
                :Category(allSpellsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 20190, -- Aspect of the Wild
          { type         = "aura", default = false,
            singleFamily = { 20043, 20190, -- Aspect of the Wild 1-2
                             27045, -- TBC: Aspect of the Wild 3
                             49071 } -- WotLK: Aspect of the Wild 4
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.AURA)
  spellDefModule:createAndRegisterBuff(spells, 5118, --Aspect of the Cheetah
          { type = "aura", default = false
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 13159, --Aspect of the Pack
          { type = "aura", default = false
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.AURA)
  spellDefModule:createAndRegisterBuff(spells, 13161, -- Aspect of the Beast
          { type = "aura", default = false
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.CLASS)

  spellDefModule:createAndRegisterBuff(spells, 1494, -- Track Beast
          { type = "tracking", default = false
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19878, -- Track Demon
          { type = "tracking", default = false
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19879, -- Track Dragonkin
          { type = "tracking", default = false
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19880, -- Track Elemental
          { type = "tracking", default = false
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19883, -- Track Humanoids
          { type = "tracking", default = false
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19882, -- Track Giants / riesen
          { type = "tracking", default = false
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19884, -- Track Undead
          { type = "tracking", default = false
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.TRACKING)
  spellDefModule:createAndRegisterBuff(spells, 19885, -- Track Hidden / verborgenes
          { type = "tracking", default = false
          })    :ClassOnly("HUNTER")
                :Category(allSpellsModule.TRACKING)

  -- TODO: Do not use tbc_consumable function, add new flags for pet-buff
  spellDefModule:tbcConsumable(spells, 43771, 33874,
          {}, "Pet buff +Str",
          { tbcHunterPetBuff = true } --TBC: Kibler's Bits +20 STR/20 SPI for hunter pet
  )             :ClassOnly("HUNTER")
                :Category(allSpellsModule.PET)
  spellDefModule:tbcConsumable(spells, 33272, 27656,
          {}, "Pet buff +Stamina",
          { tbcHunterPetBuff = true } --TBC: Sporeling Snack +20 STAM/20 SPI for hunter pet
  )             :ClassOnly("HUNTER")
                :Category(allSpellsModule.PET)
end
