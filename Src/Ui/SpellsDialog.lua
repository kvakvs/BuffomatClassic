---@diagnostic disable: invisible
--
-- Module implements AceGUI dialog for choosing spells and spell settings.
-- Replaces the classic Buffomat spells tab.
--

---@class SpellsDialogContext
---@field categoryFrames {[string]: AceGUIWidget} Contains title and checkbox to show/hide the category
---@field playerIsHorde boolean

---@class SpellsDialogModule
---@field dialog AceGUIWidget AceGUI frame containing the spells list
---@field scrollFrame AceGUIWidget AceGUI scroll frame containing the spells list
---@field context SpellsDialogContext

local _t = LibStub("Buffomat-Languages") --[[@as LanguagesModule]]
local allBuffsModule = LibStub("Buffomat-AllBuffs") --[[@as AllBuffsModule]]
local buffomatModule = LibStub("Buffomat-Buffomat") --[[@as BuffomatModule]]
local constModule = LibStub("Buffomat-Const") --[[@as ConstModule]]
local envModule = LibStub("KvLibShared-Env") --[[@as KvSharedEnvModule]]
local libGUI = LibStub("AceGUI-3.0")
local ngStringsModule = LibStub("Buffomat-NgStrings") --[[@as NgStringsModule]]
local ngToolboxModule = LibStub("Buffomat-NgToolbox") --[[@as NgToolboxModule]]
local profileModule = LibStub("Buffomat-Profile") --[[@as ProfileModule]]
local spellsDialogModule = LibStub("Buffomat-SpellsDialog") --[[@as SpellsDialogModule]]
local texturesModule = LibStub("Buffomat-Textures") --[[@as TexturesModule]]

function spellsDialogModule:Show()
  -- InCombat Protection is checked by the caller (Update***Tab)
  if allBuffsModule.selectedBuffs == nil then
    return false
  end

  if InCombatLockdown() then
    return false
  end

  if self.dialog then
    self:Hide()
  end

  local frame = libGUI:Create("Frame")
  self.dialog = frame

  frame:SetTitle(_t("SpellsWindow_Title"))
  frame:SetLayout("Fill")
  frame:SetWidth(800)
  frame:SetHeight(400)
  frame:SetPoint("CENTER")
  frame:Show()

  local scrollFrame = libGUI:Create("ScrollFrame")
  self.scrollFrame = scrollFrame
  scrollFrame:SetLayout("List")
  scrollFrame:SetFullHeight(true)
  scrollFrame:SetFullWidth(true)
  frame:AddChild(scrollFrame)

  self:FillBuffsList()
end

function spellsDialogModule:FillBuffsList()
  self.context = {
    playerIsHorde = UnitFactionGroup("player") == "Horde",
    categoryFrames = {},
  } ---@type SpellsDialogContext

  self:CreateCategoryFrames(self.context)

  for _, buffDef in ipairs(allBuffsModule.selectedBuffs) do
    local profileBuff = profileModule:GetProfileBuff(buffDef.buffId, nil)

    if not self:CategoryIsHidden(buffDef.category) then
      local categoryFrame = self.context.categoryFrames[buffDef.category]

      if profileBuff ~= nil and categoryFrame ~= nil then
        local row = self:CreateBuffRow(buffDef, profileBuff, self.context)
        categoryFrame:AddChild(row)
      end
    end
  end

  self.scrollFrame:DoLayout()
end

function spellsDialogModule:CategoryLabel(catId)
  if not catId then
    return _t("Category_none")
  end
  return _t("Category_" .. catId)
end

---@param category BuffCategoryName
---@return boolean
function spellsDialogModule:CategoryIsHidden(category)
  return buffomatModule.character.BuffCategoriesHidden[category] == true
end

local function SetVisible(widget, visible)
  if visible then
    widget.frame:Show()
  else
    widget.frame:Hide()
  end
end

-- Pre-create category frames
---@param context SpellsDialogContext
function spellsDialogModule:CreateCategoryFrames(context)
  for _, cat in ipairs(allBuffsModule.buffCategories) do
    -- Contains the text heading and checkbox to show/hide the category
    local categoryFrame = libGUI:Create("SimpleGroup")
    context.categoryFrames[cat] = categoryFrame
    categoryFrame:SetLayout("List")
    categoryFrame:SetFullWidth(true)
    self.scrollFrame:AddChild(categoryFrame)

    local headingPanel = libGUI:Create("SimpleGroup")
    headingPanel:SetLayout("Flow")
    headingPanel:SetFullWidth(true)
    headingPanel:SetRelativeWidth(1)
    categoryFrame:AddChild(headingPanel)

    local label = libGUI:Create("InteractiveLabel")
    label:SetText(buffomatModule:Color("aaaaaa", self:CategoryLabel(cat)))
    label:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    label:SetWidth(300)
    headingPanel:AddChild(label)

    local isVisible = not self:CategoryIsHidden(cat)
    local showCategoryCheckbox = libGUI:Create("CheckBox")
    showCategoryCheckbox:SetWidth(32)
    showCategoryCheckbox:SetValue(isVisible)
    showCategoryCheckbox:SetLabel("")
    showCategoryCheckbox:SetCallback("OnValueChanged", function(_control, _callbackName, value)
      buffomatModule.character.BuffCategoriesHidden[cat] = not value
      spellsDialogModule:Hide()
      spellsDialogModule:Show()
    end)
    headingPanel:AddChild(showCategoryCheckbox)
  end
end

-- From a buff definition, create an icon button. For consumable buffs, the icon is
-- calculated differently. Clicking the consumable icon will print all items which
-- provide this buff from the smallest to largest value.
---@param buffDef BomBuffDefinition
---@return AceGUIWidget
function spellsDialogModule:CreateInfoIcon(buffDef)
  local iconButton = libGUI:Create("Button")
  -- iconButton:SetImage(buffDef.icon)
  iconButton:SetWidth(20)
  iconButton:SetHeight(20)

  if buffDef.consumeGroupIcon then
    ngToolboxModule:SetButtonTextures(iconButton.frame, buffDef.consumeGroupIcon)

    iconButton:SetCallback("OnClick", function(_control, mouseButton)
      if mouseButton == 'LeftButton' then
        buffDef:ShowItemsProvidingBuff()
      end
    end)
    ngToolboxModule:TooltipWithTranslationKey(iconButton, "Click to print all items which provide this buff")
    iconButton:SetCallback("OnClick", function(_control, mouseButton)
      buffDef:ShowItemsProvidingBuff()
    end)
  else
    if buffDef.isConsumable then
      ngToolboxModule:TooltipLink(iconButton, "item:" .. buffDef:GetFirstItem())
    else
      ngToolboxModule:TooltipLink(iconButton, "spell:" .. buffDef.highestRankSingleId)
    end

    -- Set texture when ready, might load with a delay
    buffDef:GetIcon(function(texture)
      ngToolboxModule:SetButtonTextures(iconButton.frame, texture)
    end)
  end

  return iconButton
end

-- Player choices are stored separately in their profile
---@param buffDef BomBuffDefinition
---@param context SpellsDialogContext
function spellsDialogModule:CreateBuffRow(buffDef, profileBuff, context)
  local row = libGUI:Create("SimpleGroup")
  row:SetLayout("Flow")
  row:SetFullWidth(true)

  -- Create the icon button
  local iconButton = self:CreateInfoIcon(buffDef)
  row:AddChild(iconButton)

  -- Create the checkbox to enable/disable the buff
  local checkEnabled = libGUI:Create("CheckBox")
  checkEnabled:SetValue(profileBuff.Enable)
  checkEnabled:SetCallback("OnValueChanged", function(_control, _callbackName, value)
    profileBuff.Enable = value
  end)
  checkEnabled:SetLabel("-")
  buffDef:SetSpellListText(function(text)
    checkEnabled:SetLabel(text)
    checkEnabled:SetWidth(checkEnabled.text:GetStringWidth() + 32)
  end)
  row:AddChild(checkEnabled)

  -- Create checkboxes one per class
  if buffDef:HasClasses() then
    self:AddSelfCastToggle(row, profileBuff)
    self:AddClassRoleToggles(row, profileBuff)
  end

  return row
end

---Add class selector for buff which makes sense to differentiate per class.
---@param row AceGUIWidget The GUI panel where controls are added
---@param profileBuff PlayerBuffChoice The profile buff currently being displayed
function spellsDialogModule:AddSelfCastToggle(row, profileBuff)
  local selfCastTooltip = ngStringsModule:FormatTexture(texturesModule.ICON_SELF_CAST_ON)
    .. " - " .. _t("TooltipSelfCastCheckbox_Self") .. "|n"
    .. ngStringsModule:FormatTexture(texturesModule.ICON_SELF_CAST_OFF)
    .. " - " .. _t("TooltipSelfCastCheckbox_Party")

  local selfcastToggle = ngToolboxModule:CreateToggle(
    selfCastTooltip,
    texturesModule.ICON_SELF_CAST_ON,
    texturesModule.ICON_SELF_CAST_OFF,
    function() return profileBuff.SelfCast end,
    function(value) profileBuff.SelfCast = value end
  )

  ngToolboxModule:SetTooltip(selfcastToggle, selfCastTooltip)
  row:AddChild(selfcastToggle)
end

---Add Cast-on-class checkboxes one per class, and for 2 extra roles (tank, pet)
---@param row AceGUIWidget The GUI panel where controls are added
---@param profileBuff PlayerBuffChoice The profile buff currently being displayed
function spellsDialogModule:AddClassRoleToggles(row, profileBuff)
  for _, class in ipairs(constModule.CLASSES) do
    self:AddClassRoleToggle(row, profileBuff, class)
  end -- for each class in class_sort_orderend

  self:AddClassRoleToggle(row, profileBuff, "tank")
  self:AddClassRoleToggle(row, profileBuff, "pet")
end

---Creates one toggle for one class or role (call in loop)
---@param row AceGUIWidget The GUI panel where controls are added
---@param profileBuff PlayerBuffChoice The profile buff currently being displayed
---@param classOrRole ClassName
function spellsDialogModule:AddClassRoleToggle(row, profileBuff, classOrRole)
  local skip = false
  local hordePaladin = self.context.playerIsHorde and classOrRole == "PALADIN"
  local allianceShaman = not self.context.playerIsHorde and classOrRole == "SHAMAN"
  -- if not TBC hide paladin for horde, hide shaman for alliance
  if not envModule.haveTBC and (hordePaladin or allianceShaman) then
    skip = true
  end

  if not skip then
    local tooltip2 = constModule.CLASS_ICONS[classOrRole]
        .. " - " .. _t("TooltipCastOnClass")
        .. ": " .. constModule.CLASS_NAME[ classOrRole --[[@as ClassName]] ] .. "|n"
        .. ngStringsModule:FormatTexture(texturesModule.ICON_EMPTY) .. " - " .. _t("TabDoNotBuff")
        .. ": " .. constModule.CLASS_NAME[ classOrRole --[[@as ClassName]] ] .. "|n"
        .. ngStringsModule:FormatTexture(texturesModule.ICON_DISABLED) .. " - " .. _t("TabBuffOnlySelf")

    -- local classToggle = buffDef.frames:CreateClassToggle(class, tooltip2, bomDoBlessingOnClick)
    local classToggle = ngToolboxModule:CreateToggle(
      tooltip2,
      texturesModule.CLASS_ICONS_BUNDLED[classOrRole],
      texturesModule.ICON_EMPTY,
      function() return profileBuff.Class[classOrRole] == true end,
      function(value) profileBuff.Class[classOrRole] = value end
    )
    row:AddChild(classToggle)
  end
end

---@param row AceGUIWidget The GUI panel where controls are added
---@param profileBuff PlayerBuffChoice The profile buff currently being displayed
function spellsDialogModule:AddForceTargets(row, profileBuff)
  -- Force Cast Button -(+)-
  local forceToggle = buffDef.frames:CreateForceCastToggle(_t("TooltipForceCastOnTarget"), buffDef)
  rowBuilder:AppendRight(nil, forceToggle, 0)

  -- Exclude/Ignore Buff Target Button (X)
  local excludeToggle = buffDef.frames:CreateExcludeToggle(_t("TooltipExcludeTarget"), buffDef)
  rowBuilder:AppendRight(nil, excludeToggle, 2)
end


function spellsDialogModule:Hide()
  if self.dialog then
    self.scrollFrame:ReleaseChildren()

    for _, categoryFrame in pairs(self.context.categoryFrames) do
      categoryFrame:ReleaseChildren()
    end
    self.context.categoryFrames = {}

    self.dialog:Release()
    self.dialog = nil
    self.scrollFrame = nil
    self.context = nil
  end
end
