---| Module contains code to update the already selected spells in tabs
--local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomSpellButtonsTabModule
---@field spellTabsCreatedFlag boolean True if spells tab is created and filled
---@field categoryLabels table<string, BomGPIControl> Collection of category labels indexed per category name
---@field spellTabUpdateRequestedBy table<number, string> Contains the callers who last requested spells tab update, or nothing
local spellButtonsTabModule = {
  categoryLabels            = {},
  spellTabUpdateRequestedBy = {},
}
BomModuleManager.spellButtonsTabModule = spellButtonsTabModule

local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffDefModule = BomModuleManager.buffDefinitionModule
local buffomatModule = BomModuleManager.buffomatModule
local buffRowModule = BomModuleManager.buffRowModule
local managedUiModule = BomModuleManager.myButtonModule
local optionsPopupModule = BomModuleManager.optionsPopupModule
local profileModule = BomModuleManager.profileModule
local rowBuilderModule = BomModuleManager.rowBuilderModule
local toolboxModule = BomModuleManager.toolboxModule

---@deprecated
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
      buffomatModule.currentProfile.Spell[spell.buffId].Class[self._privat_Var] = false
    end
  end
  self._privat_DB[self._privat_Var] = saved

  managedUiModule:UpdateAll()
  buffomatModule:OptionsUpdate()
end

-- accessible from TaskScan.MaybeResetWatchGroups
spellButtonsTabModule.spellSettingsFrames = {}

---Add some clickable elements to Spell Tab row with all classes
---@param rowBuilder BomRowBuilder The structure used for building button rows
---@param playerIsHorde boolean Whether we are the horde
---@param spell BomBuffDefinition The spell currently being displayed
function spellButtonsTabModule:AddSpellRow_ClassSelector(rowBuilder, playerIsHorde, spell, profileSpell)
  local tooltip1 = BOM.FormatTexture(texturesModule.ICON_SELF_CAST_ON) .. " - " .. _t("TooltipSelfCastCheckbox_Self") .. "|n"
          .. BOM.FormatTexture(texturesModule.ICON_SELF_CAST_OFF) .. " - " .. _t("TooltipSelfCastCheckbox_Party")
  local selfcastToggle = spell.frames:CreateSelfCastToggle(tooltip1)
  rowBuilder:ChainToTheRight(nil, selfcastToggle, 5)
  selfcastToggle:SetVariable(profileSpell, "SelfCast")

  --------------------------------------
  -- Class-Cast checkboxes one per class
  --------------------------------------
  for ci, class in ipairs(BOM.Tool.Classes) do
    local tooltip2 = BOM.Tool.IconClass[class] .. " - " .. _t("TooltipCastOnClass") .. ": " .. BOM.Tool.ClassName[class] .. "|n"
            .. BOM.FormatTexture(texturesModule.ICON_EMPTY) .. " - " .. _t("TabDoNotBuff") .. ": " .. BOM.Tool.ClassName[class] .. "|n"
            .. BOM.FormatTexture(texturesModule.ICON_DISABLED) .. " - " .. _t("TabBuffOnlySelf")
    local classToggle = spell.frames:CreateClassToggle(class, tooltip2, bomDoBlessingOnClick)
    classToggle:SetVariable(profileSpell.Class, class)
    rowBuilder:ChainToTheRight(nil, classToggle, 0)

    if not BOM.haveTBC and (-- if not TBC hide paladin for horde, hide shaman for alliance
            (playerIsHorde and class == "PALADIN") or (not playerIsHorde and class == "SHAMAN")) then
      classToggle:Hide()
    else
      rowBuilder.prevControl = classToggle
    end
  end -- for each class in class_sort_order

  --========================================
  local tooltip3 = BOM.FormatTexture(BOM.ICON_TANK) .. " - " .. _t("TooltipCastOnTank")
  local tankToggle = spell.frames:CreateTankToggle(tooltip3, bomDoBlessingOnClick)
  tankToggle:SetVariable(profileSpell.Class, "tank")
  rowBuilder:ChainToTheRight(nil, tankToggle, 0)
  rowBuilder.prevControl = tankToggle

  --========================================
  local tooltip4 = BOM.FormatTexture(BOM.ICON_PET) .. " - " .. _t("TooltipCastOnPet")
  local petToggle = spell.frames:CreatePetToggle(tooltip4, bomDoBlessingOnClick)
  petToggle:SetVariable(profileSpell.Class, "pet")
  rowBuilder:ChainToTheRight(nil, petToggle, 5)

  -- Force Cast Button -(+)-
  local forceToggle = spell.frames:CreateForceCastToggle(_t("TooltipForceCastOnTarget"), spell)
  rowBuilder:ChainToTheRight(nil, forceToggle, 0)

  -- Exclude/Ignore Buff Target Button (X)
  local excludeToggle = spell.frames:CreateExcludeToggle(_t("TooltipExcludeTarget"), spell)
  rowBuilder:ChainToTheRight(nil, excludeToggle, 2)
end

---Add a row with spell cancel buttons
---@param spell BomBuffDefinition - The spell to be canceled
---@param rowBuilder BomRowBuilder The structure used for building button rows
---@return {dy, prev_control}
function spellButtonsTabModule:AddSpellCancelRow(spell, rowBuilder)
  local infoIcon = spell.frames:CreateInfoIcon(spell)
  rowBuilder:PositionAtNewRow(infoIcon, 0, 7)
  infoIcon:Show()

  local enableCheckbox = spell.frames:CreateEnableCheckbox(_t("TooltipEnableBuffCancel"))
  rowBuilder:ChainToTheRight(infoIcon, enableCheckbox, 7)
  enableCheckbox:SetVariable(buffomatModule.currentProfile.CancelBuff[spell.buffId], "Enable")
  enableCheckbox:Show()

  --Add "Only before combat" text label
  spell.frames.cancelBuffLabel = toolboxModule:CreateSmalltextLabel(
          spell.frames.cancelBuffLabel,
          BomC_SpellTab_Scroll_Child,
          function(ctrl)
            if spell.onlyCombat then
              ctrl:SetText(_t("HintCancelThisBuff") .. ": " .. _t("HintCancelThisBuff_Combat"))
            else
              ctrl:SetText(_t("HintCancelThisBuff") .. ": " .. _t("HintCancelThisBuff_Always"))
            end

            rowBuilder.dy = 3
            rowBuilder:ChainToTheRight(nil, ctrl)
          end)
  spell.frames.cancelBuffLabel:Show()
end

---@param rowBuilder BomRowBuilder The structure used for building button rows
function spellButtonsTabModule:AddGroupScanSelector(rowBuilder)
  -------------------------
  -- Add settings frame with icon, icon is not clickable
  -------------------------
  if self.spellSettingsFrames.Settings == nil then
    self.spellSettingsFrames.Settings = managedUiModule:CreateManagedButton(
            BomC_SpellTab_Scroll_Child,
            texturesModule.ICON_GEAR,
            nil,
            nil,
            texturesModule.ICONCOORD,
            nil, nil, "groupScanSelector.icon")
  end

  toolboxModule:Tooltip(self.spellSettingsFrames.Settings, _t("TooltipRaidGroupsSettings"))
  rowBuilder:PositionAtNewRow(self.spellSettingsFrames.Settings, 0, 7)
  rowBuilder.dx = 7

  ------------------------------
  -- Add "Watch Group #" buttons
  ------------------------------
  for i = 1, 8 do
    if self.spellSettingsFrames[i] == nil then
      self.spellSettingsFrames[i] = managedUiModule:CreateManagedButton(
              BomC_SpellTab_Scroll_Child,
              texturesModule.ICON_GROUP_ITEM,
              texturesModule.ICON_GROUP_NONE,
              nil, nil, nil, nil, "groupScanSelector." .. tostring(i))
    end

    rowBuilder:ChainToTheRight(nil, self.spellSettingsFrames[i], 2)
    self.spellSettingsFrames[i]:SetVariable(buffomatModule.character.WatchGroup, i)
    self.spellSettingsFrames[i]:SetText(i)
    toolboxModule:TooltipText(self.spellSettingsFrames[i], string.format(_t("TooltipGroup"), i))
    self.spellSettingsFrames[i]:Show()

    -- Let the MyButton library function handle the data update, and update the tab text too
    self.spellSettingsFrames[i]:SetOnClick(function()
      BOM.MyButtonOnClick(self)
      buffomatModule:UpdateBuffTabText()
    end)
  end

  self.spellSettingsFrames.Settings:Show()

  for i, set in ipairs(optionsPopupModule.behaviourSettings) do
    if self.spellSettingsFrames[set[1]] then
      self.spellSettingsFrames[set[1]]:Show()
    end
    if self.spellSettingsFrames[set[1] .. "txt"] then
      self.spellSettingsFrames[set[1] .. "txt"]:Show()
    end
  end
end

---@param category string
---@return boolean
-- TODO: Move this to spelldef
function spellButtonsTabModule:CategoryIsHidden(category)
  return buffomatModule.character.BuffCategoriesHidden[category] == true
end

---Creates a row
---@param playerIsHorde boolean Whether we're the horde
---@param spell BomBuffDefinition Spell we're adding now
---@param rowBuilder BomRowBuilder The structure used for building button rows
---@param playerClass string Character class
function spellButtonsTabModule:AddSpellRow(rowBuilder, playerIsHorde, spell, playerClass)
  --if self:CategoryIsHidden(spell.category) then
  --  return -- do not show any controls if spell category is hidden
  --end

  -- Create buff icon with tooltip
  local infoIcon = spell.frames:CreateInfoIcon(spell)
  rowBuilder:PositionAtNewRow(infoIcon, 0, 7)

  local profileSpell = buffDefModule:GetProfileBuff(spell.buffId)

  -- Add a checkbox [x]
  local enableCheckbox = spell.frames:CreateEnableCheckbox(_t("TooltipEnableSpell"))
  enableCheckbox:SetVariable(profileSpell, "Enable")
  rowBuilder:ChainToTheRight(nil, enableCheckbox, 7)

  if spell:HasClasses() then
    -- Create checkboxes one per class
    self:AddSpellRow_ClassSelector(rowBuilder, playerIsHorde, spell, profileSpell)
  end

  -- Add checkbox for spells which can be enabled and present at the same time?
  -->>------------------------------
  if (spell.type == "tracking"
          or spell.type == "aura"
          or spell.type == "seal")
          and spell.requiresForm == nil then
    local statusImage = spell.frames:CreateStatusCheckboxImage(spell)
    statusImage:SetPoint("TOPLEFT", infoIcon, "TOPRIGHT", rowBuilder.dx, 0)
    rowBuilder:SpaceToTheRight(statusImage, 7)
  end
  --<<------------------------------

  ----------------------------------
  if spell.isInfo and spell.allowWhisper then
    local whisperToggle = spell.frames:CreateWhisperToggle(_t("TooltipWhisperWhenExpired"))
    whisperToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
    whisperToggle:SetVariable(profileSpell, "Whisper")
    rowBuilder:SpaceToTheRight(whisperToggle, 2)
  end

  ----------------------------------
  if spell.type == "weapon" then
    -- Add choices for mainhand & offhand
    local mainhandToggle = spell.frames:CreateMainhandToggle(_t("TooltipMainHand"))
    mainhandToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
    mainhandToggle:SetVariable(profileSpell, "MainHandEnable")
    rowBuilder:SpaceToTheRight(mainhandToggle, 2)

    local offhandToggle = spell.frames:CreateOffhandToggle(_t("TooltipOffHand"))
    offhandToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
    offhandToggle:SetVariable(profileSpell, "OffHandEnable")
    rowBuilder:SpaceToTheRight(offhandToggle, 2)
  end

  -- Calculate label to the right of the spell config buttons,
  -- spell name and extra text label
  -->>---------------------------
  local buffLabel = spell.frames:CreateBuffLabel("-")
  buffLabel:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", 7, -1)
  managedUiModule:ManageControl(tostring(spell.buffId) .. ".buffLabel", buffLabel)

  spell:GetSingleText(
          function(buffLabelText)
            if spell.type == "weapon" then
              buffLabelText = buffLabelText .. ": " .. buffomatModule:Color("bbbbee", _t("TooltipIncludesAllRanks"))
            elseif spell.extraText then
              buffLabelText = buffLabelText .. ": " .. buffomatModule:Color("bbbbee", spell.extraText)
            end
            buffLabel:SetText(buffLabelText)
          end
  ) -- update when spell loaded

  rowBuilder:SpaceToTheRight(buffLabel, 7)
  --<<---------------------------

  --infoIcon:Show()
  --enableCheckbox:Show()
  --
  --if spell:HasClasses() then
  --  spell.frames.toggleSelfCast:Show()
  --  spell.frames.toggleForceCast:Show()
  --  spell.frames.toggleExclude:Show()
  --
  --  for ci, class in ipairs(BOM.Tool.Classes) do
  --    if not BOM.IsTBC and -- if not TBC, hide paladin for horde, hide shaman for alliance
  --            ((playerIsHorde and class == "PALADIN") or (not playerIsHorde and class == "SHAMAN")) then
  --      spell.frames[class]:Hide()
  --    else
  --      spell.frames[class]:Show()
  --    end
  --  end
  --
  --  spell.frames.tank:Show()
  --  spell.frames.pet:Show()
  --end
  --
  --if spell.frames.checkboxSet then
  --  spell.frames.checkboxSet:Show()
  --end
  --
  --if buffLabel then
  --  buffLabel:Show()
  --end
  --
  --if spell.frames.toggleWhisper then
  --  spell.frames.toggleWhisper:Show()
  --end
  --
  --if spell.frames.toggleMainHand then
  --  spell.frames.toggleMainHand:Show()
  --end
  --
  --if spell.frames.toggleOffHand then
  --  spell.frames.toggleOffHand:Show()
  --end

  -- Finished building a row, set the icon frame for this row to be the anchor
  -- point for the next
  rowBuilder.prevControl = infoIcon
end

---Filter all known spells through current player spellbook.
---Called below from BOM.UpdateSpellsTab()
function spellButtonsTabModule:CreateTab(playerIsHorde)
  local rowBuilder = rowBuilderModule:new()
  local _, selfClass, _ = UnitClass("player")

  buffomatModule.character.BuffCategoriesHidden = buffomatModule.character.BuffCategoriesHidden or {}

  for j, cat in ipairs(allBuffsModule.buffCategories) do
    if not self:CategoryIsHidden(cat) then
      for i, spell in ipairs(BOM.SelectedSpells) do -- for all spells known by Buffomat and the player
        if spell.category ~= cat -- category has changed from the previous row
                or (type(spell.onlyUsableFor) == "table"
                and not tContains(spell.onlyUsableFor, selfClass)) then
          -- skip not usable
        else
          if not rowBuilder.categories[cat] then -- if category header was not yet added
            rowBuilder.categories[cat] = true
            self:AddCategoryRow(cat, rowBuilder) -- only add once if ever found one in that category
          else -- category header was already added
            rowBuilder.dy = 2 -- step down 2 px between rows
          end

          self:AddSpellRow(rowBuilder, playerIsHorde, spell, selfClass)
        end -- if category of the spell == cat
      end -- for selected spells
    else -- cat is hidden
      -- Label for hidden category might still be visible from the time before
      if self.categoryLabels[cat] then
        self.categoryLabels[cat]:Hide()
      end
    end -- if cat is hidden
  end -- for buff categories

  rowBuilder.dy = 12

  --
  -- Add spell cancel buttons for all spells in CancelBuffs
  -- (and CustomCancelBuffs which user can add manually in the config file)
  --
  for i, spell in ipairs(BOM.cancelBuffs) do
    self:AddSpellCancelRow(spell, rowBuilder)
  end

  --if rowBuilder.prev_control then
  self:AddGroupScanSelector(rowBuilder)
  --end
end

---Build a tooltip string to add to the target force-cast or exclude button
---@param prefix string - if table is not empty, will prefix tooltip with this string
---@param empty_text string - if table is empty, use this text
---@param name_table table - keys from table are formatted comma-separated
function spellButtonsTabModule:GetTargetsTooltipText(prefix, empty_text, name_table)
  local text = ""
  for name, value in pairs(name_table) do
    if value then
      if text ~= "" then
        text = text .. ", "
      end
      text = text .. buffomatModule:Color("ffffff", name)
    end
  end

  if text == "" then
    return "|n" .. empty_text
  else
    return "|n" .. prefix .. text
  end
end

function spellButtonsTabModule:ForceTargetsTooltipText(spell)
  return self:GetTargetsTooltipText(
          _t("FormatAllForceCastTargets"),
          _t("FormatForceCastNone"),
          spell.ForcedTarget or {})
end

---@param spell BomBuffDefinition
function spellButtonsTabModule:UpdateForcecastTooltip(button, spell)
  local tooltip_force_targets = self:ForceTargetsTooltipText(spell)
  toolboxModule:TooltipText(
          button,
          _t("TooltipForceCastOnTarget") .. "|n"
                  .. string.format(_t("FormatToggleTarget"), buffomatModule:Color("ffffff", BOM.lastTarget))
                  .. tooltip_force_targets)
end

function spellButtonsTabModule:ExcludeTargetsTooltip(spell)
  return self:GetTargetsTooltipText(
          _t("FormatAllExcludeTargets"),
          _t("FormatExcludeNone"),
          spell.ExcludedTarget or {})
end

---@param spell BomBuffDefinition
function spellButtonsTabModule:UpdateExcludeTargetsTooltip(button, spell)
  local tooltip_exclude_targets = self:ExcludeTargetsTooltip(spell)
  toolboxModule:TooltipText(
          button,
          _t("TooltipExcludeTarget") .. "|n"
                  .. string.format(_t("FormatToggleTarget"), buffomatModule:Color("ffffff", BOM.lastTarget))
                  .. tooltip_exclude_targets)
end

function spellButtonsTabModule:CategoryLabel(catId)
  if not catId then
    return L["Category_none"]
  end
  return L["Category_" .. catId]
end

---Takes a category id from allBuffsModule constants, and adds a nice text title
---with localised category name
---@param rowBuilder BomRowBuilder
function spellButtonsTabModule:AddCategoryRow(catId, rowBuilder)
  local label = self.categoryLabels[catId]

  if not label then
    label = BomC_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  end

  label:Show()
  label:SetText(buffomatModule:Color("aaaaaa", self:CategoryLabel(catId)))
  managedUiModule:ManageControl(catId .. "categoryTitleLabel", label)
  self.categoryLabels[catId] = label

  rowBuilder:PositionAtNewRow(label, 6)
  --rowBuilder:ChainToTheRight(buffCatCheckbox, label)
  rowBuilder.dy = 4 -- step down a little
end

---@param spell BomBuffDefinition
function spellButtonsTabModule:UpdateSelectedSpell(spell)
  -- temp fix
  if not spell.frames.checkboxEnable then
    return
  end

  -- the pointer to spell in current BOM profile
  ---@type BomBuffDefinition
  local profileSpell = buffomatModule.currentProfile.Spell[spell.buffId]
  spell.frames.checkboxEnable:SetVariable(profileSpell, "Enable")

  if spell:HasClasses() then
    spell.frames.toggleSelfCast:SetVariable(profileSpell, "SelfCast")

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
    local forceCastButton = spell.frames.toggleForceCast ---@type BomGPIControl
    local excludeButton = spell.frames.toggleExclude ---@type BomGPIControl

    if BOM.lastTarget ~= nil then
      -------------------------
      forceCastButton:Enable()
      self:UpdateForcecastTooltip(forceCastButton, profileSpell)

      local spellForcedTarget = profileSpell.ForcedTarget
      local lastTarget = BOM.lastTarget

      forceCastButton:SetScript("OnClick", function(self)
        if spellForcedTarget[lastTarget] == nil then
          buffomatModule:P(BOM.FormatTexture(texturesModule.ICON_TARGET_ON) .. " "
                  .. _t("MessageAddedForced") .. ": " .. lastTarget)
          spellForcedTarget[lastTarget] = lastTarget
        else
          buffomatModule:P(BOM.FormatTexture(texturesModule.ICON_TARGET_ON) .. " "
                  .. _t("MessageClearedForced") .. ": " .. lastTarget)
          spellForcedTarget[lastTarget] = nil
        end
        spellButtonsTabModule:UpdateForcecastTooltip(self, profileSpell)
      end)
      -------------------------
      excludeButton:Enable()
      self:UpdateExcludeTargetsTooltip(excludeButton, profileSpell)

      local spell_exclude = profileSpell.ExcludedTarget
      lastTarget = BOM.lastTarget

      excludeButton:SetScript("OnClick", function(control)
        if spell_exclude[lastTarget] == nil then
          buffomatModule:P(BOM.FormatTexture(texturesModule.ICON_TARGET_EXCLUDE) .. " "
                  .. _t("MessageAddedExcluded") .. ": " .. lastTarget)
          spell_exclude[lastTarget] = lastTarget
        else
          buffomatModule:P(BOM.FormatTexture(texturesModule.ICON_TARGET_EXCLUDE) .. " "
                  .. _t("MessageClearedExcluded") .. ": " .. lastTarget)
          spell_exclude[lastTarget] = nil
        end
        spellButtonsTabModule:UpdateExcludeTargetsTooltip(control, profileSpell)
      end)

    else
      --======================================
      forceCastButton:Disable()
      toolboxModule:TooltipText(
              forceCastButton,
              _t("TooltipForceCastOnTarget") .. "|n" .. _t("TooltipSelectTarget")
                      .. self:ForceTargetsTooltipText(profileSpell))
      --force_cast_button:SetVariable()
      ---------------------------------
      excludeButton:Disable()
      toolboxModule:TooltipText(
              excludeButton,
              _t("TooltipExcludeTarget") .. "|n" .. _t("TooltipSelectTarget")
                      .. self:ExcludeTargetsTooltip(profileSpell))
      --exclude_button:SetVariable()
    end
  end -- end if has classes

  if spell.isInfo and spell.allowWhisper then
    spell.frames.toggleWhisper:SetVariable(profileSpell, "Whisper")
  end

  if spell.type == "weapon" then
    spell.frames.toggleMainHand:SetVariable(profileSpell, "MainHandEnable")
    spell.frames.toggleOffHand:SetVariable(profileSpell, "OffHandEnable")
  end

  if (spell.type == "tracking"
          or spell.type == "aura"
          or spell.type == "seal") and spell.requiresForm == nil
  then
    if (spell.type == "tracking" and buffomatModule.character.LastTracking == spell.trackingIconId) or
            (spell.type == "aura" and spell.buffId == buffomatModule.currentProfile.LastAura) or
            (spell.type == "seal" and spell.buffId == buffomatModule.currentProfile.LastSeal) then
      spell.frames.checkboxSet:SetState(true)
    else
      spell.frames.checkboxSet:SetState(false)
    end
  end
end

function spellButtonsTabModule:HideAllControls()
  managedUiModule:HideAllManagedButtons()

  for cat, frame in ipairs(self.categoryLabels) do
    frame:Hide()
    --frame:SetParent(nil)
    frame:ClearAllPoints()
  end

  -- Keep labels hidden
  --wipe(self.categoryLabels)

  --BomC_SpellTab_Scroll_Child
  for _i, spell in ipairs(allBuffsModule.allBuffs) do
    if self:CategoryIsHidden(spell.category) then
      spell.frames:Destroy()
      spell.frames = buffRowModule:New(tostring(spell.singleId))
    else
      spell.frames:Hide()
    end
  end
end

---UpdateTab - update spells in one of the spell tabs
---BOM.SelectedSpells: table - Spells which were selected for display in Scan function, their
---state will be displayed in a spell tab
---@return boolean Whether update has happened
function spellButtonsTabModule:UpdateSpellsTab_Throttled()
  if next(self.spellTabUpdateRequestedBy) == nil then
    return false -- nothing to do
  end

  -- Debug: Print the list who requrested the update
  -- buffomatModule:PrintCallers("Upd spells tab: ", self.spellTabUpdateRequestedBy)
  wipe(self.spellTabUpdateRequestedBy)

  -- InCombat Protection is checked by the caller (Update***Tab)
  if BOM.SelectedSpells == nil then
    return false
  end

  if InCombatLockdown() then
    return false
  end

  buffomatModule:UseProfile(profileModule:ChooseProfile())
  self:HideAllControls()
  self:CreateTab(UnitFactionGroup("player") == "Horde")

  local _className, playerClass, _classId = UnitClass("player")

  for i, spell in ipairs(BOM.SelectedSpells) do
    if self:CategoryIsHidden(spell.category) then
      -- nothing, is hidden
    elseif type(spell.onlyUsableFor) == "table"
            and not tContains(spell.onlyUsableFor, playerClass) then
      -- skip not usable
      --elseif tContains(allBuffsModule.buffCategories, spell.category) then
    else
      self:UpdateSelectedSpell(spell)
    end
  end -- all spells

  for _i, spell in ipairs(BOM.cancelBuffs) do
    spell.frames.checkboxEnable:SetVariable(buffomatModule.currentProfile.CancelBuff[spell.buffId], "Enable")
  end

  --Create small SINGLE-BUFF toggle to the right of [Cast <spell>]
  BOM.CreateSingleBuffButton(BomC_ListTab) --maybe not created yet?
  return true
end

---Record the need to update spells tab, but the actual update is called on a timer
function spellButtonsTabModule:UpdateSpellsTab(caller)
  table.insert(self.spellTabUpdateRequestedBy, caller)
end
