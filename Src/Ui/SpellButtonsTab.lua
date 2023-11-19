---| Module contains code to update the already selected spells in tabs
--local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@shape BomSpellButtonsTabModule
---@field spellTabsCreatedFlag boolean True if spells tab is created and filled
---@field categoryLabels table<BomBuffCategoryName, BomGPIControl> Collection of category labels indexed per category name
---@field spellTabUpdateRequestedBy table<string, boolean> Contains the callers who last requested spells tab update, or nothing
---@field spellSettingsFrames table
local spellButtonsTabModule = BomModuleManager.spellButtonsTabModule ---@type BomSpellButtonsTabModule
spellButtonsTabModule.categoryLabels = {}
spellButtonsTabModule.spellTabUpdateRequestedBy = {}
spellButtonsTabModule.spellSettingsFrames = {} -- accessible from TaskScan.MaybeResetWatchGroups

local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule
local buffDefModule = BomModuleManager.buffDefinitionModule
local buffRowModule = BomModuleManager.buffRowModule
local buffomatModule = BomModuleManager.buffomatModule
local constModule = BomModuleManager.constModule
local envModule = KvModuleManager.envModule
local managedUiModule = BomModuleManager.myButtonModule
local profileModule = BomModuleManager.profileModule
local rowBuilderModule = BomModuleManager.rowBuilderModule
local texturesModule = BomModuleManager.texturesModule
local toolboxModule = BomModuleManager.toolboxModule

local function bomDoBlessingOnClick(self)
  local saved = self.gpiDict[self.gpiVariableName]

  for i, buffDef in ipairs(allBuffsModule.selectedBuffs) do
    if buffDef.isBlessing then
      -- TODO: use spell instead of BOM.CurrentProfile.Spell[]
      buffomatModule.currentProfile.Spell[buffDef.buffId].Class[self.gpiVariableName] = false
    end
  end
  self.gpiDict[self.gpiVariableName] = saved

  managedUiModule:UpdateAll()
  buffomatModule:OptionsUpdate()
end

---Add some clickable elements to Spell Tab row with all classes
---@param rowBuilder BomRowBuilder The structure used for building button rows
---@param playerIsHorde boolean Whether we are the horde
---@param spell BomBuffDefinition The spell currently being displayed
function spellButtonsTabModule:AddSpellRow_ClassSelector(rowBuilder, playerIsHorde, spell, profileSpell)
  local tooltip1 = BOM.FormatTexture(texturesModule.ICON_SELF_CAST_ON) .. " - " .. _t("TooltipSelfCastCheckbox_Self") .. "|n"
          .. BOM.FormatTexture(texturesModule.ICON_SELF_CAST_OFF) .. " - " .. _t("TooltipSelfCastCheckbox_Party")
  local selfcastToggle = spell.frames:CreateSelfCastToggle(tooltip1)
  rowBuilder:ChainToTheRight(nil, selfcastToggle, 5)
  selfcastToggle:SetVariable(profileSpell, "SelfCast", nil)

  --------------------------------------
  -- Class-Cast checkboxes one per class
  --------------------------------------
  for _, class in ipairs(constModule.CLASSES) do
    local tooltip2 = constModule.CLASS_ICONS[class]
            .. " - " .. _t("TooltipCastOnClass")
            .. ": " .. constModule.CLASS_NAME[--[[---@type BomClassName]] class] .. "|n"
            .. BOM.FormatTexture(texturesModule.ICON_EMPTY) .. " - " .. _t("TabDoNotBuff")
            .. ": " .. constModule.CLASS_NAME[--[[---@type BomClassName]] class] .. "|n"
            .. BOM.FormatTexture(texturesModule.ICON_DISABLED) .. " - " .. _t("TabBuffOnlySelf")

    local classToggle = spell.frames:CreateClassToggle(class, tooltip2, bomDoBlessingOnClick)
    classToggle:SetVariable(profileSpell.Class, class, nil)
    rowBuilder:ChainToTheRight(nil, classToggle, 0)

    if not envModule.haveTBC and (-- if not TBC hide paladin for horde, hide shaman for alliance
            (playerIsHorde and class == "PALADIN") or (not playerIsHorde and class == "SHAMAN")) then
      classToggle:Hide()
    else
      rowBuilder.prevControl = classToggle
    end
  end -- for each class in class_sort_order

  --========================================
  local tooltip3 = BOM.FormatTexture(texturesModule.ICON_TANK) .. " - " .. _t("TooltipCastOnTank")
  local tankToggle = spell.frames:CreateTankToggle(tooltip3, bomDoBlessingOnClick)
  tankToggle:SetVariable(profileSpell.Class, "tank", nil)
  rowBuilder:ChainToTheRight(nil, tankToggle, 0)
  rowBuilder.prevControl = tankToggle

  --========================================
  local tooltip4 = BOM.FormatTexture(texturesModule.ICON_PET) .. " - " .. _t("TooltipCastOnPet")
  local petToggle = spell.frames:CreatePetToggle(tooltip4, bomDoBlessingOnClick)
  petToggle:SetVariable(profileSpell.Class, "pet", nil)
  rowBuilder:ChainToTheRight(nil, petToggle, 5)

  -- Force Cast Button -(+)-
  local forceToggle = spell.frames:CreateForceCastToggle(_t("TooltipForceCastOnTarget"), spell)
  rowBuilder:ChainToTheRight(nil, forceToggle, 0)

  -- Exclude/Ignore Buff Target Button (X)
  local excludeToggle = spell.frames:CreateExcludeToggle(_t("TooltipExcludeTarget"), spell)
  rowBuilder:ChainToTheRight(nil, excludeToggle, 2)
end

---Add a row with spell cancel buttons
---@param buffDef BomBuffDefinition - The spell to be canceled
---@param rowBuilder BomRowBuilder The structure used for building button rows
function spellButtonsTabModule:AddSpellCancelRow(buffDef, rowBuilder)
  local infoIcon = buffDef.frames:CreateInfoIcon(buffDef)
  rowBuilder:PositionAtNewRow(infoIcon, 0, 7)
  infoIcon:Show()

  local enableCheckbox = buffDef.frames:CreateEnableCheckbox(_t("TooltipEnableBuffCancel"))
  rowBuilder:ChainToTheRight(infoIcon, enableCheckbox, 7)
  enableCheckbox:SetVariable(buffomatModule.currentProfile.CancelBuff[buffDef.buffId], "Enable", nil)
  enableCheckbox:Show()

  --Add "Only before combat" text label
  local positionFn = function(ctrl)
    if buffDef.onlyCombat then
      ctrl:SetText(_t("HintCancelThisBuff") .. ": " .. _t("HintCancelThisBuff_Combat"))
    else
      ctrl:SetText(_t("HintCancelThisBuff") .. ": " .. _t("HintCancelThisBuff_Always"))
    end

    rowBuilder.dy = 3
    rowBuilder:ChainToTheRight(nil, ctrl, nil)
  end
  buffDef.frames.cancelBuffLabel = toolboxModule:CreateSmalltextLabel(
          buffDef.frames.cancelBuffLabel,
          BomC_SpellTab_Scroll_Child,
          positionFn)
  buffDef.frames.cancelBuffLabel:Show()
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
            texturesModule.ICON_COORD_09,
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
end

---TODO: Move this to spelldef
---@param category BomBuffCategoryName
---@return boolean
function spellButtonsTabModule:CategoryIsHidden(category)
  return buffomatModule.character.BuffCategoriesHidden[category] == true
end

---Creates a row
---@param playerIsHorde boolean Whether we're the horde
---@param buff BomBuffDefinition Spell we're adding now
---@param rowBuilder BomRowBuilder The structure used for building button rows
function spellButtonsTabModule:AddSpellRow(rowBuilder, playerIsHorde, buff)
  local profileBuff = buffDefModule:GetProfileBuff(buff.buffId, nil)
  if profileBuff == nil then
    return
  end

  -- Create buff icon with tooltip
  local infoIcon = buff.frames:CreateInfoIcon(buff)
  rowBuilder:PositionAtNewRow(infoIcon, 0, 7)

  -- Add a checkbox [x]
  local enableCheckbox = buff.frames:CreateEnableCheckbox(_t("TooltipEnableSpell"))
  enableCheckbox:SetVariable(--[[---@not nil]] profileBuff, "Enable", nil)
  rowBuilder:ChainToTheRight(nil, enableCheckbox, 7)

  if buff:HasClasses() then
    -- Create checkboxes one per class
    self:AddSpellRow_ClassSelector(rowBuilder, playerIsHorde, buff, profileBuff)
  end

  -- Add checkbox for spells which can be enabled and present at the same time?
  -->>------------------------------
  if (buff.type == "tracking"
          or buff.type == "aura"
          or buff.type == "seal")
          and buff.requiresForm == nil then
    local statusImage = buff.frames:CreateStatusCheckboxImage(buff)
    statusImage:SetPoint("TOPLEFT", infoIcon, "TOPRIGHT", rowBuilder.dx, 0)
    rowBuilder:SpaceToTheRight(statusImage, 7)
  end
  --<<------------------------------

  ----------------------------------
  if buff.isInfo and buff.AllowWhisper then
    local whisperToggle = buff.frames:CreateWhisperToggle(_t("TooltipWhisperWhenExpired"))
    whisperToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
    whisperToggle:SetVariable(--[[---@not nil]] profileBuff, "Whisper", nil)
    rowBuilder:SpaceToTheRight(whisperToggle, 2)
  end

  ----------------------------------
  if buff.type == "weapon" then
    -- Add choices for mainhand & offhand
    local mainhandToggle = buff.frames:CreateMainhandToggle(_t("tooltip.mainhand"))
    mainhandToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
    mainhandToggle:SetVariable(--[[---@not nil]] profileBuff, "MainHandEnable", nil)
    rowBuilder:SpaceToTheRight(mainhandToggle, 2)

    local offhandToggle = buff.frames:CreateOffhandToggle(_t("tooltip.offhand"))
    offhandToggle:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", rowBuilder.dx, 0)
    offhandToggle:SetVariable(--[[---@not nil]] profileBuff, "OffHandEnable", nil)
    rowBuilder:SpaceToTheRight(offhandToggle, 2)
  end

  -- Calculate label to the right of the spell config buttons,
  -- spell name and extra text label
  -->>---------------------------
  local buffLabel = buff.frames:CreateBuffLabel("-")
  buffLabel:SetPoint("TOPLEFT", rowBuilder.prevControl, "TOPRIGHT", 7, -1)
  managedUiModule:ManageControl(tostring(buff.buffId) .. ".buffLabel", buffLabel)

  -- Having 'consumeGroupTitle' set will override buff single text from the iteminfo
  if buff.consumeGroupTitle then
    local text = buff.consumeGroupTitle
    if buff.extraText then
      text = text .. ": " .. buffomatModule:Color("bbbbee", buff.extraText)
    end
    buffLabel:SetText(text)
  else
    buff:GetSingleText(
            function(buffLabelText)
              if buff.type == "weapon" then
                buffLabelText = buffLabelText .. ": " .. buffomatModule:Color("bbbbee", _t("TooltipIncludesAllRanks"))
              elseif buff.extraText then
                buffLabelText = buffLabelText .. ": " .. buffomatModule:Color("bbbbee", buff.extraText)
              end
              buffLabel:SetText(buffLabelText)
            end
    ) -- update when spell loaded
  end

  rowBuilder:SpaceToTheRight(buffLabel, 7)
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
      for i, spell in ipairs(allBuffsModule.selectedBuffs) do
        -- for all spells known by Buffomat and the player
        if spell.category ~= cat -- category has changed from the previous row
                or (type(spell.onlyUsableFor) == "table"
                and not tContains(spell.onlyUsableFor, selfClass)) then
          -- skip not usable
        else
          if not rowBuilder.categories[cat] then
            -- if category header was not yet added
            rowBuilder.categories[cat] = true
            self:AddCategoryRow(cat, rowBuilder) -- only add once if ever found one in that category
          else
            -- category header was already added
            rowBuilder.dy = 2 -- step down 2 px between rows
          end

          self:AddSpellRow(rowBuilder, playerIsHorde, spell)
        end -- if category of the spell == cat
      end -- for selected spells
    else
      -- cat is hidden
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
    return _t("Category_none")
  end
  return _t("Category_" .. catId)
end

---Takes a category id from allBuffsModule constants, and adds a nice text title
---with localised category name
---@param catId BomBuffCategoryName
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

  rowBuilder:PositionAtNewRow(label, 6, nil)
  --rowBuilder:ChainToTheRight(buffCatCheckbox, label)
  rowBuilder.dy = 4 -- step down a little
end

---@param buffDef BomBuffDefinition
function spellButtonsTabModule:UpdateSelectedSpell(buffDef)
  -- temp fix
  if not buffDef.frames.checkboxEnable then
    return
  end

  -- the pointer to spell in current BOM profile
  ---@type BomBuffDefinition
  local profileSpell = buffomatModule.currentProfile.Spell[buffDef.buffId]
  buffDef.frames.checkboxEnable:SetVariable(profileSpell, "Enable", nil)

  if buffDef:HasClasses() then
    buffDef.frames.toggleSelfCast:SetVariable(profileSpell, "SelfCast", nil)

    for ci, class in ipairs(constModule.CLASSES) do
      buffDef.frames[class]:SetVariable(profileSpell.Class, class, nil)

      if profileSpell.SelfCast then
        buffDef.frames[class]:Disable()
      else
        buffDef.frames[class]:Enable()
      end
    end -- for all class names

    buffDef.frames["tank"]:SetVariable(profileSpell.Class, "tank", nil)
    buffDef.frames["pet"]:SetVariable(profileSpell.Class, "pet", nil)

    if profileSpell.SelfCast then
      buffDef.frames["tank"]:Disable()
      buffDef.frames["pet"]:Disable()
    else
      buffDef.frames["tank"]:Enable()
      buffDef.frames["pet"]:Enable()
    end

    --========================================
    local forceCastButton = buffDef.frames.toggleForceCast ---@type BomGPIControl
    local excludeButton = buffDef.frames.toggleExclude ---@type BomGPIControl

    if BOM.lastTarget ~= nil then
      ------------------------- forceCastButton:Enable() self:UpdateForcecastTooltip(forceCastButton, profileSpell)

      local spellForcedTarget = profileSpell.ForcedTarget
      local lastTarget = BOM.lastTarget

      forceCastButton:SetScript("OnClick", function(self)
        if lastTarget then
          if not spellForcedTarget[--[[---@not nil]] lastTarget] then
            BOM:Print(BOM.FormatTexture(texturesModule.ICON_TARGET_ON) .. " "
                    .. _t("MessageAddedForced") .. ": " .. lastTarget)
            spellForcedTarget[--[[---@not nil]] lastTarget] = true
          else
            BOM:Print(BOM.FormatTexture(texturesModule.ICON_TARGET_ON) .. " "
                    .. _t("MessageClearedForced") .. ": " .. lastTarget)
            spellForcedTarget[--[[---@not nil]] lastTarget] = nil
          end
        end
        spellButtonsTabModule:UpdateForcecastTooltip(self, profileSpell)
      end)
      ------------------------- excludeButton:Enable() self:UpdateExcludeTargetsTooltip(excludeButton, profileSpell)

      local spellExclude = profileSpell.ExcludedTarget
      lastTarget = BOM.lastTarget

      excludeButton:SetScript("OnClick", function(control)
        if lastTarget then
          if not spellExclude[--[[---@not nil]] lastTarget] then
            BOM:Print(BOM.FormatTexture(texturesModule.ICON_TARGET_EXCLUDE) .. " "
                    .. _t("MessageAddedExcluded") .. ": " .. lastTarget)
            spellExclude[--[[---@not nil]] lastTarget] = true
          else
            BOM:Print(BOM.FormatTexture(texturesModule.ICON_TARGET_EXCLUDE) .. " "
                    .. _t("MessageClearedExcluded") .. ": " .. lastTarget)
            spellExclude[--[[---@not nil]] lastTarget] = nil
          end
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

      excludeButton:Disable()
      toolboxModule:TooltipText(
              excludeButton,
              _t("TooltipExcludeTarget") .. "|n" .. _t("TooltipSelectTarget")
                      .. self:ExcludeTargetsTooltip(profileSpell))
      --exclude_button:SetVariable()
    end
  end -- end if has classes

  if buffDef.isInfo and buffDef.AllowWhisper then
    buffDef.frames.toggleWhisper:SetVariable(profileSpell, "AllowWhisper", nil)
  end

  if buffDef.type == "weapon" then
    buffDef.frames.toggleMainHand:SetVariable(profileSpell, "MainHandEnable", nil)
    buffDef.frames.toggleOffHand:SetVariable(profileSpell, "OffHandEnable", nil)
  end

  if (buffDef.type == "tracking"
          or buffDef.type == "aura"
          or buffDef.type == "seal") and buffDef.requiresForm == nil
  then
    if (buffDef.type == "tracking" and buffomatModule.character.lastTrackingIconId == buffDef.trackingIconId) or
            (buffDef.type == "aura" and buffDef.buffId == buffomatModule.currentProfile.LastAura) or
            (buffDef.type == "seal" and buffDef.buffId == buffomatModule.currentProfile.LastSeal) then
      buffDef.frames.checkboxSet:SetState(true)
    else
      buffDef.frames.checkboxSet:SetState(false)
    end
  end
end

function spellButtonsTabModule:HideAllControls()
  managedUiModule:HideAllManagedButtons()

  for _cat, frame in pairs(self.categoryLabels) do
    frame:Hide()
    --frame:SetParent(nil)
    frame:ClearAllPoints()
  end

  for _id, buffDef in pairs(allBuffsModule.allBuffs) do
    if self:CategoryIsHidden(buffDef.category) then
      buffDef.frames:Destroy()
      buffDef.frames = buffRowModule:New(tostring(buffDef.highestRankSingleId))
    else
      buffDef.frames:Hide()
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
  if allBuffsModule.selectedBuffs == nil then
    return false
  end

  if InCombatLockdown() then
    return false
  end

  buffomatModule:UseProfile(profileModule:ChooseProfile())
  self:HideAllControls()
  self:CreateTab(UnitFactionGroup("player") == "Horde")

  local _className, playerClass, _classId = UnitClass("player")

  for i, spell in ipairs(allBuffsModule.selectedBuffs) do
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
    spell.frames.checkboxEnable:SetVariable(buffomatModule.currentProfile.CancelBuff[spell.buffId], "Enable", nil)
  end

  --Create small SINGLE-BUFF toggle to the right of [Cast <spell>]
  BOM.CreateSingleBuffButton(BomC_ListTab) --maybe not created yet?
  return true
end

---Record the need to update spells tab, but the actual update is called on a timer
---@param caller string
function spellButtonsTabModule:UpdateSpellsTab(caller)
  self.spellTabUpdateRequestedBy[caller] = true
end
