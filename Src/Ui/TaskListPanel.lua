local BOM = BuffomatAddon

---@class TaskListPanelModule
---@field taskFrame AceGUIWidget Floating frame for task list
---@field buffButton AceGUIWidget Button for casting a buff or reporting status
---@field scrollPanel AceGUIWidget Scroll panel for list of tasks/messages
---@field topUiPanel AceGUIWidget Top panel for buff button and menu
---@field messages AceGUIWidget[]
---@field titleProfile string The profile name which goes into the title of the window
---@field titleBuffGroups string The buff groups which go into the title of the window

local taskListPanelModule = --[[@as TaskListPanelModule]] LibStub("Buffomat-TaskListPanel")
taskListPanelModule.titleProfile = ""
taskListPanelModule.titleBuffGroups = ""
local buffomatModule = --[[@as BomBuffomatModule]] LibStub("Buffomat-Buffomat")
local taskScanModule = --[[@as BomTaskScanModule]] LibStub("Buffomat-TaskScan")
local ngToolboxModule = --[[@as NgToolboxModule]] LibStub("Buffomat-NgToolbox")
local actionMacroModule = --[[@as BomActionMacroModule]] LibStub("Buffomat-ActionMacro")
local constModule = --[[@as BomConstModule]] LibStub("Buffomat-Const")
local _t = --[[@as BomLanguagesModule]] LibStub("Buffomat-Languages")

local libGUI = LibStub("AceGUI-3.0")

function taskListPanelModule:CreateTaskFrame()
  local taskFrame = libGUI:Create("NgTaskListWindow")
  self.taskFrame = taskFrame
  taskFrame:SetLayout("Fill")
  taskFrame:ClearAllPoints()
  taskFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", buffomatModule.shared.X, buffomatModule.shared.Y)
  taskFrame:SetWidth(buffomatModule.shared.Width)
  taskFrame:SetHeight(buffomatModule.shared.Height)
  taskFrame:SetCallback("OnClose", function()
    taskListPanelModule:HideWindow()
  end)
  self:SetWindowScale(tonumber(buffomatModule.shared.UIWindowScale) or 1.0)

  local scrollPanel = libGUI:Create("ScrollFrame")
  self.scrollPanel = scrollPanel
  scrollPanel:SetLayout("List")
  taskFrame:AddChild(scrollPanel)

  self:CreateUIRow()
  self:SetTitle()
end

function taskListPanelModule:SetTitle()
  if self.taskFrame ~= nil then
    self.taskFrame:SetTitle(self.titleProfile .. ' ' .. self.titleBuffGroups)
  end
end

function taskListPanelModule:ToggleWindow()
  if self:IsWindowVisible() then
    self:HideWindow()
  else
    buffomatModule:RequestTaskRescan("toggleWindow")
    taskScanModule:ScanTasks("toggleWindow")
    self:ShowWindow()
  end
end

function taskListPanelModule:IsWindowVisible()
  return self.taskFrame ~= nil and self.taskFrame:IsVisible()
end

function taskListPanelModule:HideWindow()
  if not InCombatLockdown() and self.taskFrame ~= nil then
    self.taskFrame:Release()
    self.taskFrame = nil
    buffomatModule.autoHelper = "KeepClose"
    buffomatModule:RequestTaskRescan("hideWindow")
    taskScanModule:ScanTasks("hideWindow")
  end
end

function taskListPanelModule:ShowWindow()
  if not InCombatLockdown() then
    if self.taskFrame == nil then
      -- self.taskFrame:Show()
      self:CreateTaskFrame()
      self:SetWindowScale(tonumber(buffomatModule.shared.UIWindowScale) or 1.0)
      buffomatModule:RequestTaskRescan("showWindow")
      buffomatModule.autoHelper = "KeepOpen"
    else
      self.taskFrame:Show()
    end
  else
    BOM:Print(_t("message.ShowHideInCombat"))
  end
end

-- Reset the window to the default position and size, save the default position and size
function taskListPanelModule:ResetWindow()
  self.taskFrame:ClearAllPoints()
  self.taskFrame:SetPoint("Center", UIParent, "Center", 0, 0)
  self.taskFrame:SetWidth(200)
  self.taskFrame:SetHeight(200)
  BOM.SaveWindowPosition()
  self:ShowWindow()
  BOM:Print("Window position is reset.")
end

-- Add a message to the scroll panel (stacking down)
function taskListPanelModule:AddMessage(text)
  local message = libGUI:Create("Label")
  message:SetText(text)
  message:SetFullWidth(true)
  if type(self.messages) ~= "table" then
    self.messages = {}
  end
  tinsert(self.messages, message)
  self.scrollPanel:AddChild(message)
end

-- Clear the scroll panel and create a new row with a buff button and menu
function taskListPanelModule:Clear()
  if type(self.messages) ~= "table" then
    return
  end
  self.scrollPanel:ReleaseChildren()
  self.messages = {}
  self.buffButton = nil

  self:CreateUIRow()
end

-- For a fresh emptied scroll panel, create a row with a buff button and menu
function taskListPanelModule:CreateUIRow()
  local topUiPanel = libGUI:Create("SimpleGroup")
  self.topUiPanel = topUiPanel
  topUiPanel:SetLayout("Flow")
  topUiPanel:SetFullWidth(true)
  topUiPanel:SetHeight(36)
  self.scrollPanel:AddChild(topUiPanel)

  -- Create the secure action button, as macro button
  local buffButton = libGUI:Create("NgSecureActionButton")
  self.buffButton = buffButton
  buffButton.frame:SetAttribute("type", "macro")
  buffButton.frame:SetAttribute("macro", constModule.MACRO_NAME)
  buffButton:SetFullWidth(true)
  buffButton:SetHeight(24)
  -- buffButton.frame:SetNormalTexture("Interface\\Buttons\\UI-MicroButton-Talents-Up")
  -- buffButton.frame:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Talents-Down")
  -- buffButton.frame:SetDisabledTexture("Interface\\Buttons\\UI-MicroButton-Talents-Disabled")
  buffButton:SetAutoWidth(true)
  -- buffButton:SetText("Buff")
  -- buffButton:SetCallback("OnClick", function() print("Click Buff!") end)
  ngToolboxModule:TooltipWithTranslationKey(buffButton, "TooltipCastButton")
  topUiPanel:AddChild(buffButton)
end

---Set text and enable the cast button (or disable)
---@param text string - text for the cast button
---@param enable boolean - whether to enable the button or not
function taskListPanelModule:CastButtonText(text, enable)
  -- not really a necessary check but for safety
  if InCombatLockdown()
      or self.buffButton == nil
      or self.buffButton.SetText == nil then
    return
  end

  self.buffButton:SetText(text)

  if enable then
    self.buffButton:SetDisabled(false)
  else
    actionMacroModule:WipeMacro(nil)
    self.buffButton:SetDisabled(true)
  end

  buffomatModule:FadeBuffomatWindow()
end

function taskListPanelModule:SetAlpha(alpha)
  if self.taskFrame ~= nil then
    self.taskFrame.frame:SetAlpha(alpha)
  end
end

function taskListPanelModule:SetWindowScale(scale)
  if self.taskFrame ~= nil then
    self.taskFrame.frame:SetScale(scale)
  end
end

function taskListPanelModule:IsBuffButtonEnabled()
  return self.buffButton ~= nil and not self.buffButton.disabled
end
