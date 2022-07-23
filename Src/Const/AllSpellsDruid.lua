local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsDruidModule
local druidModule = BuffomatModule.New("AllSpellsDruid") ---@type BomAllSpellsDruidModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allSpellsModule = BuffomatModule.Import("AllSpells") ---@type BomAllSpellsModule
local spellDefModule = BuffomatModule.Import("SpellDef") ---@type BomSpellDefModule

---Add DRUID spells
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function druidModule:SetupDruidSpells(spells, enchants)
  spellDefModule:createAndRegisterBuff(spells, 9885, --Gift/Mark of the Wild | Gabe/Mal der Wildniss
          { groupId         = 21849, cancelForm = true, default = true,
            singleFamily    = { 1126, 5232, 6756, 5234, 8907, 9884, 9885, -- Mark of the Wild 1-7
                                26990, -- TBC: Mark of the Wild 8
                                48469 }, -- WotLK: Mark of the Wild 9
            groupFamily     = { 21849, 21850, -- Gift of the Wild 1-2
                                26991, -- TBC: Gift of the Wild 3
                                48470 }, -- WotLK: Gift of the Wild 4
            singleDuration  = allSpellsModule.DURATION_30M, groupDuration = allSpellsModule.DURATION_1H,
            reagentRequired = { 17021, 17026,
                                44605 }, -- WotLK: Wild Spineleaf
          })    :DefaultTargetClasses(allSpellsModule.ALL_CLASSES)
                :ClassOnly("DRUID")
                :Category(allSpellsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 9910, --Thorns | Dornen
          { cancelForm     = false, default = false,
            singleFamily   = { 467, 782, 1075, 8914, 9756, 9910, -- Thorns 1-6
                               26992, -- TBC: Thorns 7
                               53307 }, -- WotLK: Thorns 8
            singleDuration = allSpellsModule.DURATION_10M,
          })    :DefaultTargetClasses(allSpellsModule.BOM_MELEE_CLASSES)
                :ClassOnly("DRUID")
                :Category(allSpellsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 16864, --Omen of Clarity
          { isOwn = true, cancelForm = true, default = true
          })    :ClassOnly("DRUID")
                :Category(allSpellsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 17329, -- Nature's Grasp | Griff der Natur
          { isOwn        = true, cancelForm = true, default = false,
            hasCD        = true, requiresOutdoors = true,
            singleFamily = { 16689, 16810, 16811, 16812, 16813, 17329, -- Nature's Grasp 1-6
                             27009, -- TBC: Nature's Grasp 7
                             53312 } -- WotLK: Nature's Grasp 8
          })    :ClassOnly("DRUID")
                :Category(allSpellsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 33891, --TBC: Tree of life
          { isOwn = true, default = true, default = false, singleId = 33891, shapeshiftFormId = 2
          })    :ClassOnly("DRUID")
                :ShowInTBC() -- Requires TBC and up
                :Category(allSpellsModule.CLASS)

  -- Special code: This will disable herbalism and mining tracking in Cat Form
  spellDefModule:createAndRegisterBuff(spells, BOM.SpellId.Druid.TrackHumanoids, -- Track Humanoids (Cat Form)
          { type      = "tracking", needForm = CAT_FORM, default = true,
            extraText = _t("SpellLabel_TrackHumanoids")
          })    :ClassOnly("DRUID")
                :Category(self.TRACKING)

  spellDefModule:createAndRegisterBuff(spells, 50763, -- Revive (WotLK)
          { cancelForm   = true, type = "resurrection", default = true,
            singleFamily = { 50769, 50768, 50767, 50766, 50765, 50764, 50763 }, -- WotLK: Revive 1-7
          })    :ShowInWotLK()
                :ClassOnly("DRUID")
                :Category(allSpellsModule.CLASS)
end
