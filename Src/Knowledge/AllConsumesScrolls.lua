local BOM = BuffomatAddon ---@type BomAddon

---@shape BomAllConsumesScrollsModule
local scrollsModule = BomModuleManager.allConsumesScrollsModule ---@type BomAllConsumesScrollsModule

local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffDefModule = BomModuleManager.buffDefinitionModule

---SCROLLS
---@param allBuffs BomBuffDefinition[] A list of buffs (not dictionary)
---@param enchantments table<number, number[]> Key is spell id, value is list of enchantment ids
function scrollsModule:SetupScrolls(allBuffs, enchantments)
  self:_SetupScrollsAgility(allBuffs, enchantments)
  self:_SetupScrollsStrength(allBuffs, enchantments)
  self:_SetupScrollsProtection(allBuffs, enchantments)
  self:_SetupScrollsSpirit(allBuffs, enchantments)
  self:_SetupScrollsIntellect(allBuffs, enchantments)
  self:_SetupInscriptionScrolls(allBuffs, enchantments)
end

function scrollsModule:AddScroll(buffs, buffSpellId, itemId)
  return buffDefModule:genericConsumable(buffs, buffSpellId, itemId)
                      :ConsumableTarget("player")
                      :SingleDuration(allBuffsModule.HALF_AN_HOUR)
                      :Category("scroll")
end

---@param allBuffs BomBuffDefinition[] A list of buffs (not dictionary)
---@param enchantments table<number, number[]> Key is spell id, value is list of enchantment ids
function scrollsModule:_SetupScrollsAgility(allBuffs, enchantments)
  --
  -- WotLK
  --
  self:AddScroll(allBuffs, 58451, 43464) -- WotLK: Scroll of Agility 8
      :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
      :RequireWotLK()
  self:AddScroll(allBuffs, 58450, 43463) -- WotLK: Scroll of Agility 7
      :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
      :RequireWotLK()
  self:AddScroll(allBuffs, 43194, 33457) -- WotLK: Scroll of Agility 6
      :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
      :RequireWotLK()

  --
  -- TBC
  --
  self:AddScroll(allBuffs, 33077, 27498) -- TBC: Scroll of Agility 5
      :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
      :RequireTBC()

  --
  -- Classic
  --
  self:AddScroll(allBuffs, 12174, 10309) -- Scroll of Agility 4
      :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
  self:AddScroll(allBuffs, 8117, 4425) -- Scroll of Agility 3
      :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
end

---@param allBuffs BomBuffDefinition[] A list of buffs (not dictionary)
---@param enchantments table<number, number[]> Key is spell id, value is list of enchantment ids
function scrollsModule:_SetupScrollsStrength(allBuffs, enchantments)
  --
  -- WotLK
  --
  self:AddScroll(allBuffs, 58449, 43466) -- WotLK: Scroll of Strength 8
      :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
      :RequireWotLK()
  self:AddScroll(allBuffs, 58448, 43465) -- WotLK: Scroll of Strength 7
      :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
      :RequireWotLK()
  self:AddScroll(allBuffs, 43199, 33462) -- WotLK: Scroll of Strength 6
      :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
      :RequireWotLK()

  --
  -- TBC
  --
  self:AddScroll(allBuffs, 33082, 27503) -- TBC: Scroll of Strength 5
      :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
      :RequireTBC()

  --
  -- Classic
  --
  self:AddScroll(allBuffs, 12179, 10310) -- Scroll of Strength 4
      :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
  self:AddScroll(allBuffs, 8120, 4426) -- Scroll of Strength 3
      :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
end

---@param allBuffs BomBuffDefinition[] A list of buffs (not dictionary)
---@param enchantments table<number, number[]> Key is spell id, value is list of enchantment ids
function scrollsModule:_SetupScrollsProtection(allBuffs, enchantments)
  --
  -- WotLK
  --
  self:AddScroll(allBuffs, 58453, 43468) -- WotLK: Scroll of Protection 8
      :RequireWotLK()
  self:AddScroll(allBuffs, 58452, 43467) -- WotLK: Scroll of Protection 7
      :RequireWotLK()
  self:AddScroll(allBuffs, 43196, 33459) -- WotLK: Scroll of Protection 6
      :RequireWotLK()

  --
  -- TBC
  --
  self:AddScroll(allBuffs, 33079, 27500) -- TBC: Scroll of Protection 5
      :RequireTBC()
  --
  -- Classic
  --
  self:AddScroll(allBuffs, 12175, 10305) -- Scroll of Protection 4
end

---@param allBuffs BomBuffDefinition[] A list of buffs (not dictionary)
---@param enchantments table<number, number[]> Key is spell id, value is list of enchantment ids
function scrollsModule:_SetupScrollsSpirit(allBuffs, enchantments)
  --
  -- WotLK
  --
  self:AddScroll(allBuffs, 48104, 37098) -- WotLK: Scroll of Spirit 8
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
      :RequireWotLK()
  self:AddScroll(allBuffs, 48103, 37097) -- WotLK: Scroll of Spirit 7
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
      :RequireWotLK()
  self:AddScroll(allBuffs, 43197, 33460) -- WotLK: Scroll of Spirit 6
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
      :RequireWotLK()

  --
  -- TBC
  --
  self:AddScroll(allBuffs, 33080, 27501) -- TBC: Scroll of Spirit 5
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
      :RequireTBC()
  --
  -- Classic
  --
  self:AddScroll(allBuffs, 12177, 10306) -- Scroll of Spirit 4
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
end

---@param allBuffs BomBuffDefinition[] A list of buffs (not dictionary)
---@param enchantments table<number, number[]> Key is spell id, value is list of enchantment ids
function scrollsModule:_SetupScrollsIntellect(allBuffs, enchantments)
  --
  -- WotLK
  --
  self:AddScroll(allBuffs, 48100, 37092) -- WotLK: Scroll of Intellect 8
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
      :RequireWotLK()
  self:AddScroll(allBuffs, 48099, 37091) -- WotLK: Scroll of Intellect 7
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
      :RequireWotLK()
  self:AddScroll(allBuffs, 43195, 33458) -- WotLK: Scroll of Intellect 6
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
      :RequireWotLK()

  --
  -- TBC
  --
  self:AddScroll(allBuffs, 33078, 27499) -- TBC: Scroll of Intellect 5
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
      :RequireTBC()
end

---@param allBuffs BomBuffDefinition[] A list of buffs (not dictionary)
---@param enchantments table<number, number[]> Key is spell id, value is list of enchantment ids
function scrollsModule:_SetupInscriptionScrolls(allBuffs, enchantments)
  -- TODO: Brilliance scroll
  -- TODO: Fortitude scroll
end
