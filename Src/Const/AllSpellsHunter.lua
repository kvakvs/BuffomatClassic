local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsHunterModule
local hunterModule = BuffomatModule.New("AllSpellsHunter") ---@type BomAllSpellsHunterModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule

---Add HUNTER spells
---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function hunterModule:SetupHunterSpells(buffs, enchantments)
  self:_SetupHunterSpellsTBC(buffs, enchantments)
  self:_SetupPetBuffs(buffs, enchantments)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function hunterModule:_SetupHunterSpellsTBC(buffs, enchantments)
  buffDefModule:createAndRegisterBuff(buffs, 20906, -- Trueshot Aura
          { isOwn        = true, default = true,
            singleFamily = { 19506, 20905, 20906, -- Trueshot Aura 1-3, WotLK: Trueshot Aura
                             27066 }  -- TBC: Trueshot Aura 4
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.AURA)

  buffDefModule:createAndRegisterBuff(buffs, 25296, -- Aspect of the Hawk
          { type         = "aura", default = true,
            singleFamily = { 13165, 14318, 14319, 14320, 14321, 14322, 25296, -- Aspect of the Hawk 1-7
                             27044, -- TBC: Aspect of the Hawk 8
                             61846, 61847 } -- WotLK: Aspect of the Dragonhawk 1-2
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.CLASS)
  buffDefModule:createAndRegisterBuff(buffs, 13163, --Aspect of the monkey
          { type = "aura", default = false
          })   :MaxLevel(74) -- Superceded by Aspect of the Dragonhawk
               :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.CLASS)
  buffDefModule:createAndRegisterBuff(buffs, 34074, -- TBC: Aspect of the Viper
          { type = "aura", default = false
          })   :RequirePlayerClass("HUNTER")
               :RequireTBC()
               :Category(allBuffsModule.CLASS)
  buffDefModule:createAndRegisterBuff(buffs, 20190, -- Aspect of the Wild
          { type         = "aura", default = false,
            singleFamily = { 20043, 20190, -- Aspect of the Wild 1-2
                             27045, -- TBC: Aspect of the Wild 3
                             49071 } -- WotLK: Aspect of the Wild 4
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.AURA)
  buffDefModule:createAndRegisterBuff(buffs, 5118, --Aspect of the Cheetah
          { type = "aura", default = false
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.CLASS)
  buffDefModule:createAndRegisterBuff(buffs, 13159, --Aspect of the Pack
          { type = "aura", default = false
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.AURA)
  buffDefModule:createAndRegisterBuff(buffs, 13161, -- Aspect of the Beast
          { type = "aura", default = false
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.CLASS)

  buffDefModule:createAndRegisterBuff(buffs, 1494, -- Track Beast
          { type = "tracking", default = false
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)
  buffDefModule:createAndRegisterBuff(buffs, 19878, -- Track Demon
          { type = "tracking", default = false
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)
  buffDefModule:createAndRegisterBuff(buffs, 19879, -- Track Dragonkin
          { type = "tracking", default = false
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)
  buffDefModule:createAndRegisterBuff(buffs, 19880, -- Track Elemental
          { type = "tracking", default = false
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)
  buffDefModule:createAndRegisterBuff(buffs, 19883, -- Track Humanoids
          { type = "tracking", default = false
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)
  buffDefModule:createAndRegisterBuff(buffs, 19882, -- Track Giants / riesen
          { type = "tracking", default = false
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)
  buffDefModule:createAndRegisterBuff(buffs, 19884, -- Track Undead
          { type = "tracking", default = false
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)
  buffDefModule:createAndRegisterBuff(buffs, 19885, -- Track Hidden / verborgenes
          { type = "tracking", default = false
          })   :RequirePlayerClass("HUNTER")
               :Category(allBuffsModule.TRACKING)
end

---@param buffs table<string, BomBuffDefinition>
---@param enchantments table<string, table<number>>
function hunterModule:_SetupPetBuffs(buffs, enchantments)
  -- TODO: Do not use tbc_consumable function, add new flags for pet-buff
  buffDefModule:genericConsumable(buffs, 65247, 33874)
               :RequireTBC()
               :HunterPetFood()
               :Category(allBuffsModule.PET)
  buffDefModule:genericConsumable(buffs, 33272, 27656)
               :RequireTBC()
               :HunterPetFood()
               :ExtraText(_t("tooltip.buff.petStrength"))
               :Category(allBuffsModule.PET)
  buffDefModule:genericConsumable(buffs, 43771, 43005)
               :RequireWotLK()
               :HunterPetFood()
               :ExtraText(_t("tooltip.buff.petStrength"))
               :Category(allBuffsModule.PET)
  --buffDefModule:genericConsumable(buffs, 43771, 43005) -- WotLK: Spiced Mammoth Treats +30 Str/30 Stam for pet
  --             :RequireWotLK()
  --             :HunterPetFood()
  --             :ExtraText(_t("tooltip.buff.petStrength"))
  --             :RequirePlayerClass("HUNTER")
  --             :Category(allBuffsModule.PET)
end
