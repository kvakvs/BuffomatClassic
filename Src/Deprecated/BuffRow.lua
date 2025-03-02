if false then
  local BuffomatAddon = BuffomatAddon

  ---@class BuffRowModule

  local buffRowModule = --[[@as BuffRowModule]] LibStub("Buffomat-BuffRow")
  local _t = LibStub("Buffomat-Languages") --[[@as LanguagesModule]]
  local toolboxModule = LibStub("Buffomat-LegacyToolbox") --[[@as LegacyToolboxModule]]
  local texturesModule = --[[@as TexturesModule]] LibStub("Buffomat-Textures")

  ---@class BomBuffRowFrames
  ---@field [ClassName] BomGPIControl Used for class toggle buttons
  ---@field uniqueId string Used for ManageControl() calls as prefix
  ---@field iconInfo WowControl Icon for spell or item which provides the buff
  ---@field checkboxEnable BomGPIControl Checkbox for enable/disable buff
  ---@field sortingInput BomGPIControl Input for sorting the buffs
  ---@field checkboxSet BomGPIControl Status checkbox for tracking/auras/seals
  ---@field toggleSelfCast BomGPIControl Checkbox toggle to self cast only
  ---@field toggleForceCast BomGPIControl Button to add/remove from force cast list
  ---@field toggleExclude BomGPIControl Button to add/remove from exclude list
  ---@field toggleWhisper BomGPIControl Button to whisper on buff expiration
  ---@field labelBuff WowControl Text label with buff name
  ---@field toggleMainHand BomGPIControl Toggle to enchant main hand
  ---@field toggleOffHand BomGPIControl Toggle to enchant off-hand
  ---@field tank BomGPIControl Toggle to buff tanks
  ---@field pet BomGPIControl Toggle to buff pets
  ---@field WARRIOR BomGPIControl Per class setting for class-specific buffs
  ---@field MAGE BomGPIControl Per class setting for class-specific buffs
  ---@field ROGUE BomGPIControl Per class setting for class-specific buffs
  ---@field DRUID BomGPIControl Per class setting for class-specific buffs
  ---@field HUNTER BomGPIControl Per class setting for class-specific buffs
  ---@field SHAMAN BomGPIControl Per class setting for class-specific buffs
  ---@field PRIEST BomGPIControl Per class setting for class-specific buffs
  ---@field WARLOCK BomGPIControl Per class setting for class-specific buffs
  ---@field PALADIN BomGPIControl Per class setting for class-specific buffs
  ---@field DEATHKNIGHT BomGPIControl Per class setting for class-specific buffs
  ---@field cancelBuffLabel BomGPIControl Text label for buff cancel row (in combat or always)
  local buffRowClass = {}
  buffRowClass.__index = buffRowClass

  ---Creates a new Buff Row UI
  ---@return BomBuffRowFrames
  ---@param uniqueId string Used for ManageControl calls as prefix
  function buffRowModule:New(uniqueId)
    local newRow = --[[@as BomBuffRowFrames]] {
      uniqueId = uniqueId,
    }
    setmetatable(newRow, buffRowClass)
    return newRow
  end

  ---@return WowControl[]
  function buffRowClass:AllControls()
    return {
      self.iconInfo,
      self.checkboxSet,
      self.checkboxEnable,
      self.toggleOffHand,
      self.toggleExclude,
      self.toggleForceCast,
      self.toggleMainHand,
      self.labelBuff,
      self.toggleSelfCast,
      self.toggleWhisper,
      self.tank,
      self.pet,
      self.WARRIOR,
      self.MAGE,
      self.ROGUE,
      self.DRUID,
      self.HUNTER,
      self.SHAMAN,
      self.PRIEST,
      self.WARLOCK,
      self.PALADIN,
      self.DEATHKNIGHT,
    }
  end

  function buffRowClass:Hide()
    for _j, frame in ipairs(self:AllControls()) do
      frame:Hide()
    end
  end

  function buffRowClass:Destroy()
    for _j, frame in ipairs(self:AllControls()) do
      frame:Hide()
      frame:ClearAllPoints()
      frame:SetParent(nil)
    end
  end

  ---@return BomGPIControl Created or pre-existing enable checkbox
  ---@param tooltip string
  function buffRowClass:CreateEnableCheckbox(tooltip)
    if self.checkboxEnable == nil then
      self.checkboxEnable = managedUiModule:CreateManagedButton(
        BomC_SpellTab_Scroll_Child,
        texturesModule.ICON_OPT_ENABLED,
        texturesModule.ICON_OPT_DISABLED,
        nil, nil, nil, nil,
        self.uniqueId .. ".enableCheckbox")
      self.checkboxEnable:SetOnClick(BuffomatAddon.MyButtonOnClick)
      toolboxModule:Tooltip(self.checkboxEnable, tooltip)
    end

    self.checkboxEnable:Show()
    return self.checkboxEnable
  end

  ---@return BomGPIControl Created or pre-existing text input
  ---@param tooltip string
  ---@param buffDef BomBuffDefinition
  function buffRowClass:CreateSortingInput(tooltip, buffDef)
    local field = self.sortingInput

    if field == nil then
      field = managedUiModule:CreateManagedInput(BomC_SpellTab_Scroll_Child, self.uniqueId .. ".sortingInput");
      field:SetAutoFocus(false);
      field:SetSize(20, 22);
      toolboxModule:Tooltip(field, tooltip)

      self.sortingInput = field
    end
    field:SetText(buffDef.customSort or '5')
    field:SetScript("OnEnterPressed",
      function(control)
        buffDef.customSort = field:GetText()
        BuffomatAddon:Print("edited customsort=" ..
        buffDef.customSort .. " for " .. (buffDef.singleLink or buffDef.buffId))
        control:ClearFocus()
      end
    )

    self.sortingInput:Show()
    return self.sortingInput
  end

  ---@return BomGPIControl Created or pre-existing status on/off image
  ---@param buffDef BomBuffDefinition
  function buffRowClass:CreateStatusCheckboxImage(buffDef)
    if self.checkboxSet == nil then
      self.checkboxSet = managedUiModule:CreateMyButtonSecure(
        BomC_SpellTab_Scroll_Child,
        texturesModule.ICON_CHECKED,
        texturesModule.ICON_CHECKED_OFF,
        nil, nil, nil, nil, self.uniqueId .. ".statusCheckbox")
      self.checkboxSet:SetSpell(buffDef.highestRankSingleId)
    end

    self.checkboxSet:Show()
    return self.checkboxEnable -- checkboxSet
  end

  ---@param buffDef BomBuffDefinition
  function buffRowClass:CreateInfoIcon(buffDef)
    if self.iconInfo == nil then
      self.iconInfo = managedUiModule:CreateManagedButton(
        BomC_SpellTab_Scroll_Child,
        texturesModule.ICON_EMPTY,
        nil,
        nil,
        texturesModule.ICON_COORD_09,
        nil, nil, tostring(buffDef.buffId) .. ".infoIcon")

      if buffDef.consumeGroupIcon then
        self.iconInfo:SetTextures(buffDef.consumeGroupIcon, nil, nil, texturesModule.ICON_COORD_09, nil, nil)
        self.iconInfo:SetScript("OnMouseDown", function(self, button)
          if button == 'LeftButton' then
            buffDef:ShowItemsProvidingBuff()
          end
        end)
        toolboxModule:Tooltip(self.iconInfo, _t("Click to print all items which provide this buff"))
      else
        if buffDef.isConsumable then
          toolboxModule:TooltipLink(self.iconInfo, "item:" .. buffDef:GetFirstItem())
        else
          toolboxModule:TooltipLink(self.iconInfo, "spell:" .. buffDef.highestRankSingleId)
        end

        -- Set texture when ready, might load with a delay
        buffDef:GetIcon(function(texture)
          self.iconInfo:SetTextures(texture, nil, nil, texturesModule.ICON_COORD_09, nil, nil)
        end)
      end
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

  ---@return BomGPIControl
  function buffRowClass:CreateMainhandToggle(tooltip)
    if self.toggleMainHand == nil then
      self.toggleMainHand = managedUiModule:CreateManagedButton(
        BomC_SpellTab_Scroll_Child,
        texturesModule.ICON_MAINHAND_ON,
        texturesModule.ICON_MAINHAND_OFF,
        texturesModule.ICON_DISABLED,
        texturesModule.ICON_MAINHAND_COORD,
        nil, nil, self.uniqueId .. ".mainhandToggle")
      self.toggleMainHand:SetOnClick(BuffomatAddon.MyButtonOnClick)
      toolboxModule:Tooltip(self.toggleMainHand, tooltip)
    end

    self.toggleMainHand:Show()
    return self.toggleMainHand
  end

  ---@param tooltip string
  ---@return BomGPIControl
  function buffRowClass:CreateOffhandToggle(tooltip)
    if self.toggleOffHand == nil then
      self.toggleOffHand = managedUiModule:CreateManagedButton(
        BomC_SpellTab_Scroll_Child,
        texturesModule.ICON_OFFHAND_ON,
        texturesModule.ICON_OFFHAND_OFF,
        texturesModule.ICON_DISABLED,
        texturesModule.ICON_OFFHAND_COORD,
        nil, nil, self.uniqueId .. ".offhandToggle")
      self.toggleOffHand:SetOnClick(BuffomatAddon.MyButtonOnClick)
      toolboxModule:Tooltip(self.toggleOffHand, tooltip)
    end

    self.toggleOffHand:Show()
    return self.toggleOffHand
  end

  ---@param tooltip string
  ---@return BomGPIControl
  function buffRowClass:CreateWhisperToggle(tooltip)
    if self.toggleWhisper == nil then
      self.toggleWhisper = managedUiModule:CreateManagedButton(
        BomC_SpellTab_Scroll_Child,
        texturesModule.ICON_WHISPER_ON,
        texturesModule.ICON_WHISPER_OFF,
        nil, nil, nil, nil, self.uniqueId .. ".whisperToggle")
      self.toggleWhisper:SetOnClick(BuffomatAddon.MyButtonOnClick)
    end

    toolboxModule:Tooltip(self.toggleWhisper, tooltip)
    self.toggleWhisper:Show()
    return self.toggleWhisper
  end

  ---@param tooltip string
  ---@return BomGPIControl
  function buffRowClass:CreateSelfCastToggle(tooltip)
    if self.toggleSelfCast == nil then
      self.toggleSelfCast = managedUiModule:CreateManagedButton(
        BomC_SpellTab_Scroll_Child,
        texturesModule.ICON_SELF_CAST_ON,
        texturesModule.ICON_SELF_CAST_OFF,
        nil, nil, nil, nil, self.uniqueId .. ".selfCastToggle")
      self.toggleSelfCast:SetOnClick(BuffomatAddon.MyButtonOnClick)
    end

    toolboxModule:TooltipText(self.toggleSelfCast, tooltip)
    self.toggleSelfCast:Show()
    return self.toggleSelfCast
  end

  ---@param class ClassName
  ---@param tooltip string
  ---@param onClick function
  ---@return BomGPIControl
  function buffRowClass:CreateClassToggle(class, tooltip, onClick)
    local control = self[class]

    if control == nil then
      control = managedUiModule:CreateManagedButton(
        BomC_SpellTab_Scroll_Child,
        texturesModule.CLASS_ICONS_ATLAS,
        texturesModule.ICON_EMPTY,
        texturesModule.ICON_DISABLED,
        texturesModule.CLASS_ICONS_ATLAS_TEX_COORD[class],
        nil, nil, self.uniqueId .. "." .. class)
      self[class] = control
    end

    control:SetOnClick(onClick)
    toolboxModule:TooltipText(self[class], tooltip)
    control:Show()
    return control
  end

  ---@param tooltip string
  ---@param onClick function
  ---@return BomGPIControl
  function buffRowClass:CreateTankToggle(tooltip, onClick)
    if self.tank == nil then
      self.tank = managedUiModule:CreateManagedButton(
        BomC_SpellTab_Scroll_Child,
        texturesModule.ICON_TANK,
        texturesModule.ICON_EMPTY,
        texturesModule.ICON_DISABLED,
        texturesModule.ICON_TANK_COORD,
        nil, nil, self.uniqueId .. ".tank")
    end

    self.tank:SetOnClick(onClick)
    toolboxModule:TooltipText(self.tank, tooltip)
    self.tank:Show()
    return self.tank
  end

  ---@param tooltip string
  ---@param onClick function
  ---@return BomGPIControl
  function buffRowClass:CreatePetToggle(tooltip, onClick)
    if self.pet == nil then
      self.pet = managedUiModule:CreateManagedButton(
        BomC_SpellTab_Scroll_Child,
        texturesModule.ICON_PET,
        texturesModule.ICON_EMPTY,
        texturesModule.ICON_DISABLED,
        texturesModule.ICON_PET_COORD,
        nil, nil, self.uniqueId .. ".pet")
    end

    self.pet:SetOnClick(onClick)
    toolboxModule:TooltipText(self.pet, tooltip)
    self.pet:Show()
    return self.pet
  end

  ---@param tooltip string
  ---@param buffDef BomBuffDefinition
  ---@return BomGPIControl
  function buffRowClass:CreateForceCastToggle(tooltip, buffDef)
    if self.toggleForceCast == nil then
      self.toggleForceCast = --[[@as BomGPIControl]] uiButtonModule:CreateSmallButton(
        "ForceCast" .. buffDef.buffId,
        BomC_SpellTab_Scroll_Child,
        texturesModule.ICON_TARGET_ON)
      managedUiModule:ManageControl(self.uniqueId .. ".forceCastToggle", self.toggleForceCast)
      self.toggleForceCast:SetWidth(20);
      self.toggleForceCast:SetHeight(20);
    end

    toolboxModule:TooltipText(self.toggleForceCast, tooltip)
    self.toggleForceCast:Show()
    return self.toggleForceCast
  end

  ---@param tooltip string
  ---@param buffDef BomBuffDefinition
  ---@return BomGPIControl
  function buffRowClass:CreateExcludeToggle(tooltip, buffDef)
    if self.toggleExclude == nil then
      self.toggleExclude = uiButtonModule:CreateSmallButton(
        "Exclude" .. buffDef.highestRankSingleId,
        BomC_SpellTab_Scroll_Child,
        texturesModule.ICON_TARGET_EXCLUDE)
      managedUiModule:ManageControl(self.uniqueId .. ".excludeToggle", self.toggleExclude)
      self.toggleExclude:SetWidth(20);
      self.toggleExclude:SetHeight(20);
    end

    toolboxModule:TooltipText(self.toggleExclude, tooltip)
    self.toggleExclude:Show()
    return self.toggleExclude
  end
end