local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomBuffRowModule
local buffRowModule = BuffomatModule.New("Ui/BuffRow") ---@type BomBuffRowModule

local managedUiModule = BuffomatModule.Import("Ui/MyButton") ---@type BomUiMyButtonModule
local uiButtonModule = BuffomatModule.Import("Ui/UiButton") ---@type BomUiButtonModule

---@class BomBuffRowFrames
---@field info BomLegacyControl Icon for spell or item which provides the buff
---@field Enable BomLegacyControl Checkbox for enable/disable buff
---@field Set BomLegacyControl Status checkbox for tracking/auras/seals
---@field SelfCast BomLegacyControl Checkbox toggle to self cast only
---@field ForceCastButton BomLegacyControl Button to add/remove from force cast list
---@field ExcludeButton BomLegacyControl Button to add/remove from exclude list
---@field Whisper BomLegacyControl Button to whisper on buff expiration
---@field buff BomLegacyControl Text label with buff name
---@field buffNameLabel BomControl Text label for buff name
---@field MainHand BomLegacyControl Toggle to enchant main hand
---@field OffHand BomLegacyControl Toggle to enchant off-hand
---@field tank BomLegacyControl Toggle to buff tanks
---@field pet BomLegacyControl Toggle to buff pets
---@field WARRIOR BomLegacyControl Per class setting for class-specific buffs
---@field MAGE BomLegacyControl Per class setting for class-specific buffs
---@field ROGUE BomLegacyControl Per class setting for class-specific buffs
---@field DRUID BomLegacyControl Per class setting for class-specific buffs
---@field HUNTER BomLegacyControl Per class setting for class-specific buffs
---@field SHAMAN BomLegacyControl Per class setting for class-specific buffs
---@field PRIEST BomLegacyControl Per class setting for class-specific buffs
---@field WARLOCK BomLegacyControl Per class setting for class-specific buffs
---@field PALADIN BomLegacyControl Per class setting for class-specific buffs
---@field cancelBuffLabel BomControl Text label for buff cancel row (in combat or always)

local buffRowClass = {} ---@type BomBuffRowFrames
buffRowClass.__index = buffRowClass

---Creates a new Buff Row UI
---@return BomBuffRowFrames
function buffRowModule:New()
  local newRow = {} ---@type BomBuffRowFrames
  setmetatable(newRow, buffRowClass)
  return newRow
end

---@return BomControlModule Created or pre-existing enable checkbox
---@param tooltip string
function buffRowClass:CreateEnableCheckbox(tooltip)
  if self.Enable == nil then
    self.Enable = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_OPT_ENABLED,
            BOM.ICON_OPT_DISABLED)
  end

  self.Enable:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.Tooltip(self.Enable, tooltip)

  return self.Enable
end

---@return BomControlModule Created or pre-existing status on/off image
---@param spell BomBuffDefinition
function buffRowClass:CreateStatusCheckboxImage(spell)
  if self.Set == nil then
    self.Set = managedUiModule:CreateMyButtonSecure(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_CHECKED,
            BOM.ICON_CHECKED_OFF)
  end

  self.Set:SetSpell(spell.singleId)
  return self.Enable
end

---@param spell BomBuffDefinition
function buffRowClass:CreateInfoIcon(spell)
  if self.info == nil then
    self.info = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_EMPTY,
            nil,
            nil,
            { 0.1, 0.9, 0.1, 0.9 })
    -- Set texture when ready, might load with a delay
    spell:GetIcon(function(texture)
      self.info:SetTextures(texture, nil, nil, { 0.1, 0.9, 0.1, 0.9 }, nil, nil)
    end)
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
  managedUiModule.ManageControl(self.buff)

  return self.buff
end

---@return BomLegacyControl
function buffRowClass:CreateMainhandToggle(tooltip)
  if self.MainHand == nil then
    self.MainHand = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.IconMainHandOn,
            BOM.IconMainHandOff,
            BOM.ICON_DISABLED,
            BOM.IconMainHandOnCoord)
  end
  self.MainHand:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.Tooltip(self.MainHand, tooltip)

  return self.MainHand
end

---@param tooltip string
---@return BomLegacyControl
function buffRowClass:CreateOffhandToggle(tooltip)
  if self.OffHand == nil then
    self.OffHand = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.IconSecondaryHandOn,
            BOM.IconSecondaryHandOff,
            BOM.ICON_DISABLED,
            BOM.IconSecondaryHandOnCoord)
  end
  self.OffHand:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.Tooltip(self.OffHand, tooltip)

  return self.OffHand
end

---@param tooltip string
---@return BomLegacyControl
function buffRowClass:CreateWhisperToggle(tooltip)
  if self.Whisper == nil then
    self.Whisper = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_WHISPER_ON,
            BOM.ICON_WHISPER_OFF)
  end
  self.Whisper:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.Tooltip(self.Whisper, tooltip)

  return self.Whisper
end

---@param tooltip string
---@return BomLegacyControl
function buffRowClass:CreateSelfCastToggle(tooltip)
  if self.SelfCast == nil then
    self.SelfCast = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_SELF_CAST_ON,
            BOM.ICON_SELF_CAST_OFF)
  end
  self.SelfCast:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.TooltipText(self.SelfCast, tooltip)

  return self.SelfCast
end

---@param tooltip string
---@return BomLegacyControl
function buffRowClass:CreateClassToggle(class, tooltip, onClick)
  if self[class] == nil then
    self[class] = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.CLASS_ICONS_ATLAS,
            BOM.ICON_EMPTY,
            BOM.ICON_DISABLED,
            BOM.CLASS_ICONS_ATLAS_TEX_COORD[class])
  end
  self[class]:SetOnClick(onClick)
  BOM.Tool.TooltipText(self[class], tooltip)

  return self[class]
end

---@param tooltip string
---@return BomLegacyControl
function buffRowClass:CreateTankToggle(tooltip, onClick)
  if self.tank == nil then
    self.tank = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_TANK,
            BOM.ICON_EMPTY,
            BOM.ICON_DISABLED,
            BOM.ICON_TANK_COORD)
  end
  self.tank:SetOnClick(onClick)
  BOM.Tool.TooltipText(self.tank, tooltip)

  return self.tank
end

---@param tooltip string
---@return BomLegacyControl
function buffRowClass:CreatePetToggle(tooltip, onClick)
  if self.pet == nil then
    self.pet = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_PET,
            BOM.ICON_EMPTY,
            BOM.ICON_DISABLED,
            BOM.ICON_PET_COORD)
  end
  self.pet:SetOnClick(onClick)
  BOM.Tool.TooltipText(self.pet, tooltip)

  return self.pet
end

---@param tooltip string
---@return BomLegacyControl
function buffRowClass:CreateForceCastToggle(tooltip, spell)
  if self.ForceCastButton == nil then
    self.ForceCastButton = uiButtonModule:CreateSmallButton(
            "ForceCast" .. spell.singleId,
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_TARGET_ON)
  end
  self.ForceCastButton:SetWidth(20);
  self.ForceCastButton:SetHeight(20);
  BOM.Tool.TooltipText(self.ForceCastButton, tooltip)

  return self.ForceCastButton
end

---@param tooltip string
---@return BomLegacyControl
function buffRowClass:CreateExcludeToggle(tooltip, spell)
  if self.ExcludeButton == nil then
    self.ExcludeButton = uiButtonModule:CreateSmallButton(
            "Exclude" .. spell.singleId,
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_TARGET_EXCLUDE)
  end
  self.ExcludeButton:SetWidth(20);
  self.ExcludeButton:SetHeight(20);
  BOM.Tool.TooltipText(self.ExcludeButton, tooltip)

  return self.ExcludeButton
end
