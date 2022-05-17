local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomBuffRowModule
local buffRowModule = BuffomatModule.DeclareModule("Ui/BuffRow") ---@type BomBuffRowModule

---@class BomBuffRowFrames
---@field info BomControl Icon for spell or item which provides the buff
---@field Enable BomControl Checkbox for enable/disable buff
---@field Set BomControl Status checkbox for tracking/auras/seals
---@field SelfCast BomControl Checkbox toggle to self cast only
---@field ForceCastButton BomControl Button to add/remove from force cast list
---@field ExcludeButton BomControl Button to add/remove from exclude list
---@field Whisper BomControl Button to whisper on buff expiration
---@field buff BomControl Text label with buff name
---@field MainHand BomControl Toggle to enchant main hand
---@field OffHand BomControl Toggle to enchant off-hand
---@field tank BomControl Toggle to buff tanks
---@field pet BomControl Toggle to buff pets
---@field WARRIOR BomControl Per class setting for class-specific buffs
---@field MAGE BomControl Per class setting for class-specific buffs
---@field ROGUE BomControl Per class setting for class-specific buffs
---@field DRUID BomControl Per class setting for class-specific buffs
---@field HUNTER BomControl Per class setting for class-specific buffs
---@field SHAMAN BomControl Per class setting for class-specific buffs
---@field PRIEST BomControl Per class setting for class-specific buffs
---@field WARLOCK BomControl Per class setting for class-specific buffs
---@field PALADIN BomControl Per class setting for class-specific buffs

local buffRowClass = {} ---@type BomBuffRowFrames
buffRowClass.__index = buffRowClass

---Creates a new Buff Row UI
---@return BomBuffRowFrames
function buffRowModule:new()
  local newRow = {} ---@type BomBuffRowFrames
  setmetatable(newRow, buffRowClass)
  return newRow
end

---@return BomControlModule Created or pre-existing enable checkbox
---@param tooltip string
function buffRowClass:CreateEnableCheckbox(tooltip)
  if self.Enable == nil then
    self.Enable = BOM.CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_OPT_ENABLED,
            BOM.ICON_OPT_DISABLED)
  end

  self.Enable:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.Tooltip(self.Enable, tooltip)

  return self.Enable
end

---@return BomControlModule Created or pre-existing status on/off image
---@param spell BomSpellDef
function buffRowClass:CreateStatusCheckboxImage(spell)
  if self.Set == nil then
    self.Set = BOM.CreateMyButtonSecure(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_CHECKED,
            BOM.ICON_CHECKED_OFF)
  end

  self.Set:SetSpell(spell.singleId)
  return self.Enable
end

---@param spell BomSpellDef
function buffRowClass:CreateInfoIcon(spell)
  if self.info == nil then
    self.info = BOM.CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            spell:GetIcon(),
            nil,
            nil,
            { 0.1, 0.9, 0.1, 0.9 })
  end

  if spell.isConsumable then
    BOM.Tool.TooltipLink(self.info, "item:" .. spell.item)
  else
    BOM.Tool.TooltipLink(self.info, "spell:" .. spell.singleId)
  end

  return self.info
end

function buffRowClass:CreateBuffLabel(text)
  self.buff = BomC_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  self.buff:SetText(text)

  return self.buff
end
