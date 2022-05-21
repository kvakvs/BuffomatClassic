---| Module contains code to update the already selected spells in tabs
local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomSpellButtonsTabModule
---@field spellTabsCreatedFlag boolean True if spells tab is created and filled
---@field categoryLabels table<string, BomLegacyControl> Collection of category labels indexed per category name
---@field categoryCheckboxes table<string, BomLegacyControl> Collection of category checkboxes indexed per category name
local spellButtonsTabModule = BuffomatModule.DeclareModule("Ui/SpellButtonsTab") ---@type BomSpellButtonsTabModule
spellButtonsTabModule.categoryLabels = {}
spellButtonsTabModule.categoryCheckboxes = {}

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
local _t = BuffomatModule.Import("Languages") ---@type BomLanguagesModule

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
  local tooltip1 = BOM.FormatTexture(BOM.ICON_SELF_CAST_ON) .. " - " .. _t("TooltipSelfCastCheckbox_Self") .. "|n"
          .. BOM.FormatTexture(BOM.ICON_SELF_CAST_OFF) .. " - " .. _t("TooltipSelfCastCheckbox_Party")
  local selfcastToggle = spell.frames:CreateSelfCastToggle(tooltip1)
  selfcastToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  selfcastToggle:SetVariable(profileSpell, "SelfCast")
  rowBuilder:StepRight(selfcastToggle, 0)

  --------------------------------------
  -- Class-Cast checkboxes one per class
  --------------------------------------
  for ci, class in ipairs(BOM.Tool.Classes) do
    local tooltip2 = BOM.Tool.IconClass[class] .. " - " .. _t("TooltipCastOnClass") .. ": " .. BOM.Tool.ClassName[class] .. "|n"
            .. BOM.FormatTexture(BOM.ICON_EMPTY) .. " - " .. _t("TabDoNotBuff") .. ": " .. BOM.Tool.ClassName[class] .. "|n"
            .. BOM.FormatTexture(BOM.ICON_DISABLED) .. " - " .. _t("TabBuffOnlySelf")
    local classToggle = spell.frames:CreateClassToggle(class, tooltip2, bomDoBlessingOnClick)
    spell.frames[class]:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
    spell.frames[class]:SetVariable(profileSpell.Class, class)

    if not BOM.TBC and (-- if not TBC hide paladin for horde, hide shaman for alliance
            (playerIsHorde and class == "PALADIN") or (not playerIsHorde and class == "SHAMAN")) then
      spell.frames[class]:Hide()
    else
      rowBuilder.prevControl = spell.frames[class]
    end
  end -- for each class in class_sort_order

  --========================================
  local tooltip3 = BOM.FormatTexture(BOM.ICON_TANK) .. " - " .. _t("TooltipCastOnTank")
  local tankToggle = spell.frames:CreateTankToggle(tooltip3, bomDoBlessingOnClick)
  tankToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  tankToggle:SetVariable(profileSpell.Class, "tank")
  rowBuilder.prevControl = tankToggle

  --========================================
  local tooltip4 = BOM.FormatTexture(BOM.ICON_PET) .. " - " .. _t("TooltipCastOnPet")
  local petToggle = spell.frames:CreatePetToggle(tooltip4, bomDoBlessingOnClick)
  petToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  petToggle:SetVariable(profileSpell.Class, "pet")
  rowBuilder:StepRight(petToggle, 7)

  -- Force Cast Button -(+)-
  local forceToggle = spell.frames:CreateForceCastToggle(_t("TooltipForceCastOnTarget"), spell)
  forceToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  rowBuilder:StepRight(forceToggle, 0)

  -- Exclude/Ignore Buff Target Button (X)
  local excludeToggle = spell.frames:CreateExcludeToggle(_t("TooltipExcludeTarget"), spell)
  excludeToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
  rowBuilder:StepRight(excludeToggle, 2)
end

---Add a row with spell cancel buttons
---@param spell BomSpellDef - The spell to be canceled
---@param rowBuilder RowBuilder The structure used for building button rows
---@return {dy, prev_control}
function spellButtonsTabModule:AddSpellCancelRow(spell, rowBuilder)
  spell.frames:CreateInfoIcon(spell)

  if rowBuilder.prevControl then
    spell.frames.info:SetPoint("TOPLEFT", rowBuilder.prevControl, "BOTTOMLEFT", 0, -rowBuilder.dy)
  else
    spell.frames.info:SetPoint("TOPLEFT")
  end

  rowBuilder.prevControl = spell.frames.info

  local enableCheckbox = spell.frames:CreateEnableCheckbox(_t("TooltipEnableBuffCancel"))
  enableCheckbox:SetPoint("LEFT", spell.frames.info, "RIGHT", 7, 0)
  enableCheckbox:SetVariable(BOM.CurrentProfile.CancelBuff[spell.ConfigID], "Enable")

  --Add "Only before combat" text label
  spell.frames.OnlyCombat = toolboxModule:CreateSmalltextLabel(
          spell.frames.OnlyCombat,
          BomC_SpellTab_Scroll_Child,
          function(ctrl)
            if spell.OnlyCombat then
              ctrl:SetText(_t("HintCancelThisBuff") .. ": " .. _t("HintCancelThisBuff_Combat"))
            else
              ctrl:SetText(_t("HintCancelThisBuff") .. ": " .. _t("HintCancelThisBuff_Always"))
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

  BOM.Tool.Tooltip(bomSpellSettingsFrames.Settings, _t("TooltipRaidGroupsSettings"))
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
  BOM.Tool.Tooltip(bomSpellSettingsFrames[0], _t("HeaderWatchGroup"))
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
    BOM.Tool.TooltipText(bomSpellSettingsFrames[i], string.format(_t("TooltipGroup"), i))

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

  -- Add a checkbox [x]
  local enableCheckbox = spell.frames:CreateEnableCheckbox(_t("TooltipEnableSpell"))
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
    local whisperToggle = spell.frames:CreateWhisperToggle(_t("TooltipWhisperWhenExpired"))
    whisperToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
    whisperToggle:SetVariable(profileSpell, "Whisper")
    rowBuilder:StepRight(whisperToggle, 2)
  end

  if spell.type == "weapon" then
    -- Add choices for mainhand & offhand
    local mainhandToggle = spell.frames:CreateMainhandToggle(_t("TooltipMainHand"))
    mainhandToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
    mainhandToggle:SetVariable(profileSpell, "MainHandEnable")
    rowBuilder:StepRight(mainhandToggle, 2)

    local offhandToggle = spell.frames:CreateOffhandToggle(_t("TooltipOffHand"))
    offhandToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
    offhandToggle:SetVariable(profileSpell, "OffHandEnable")
    rowBuilder:StepRight(offhandToggle, 2)
  end

  -- Calculate label to the right of the spell config buttons,
  -- spell name and extra text label
  -->>---------------------------
  local buffLabel = spell.frames:CreateBuffLabel("-")
  buffLabel:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", 7, -1)

  spell:GetSingleText(
          function(buffLabelText)
            if spell.type == "weapon" then
              buffLabelText = buffLabelText .. ": " .. BOM.Color("bbbbee", _t("TooltipIncludesAllRanks"))
            elseif spell.extraText then
              buffLabelText = buffLabelText .. ": " .. BOM.Color("bbbbee", spell.extraText)
            end
            buffLabel:SetText(buffLabelText)
          end
  ) -- update when spell loaded

  rowBuilder:StepRight(buffLabel, 7)
  --<<---------------------------

  if BomCharacterState.BuffCategoriesHidden[spell.category] then
    BOM.Print("Hiding category " .. spell.category)
    return -- do not show any controls if spell category is hidden
  end

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

  BomCharacterState.BuffCategoriesHidden = BomCharacterState.BuffCategoriesHidden or {}

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
          _t("FormatAllForceCastTargets"),
          _t("FormatForceCastNone"),
          spell.ForcedTarget or {})
end

---@param spell BomSpellDef
function spellButtonsTabModule:UpdateForcecastTooltip(button, spell)
  local tooltip_force_targets = bomForceTargetsTooltipText(spell)
  BOM.Tool.TooltipText(
          button,
          _t("TooltipForceCastOnTarget") .. "|n"
                  .. string.format(_t("FormatToggleTarget"), BOM.lastTarget)
                  .. tooltip_force_targets)
end

local function bomExcludeTargetsTooltip(spell)
  return bomGetTargetsTooltipText(
          _t("FormatAllExcludeTargets"),
          _t("FormatExcludeNone"),
          spell.ExcludedTarget or {})
end

---@param spell BomSpellDef
function spellButtonsTabModule:UpdateExcludeTargetsTooltip(button, spell)
  local tooltip_exclude_targets = bomExcludeTargetsTooltip(spell)
  BOM.Tool.TooltipText(
          button,
          _t("TooltipExcludeTarget") .. "|n"
                  .. string.format(_t("FormatToggleTarget"), BOM.lastTarget)
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
  local firstRow = rowBuilder.prevControl == nil

  -->>---- Checkbox for category ----
  local buffCatCheckbox = spellButtonsTabModule.categoryCheckboxes[catId]
  if buffCatCheckbox == nil then
    buffCatCheckbox = BOM.CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_OPT_ENABLED,
            BOM.ICON_OPT_DISABLED)
    spellButtonsTabModule.categoryCheckboxes[catId] = buffCatCheckbox
  end
  buffCatCheckbox:SetOnClick(BOM.MyButtonOnClick)
  buffCatCheckbox:SetVariable(BomCharacterState.BuffCategoriesHidden, catId)

  if not firstRow then
    buffCatCheckbox:SetPoint("TOPLEFT", rowBuilder.prevControl, "BOTTOMLEFT", 0, -8)
  else
    buffCatCheckbox:SetPoint("TOPLEFT")
  end

  buffCatCheckbox:Show()

  --<<-------------------------------

  local label = self.categoryLabels[catId]

  if not label then
    label = BomC_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetText(BOM.Color("aaaaaa", self:CategoryLabel(catId)))
    self.categoryLabels[catId] = label
  end

  label:SetPoint("TOPLEFT", buffCatCheckbox, "TOPRIGHT", 0, 0)

  if not firstRow then
    rowBuilder.dy = 12 + 12 -- step 2 lines down
  else
    rowBuilder.dy = 12 -- step 1 line down
  end
end

---@param spell BomSpellDef
function spellButtonsTabModule:UpdateSelectedSpell(spell)
  -- the pointer to spell in current BOM profile
  ---@type BomSpellDef
  local profileSpell = BOM.CurrentProfile.Spell[spell.ConfigID]
  spell.frames.Enable:SetVariable(profileSpell, "Enable")

  if spell:HasClasses() then
    spell.frames.SelfCast:SetVariable(profileSpell, "SelfCast")

    for ci, class in ipairs(BOM.Tool.Classes) do
      spell.frames[class]:SetVariable(profileSpell.Class, class)

      if profileSpell.SelfCast then
        spell.frames[class]:Disable()
      else
        spell.frames[class]:Enable()
      end
    end -- for all class names

    spell.frames["tank"]:SetVariable(profileSpell.Class, "tank")
    spell.frames["pet"]:SetVariable(profileSpell.Class, "pet")

    if profileSpell.SelfCast then
      spell.frames["tank"]:Disable()
      spell.frames["pet"]:Disable()
    else
      spell.frames["tank"]:Enable()
      spell.frames["pet"]:Enable()
    end

    --========================================
    local forceCastButton = spell.frames.ForceCastButton ---@type BomLegacyControl
    local excludeButton = spell.frames.ExcludeButton ---@type BomLegacyControl

    if BOM.lastTarget ~= nil then
      -------------------------
      forceCastButton:Enable()
      self:UpdateForcecastTooltip(forceCastButton, profileSpell)

      local spellForcedTarget = profileSpell.ForcedTarget
      local lastTarget = BOM.lastTarget

      forceCastButton:SetScript("OnClick", function(self)
        if spellForcedTarget[lastTarget] == nil then
          BOM:Print(BOM.FormatTexture(BOM.ICON_TARGET_ON) .. " "
                  .. _t("MessageAddedForced") .. ": " .. lastTarget)
          spellForcedTarget[lastTarget] = lastTarget
        else
          BOM:Print(BOM.FormatTexture(BOM.ICON_TARGET_ON) .. " "
                  .. _t("MessageClearedForced") .. ": " .. lastTarget)
          spellForcedTarget[lastTarget] = nil
        end
        self:UpdateForcecastTooltip(self, profileSpell)
      end)
      -------------------------
      excludeButton:Enable()
      self:UpdateExcludeTargetsTooltip(excludeButton, profileSpell)

      local spell_exclude = profileSpell.ExcludedTarget
      lastTarget = BOM.lastTarget

      excludeButton:SetScript("OnClick", function(self)
        if spell_exclude[lastTarget] == nil then
          BOM:Print(BOM.FormatTexture(BOM.ICON_TARGET_EXCLUDE) .. " "
                  .. _t("MessageAddedExcluded") .. ": " .. lastTarget)
          spell_exclude[lastTarget] = lastTarget
        else
          BOM:Print(BOM.FormatTexture(BOM.ICON_TARGET_EXCLUDE) .. " "
                  .. _t("MessageClearedExcluded") .. ": " .. lastTarget)
          spell_exclude[lastTarget] = nil
        end
        self:UpdateExcludeTargetsTooltip(self, profileSpell)
      end)

    else
      --======================================
      forceCastButton:Disable()
      BOM.Tool.TooltipText(
              forceCastButton,
              _t("TooltipForceCastOnTarget") .. "|n" .. _t("TooltipSelectTarget")
                      .. bomForceTargetsTooltipText(profileSpell))
      --force_cast_button:SetVariable()
      ---------------------------------
      excludeButton:Disable()
      BOM.Tool.TooltipText(
              excludeButton,
              _t("TooltipExcludeTarget") .. "|n" .. _t("TooltipSelectTarget")
                      .. bomExcludeTargetsTooltip(profileSpell))
      --exclude_button:SetVariable()
    end
  end -- end if has classes

  if spell.isInfo and spell.allowWhisper then
    spell.frames.Whisper:SetVariable(profileSpell, "Whisper")
  end

  if spell.type == "weapon" then
    spell.frames.MainHand:SetVariable(profileSpell, "MainHandEnable")
    spell.frames.OffHand:SetVariable(profileSpell, "OffHandEnable")
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