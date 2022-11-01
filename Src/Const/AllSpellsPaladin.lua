local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllSpellsPaladinModule
local paladinModule = {}
BomModuleManager.allSpellsPaladinModule = paladinModule

local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffDefModule = BomModuleManager.buffDefinitionModule
local spellIdsModule = BomModuleManager.spellIdsModule

---Add PALADIN spells
---@param spells table<string, BomBuffDefinition>
---@param enchants table<string, table<number>>
function paladinModule:SetupPaladinSpells(spells, enchants)
  buffDefModule:createAndRegisterBuff(spells, 25780, --Righteous Fury, same in TBC
          { isOwn = true, default = false })
                :Category(allBuffsModule.CLASS)

  local blessing_duration = allBuffsModule.TbcOrClassic(allBuffsModule.DURATION_10M, allBuffsModule.DURATION_5M)
  local greaterBlessingDuration = allBuffsModule.TbcOrClassic(allBuffsModule.DURATION_15M, allBuffsModule.DURATION_30M)

  --
  -- LESSER BLESSINGS

  buffDefModule:createAndRegisterBuff(spells, 20217, -- Blessing of Kings
          { groupFamily    = { 25898 }, isBlessing = true, default = false,
            singleDuration = blessing_duration,
            targetClasses  = { "MAGE", "HUNTER", "WARLOCK" }
          })    :RequirePlayerClass("PALADIN")
                :IgnoreIfHaveBuff(25898) -- Greater Kings
                :Category(allBuffsModule.BLESSING)

  buffDefModule:createAndRegisterBuff(spells, 19979, -- Blessing of Light (classic and TBC only)
          { singleFamily   = { 19977, 19978, 19979, -- Ranks 1-3
                               27144 }, -- TBC: Rank 4
            isBlessing     = true, default = false,
            singleDuration = blessing_duration, groupDuration = greaterBlessingDuration
          })    :RequirePlayerClass("PALADIN")
                :HideInWotLK()
                :DefaultTargetClasses(allBuffsModule.BOM_NO_CLASSES)
                :IgnoreIfHaveBuff(21177) -- Greater Light
                :Category(allBuffsModule.BLESSING)

  buffDefModule:createAndRegisterBuff(spells, 25291, -- Blessing of Might
          { isBlessing     = true, default = true,
            singleFamily   = { 19740, 19834, 19835, 19836, 19837, 19838, 25291, -- Blessing of Might 1-7
                               27140, -- TBC: Blessing of Might 8
                               48931, 48932 }, -- WotLK: Blessing of Might 9-10
            singleDuration = blessing_duration
          })    :RequirePlayerClass("PALADIN")
                :DefaultTargetClasses(allBuffsModule.PHYSICAL_CLASSES)
                :IgnoreIfHaveBuff({ 25782, 25916, 27141 }) -- Greater Might 1-3
                :IgnoreIfHaveBuff({ 48933, 48934 }) -- WotLK: Greater Might 4-5
                :Category(allBuffsModule.BLESSING)

  buffDefModule:createAndRegisterBuff(spells, 1038, -- Blessing of Salvation (classic and TBC only)
          { isBlessing = true, default = false, singleDuration = blessing_duration,
          })    :RequirePlayerClass("PALADIN")
                :HideInWotLK()
                :DefaultTargetClasses(allBuffsModule.BOM_NO_CLASSES)
                :IgnoreIfHaveBuff(25895) -- Greater Salv
                :Category(allBuffsModule.BLESSING)

  buffDefModule:createAndRegisterBuff(spells, 25290, -- Blessing of Wisdom
          { isBlessing     = true, default = false,
            singleFamily   = { 19742, 19850, 19852, 19853, 19854, 25290, -- Blessing of Wisdom 1-6
                               27142, -- TBC: Blessing of Wisdom 7
                               48935, 48936 }, -- WotLK: Blessing of Wisdom 8-9
            singleDuration = blessing_duration, groupDuration = greaterBlessingDuration,
          })    :RequirePlayerClass("PALADIN")
                :DefaultTargetClasses(allBuffsModule.MANA_CLASSES)
                :Category(allBuffsModule.BLESSING)

  buffDefModule:createAndRegisterBuff(spells, 20914, -- Blessing of Sanctuary
          { isBlessing     = true, default = false,
            singleFamily   = { 20911, 20912, 20913, 20914, -- Blessing of Sanctuary 1-4; WotLK: Blessing of Sanctuary
                               27168 }, -- TBC: Blessing of Sanctuary 5
            singleDuration = blessing_duration, groupDuration = greaterBlessingDuration,
          })    :RequirePlayerClass("PALADIN")
                :DefaultTargetClasses(allBuffsModule.BOM_NO_CLASSES)
                :Category(allBuffsModule.BLESSING)
  --
  -- GREATER BLESSINGS
  --
  buffDefModule:createAndRegisterBuff(spells, 25898, -- Greater Blessing of Kings
          { isBlessing      = true, default = false, singleDuration = greaterBlessingDuration,
            reagentRequired = { BOM.ItemId.Paladin.SymbolOfKings },
          })    :RequirePlayerClass("PALADIN")
                :DefaultTargetClasses(allBuffsModule.BOM_NO_CLASSES)
                :Category(allBuffsModule.BLESSING)

  buffDefModule:createAndRegisterBuff(spells, 25890, -- Greater Blessing of Light
          { singleFamily    = { 25890, -- Greater Rank 1
                                27145 }, -- TBC: Greater Rank 2
            isBlessing      = true, default = false,
            reagentRequired = { BOM.ItemId.Paladin.SymbolOfKings }, singleDuration = greaterBlessingDuration,
          })    :RequirePlayerClass("PALADIN")
                :DefaultTargetClasses(allBuffsModule.BOM_NO_CLASSES)
                :Category(allBuffsModule.BLESSING)

  buffDefModule:createAndRegisterBuff(spells, 25916, --Greater Blessing of Might
          { isBlessing      = true, default = false,
            singleFamily    = { 25782, 25916, -- Greater Blessing of Might 1-2
                                27141, -- TBC: Greater Blessing of Might 3
                                48933, 48934 }, -- WotLK: Greater Blessing of Might 4-5
            singleDuration  = greaterBlessingDuration,
            reagentRequired = { BOM.ItemId.Paladin.SymbolOfKings }
          })    :RequirePlayerClass("PALADIN")
                :DefaultTargetClasses(allBuffsModule.PHYSICAL_CLASSES)
                :Category(allBuffsModule.BLESSING)

  buffDefModule:createAndRegisterBuff(spells, 25895, --Greater Blessing of Salvation
          { singleFamily    = { 25895 }, isBlessing = true, default = false,
            singleDuration  = greaterBlessingDuration,
            reagentRequired = { BOM.ItemId.Paladin.SymbolOfKings }
          })    :RequirePlayerClass("PALADIN")
                :DefaultTargetClasses(allBuffsModule.BOM_NO_CLASSES)
                :Category(allBuffsModule.BLESSING)

  buffDefModule:createAndRegisterBuff(spells, 25918, --Greater Blessing of Wisdom
          { isBlessing      = true, default = false,
            singleFamily    = { 25894, 25918, -- Greater Blessing of Wisdom 1-2
                                27143, -- TBC: Greater Blessing of Wisdom 3
                                48937, 48938 }, -- WotLK: Greater Blessing of Wisdom 4-5
            singleDuration  = greaterBlessingDuration,
            reagentRequired = { BOM.ItemId.Paladin.SymbolOfKings }
          })    :RequirePlayerClass("PALADIN")
                :DefaultTargetClasses(allBuffsModule.MANA_CLASSES)
                :Category(allBuffsModule.BLESSING)

  buffDefModule:createAndRegisterBuff(spells, 25899, --Greater Blessing of Sanctuary
          { isBlessing      = true, default = false,
            singleFamily    = { 25899, -- Greater Rank 1
                                27169 }, -- TBC: Greater Rank 2
            singleDuration  = greaterBlessingDuration,
            reagentRequired = { BOM.ItemId.Paladin.SymbolOfKings },
          })    :RequirePlayerClass("PALADIN")
                :DefaultTargetClasses(allBuffsModule.BOM_NO_CLASSES)
                :Category(allBuffsModule.BLESSING)

  -- END blessings ------
  --
  -- ----------------------------------
  --
  buffDefModule:createAndRegisterBuff(spells, 10293, -- Devotion Aura
          { type         = "aura", default = false,
            singleFamily = { 465, 10290, 643, 10291, 1032, 10292, 10293, -- Devotion Aura 1-7
                             27149, -- TBC: Devotion Aura 8
                             48941, 48942 }, -- WotLK: Devotion Aura 9-10
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.AURA)
  buffDefModule:createAndRegisterBuff(spells, 10301, -- Retribution Aura
          { type         = "aura", default = true,
            singleFamily = { 7294, 10298, 10299, 10300, 10301, -- Retribution Aura 1-5
                             27150, -- TBC: Retribution Aura 6
                             54043 } -- WotLK: Retribution Aura 7
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.AURA)
  buffDefModule:createAndRegisterBuff(spells, 19746, --Concentration Aura
          { type = "aura", default = false
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.AURA)
  buffDefModule:createAndRegisterBuff(spells, 19896, -- Shadow Resistance Aura
          { type         = "aura", default = false,
            singleFamily = { 19876, 19895, 19896, -- Shadow Resistance Aura 1-3
                             27151, -- TBC: Shadow Resistance Aura 4
                             48943 } -- WotLK: Shadow Resistance Aura 5
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.AURA)
  buffDefModule:createAndRegisterBuff(spells, 19898, -- Frost Resistance Aura
          { type         = "aura", default = false,
            singleFamily = { 19888, 19897, 19898, -- Frost Resistance Aura 1-3
                             27152, -- TBC: Frost Resistance Aura 4
                             48945 } -- WotLK: Frost Resistance Aura 5
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.AURA)
  buffDefModule:createAndRegisterBuff(spells, 19900, -- Fire Resistance Aura
          { type         = "aura", default = false,
            singleFamily = { 19891, 19899, 19900, -- Fire Resistance Aura 1-3
                             27153, -- TBC: Fire Resistance Aura 4
                             48947 } -- WotLK: Fire Resistance Aura 5
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.AURA)
  buffDefModule:createAndRegisterBuff(spells, 20218, --Sanctity Aura (classic and TBC only)
          { type = "aura", default = false
          })    :RequirePlayerClass("PALADIN")
                :HideInWotLK()
                :Category(allBuffsModule.AURA)

  BOM.CrusaderAuraSpell = buffDefModule:createAndRegisterBuff(
          spells, spellIdsModule.Paladin_CrusaderAura, --TBC: Crusader Aura
          { type       = "aura", default = false, extraText = _t("CRUSADER_AURA_COMMENT"),
            singleMana = 0
          })                            :RequirePlayerClass("PALADIN")
                                        :Category(allBuffsModule.AURA)

  --
  -- ----------------------------------
  --
  buffDefModule:createAndRegisterBuff(spells, 20773, -- Redemption / Auferstehung
          { type         = "resurrection", default = true,
            singleFamily = { 7328, 10322, 10324, 20772, 20773, -- Classic: Redemption 1-5
                             48949, 48950 }, -- WotLK: Redemption 6-7
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.CLASS)

  buffDefModule:createAndRegisterBuff(spells, 20164, -- Sanctity Seal (classic and TBC only)
          { type = "seal", default = false
          })    :RequirePlayerClass("PALADIN")
                :HideInTBC()
                :Category(allBuffsModule.SEAL) -- classic only

  buffDefModule:createAndRegisterBuff(spells, 5502, -- Sense undead
          { type = "tracking", default = false
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.TRACKING)

  buffDefModule:createAndRegisterBuff(spells, 20165, -- Seal of Light
          { type         = "seal", default = false,
            singleFamily = { 20165, 20347, 20348, 20349, -- Seal of Light 1-4; also WotLK: Seal of Light
                             27160 }  -- TBC: Seal of Light 5
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.SEAL)
  buffDefModule:createAndRegisterBuff(spells, 20154, -- Seal of Righteousness
          { type         = "seal", default = false,
            singleFamily = { 20154, 20287, 20288, 20289, 20290, 20291, 20292, 20293, -- Seal of Righteousness 1-8
                             27155, -- TBC: Seal of Righteousness 9
                             21084 } -- WotLK: Seal of Righteousness
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.SEAL)
  buffDefModule:createAndRegisterBuff(spells, 20166, -- Seal of Wisdom
          { type = "seal", default = false
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.SEAL)
  buffDefModule:createAndRegisterBuff(spells, 348704, -- TBC: Seal of Vengeance
          { type         = "seal", default = false,
            singleFamily = { 31801, -- TBC: level 70 spell for Blood Elf
                             348704 }  -- TBC: Base spell for the alliance races
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.SEAL)
  buffDefModule:createAndRegisterBuff(spells, 348700, -- TBC: Seal of the Martyr (Draenei, Dwarf, Human)
          { type = "seal", default = false
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.SEAL)
  buffDefModule:createAndRegisterBuff(spells, 31892, -- TBC: Seal of Blood
          { type         = "seal", default = false,
            singleFamily = { 31892, -- TBC: Base Blood Elf spell
                             38008 }  -- TBC: Alliance version???
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.SEAL)
  buffDefModule:createAndRegisterBuff(spells, 20375, -- TBC/WotLK: Seal of Command
          { type         = "seal", default = false,
            singleFamily = { 20375 }
          })    :RequirePlayerClass("PALADIN")
                :Category(allBuffsModule.SEAL)
end
