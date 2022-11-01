local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomBuffRowModule
local buffRowModule = {}
BomModuleManager.buffRowModule = buffRowModule

local managedUiModule = BomModuleManager.myButtonModule
local uiButtonModule = BomModuleManager.uiButtonModule

---@class BomBuffRowFrames
---@field uniqueId string Used for ManageControl() calls as prefix
---@field iconInfo BomLegacyControl Icon for spell or item which provides the buff
---@field checkboxEnable BomLegacyControl Checkbox for enable/disable buff
---@field checkboxSet BomLegacyControl Status checkbox for tracking/auras/seals
---@field toggleSelfCast BomLegacyControl Checkbox toggle to self cast only
---@field toggleForceCast BomLegacyControl Button to add/remove from force cast list
---@field toggleExclude BomLegacyControl Button to add/remove from exclude list
---@field toggleWhisper BomLegacyControl Button to whisper on buff expiration
---@field labelBuff BomLegacyControl Text label with buff name
---@field toggleMainHand BomLegacyControl Toggle to enchant main hand
---@field toggleOffHand BomLegacyControl Toggle to enchant off-hand
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
local buffRowClass = {}
buffRowClass.__index = buffRowClass

---Creates a new Buff Row UI
---@return BomBuffRowFrames
---@param uniqueId string Used for ManageControl calls as prefix
function buffRowModule:New(uniqueId)
  local newRow = {} ---@type BomBuffRowFrames
  setmetatable(newRow, buffRowClass)
  newRow.uniqueId = uniqueId
  return newRow
end

function buffRowClass:Hide()
  for _j, frame in ipairs(self) do
    frame:Hide()
  end
end

function buffRowClass:Destroy()
  for _j, frame in ipairs(self) do
    frame:Hide()
    frame:ClearAllPoints()
    frame:SetParent(nil)
  end
end

---@return BomControlModule Created or pre-existing enable checkbox
---@param tooltip string
function buffRowClass:CreateEnableCheckbox(tooltip)
  if self.checkboxEnable == nil then
    self.checkboxEnable = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_OPT_ENABLED,
            BOM.ICON_OPT_DISABLED,
            nil, nil, nil, nil,
            self.uniqueId .. ".enableCheckbox")
    self.checkboxEnable:SetOnClick(BOM.MyButtonOnClick)
    BOM.Tool.Tooltip(self.checkboxEnable, tooltip)
  end

  self.checkboxEnable:Show()
  return self.checkboxEnable
end

---@return BomControlModule Created or pre-existing status on/off image
---@param spell BomBuffDefinition
function buffRowClass:CreateStatusCheckboxImage(spell)
  if self.checkboxSet == nil then
    self.checkboxSet = managedUiModule:CreateMyButtonSecure(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_CHECKED,
            BOM.ICON_CHECKED_OFF,
            nil, nil, nil, nil, self.uniqueId .. ".statusCheckbox")
    self.checkboxSet:SetSpell(spell.singleId)
  end

  self.checkboxSet:Show()
  return self.checkboxEnable -- checkboxSet
end

---@param spell BomBuffDefinition
function buffRowClass:CreateInfoIcon(spell)
  if self.iconInfo == nil then
    self.iconInfo = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_EMPTY,
            nil,
            nil,
            { 0.1, 0.9, 0.1, 0.9 },
            nil, nil, tostring(spell.buffId) .. ".infoIcon")

    if spell.isConsumable then
      BOM.Tool.TooltipLink(self.iconInfo, "item:" .. spell.item)
    else
      BOM.Tool.TooltipLink(self.iconInfo, "spell:" .. spell.singleId)
    end

    -- Set texture when ready, might load with a delay
    spell:GetIcon(function(texture)
      self.iconInfo:SetTextures(texture, nil, nil, { 0.1, 0.9, 0.1, 0.9 }, nil, nil)
    end)
  end

  self.iconInfo:Show()
  return self.iconInfo
end

function buffRowClass:CreateBuffLabel(text)
  if self.labelBuff == nil then
    self.labelBuff = BomC_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  end

  self.labelBuff:Show()
  self.labelBuff:SetText(text)
  managedUiModule:ManageControl(self.uniqueId .. ".bufflabel", self.labelBuff)

  return self.labelBuff
end

---@return BomLegacyControl
function buffRowClass:CreateMainhandToggle(tooltip)
  if self.toggleMainHand == nil then
    self.toggleMainHand = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.IconMainHandOn,
            BOM.IconMainHandOff,
            BOM.ICON_DISABLED,
            BOM.IconMainHandOnCoord, nil, nil, self.uniqueId .. ".mainhandToggle")
    self.toggleMainHand:SetOnClick(BOM.MyButtonOnClick)
    BOM.Tool.Tooltip(self.toggleMainHand, tooltip)
  end

  self.toggleMainHand:Show()
  return self.toggleMainHand
end

---@param tooltip string
---@return BomLegacyControl
function buffRowClass:CreateOffhandToggle(tooltip)
  if self.toggleOffHand == nil then
    self.toggleOffHand = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.IconSecondaryHandOn,
            BOM.IconSecondaryHandOff,
            BOM.ICON_DISABLED,
            BOM.IconSecondaryHandOnCoord, nil, nil, self.uniqueId .. ".offhandToggle")
    self.toggleOffHand:SetOnClick(BOM.MyButtonOnClick)
    BOM.Tool.Tooltip(self.toggleOffHand, tooltip)
  end

  self.toggleOffHand:Show()
  return self.toggleOffHand
end

---@param tooltip string
---@return BomLegacyControl
function buffRowClass:CreateWhisperToggle(tooltip)
  if self.toggleWhisper == nil then
    self.toggleWhisper = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_WHISPER_ON,
            BOM.ICON_WHISPER_OFF,
            nil, nil, nil, nil, self.uniqueId .. ".whisperToggle")
    self.toggleWhisper:SetOnClick(BOM.MyButtonOnClick)
  end

  BOM.Tool.Tooltip(self.toggleWhisper, tooltip)
  self.toggleWhisper:Show()
  return self.toggleWhisper
end

---@param tooltip string
---@return BomLegacyControl
function buffRowClass:CreateSelfCastToggle(tooltip)
  if self.toggleSelfCast == nil then
    self.toggleSelfCast = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_SELF_CAST_ON,
            BOM.ICON_SELF_CAST_OFF,
            nil, nil, nil, nil, self.uniqueId .. ".selfCastToggle")
    self.toggleSelfCast:SetOnClick(BOM.MyButtonOnClick)
  end

  BOM.Tool.TooltipText(self.toggleSelfCast, tooltip)
  self.toggleSelfCast:Show()
  return self.toggleSelfCast
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
            BOM.CLASS_ICONS_ATLAS_TEX_COORD[class],
            nil, nil, self.uniqueId .. "." .. class)
  end

  self[class]:SetOnClick(onClick)
  BOM.Tool.TooltipText(self[class], tooltip)
  self[class]:Show()
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
            BOM.ICON_TANK_COORD,
            nil, nil, self.uniqueId .. ".tank")
  end

  self.tank:SetOnClick(onClick)
  BOM.Tool.TooltipText(self.tank, tooltip)
  self.tank:Show()
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
            BOM.ICON_PET_COORD,
            nil, nil, self.uniqueId .. ".pet")
  end

  self.pet:SetOnClick(onClick)
  BOM.Tool.TooltipText(self.pet, tooltip)
  self.pet:Show()
  return self.pet
end

---@param tooltip string
---@return BomLegacyControl
function buffRowClass:CreateForceCastToggle(tooltip, spell)
  if self.toggleForceCast == nil then
    self.toggleForceCast = uiButtonModule:CreateSmallButton(
            "ForceCast" .. spell.singleId,
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_TARGET_ON)
    managedUiModule:ManageControl(self.uniqueId .. ".forceCastToggle", self.toggleForceCast)
    self.toggleForceCast:SetWidth(20);
    self.toggleForceCast:SetHeight(20);
  end

  BOM.Tool.TooltipText(self.toggleForceCast, tooltip)
  self.toggleForceCast:Show()
  return self.toggleForceCast
end

---@param tooltip string
---@return BomLegacyControl
function buffRowClass:CreateExcludeToggle(tooltip, spell)
  if self.toggleExclude == nil then
    self.toggleExclude = uiButtonModule:CreateSmallButton(
            "Exclude" .. spell.singleId,
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_TARGET_EXCLUDE)
    managedUiModule:ManageControl(self.uniqueId .. ".excludeToggle", self.toggleExclude)
    self.toggleExclude:SetWidth(20);
    self.toggleExclude:SetHeight(20);
  end

  BOM.Tool.TooltipText(self.toggleExclude, tooltip)
  self.toggleExclude:Show()
  return self.toggleExclude
end
