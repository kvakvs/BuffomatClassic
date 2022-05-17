---| Module contains code to update the already selected spells in tabs
local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomSpellButtonsTabModule
---@field spellTabsCreatedFlag boolean True if spells tab is created and filled
---@field categoryLabels table<string, BomControl> Collection of category labels indexed per category name
local spellButtonsTabModule = BuffomatModule.DeclareModule("Ui/SpellButtonsTab") ---@type BomSpellButtonsTabModule
spellButtonsTabModule.categoryLabels = {}

local allSpellsModule = BuffomatModule.Import("AllSpells") ---@type BomAllSpellsModule
local buffomatModule = BuffomatModule.Import("Buffomat") ---@type BomBuffomatModule
local itemCacheModule = BuffomatModule.Import("ItemCache") ---@type BomItemCacheModule
local optionsPopupModule = BuffomatModule.Import("OptionsPopup") ---@type BomOptionsPopupModule
local rowBuilderModule = BuffomatModule.Import("RowBuilder") ---@type BomRowBuilderModule
local spellCacheModule = BuffomatModule.Import("SpellCache") ---@type BomSpellCacheModule
local spellDefModule = BuffomatModule.Import("SpellDef") ---@type BomSpellDefModule
local spellSetupModule = BuffomatModule.Import("SpellSetup") ---@type BomSpellSetupModule
local toolboxModule = BuffomatModule.Import("Toolbox") ---@type BomToolboxModule
local uiButtonModule = BuffomatModule.Import("Ui/UiButton") ---@type BomUiButtonModule

local L = setmetatable(
        {},
        {
          __index = function(_t, k)
            if BOM.L and BOM.L[k] then
              return BOM.L[k]
            else
              return "[" .. k .. "]"
            end
          end
        })

local function bomDoBlessingOnClick(self)
  local saved = self._privat_DB[self._privat_Var]

  for i, spell in ipairs(BOM.SelectedSpells) do
    if spell.isBlessing then
      -- TODO: use spell instead of BOM.CurrentProfile.Spell[]
      BOM.CurrentProfile.Spell[spell.ConfigID].Class[self._privat_Var] = false
    end
  end
  self._privat_DB[self._privat_Var] = saved

  BOM.MyButtonUpdateAll()
  buffomatModule:OptionsUpdate()
end

local bomSpellSettingsFrames = {}
-- accessible from TaskScan.MaybeResetWatchGroups
spellButtonsTabModule.spellSettingsFrames = bomSpellSettingsFrames

---Add some clickable elements to Spell Tab row with all classes
---@param rowBuilder RowBuilder The structure used for building button rows
---@param playerIsHorde boolean Whether we are the horde
---@param spell BomSpellDef The spell currently being displayed
function spellButtonsTabModule:AddSpellRow_ClassSelector(rowBuilder, playerIsHorde, spell, profileSpell)
  if spell.frames.SelfCast == nil then
    spell.frames.SelfCast = BOM.CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_SELF_CAST_ON,
            BOM.ICON_SELF_CAST_OFF)
  end

  spell.frames.SelfCast:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  spell.frames.SelfCast:SetVariable(profileSpell, "SelfCast")
  spell.frames.SelfCast:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.TooltipText(
          spell.frames.SelfCast,
          BOM.FormatTexture(BOM.ICON_SELF_CAST_ON) .. " - " .. L.TooltipSelfCastCheckbox_Self .. "|n"
                  .. BOM.FormatTexture(BOM.ICON_SELF_CAST_OFF) .. " - " .. L.TooltipSelfCastCheckbox_Party)

  rowBuilder:StepRight(spell.frames.SelfCast, 0)

  --------------------------------------
  -- Class-Cast checkboxes one per class
  --------------------------------------
  for ci, class in ipairs(BOM.Tool.Classes) do
    if spell.frames[class] == nil then
      spell.frames[class] = BOM.CreateManagedButton(
              BomC_SpellTab_Scroll_Child,
              BOM.CLASS_ICONS_ATLAS,
              BOM.ICON_EMPTY,
              BOM.ICON_DISABLED,
              BOM.CLASS_ICONS_ATLAS_TEX_COORD[class])
    end

    spell.frames[class]:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
    spell.frames[class]:SetVariable(profileSpell.Class, class)
    spell.frames[class]:SetOnClick(bomDoBlessingOnClick)

    BOM.Tool.TooltipText(
            spell.frames[class],
            BOM.Tool.IconClass[class] .. " - " .. L.TooltipCastOnClass .. ": " .. BOM.Tool.ClassName[class] .. "|n"
                    .. BOM.FormatTexture(BOM.ICON_EMPTY) .. " - " .. L.TabDoNotBuff .. ": " .. BOM.Tool.ClassName[class] .. "|n"
                    .. BOM.FormatTexture(BOM.ICON_DISABLED) .. " - " .. L.TabBuffOnlySelf)

    if not BOM.TBC and (-- if not TBC hide paladin for horde, hide shaman for alliance
            (playerIsHorde and class == "PALADIN") or (not playerIsHorde and class == "SHAMAN")) then
      spell.frames[class]:Hide()
    else
      rowBuilder.prevControl = spell.frames[class]
    end
  end -- for each class in class_sort_order

  --========================================
  if spell.frames["tank"] == nil then
    spell.frames["tank"] = BOM.CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_TANK,
            BOM.ICON_EMPTY,
            BOM.ICON_DISABLED,
            BOM.ICON_TANK_COORD)
  end

  spell.frames["tank"]:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  spell.frames["tank"]:SetVariable(profileSpell.Class, "tank")
  spell.frames["tank"]:SetOnClick(bomDoBlessingOnClick)
  BOM.Tool.TooltipText(spell.frames["tank"], BOM.FormatTexture(BOM.ICON_TANK) .. " - " .. L.TooltipCastOnTank)

  rowBuilder.prevControl = spell.frames["tank"]

  --========================================
  if spell.frames["pet"] == nil then
    spell.frames["pet"] = BOM.CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_PET,
            BOM.ICON_EMPTY,
            BOM.ICON_DISABLED,
            BOM.ICON_PET_COORD)
  end

  spell.frames["pet"]:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  spell.frames["pet"]:SetVariable(profileSpell.Class, "pet")
  spell.frames["pet"]:SetOnClick(bomDoBlessingOnClick)
  BOM.Tool.TooltipText(spell.frames["pet"], BOM.FormatTexture(BOM.ICON_PET) .. " - " .. L.TooltipCastOnPet)

  rowBuilder:StepRight(spell.frames["pet"], 7)

  --========================================
  -- Force Cast Button -(+)-
  --========================================
  if spell.frames.ForceCastButton == nil then
    spell.frames.ForceCastButton = uiButtonModule:CreateSmallButton(
            "ForceCast" .. spell.singleId,
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_TARGET_ON)
    spell.frames.ForceCastButton:SetWidth(20);
    spell.frames.ForceCastButton:SetHeight(20);
  end

  spell.frames.ForceCastButton:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  BOM.Tool.Tooltip(spell.frames.ForceCastButton, "TooltipForceCastOnTarget")

  rowBuilder:StepRight(spell.frames.ForceCastButton, 0)

  --========================================
  -- Exclude/Ignore Buff Target Button (X)
  --========================================
  if spell.frames.ExcludeButton == nil then
    spell.frames.ExcludeButton = uiButtonModule:CreateSmallButton(
            "Exclude" .. spell.singleId,
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_TARGET_EXCLUDE)
    spell.frames.ExcludeButton:SetWidth(20);
    spell.frames.ExcludeButton:SetHeight(20);
  end

  spell.frames.ExcludeButton:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  BOM.Tool.Tooltip(spell.frames.ExcludeButton, "TooltipExcludeTarget")

  rowBuilder:StepRight(spell.frames.ExcludeButton, 2)
end

---Add a row with spell cancel buttons
---@param spell BomSpellDef - The spell to be canceled
---@param rowBuilder RowBuilder The structure used for building button rows
---@return {dy, prev_control}
function spellButtonsTabModule:AddSpellCancelRow(spell, rowBuilder)
  if spell.frames.info == nil then
    -- Create spell tooltip button
    spell.frames.info = BOM.CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            spell:GetIcon(),
            nil,
            nil,
            { 0.1, 0.9, 0.1, 0.9 })
    BOM.Tool.TooltipLink(spell.frames.info, "spell:" .. spell.singleId)
  end

  if rowBuilder.prevControl then
    spell.frames.info:SetPoint("TOPLEFT", rowBuilder.prevControl, "BOTTOMLEFT", 0, -rowBuilder.dy)
  else
    spell.frames.info:SetPoint("TOPLEFT")
  end

  rowBuilder.prevControl = spell.frames.info

  local enableCheckbox = spell.frames:CreateEnableCheckbox(L.TooltipEnableBuffCancel)
  enableCheckbox:SetPoint("LEFT", spell.frames.info, "RIGHT", 7, 0)
  enableCheckbox:SetVariable(BOM.CurrentProfile.CancelBuff[spell.ConfigID], "Enable")

  --Add "Only before combat" text label
  spell.frames.OnlyCombat = toolboxModule:CreateSmalltextLabel(
          spell.frames.OnlyCombat,
          BomC_SpellTab_Scroll_Child,
          function(ctrl)
            if spell.OnlyCombat then
              ctrl:SetText(L.HintCancelThisBuff .. ": " .. L.HintCancelThisBuff_Combat)
            else
              ctrl:SetText(L.HintCancelThisBuff .. ": " .. L.HintCancelThisBuff_Always)
            end
            ctrl:SetPoint("TOPLEFT", enableCheckbox, "TOPRIGHT", 7, -3)
          end)

  spell.frames.info:Show()
  enableCheckbox:Show()

  if spell.frames.OnlyCombat then
    spell.frames.OnlyCombat:Show()
  end
end

---@param rowBuilder RowBuilder The structure used for building button rows
function spellButtonsTabModule:AddGroupScanSelector(rowBuilder)
  -------------------------
  -- Add settings frame with icon, icon is not clickable
  -------------------------
  if bomSpellSettingsFrames.Settings == nil then
    bomSpellSettingsFrames.Settings = BOM.CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_GEAR,
            nil,
            nil,
            { 0.1, 0.9, 0.1, 0.9 })
  end

  BOM.Tool.Tooltip(bomSpellSettingsFrames.Settings, "TooltipRaidGroupsSettings")
  bomSpellSettingsFrames.Settings:SetPoint("TOPLEFT", rowBuilder.prevControl, "BOTTOMLEFT", 0, -12)

  rowBuilder:StepRight(bomSpellSettingsFrames.Settings, 7)
  local l = rowBuilder.prevControl

  if bomSpellSettingsFrames[0] == nil then
    bomSpellSettingsFrames[0] = BOM.CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_GROUP,
            nil,
            nil,
            { 0.1, 0.9, 0.1, 0.9 })
  end
  BOM.Tool.Tooltip(bomSpellSettingsFrames[0], "HeaderWatchGroup")
  bomSpellSettingsFrames[0]:SetPoint("TOPLEFT", l, "TOPRIGHT", rowBuilder.dx, 0)

  l = bomSpellSettingsFrames[0]
  rowBuilder.dx = 7

  ------------------------------
  -- Add "Watch Group #" buttons
  ------------------------------
  for i = 1, 8 do
    if bomSpellSettingsFrames[i] == nil then
      bomSpellSettingsFrames[i] = BOM.CreateManagedButton(
              BomC_SpellTab_Scroll_Child,
              BOM.ICON_GROUP_ITEM,
              BOM.ICON_GROUP_NONE)
    end

    bomSpellSettingsFrames[i]:SetPoint("TOPLEFT", l, "TOPRIGHT", rowBuilder.dx, 0)
    bomSpellSettingsFrames[i]:SetVariable(BomCharacterState.WatchGroup, i)
    bomSpellSettingsFrames[i]:SetText(i)
    BOM.Tool.TooltipText(bomSpellSettingsFrames[i], string.format(L.TooltipGroup, i))

    -- Let the MyButton library function handle the data update, and update the tab text too
    bomSpellSettingsFrames[i]:SetOnClick(function()
      BOM.MyButtonOnClick(self)
      BOM.UpdateBuffTabText()
    end)

    l = bomSpellSettingsFrames[i]
    rowBuilder.dx = 2
  end

  rowBuilder.prevControl = bomSpellSettingsFrames[0]

  bomSpellSettingsFrames.Settings:Show()

  for i = 0, 8 do
    bomSpellSettingsFrames[i]:Show()
  end

  for i, set in ipairs(optionsPopupModule.behaviourSettings) do
    if bomSpellSettingsFrames[set[1]] then
      bomSpellSettingsFrames[set[1]]:Show()
    end
    if bomSpellSettingsFrames[set[1] .. "txt"] then
      bomSpellSettingsFrames[set[1] .. "txt"]:Show()
    end
  end

  rowBuilder.prevControl = bomSpellSettingsFrames.Settings
end

---@param rowBuilder RowBuilder The structure used for building button rows
---@param spell BomSpellDef Spell we're adding now
function spellButtonsTabModule:AddSpellRow_WhisperExpired(rowBuilder, spell, profileSpell)
  if spell.frames.Whisper == nil then
    spell.frames.Whisper = BOM.CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_WHISPER_ON,
            BOM.ICON_WHISPER_OFF)
  end

  spell.frames.Whisper:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  spell.frames.Whisper:SetVariable(profileSpell, "Whisper")
  spell.frames.Whisper:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.Tooltip(spell.frames.Whisper, "TooltipWhisperWhenExpired")

  rowBuilder:StepRight(spell.frames.Whisper, 2)
end

---@param rowBuilder RowBuilder The structure used for building button rows
---@param spell BomSpellDef Spell we're adding now
function spellButtonsTabModule:AddSpellRow_Weapon(rowBuilder, spell, profileSpell)
  if spell.frames.MainHand == nil then
    spell.frames.MainHand = BOM.CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.IconMainHandOn,
            BOM.IconMainHandOff,
            BOM.ICON_DISABLED,
            BOM.IconMainHandOnCoord)
  end

  spell.frames.MainHand:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  spell.frames.MainHand:SetVariable(profileSpell, "MainHandEnable")
  spell.frames.MainHand:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.Tooltip(spell.frames.MainHand, "TooltipMainHand")

  rowBuilder:StepRight(spell.frames.MainHand, 2)

  if spell.frames.OffHand == nil then
    spell.frames.OffHand = BOM.CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.IconSecondaryHandOn,
            BOM.IconSecondaryHandOff,
            BOM.ICON_DISABLED,
            BOM.IconSecondaryHandOnCoord)
  end

  spell.frames.OffHand:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  spell.frames.OffHand:SetVariable(profileSpell, "OffHandEnable")
  spell.frames.OffHand:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.Tooltip(spell.frames.OffHand, "TooltipOffHand")

  rowBuilder:StepRight(spell.frames.OffHand, 2)
end

---Creates a row
---@param playerIsHorde boolean Whether we're the horde
---@param spell BomSpellDef Spell we're adding now
---@param rowBuilder RowBuilder The structure used for building button rows
---@param playerClass string Character class
function spellButtonsTabModule:AddSpellRow(rowBuilder, playerIsHorde, spell, playerClass)
  -- Create buff icon with tooltip
  local infoIcon = spell.frames:CreateInfoIcon(spell)

  if rowBuilder.prevControl then
    infoIcon:SetPoint("TOPLEFT", rowBuilder.prevControl, "BOTTOMLEFT", 0, -rowBuilder.dy)
  else
    infoIcon:SetPoint("TOPLEFT", 0, -rowBuilder.dy)
  end

  rowBuilder:StepRight(infoIcon, 7)

  local profileSpell = spellDefModule:GetProfileSpell(spell.ConfigID)

  local enableCheckbox = spell.frames:CreateEnableCheckbox(L.TooltipEnableSpell)
  enableCheckbox:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  enableCheckbox:SetVariable(profileSpell, "Enable")

  rowBuilder:StepRight(enableCheckbox, 7)

  if spell:HasClasses() then
    -- Create checkboxes one per class
    self:AddSpellRow_ClassSelector(rowBuilder, playerIsHorde, spell, profileSpell)
  end

  -- Add checkbox for spells which can be enabled and present at the same time?
  -->>------------------------------
  if (spell.type == "tracking"
          or spell.type == "aura"
          or spell.type == "seal")
          and spell.needForm == nil then
    local statusImage = spell.frames:CreateStatusCheckboxImage(spell)
    statusImage:SetPoint("TOPLEFT", infoIcon, "TOPRIGHT", rowBuilder.dx, 0)
    rowBuilder:StepRight(statusImage, 7)
  end
  --<<------------------------------

  if spell.isInfo and spell.allowWhisper then
    self:AddSpellRow_WhisperExpired(rowBuilder, spell, profileSpell)
  end

  if spell.type == "weapon" then
    self:AddSpellRow_Weapon(rowBuilder, spell, profileSpell)
  end

  -- Calculate label to the right of the spell config buttons,
  -- spell name and extra text label
  -->>---------------------------
  local buffLabelText = spell:GetSingleText() or "-"

  if spell.type == "weapon" then
    buffLabelText = buffLabelText .. ": " .. BOM.Color("bbbbee", L.TooltipIncludesAllRanks)
  elseif spell.extraText then
    buffLabelText = buffLabelText .. ": " .. BOM.Color("bbbbee", spell.extraText)
  end

  local buffLabel = spell.frames:CreateBuffLabel(buffLabelText)
  buffLabel:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", 7, -1)
  rowBuilder:StepRight(buffLabel, 7)
  --<<---------------------------

  infoIcon:Show()
  enableCheckbox:Show()

  if spell:HasClasses() then
    spell.frames.SelfCast:Show()
    spell.frames.ForceCastButton:Show()
    spell.frames.ExcludeButton:Show()

    for ci, class in ipairs(BOM.Tool.Classes) do
      if not BOM.TBC and -- if not TBC, hide paladin for horde, hide shaman for alliance
              ((playerIsHorde and class == "PALADIN") or (not playerIsHorde and class == "SHAMAN")) then
        spell.frames[class]:Hide()
      else
        spell.frames[class]:Show()
      end
    end

    spell.frames.tank:Show()
    spell.frames.pet:Show()
  end

  if spell.frames.Set then
    spell.frames.Set:Show()
  end

  if buffLabel then
    buffLabel:Show()
  end

  if spell.frames.Whisper then
    spell.frames.Whisper:Show()
  end

  if spell.frames.MainHand then
    spell.frames.MainHand:Show()
  end

  if spell.frames.OffHand then
    spell.frames.OffHand:Show()
  end

  -- Finished building a row, set the icon frame for this row to be the anchor
  -- point for the next
  rowBuilder.prevControl = infoIcon
end

---Filter all known spells through current player spellbook.
---Called below from BOM.UpdateSpellsTab()
function spellButtonsTabModule:CreateTab(playerIsHorde)
  local rowBuilder = rowBuilderModule:new()
  local _, selfClass, _ = UnitClass("player")

  for j, cat in ipairs(allSpellsModule.buffCategories) do
    for i, spell in ipairs(BOM.SelectedSpells) do
      if spell.category ~= cat
              or (type(spell.onlyUsableFor) == "table" and not tContains(spell.onlyUsableFor, selfClass)) then
        -- skip not usable
      else
        if not rowBuilder.categories[cat] then
          rowBuilder.categories[cat] = true
          self:AddCategoryRow(cat, rowBuilder) -- only add once if ever found one in that category
        else
          rowBuilder.dy = 2 -- step down 2 px between rows
        end

        self:AddSpellRow(rowBuilder, playerIsHorde, spell, selfClass)
      end -- if category of the spell == cat
    end
  end

  rowBuilder.dy = 12

  --
  -- Add spell cancel buttons for all spells in CancelBuffs
  -- (and CustomCancelBuffs which user can add manually in the config file)
  --
  for i, spell in ipairs(BOM.CancelBuffs) do
    rowBuilder.dx = 2

    self:AddSpellCancelRow(spell, rowBuilder)

    rowBuilder.dy = 2
  end

  if rowBuilder.prev_control then
    self:AddGroupScanSelector(rowBuilder)
  end
end

---Build a tooltip string to add to the target force-cast or exclude button
---@param prefix string - if table is not empty, will prefix tooltip with this string
---@param empty_text string - if table is empty, use this text
---@param name_table table - keys from table are formatted comma-separated
local function bomGetTargetsTooltipText(prefix, empty_text, name_table)
  local text = ""
  for name, value in pairs(name_table) do
    if value then
      if text ~= "" then
        text = text .. ", "
      end
      text = text .. name
    end
  end

  if text == "" then
    return "|n" .. empty_text
  else
    return "|n" .. prefix .. text
  end
end

local function bomForceTargetsTooltipText(spell)
  return bomGetTargetsTooltipText(
          L.FormatAllForceCastTargets,
          L.FormatForceCastNone,
          spell.ForcedTarget or {})
end

---@param spell BomSpellDef
function spellButtonsTabModule:UpdateForcecastTooltip(button, spell)
  local tooltip_force_targets = bomForceTargetsTooltipText(spell)
  BOM.Tool.TooltipText(
          button,
          L.TooltipForceCastOnTarget .. "|n"
                  .. string.format(L.FormatToggleTarget, BOM.lastTarget)
                  .. tooltip_force_targets)
end

local function bomExcludeTargetsTooltip(spell)
  return bomGetTargetsTooltipText(
          L.FormatAllExcludeTargets,
          L.FormatExcludeNone,
          spell.ExcludedTarget or {})
end

---@param spell BomSpellDef
function spellButtonsTabModule:UpdateExcludeTargetsTooltip(button, spell)
  local tooltip_exclude_targets = bomExcludeTargetsTooltip(spell)
  BOM.Tool.TooltipText(
          button,
          L.TooltipExcludeTarget .. "|n"
                  .. string.format(L.FormatToggleTarget, BOM.lastTarget)
                  .. tooltip_exclude_targets)
end

function spellButtonsTabModule:CategoryLabel(catId)
  if not catId then
    return L["Category_none"]
  end
  return L["Category_" .. catId]
end

---Takes a category id from allSpellsModule constants, and adds a nice text title
---with localised category name
---@param rowBuilder RowBuilder
function spellButtonsTabModule:AddCategoryRow(catId, rowBuilder)
  local label = self.categoryLabels[catId]

  if not label then
    label = BomC_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetText(BOM.Color("aaaaaa", self:CategoryLabel(catId)))
    self.categoryLabels[catId] = label
  end

  if rowBuilder.prevControl then
    label:SetPoint("TOPLEFT", rowBuilder.prevControl, "BOTTOMLEFT", 0, -8)
    rowBuilder.dy = 12 + 12 -- step 2 lines down
  else
    label:SetPoint("TOPLEFT")
    rowBuilder.dy = 12 -- step 1 line down
  end
end

---@param spell BomSpellDef
function spellButtonsTabModule:UpdateSelectedSpell(spell)
  -- the pointer to spell in current BOM profile
  ---@type BomSpellDef
  local profile_spell = BOM.CurrentProfile.Spell[spell.ConfigID]

  spell.frames.Enable:SetVariable(profile_spell, "Enable")

  if spell:HasClasses() then
    spell.frames.SelfCast:SetVariable(profile_spell, "SelfCast")

    for ci, class in ipairs(BOM.Tool.Classes) do
      spell.frames[class]:SetVariable(profile_spell.Class, class)

      if profile_spell.SelfCast then
        spell.frames[class]:Disable()
      else
        spell.frames[class]:Enable()
      end
    end -- for all class names

    spell.frames["tank"]:SetVariable(profile_spell.Class, "tank")
    spell.frames["pet"]:SetVariable(profile_spell.Class, "pet")

    if profile_spell.SelfCast then
      spell.frames["tank"]:Disable()
      spell.frames["pet"]:Disable()
    else
      spell.frames["tank"]:Enable()
      spell.frames["pet"]:Enable()
    end

    --========================================
    local forceCastButton = spell.frames.ForceCastButton ---@type BomControl
    local excludeButton = spell.frames.ExcludeButton ---@type BomControl

    if BOM.lastTarget ~= nil then
      -------------------------
      forceCastButton:Enable()
      self:UpdateForcecastTooltip(forceCastButton, profile_spell)

      local spellForcedTarget = profile_spell.ForcedTarget
      local lastTarget = BOM.lastTarget

      forceCastButton:SetScript("OnClick", function(self)
        if spellForcedTarget[lastTarget] == nil then
          BOM:Print(BOM.FormatTexture(BOM.ICON_TARGET_ON) .. " "
                  .. L.MessageAddedForced .. ": " .. lastTarget)
          spellForcedTarget[lastTarget] = lastTarget
        else
          BOM:Print(BOM.FormatTexture(BOM.ICON_TARGET_ON) .. " "
                  .. L.MessageClearedForced .. ": " .. lastTarget)
          spellForcedTarget[lastTarget] = nil
        end
        self:UpdateForcecastTooltip(self, profile_spell)
      end)
      -------------------------
      excludeButton:Enable()
      self:UpdateExcludeTargetsTooltip(excludeButton, profile_spell)

      local spell_exclude = profile_spell.ExcludedTarget
      lastTarget = BOM.lastTarget

      excludeButton:SetScript("OnClick", function(self)
        if spell_exclude[lastTarget] == nil then
          BOM:Print(BOM.FormatTexture(BOM.ICON_TARGET_EXCLUDE) .. " "
                  .. L.MessageAddedExcluded .. ": " .. lastTarget)
          spell_exclude[lastTarget] = lastTarget
        else
          BOM:Print(BOM.FormatTexture(BOM.ICON_TARGET_EXCLUDE) .. " "
                  .. L.MessageClearedExcluded .. ": " .. lastTarget)
          spell_exclude[lastTarget] = nil
        end
        self:UpdateExcludeTargetsTooltip(self, profile_spell)
      end)

    else
      --======================================
      forceCastButton:Disable()
      BOM.Tool.TooltipText(
              forceCastButton,
              L.TooltipForceCastOnTarget .. "|n" .. L.TooltipSelectTarget
                      .. bomForceTargetsTooltipText(profile_spell))
      --force_cast_button:SetVariable()
      ---------------------------------
      excludeButton:Disable()
      BOM.Tool.TooltipText(
              excludeButton,
              L.TooltipExcludeTarget .. "|n" .. L.TooltipSelectTarget
                      .. bomExcludeTargetsTooltip(profile_spell))
      --exclude_button:SetVariable()
    end
  end -- end if has classes

  if spell.isInfo and spell.allowWhisper then
    spell.frames.Whisper:SetVariable(profile_spell, "Whisper")
  end

  if spell.type == "weapon" then
    spell.frames.MainHand:SetVariable(profile_spell, "MainHandEnable")
    spell.frames.OffHand:SetVariable(profile_spell, "OffHandEnable")
  end

  if (spell.type == "tracking"
          or spell.type == "aura"
          or spell.type == "seal") and spell.needForm == nil
  then
    if (spell.type == "tracking" and BOM.CharacterState.LastTracking == spell.trackingIconId) or
            (spell.type == "aura" and spell.ConfigID == BOM.CurrentProfile.LastAura) or
            (spell.type == "seal" and spell.ConfigID == BOM.CurrentProfile.LastSeal) then
      spell.frames.Set:SetState(true)
    else
      spell.frames.Set:SetState(false)
    end
  end
end

---UpdateTab - update spells in one of the spell tabs
---BOM.SelectedSpells: table - Spells which were selected for display in Scan function, their
---state will be displayed in a spell tab
function spellButtonsTabModule:UpdateSpellsTab(caller)
  -- InCombat Protection is checked by the caller (Update***Tab)
  if BOM.SelectedSpells == nil then
    return
  end

  if InCombatLockdown() then
    return
  end

  if self.spellTabsCreatedFlag and (spellCacheModule.cacheChanged or itemCacheModule.cacheChanged) then
    --spellSetupModule:SetupAvailableSpells()
    BOM.HideAllManagedButtons()
    self.categoryLabels = {}
    self.spellTabsCreatedFlag = false

    spellCacheModule.cacheChanged = false
    itemCacheModule.cacheChanged = false
  end

  if not self.spellTabsCreatedFlag then
    BOM.HideAllManagedButtons()

    local playerIsHorde = (UnitFactionGroup("player") == "Horde")
    self:CreateTab(playerIsHorde)
    self.spellTabsCreatedFlag = true
  end

  local _className, playerClass, _classId = UnitClass("player")

  for i, spell in ipairs(BOM.SelectedSpells) do
    if type(spell.onlyUsableFor) == "table"
            and not tContains(spell.onlyUsableFor, selfClass) then
      -- skip not usable
      --elseif tContains(allSpellsModule.buffCategories, spell.category) then
    else
      self:UpdateSelectedSpell(spell)
    end
  end -- all spells

  for _i, spell in ipairs(BOM.CancelBuffs) do
    spell.frames.Enable:SetVariable(BOM.CurrentProfile.CancelBuff[spell.ConfigID], "Enable")
  end

  --Create small SINGLE-BUFF toggle to the right of [Cast <spell>]
  BOM.CreateSingleBuffButton(BomC_ListTab) --maybe not created yet?
end

-- ---@param from string Caller of this function, for debug purposes
--function BOM.UpdateSpellsTab(from)
--  spellButtonsTabModule:UpdateSpellsTab()
--end