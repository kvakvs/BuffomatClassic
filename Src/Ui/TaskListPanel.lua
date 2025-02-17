local BOM = BuffomatAddon

---@class TaskListPanelModule
---@field taskFrame AceGUIWidget Floating frame for task list
---@field buffButton AceGUIWidget Button for casting a buff or reporting status
---@field windowExists boolean
---@field scrollPanel AceGUIWidget Scroll panel for list of tasks/messages
---@field topUiPanel AceGUIWidget Top panel for buff button and menu
---@field messages AceGUIWidget[]

local taskListPanelModule = BomModuleManager.taskListPanelModule ---@type TaskListPanelModule
local buffomatModule = BomModuleManager.buffomatModule ---@type BomBuffomatModule
local taskScanModule = BomModuleManager.taskScanModule
local ngToolboxModule = BomModuleManager.ngToolboxModule
local actionMacroModule = BomModuleManager.actionMacroModule
local constModule = BomModuleManager.constModule
local messages = {}

local libGUI = LibStub("AceGUI-3.0")

function taskListPanelModule:CreateTaskFrame()
  local taskFrame = libGUI:Create("Window")
  self.taskFrame = taskFrame
  taskFrame:SetTitle("Tasks")
  taskFrame:SetLayout("Fill")
  taskFrame:ClearAllPoints()
  taskFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", buffomatModule.shared.X, buffomatModule.shared.Y)
  taskFrame:SetWidth(buffomatModule.shared.Width)
  taskFrame:SetHeight(buffomatModule.shared.Height)
  taskFrame:SetCallback("OnClose", function()
    BOM.BtnClose()
    taskListPanelModule.windowExists = false
  end)
  self:SetWindowScale(tonumber(buffomatModule.shared.UIWindowScale) or 1.0)

  local scrollPanel = libGUI:Create("ScrollFrame")
  self.scrollPanel = scrollPanel
  scrollPanel:SetLayout("List")
  taskFrame:AddChild(scrollPanel)

  self:CreateUIRow()

  self.windowExists = true
end

function taskListPanelModule:SetWindowScale(scale)
  self.taskFrame.frame:SetScale(scale)
end

function taskListPanelModule:ToggleWindow()
  if self.windowExists then
    self:HideWindow()
  else
    buffomatModule:RequestTaskRescan("toggleWindow")
    taskScanModule:ScanTasks("toggleWindow")
    self:ShowWindow(nil)
  end
end

function taskListPanelModule:IsWindowVisible()
  return self.windowExists and self.taskFrame:IsVisible()
end

function taskListPanelModule:HideWindow()
  if not InCombatLockdown() then
    if self.windowExists then
      self.taskFrame:Hide()
      -- self.taskFrame:Release()
      buffomatModule.autoHelper = "KeepClose"
      buffomatModule:RequestTaskRescan("hideWindow")
      taskScanModule:ScanTasks("hideWindow")
      self.windowExists = false
    end
  end
end

function taskListPanelModule:ShowWindow()
  if not InCombatLockdown() then
    if not self.windowExists then
      -- self.taskFrame:Show()
      self:CreateTaskFrame()
      self:SetWindowScale(tonumber(buffomatModule.shared.UIWindowScale) or 1.0)
      buffomatModule:RequestTaskRescan("showWindow")
      buffomatModule.autoHelper = "KeepOpen"
      self.windowExists = true
    else
      self:HideWindow()
      self.windowExists = false
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
  buffButton:SetHeight(32)
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
