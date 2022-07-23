local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsMageModule
local mageModule = BuffomatModule.New("AllSpellsMage") ---@type BomAllSpellsMageModule

local allSpellsModule = BuffomatModule.Import("AllSpells") ---@type BomAllSpellsModule
local spellDefModule = BuffomatModule.Import("SpellDef") ---@type BomSpellDefModule

---Add MAGE spells
---@param spells table<string, BomSpellDef>
---@param enchants table<string, table<number>>
function mageModule:SetupMageSpells(spells, enchants)
  BOM.SpellDef_ArcaneIntelligence = function()
    return spellDefModule:New(10157, --Arcane Intellect | Brilliance
            { singleFamily    = { 1459, 1460, 1461, 10156, 10157, -- Ranks 1-5
                                  27126 }, -- TBC: Rank 6
              groupFamily     = { 23028, -- Brilliance Rank 1
                                  27127, -- TBC: Brillance Rank 2
                                  61316 }, -- WotLK: Dalaran Brilliance Rank 3
              default         = true, singleDuration = allSpellsModule.DURATION_30M, groupDuration = allSpellsModule.DURATION_1H,
              reagentRequired = { 17020 }, targetClasses = allSpellsModule.BOM_MANA_CLASSES })
                         :ClassOnly("MAGE")
                         :IgnoreIfHaveBuff(46302) -- Kiru's Song of Victory (Sunwell)
                         :Category(self.CLASS)
  end
  tinsert(spells, BOM.SpellDef_ArcaneIntelligence())

  spellDefModule:createAndRegisterBuff(spells, 10174, --Dampen Magic
          { default      = false, singleDuration = allSpellsModule.DURATION_10M, targetClasses = { },
            singleFamily = { 604, 8450, 8451, 10173, 10174, -- Ranks 1-5
                             33944 } }) -- TBC: Rank 6
                :ClassOnly("MAGE")
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 10170, --Amplify Magic
          { default      = false, singleDuration = allSpellsModule.DURATION_10M, targetClasses = { },
            singleFamily = { 1008, 8455, 10169, 10170, -- Ranks 1-4
                             27130, 33946 } }) -- TBC: Ranks 5-6
                :ClassOnly("MAGE")
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 10220, -- Ice Armor / eisrüstung
          { type         = "seal", default = false,
            singleFamily = { 7302, 7320, 10219, 10220, -- Ranks 1-4, levels 30 40 50 60
                             27124 } }) -- TBC: Rank 5, level 69
                :ClassOnly("MAGE")
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 7301, -- Frost Armor / frostrüstung
          { type         = "seal", default = false,
            singleFamily = { 168, 7300, 7301 } }) -- Ranks 1-3, Levels 1, 10, 20
                :ClassOnly("MAGE")
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 30482, -- TBC: Molten Armor
          { type = "seal", default = false, singleFamily = { 30482 } }) -- TBC: Rank 1
                :ClassOnly("MAGE")
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 22783, -- Mage Armor / magische rüstung
          { type         = "seal", default = false,
            singleFamily = { 6117, 22782, 22783, -- Ranks 1-3
                             27125 } }) -- TBC: Rank 4
                :ClassOnly("MAGE")
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 10193, --Mana Shield | Manaschild - unabhängig von allen.
          { isOwn        = true, default = false, singleDuration = 60,
            singleFamily = { 1463, 8494, 8495, 10191, 10192, 10193, -- Ranks 1-6
                             27131 } }) -- TBC: Rank 7
                :ClassOnly("MAGE")
                :Category(self.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 13033, --Ice Barrier
          { isOwn        = true, default = false, singleDuration = 60,
            singleFamily = { 11426, 13031, 13032, 13033, -- Ranks 1-4
                             27134, 33405 } }) -- TBC: Ranks 5-6
                :Category(self.CLASS)

  local playerLevel = UnitLevel("player")

  if playerLevel >= 77 then
    -- TODO: Wotlk Mana gem is unique
    BOM.Dbg("TODO: Wotlk mana gem")
  elseif playerLevel >= 58 then
    -- Conjure separate mana gems of 3 kinds
    tinsert(spells,
            spellDefModule:conjureItem(BOM.SpellId.Mage.ConjureManaEmerald, BOM.ItemId.Mage.ManaEmerald)
                          :ClassOnly("MAGE")
                          :Category(self.CLASS)
    )
    tinsert(spells,
            spellDefModule:conjureItem(BOM.SpellId.Mage.ConjureManaRuby, BOM.ItemId.Mage.ManaRuby)
                          :ClassOnly("MAGE")
                          :Category(self.CLASS)
    )
    if playerLevel > 68 then
      -- Players > 68 will not be interested in Citrine
      tinsert(spells,
              spellDefModule:conjureItem(BOM.SpellId.Mage.ConjureManaCitrine, BOM.ItemId.Mage.ManaCitrine)
                            :ClassOnly("MAGE")
                            :Category(self.CLASS)
      )
    end
  else
    -- For < 58 - Have generic conjuration of 1 gem (only max rank)
    spellDefModule:createAndRegisterBuff(spells, BOM.SpellId.Mage.ConjureManaEmerald, -- Conjure Mana Stone (Max Rank)
            { isOwn          = true, default = true,
              lockIfHaveItem = { BOM.ItemId.Mage.ManaAgate,
                                 BOM.ItemId.Mage.ManaJade,
                                 BOM.ItemId.Mage.ManaCitrine,
                                 BOM.ItemId.Mage.ManaRuby,
                                 BOM.ItemId.Mage.ManaEmerald },
              singleFamily   = { BOM.SpellId.Mage.ConjureManaAgate,
                                 BOM.SpellId.Mage.ConjureManaJade,
                                 BOM.SpellId.Mage.ConjureManaCitrine,
                                 BOM.SpellId.Mage.ConjureManaRuby,
                                 BOM.SpellId.Mage.ConjureManaEmerald } })
                  :ClassOnly("MAGE")
                  :Category(self.CLASS)
  end
end
