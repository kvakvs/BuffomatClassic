local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsMageModule
local mageModule = {}
BomModuleManager.allSpellsMageModule = mageModule

local spellIdsModule = BomModuleManager.spellIdsModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffDefModule = BomModuleManager.buffDefinitionModule
local itemIdsModule = BomModuleManager.itemIdsModule

function mageModule:CreateIntelligenceBuff()
  return buffDefModule:New(10157) --Arcane Intellect | Brilliance
                      :SingleFamily({ 1459, 1460, 1461, 10156, 10157, -- Ranks 1-5
                                      27126, -- TBC: Rank 6
                                      42995, 61024 }) -- WotLK: Arcane Intellect 7; Dalaran Intellect
                      :GroupFamily({ 23028, -- Brilliance Rank 1
                                     27127, -- TBC: Brillance Rank 2
                                     43002, 61316 }) -- WotLK: Arcane Brilliance Rank 3; Dalaran Brilliance
                      :IsDefault(true)
                      :SingleDuration(allBuffsModule.DURATION_30M)
                      :GroupDuration(allBuffsModule.DURATION_1H)
                      :ReagentRequired({ 17020 }) -- Arcane Powder
                      :DefaultTargetClasses(allBuffsModule.MANA_CLASSES)
                      :RequirePlayerClass("MAGE")
                      :IgnoreIfHaveBuff(46302) -- Kiru's Song of Victory (Sunwell)
                      :IgnoreIfHaveBuff(54424) -- Fel Intelligence 1 (Wotlk Warlock)
                      :IgnoreIfHaveBuff(57564) -- Fel Intelligence 2 (Wotlk Warlock)
                      :IgnoreIfHaveBuff(57565) -- Fel Intelligence 3 (Wotlk Warlock)
                      :IgnoreIfHaveBuff(57566) -- Fel Intelligence 4 (Wotlk Warlock)
                      :IgnoreIfHaveBuff(57567) -- Fel Intelligence 5 (Wotlk Warlock)
                      :Category(allBuffsModule.CLASS)
end

---Add MAGE spells
---@param allBuffs BomBuffDefinition[]
---@param enchantments BomEnchantmentsMapping
function mageModule:SetupMageSpells(allBuffs, enchantments)
  tinsert(allBuffs, self:CreateIntelligenceBuff())

  --Dampen Magic
  buffDefModule:createAndRegisterBuff(allBuffs, 10174, nil)
               :IsDefault(false)
               :SingleDuration(allBuffsModule.DURATION_10M)
               :SingleFamily({ 604, 8450, 8451, 10173, 10174, -- Ranks 1-5
                               33944, -- TBC: Rank 6
                               43015 }) -- WotLK: Dampen Magic 7
               :DefaultTargetClasses(allBuffsModule.BOM_NO_CLASSES)
               :RequirePlayerClass("MAGE")
               :Category(allBuffsModule.CLASS)
  --Amplify Magic
  buffDefModule:createAndRegisterBuff(allBuffs, 10170, nil)
               :IsDefault(false)
               :SingleDuration(allBuffsModule.DURATION_10M)
               :SingleFamily({ 1008, 8455, 10169, 10170, -- Ranks 1-4
                               27130, 33946, -- TBC: Ranks 5-6
                               43017 }) -- WotLK: Amplify Magic 7
               :DefaultTargetClasses(allBuffsModule.BOM_NO_CLASSES)
               :RequirePlayerClass("MAGE")
               :Category(allBuffsModule.CLASS)
  -- Ice Armor / eisrüstung
  buffDefModule:createAndRegisterBuff(allBuffs, 10220, nil)
               :BuffType("seal")
               :IsDefault(false)
               :SingleFamily({ 168, 7300, 7301, -- Frost Armor 1-3
                               7302, 7320, 10219, 10220, -- Ice Armor 1-4
                               27124, -- TBC: Ice Armor 5
                               43008 }) -- WotLK: Ice Armor 6
               :RequirePlayerClass("MAGE")
               :Category(allBuffsModule.CLASS)
  -- Ice Barrier
  buffDefModule:createAndRegisterBuff(allBuffs, 11426, nil)
               :BuffType("seal")
               :IsDefault(false)
               :SingleDuration(allBuffsModule.DURATION_1M)
               :SingleFamily({ 11426, 13031, 13032, 13033, -- Ice Barrier 1-4
                               27134, 33405, -- TBC: Ice Barrier 5, 6
                               43038, 43039 }) -- WotLK: Ice Barrier 7
               :RequirePlayerClass("MAGE")
               :Category(allBuffsModule.CLASS)
  -- TBC: Molten Armor
  buffDefModule:createAndRegisterBuff(allBuffs, 30482, nil)
               :BuffType("seal")
               :IsDefault(false)
               :SingleFamily({ 30482, -- TBC: Molten Armor 1
                               43045, 43046 }) -- WotLK: Molten Armor 2, 3
               :RequirePlayerClass("MAGE")
               :Category(allBuffsModule.CLASS)
  -- Mage Armor / magische rüstung
  buffDefModule:createAndRegisterBuff(allBuffs, 22783, nil)
               :BuffType("seal")
               :IsDefault(false)
               :SingleFamily({ 6117, 22782, 22783, -- Mage Armor 1-3
                               27125, -- TBC: Mage Armor 4
                               43023, 43024 }) -- WotLK: Mage Armor 5, 6
               :RequirePlayerClass("MAGE")
               :Category(allBuffsModule.CLASS)
  --Mana Shield | Manaschild - unabhängig von allen.
  buffDefModule:createAndRegisterBuff(allBuffs, 10193, nil)
               :IsOwn(true)
               :IsDefault(false)
               :SingleDuration(allBuffsModule.DURATION_1M)
               :SingleFamily({ 1463, 8494, 8495, 10191, 10192, 10193, -- Mana Shield 1-6
                               27131, -- TBC: Mana Shield 7
                               43019, 43020 }) -- WotLK: Mana Shield 8, 9
               :RequirePlayerClass("MAGE")
               :Category(allBuffsModule.CLASS)

  local playerLevel = UnitLevel("player")

  if playerLevel >= 58 and playerLevel < 77 then
    -- Conjure separate mana gems of 3 kinds
    -- For WotLK only 1 mana gem can be owned
    tinsert(allBuffs,
            buffDefModule:conjureItem(spellIdsModule.Mage_ConjureManaEmerald, itemIdsModule.Mage_ManaEmerald)
                         :RequirePlayerClass("MAGE")
                         :Category(allBuffsModule.CLASS)
    )
    tinsert(allBuffs,
            buffDefModule:conjureItem(spellIdsModule.Mage_ConjureManaRuby, itemIdsModule.Mage_ManaRuby)
                         :RequirePlayerClass("MAGE")
                         :Category(allBuffsModule.CLASS)
    )
    if playerLevel <= 68 then
      -- Players > 68 will not be interested in Citrine
      tinsert(allBuffs,
              buffDefModule:conjureItem(spellIdsModule.Mage_ConjureManaCitrine, itemIdsModule.Mage_ManaCitrine)
                           :RequirePlayerClass("MAGE")
                           :Category(allBuffsModule.CLASS)
      )
    end
  else
    -- For < 58 - Have generic conjuration of 1 gem (only max rank)
    -- Conjure Mana Stone (Max Rank)
    buffDefModule:createAndRegisterBuff(allBuffs, spellIdsModule.Mage_ConjureManaEmerald, nil)
                 :IsOwn(true)
                 :IsDefault(true)
                 :LockIfHaveItem({ itemIdsModule.Mage_ManaSapphire,
                                   itemIdsModule.Mage_ManaAgate,
                                   itemIdsModule.Mage_ManaJade,
                                   itemIdsModule.Mage_ManaCitrine,
                                   itemIdsModule.Mage_ManaRuby,
                                   itemIdsModule.Mage_ManaEmerald })
                 :SingleFamily({ spellIdsModule.Mage_ConjureManaAgate,
                                 spellIdsModule.Mage_ConjureManaJade,
                                 spellIdsModule.Mage_ConjureManaCitrine,
                                 spellIdsModule.Mage_ConjureManaRuby,
                                 spellIdsModule.Mage_ConjureManaEmerald,
                                 spellIdsModule.Mage_ConjureManaSapphire })
                 :RequirePlayerClass("MAGE")
                 :Category(allBuffsModule.CLASS)
  end
end
