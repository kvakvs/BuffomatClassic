-- Implements AceGUI dialog for choosing spells and spell settings.
-- Replaces the classic Buffomat spells tab.
--local TOCNAME, _ = ...
local BOM = BuffomatAddon

---@class SpellsDialogContext
---@field categoryFrames {[string]: AceGUIWidget} Contains title and checkbox to show/hide the category

---@class BomSpellsDialogModule
---@field dialog AceGUIWidget AceGUI frame containing the spells list
---@field scrollFrame AceGUIWidget AceGUI scroll frame containing the spells list
---@field context SpellsDialogContext

local spellsDialogModule = BomModuleManager.spellsDialogModule ---@type BomSpellsDialogModule
local _t = BomModuleManager.languagesModule ---@type BomLanguagesModule
local allBuffsModule = BomModuleManager.allBuffsModule ---@type BomAllBuffsModule
local buffomatModule = BomModuleManager.buffomatModule ---@type BomBuffomatModule
local buffDefModule = BomModuleManager.buffDefinitionModule ---@type BomBuffDefinitionModule
local toolboxModule = BomModuleManager.toolboxModule ---@type BomToolboxModule

-- local constModule = BomModuleManager.constModule
-- local eventsModule = BomModuleManager.eventsModule
-- local taskScanModule = BomModuleManager.taskScanModule
-- local kvOptionsModule = KvModuleManager.optionsModule
-- local taskListPanelModule = BomModuleManager.taskListPanelModule

local libGUI = LibStub("AceGUI-3.0")

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
  frame:SetWidth(600)
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
    isHorde = UnitFactionGroup("player") == "Horde",
    categoryFrames = {},
  } ---@type SpellsDialogContext

  self:CreateCategoryFrames(self.context)

  for _, buffDef in ipairs(allBuffsModule.selectedBuffs) do
    --local profileBuff = buffomatModule.currentProfile.Spell[buffDef.buffId]
    local profileBuff = buffDefModule:GetProfileBuff(buffDef.buffId, nil)

    if not self:CategoryIsHidden(buffDef.category) then
      local categoryFrame = self.context.categoryFrames[buffDef.category]

      if profileBuff ~= nil and categoryFrame ~= nil then
        local row = self:CreateBuffRow(buffDef, profileBuff, self.context)
        categoryFrame:AddChild(row)
      end
    end
  end
end

function spellsDialogModule:CategoryLabel(catId)
  if not catId then
    return _t("Category_none")
  end
  return _t("Category_" .. catId)
end

---@param category BomBuffCategoryName
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
    headingPanel:AddChild(label)

    local isVisible = not self:CategoryIsHidden(cat)
    local showCategoryCheckbox = libGUI:Create("CheckBox")
    showCategoryCheckbox:SetValue(isVisible)
    showCategoryCheckbox:SetLabel("")
    showCategoryCheckbox:SetCallback("OnValueChanged", function(_control, _callbackName, value)
      BOM:Print("OnValueChanged " .. tostring(value))
      buffomatModule.character.BuffCategoriesHidden[cat] = not value
      -- SetVisible(self.context.categoryContentFrames[cat], value)
      -- categoryFrame:DoLayout()
      spellsDialogModule:Hide()
      spellsDialogModule:Show()
    end)
    --toolboxModule:TooltipText(showCategoryCheckbox.frame, _t("SpellsWindow_ShowCategory"))
    headingPanel:AddChild(showCategoryCheckbox)

    -- -- Contains the rest of the category buffs (can be hidden or shown)
    -- local contentFrame = libGUI:Create("SimpleGroup")
    -- context.categoryContentFrames[cat] = contentFrame
    -- contentFrame:SetLayout("List")
    -- contentFrame:SetFullWidth(true)
    -- SetVisible(contentFrame, isVisible)
    -- categoryFrame:AddChild(contentFrame)
    -- categoryFrame:DoLayout()
  end
end

-- Player choices are stored separately in their profile
---@param buffDef BomBuffDefinition
---@param context SpellsDialogContext
function spellsDialogModule:CreateBuffRow(buffDef, profileBuff, context)
  local row = libGUI:Create("SimpleGroup")
  row:SetLayout("Flow")
  row:SetFullWidth(true)

  local checkEnabled = libGUI:Create("CheckBox")
  checkEnabled:SetValue(profileBuff.Enable)
  checkEnabled:SetCallback("OnValueChanged", function(value) profileBuff.Enable = value end)
  checkEnabled:SetLabel(buffDef.singleLink)
  checkEnabled:SetWidth(250)
  row:AddChild(checkEnabled)

  return row
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
