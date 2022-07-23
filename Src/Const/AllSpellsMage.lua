local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsMageModule
local mageModule = BuffomatModule.New("AllSpellsMage") ---@type BomAllSpellsMageModule

local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local spellDefModule = BuffomatModule.Import("SpellDef") ---@type BomSpellDefModule

---Add MAGE spells
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function mageModule:SetupMageSpells(spells, enchants)
  BOM.SpellDef_ArcaneIntelligence = function()
    return spellDefModule:New(10157, --Arcane Intellect | Brilliance
            { singleFamily    = { 1459, 1460, 1461, 10156, 10157, -- Ranks 1-5
                                  27126, -- TBC: Rank 6
                                  42995, 61024 }, -- WotLK: Arcane Intellect 7; Dalaran Intellect
              groupFamily     = { 23028, -- Brilliance Rank 1
                                  27127, -- TBC: Brillance Rank 2
                                  61316 }, -- WotLK: Dalaran Brilliance Rank 3
              default         = true, singleDuration = allBuffsModule.DURATION_30M, groupDuration = allBuffsModule.DURATION_1H,
              reagentRequired = { 17020 } })
                         :DefaultTargetClasses(allBuffsModule.BOM_MANA_CLASSES)
                         :ClassOnly("MAGE")
                         :IgnoreIfHaveBuff(46302) -- Kiru's Song of Victory (Sunwell)
                         :Category(allBuffsModule.CLASS)
  end
  tinsert(spells, BOM.SpellDef_ArcaneIntelligence())

  spellDefModule:createAndRegisterBuff(spells, 10174, --Dampen Magic
          { default      = false, singleDuration = allBuffsModule.DURATION_10M,
            singleFamily = { 604, 8450, 8451, 10173, 10174, -- Ranks 1-5
                             33944, -- TBC: Rank 6
                             43015 } }) -- WotLK: Dampen Magic 7
                :DefaultTargetClasses(allBuffsModule.BOM_NO_CLASSES)
                :ClassOnly("MAGE")
                :Category(allBuffsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 10170, --Amplify Magic
          { default      = false, singleDuration = allBuffsModule.DURATION_10M,
            singleFamily = { 1008, 8455, 10169, 10170, -- Ranks 1-4
                             27130, 33946, -- TBC: Ranks 5-6
                             43017 } }) -- WotLK: Amplify Magic 7
                :DefaultTargetClasses(allBuffsModule.BOM_NO_CLASSES)
                :ClassOnly("MAGE")
                :Category(allBuffsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 10220, -- Ice Armor / eisrüstung
          { type         = "seal", default = false,
            singleFamily = { 168, 7300, 7301, -- Frost Armor 1-3
                             7302, 7320, 10219, 10220, -- Ice Armor 1-4
                             27124, -- TBC: Ice Armor 5
                             43008 } }) -- WotLK: Ice Armor 6
                :ClassOnly("MAGE")
                :Category(allBuffsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 11426, -- Ice Barrier
          { type         = "seal", default = false, singleDuration = 60,
            singleFamily = { 11426, 13031, 13032, 13033, -- Ice Barrier 1-4
                             27134, 33405, -- TBC: Ice Barrier 5, 6
                             43038, 43039 } }) -- WotLK: Ice Barrier 7
                :ClassOnly("MAGE")
                :Category(allBuffsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 30482, -- TBC: Molten Armor
          { type         = "seal", default = false,
            singleFamily = { 30482, -- TBC: Molten Armor 1
                             43045, 43046 } }) -- WotLK: Molten Armor 2, 3
                :ClassOnly("MAGE")
                :Category(allBuffsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 22783, -- Mage Armor / magische rüstung
          { type         = "seal", default = false,
            singleFamily = { 6117, 22782, 22783, -- Mage Armor 1-3
                             27125, -- TBC: Mage Armor 4
                             43023, 43024 } }) -- WotLK: Mage Armor 5, 6
                :ClassOnly("MAGE")
                :Category(allBuffsModule.CLASS)
  spellDefModule:createAndRegisterBuff(spells, 10193, --Mana Shield | Manaschild - unabhängig von allen.
          { isOwn        = true, default = false, singleDuration = 60,
            singleFamily = { 1463, 8494, 8495, 10191, 10192, 10193, -- Mana Shield 1-6
                             27131, -- TBC: Mana Shield 7
                             43019, 43020 } }) -- WotLK: Mana Shield 8, 9
                :ClassOnly("MAGE")
                :Category(allBuffsModule.CLASS)

  local playerLevel = UnitLevel("player")

  if playerLevel >= 58 and playerLevel < 77 then
    -- Conjure separate mana gems of 3 kinds
    -- For WotLK only 1 mana gem can be owned
    tinsert(spells,
            spellDefModule:conjureItem(BOM.SpellId.Mage.ConjureManaEmerald, BOM.ItemId.Mage.ManaEmerald)
                          :ClassOnly("MAGE")
                          :Category(allBuffsModule.CLASS)
    )
    tinsert(spells,
            spellDefModule:conjureItem(BOM.SpellId.Mage.ConjureManaRuby, BOM.ItemId.Mage.ManaRuby)
                          :ClassOnly("MAGE")
                          :Category(allBuffsModule.CLASS)
    )
    if playerLevel <= 68 then
      -- Players > 68 will not be interested in Citrine
      tinsert(spells,
              spellDefModule:conjureItem(BOM.SpellId.Mage.ConjureManaCitrine, BOM.ItemId.Mage.ManaCitrine)
                            :ClassOnly("MAGE")
                            :Category(allBuffsModule.CLASS)
      )
    end
  else
    -- For < 58 - Have generic conjuration of 1 gem (only max rank)
    spellDefModule:createAndRegisterBuff(spells, BOM.SpellId.Mage.ConjureManaEmerald, -- Conjure Mana Stone (Max Rank)
            { isOwn          = true, default = true,
              lockIfHaveItem = { BOM.ItemId.Mage.ManaSapphire,
                                 BOM.ItemId.Mage.ManaAgate,
                                 BOM.ItemId.Mage.ManaJade,
                                 BOM.ItemId.Mage.ManaCitrine,
                                 BOM.ItemId.Mage.ManaRuby,
                                 BOM.ItemId.Mage.ManaEmerald },
              singleFamily   = { BOM.SpellId.Mage.ConjureManaAgate,
                                 BOM.SpellId.Mage.ConjureManaJade,
                                 BOM.SpellId.Mage.ConjureManaCitrine,
                                 BOM.SpellId.Mage.ConjureManaRuby,
                                 BOM.SpellId.Mage.ConjureManaEmerald,
                                 BOM.SpellId.Mage.ConjureManaSapphire, } })
                  :ClassOnly("MAGE")
                  :Category(allBuffsModule.CLASS)
  end
end
