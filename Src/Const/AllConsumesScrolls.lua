local BOM = BuffomatAddon ---@type BomAddon

---@class BomAllConsumesScrollsModule
local scrollsModule = BuffomatModule.New("AllConsumesScrolls") ---@type BomAllConsumesScrollsModule

local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule
local allBuffsModule = BuffomatModule.Import("AllBuffs") ---@type BomAllBuffsModule
local buffDefModule = BuffomatModule.Import("BuffDefinition") ---@type BomBuffDefinitionModule

---SCROLLS
---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function scrollsModule:SetupScrolls(buffs, enchantments)
  self:_SetupScrollsAgility(buffs, enchantments)
  self:_SetupScrollsStrength(buffs, enchantments)
  self:_SetupScrollsProtection(buffs, enchantments)
  self:_SetupScrollsSpirit(buffs, enchantments)
  self:_SetupInscriptionScrolls(buffs, enchantments)
end

function scrollsModule:AddScroll(buffs, buffSpellId, itemId)
  return buffDefModule:createAndRegisterBuff(buffs, buffSpellId,
          { item           = itemId, isConsumable = true, default = false, consumableTarget = "player",
            singleDuration = allBuffsModule.DURATION_30M,
          })          :Category(allBuffsModule.SCROLL)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function scrollsModule:_SetupScrollsAgility(buffs, enchantments)
  --
  -- WotLK
  --
  self:AddScroll(buffs, 58451, 43464) -- WotLK: Scroll of Agility 8
      :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
      :RequireWotLK()
  self:AddScroll(buffs, 58450, 43463) -- WotLK: Scroll of Agility 7
      :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
      :RequireWotLK()
  self:AddScroll(buffs, 43194, 33457) -- WotLK: Scroll of Agility 6
      :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
      :RequireWotLK()

  --
  -- TBC
  --
  self:AddScroll(buffs, 33077, 27498) -- TBC: Scroll of Agility 5
      :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
      :RequireTBC()

  --
  -- Classic
  --
  self:AddScroll(buffs, 12174, 10309) -- Scroll of Agility 4
      :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
  self:AddScroll(buffs, 8117, 4425) -- Scroll of Agility 3
      :RequirePlayerClass(allBuffsModule.PHYSICAL_CLASSES)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function scrollsModule:_SetupScrollsStrength(buffs, enchantments)
  --
  -- WotLK
  --
  self:AddScroll(buffs, 58449, 43466) -- WotLK: Scroll of Strength 8
      :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
      :RequireWotLK()
  self:AddScroll(buffs, 58448, 43465) -- WotLK: Scroll of Strength 7
      :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
      :RequireWotLK()
  self:AddScroll(buffs, 43199, 33462) -- WotLK: Scroll of Strength 6
      :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
      :RequireWotLK()

  --
  -- TBC
  --
  self:AddScroll(buffs, 33082, 27503) -- TBC: Scroll of Strength 5
      :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
      :RequireTBC()

  --
  -- Classic
  --
  self:AddScroll(buffs, 12179, 10310) -- Scroll of Strength 4
      :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
  self:AddScroll(buffs, 8120, 4426) -- Scroll of Strength 3
      :RequirePlayerClass(allBuffsModule.MELEE_CLASSES)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function scrollsModule:_SetupScrollsProtection(buffs, enchantments)
  --
  -- WotLK
  --
  self:AddScroll(buffs, 58453, 43468) -- WotLK: Scroll of Protection 8
      :RequireWotLK()
  self:AddScroll(buffs, 58452, 43467) -- WotLK: Scroll of Protection 7
      :RequireWotLK()
  self:AddScroll(buffs, 43196, 33459) -- WotLK: Scroll of Protection 6
      :RequireWotLK()

  --
  -- TBC
  --
  self:AddScroll(buffs, 33079, 27500) -- TBC: Scroll of Protection 5
      :RequireTBC()
  --
  -- Classic
  --
  self:AddScroll(buffs, 12175, 10305) -- Scroll of Protection 4
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function scrollsModule:_SetupScrollsSpirit(buffs, enchantments)
  --
  -- WotLK
  --
  self:AddScroll(buffs, 48104, 37098) -- WotLK: Scroll of Spirit 8
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
      :RequireWotLK()
  self:AddScroll(buffs, 48103, 37097) -- WotLK: Scroll of Spirit 7
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
      :RequireWotLK()
  self:AddScroll(buffs, 43197, 33460) -- WotLK: Scroll of Spirit 6
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
      :RequireWotLK()

  --
  -- TBC
  --
  self:AddScroll(buffs, 33080, 27501) -- TBC: Scroll of Spirit 5
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
      :RequireTBC()
  --
  -- Classic
  --
  self:AddScroll(buffs, 12177, 10306) -- Scroll of Spirit 4
      :RequirePlayerClass(allBuffsModule.MANA_CLASSES)
end

---@param buffs table<string, BomBuffDefinition> A list of buffs (not dictionary)
---@param enchantments table<number, table<number>> Key is spell id, value is list of enchantment ids
function scrollsModule:_SetupInscriptionScrolls(buffs, enchantments)
  -- TODO: Brilliance scroll
  -- TODO: Fortitude scroll
end
