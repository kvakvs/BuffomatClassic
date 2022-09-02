local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsDruidModule
local druidModule = BuffomatModule.New("AllSpellsDruid") ---@type BomAllSpellsDruidModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule
local spellIdsModule = BuffomatModule.Import("SpellIds") ---@type BomSpellIdsModule

---Add DRUID spells
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function druidModule:SetupDruidSpells(spells, enchants)
  buffDefModule:createAndRegisterBuff(spells, 9885, --Gift/Mark of the Wild | Gabe/Mal der Wildniss
          { groupId         = 21849, cancelForm = true, default = true,
            singleFamily    = { 1126, 5232, 6756, 5234, 8907, 9884, 9885, -- Mark of the Wild 1-7
                                26990, -- TBC: Mark of the Wild 8
                                48469 }, -- WotLK: Mark of the Wild 9
            groupFamily     = { 21849, 21850, -- Gift of the Wild 1-2
                                26991, -- TBC: Gift of the Wild 3
                                48470 }, -- WotLK: Gift of the Wild 4
            singleDuration  = allBuffsModule.DURATION_30M, groupDuration = allBuffsModule.DURATION_1H,
            reagentRequired = { 17021, 17026,
                                44605 }, -- WotLK: Wild Spineleaf
          })    :DefaultTargetClasses(allBuffsModule.BOM_ALL_CLASSES)
                :RequirePlayerClass("DRUID")
                :Category(allBuffsModule.CLASS)
  buffDefModule:createAndRegisterBuff(spells, 9910, --Thorns | Dornen
          { cancelForm     = false, default = false,
            singleFamily   = { 467, 782, 1075, 8914, 9756, 9910, -- Thorns 1-6
                               26992, -- TBC: Thorns 7
                               53307 }, -- WotLK: Thorns 8
            singleDuration = allBuffsModule.DURATION_10M,
          })    :DefaultTargetClasses(allBuffsModule.MELEE_CLASSES)
                :RequirePlayerClass("DRUID")
                :Category(allBuffsModule.CLASS)
  buffDefModule:createAndRegisterBuff(spells, 16864, --Omen of Clarity
          { isOwn = true, cancelForm = true, default = true
          })    :RequirePlayerClass("DRUID")
                :Category(allBuffsModule.CLASS)
  buffDefModule:createAndRegisterBuff(spells, 17329, -- Nature's Grasp | Griff der Natur
          { isOwn        = true, cancelForm = true, default = false,
            hasCD        = true, requiresOutdoors = true,
            singleFamily = { 16689, 16810, 16811, 16812, 16813, 17329, -- Nature's Grasp 1-6
                             27009, -- TBC: Nature's Grasp 7
                             53312 } -- WotLK: Nature's Grasp 8
          })    :RequirePlayerClass("DRUID")
                :Category(allBuffsModule.CLASS)
  buffDefModule:createAndRegisterBuff(spells, 33891, --TBC: Tree of life
          { isOwn = true, default = true, default = false, singleId = 33891, shapeshiftFormId = 2
          })    :RequirePlayerClass("DRUID")
                :RequireTBC() -- Requires TBC and up
                :Category(allBuffsModule.CLASS)

  -- Special code: This will disable herbalism and mining tracking in Cat Form
  buffDefModule:createAndRegisterBuff(spells, spellIdsModule.Druid_TrackHumanoids, -- Track Humanoids (Cat Form)
          { type      = "tracking", needForm = CAT_FORM, default = true,
            extraText = _t("SpellLabel_TrackHumanoids")
          })    :RequirePlayerClass("DRUID")
                :Category(self.TRACKING)

  buffDefModule:createAndRegisterBuff(spells, 50763, -- Revive (WotLK)
          { cancelForm   = true, type = "resurrection", default = true,
            singleFamily = { 50769, 50768, 50767, 50766, 50765, 50764, 50763 }, -- WotLK: Revive 1-7
          })    :RequireWotLK()
                :RequirePlayerClass("DRUID")
                :Category(allBuffsModule.CLASS)
end
