---@diagnostic disable: invisible, unused-local
local BuffomatAddon = BuffomatAddon

---@alias WindowCommand "show"|"hide"|nil

---@class TaskListPanelModule
---@field taskFrame? AceGUIWidget Floating frame for task list
---@field buffButton? AceGUIWidget Button for casting a buff or reporting status
---@field scrollPanel? AceGUIWidget Scroll panel for list of tasks/messages
---@field topUiPanel? AceGUIWidget Top panel for buff button and menu
---@field titleProfile string The profile name which goes into the title of the window
---@field titleBuffGroups string The buff groups which go into the title of the window
---@field holdOpen boolean If true, the window will not be hidden when the cast button is disabled
---@field windowCommand WindowCommand
---@field messages string[]

local taskListPanelModule = LibStub("Buffomat-TaskListPanel") --[[@as TaskListPanelModule]]
taskListPanelModule.titleProfile = ""
taskListPanelModule.titleBuffGroups = ""

local _t = LibStub("Buffomat-Languages") --[[@as LanguagesModule]]
local actionMacroModule = LibStub("Buffomat-ActionMacro") --[[@as BomActionMacroModule]]
local buffomatModule = LibStub("Buffomat-Buffomat") --[[@as BuffomatModule]]
local constModule = LibStub("Buffomat-Const") --[[@as ConstModule]]
local libGUI = LibStub("AceGUI-3.0")
local ngToolboxModule = LibStub("Buffomat-NgToolbox") --[[@as NgToolboxModule]]
local taskScanModule = LibStub("Buffomat-TaskScan") --[[@as TaskScanModule]]
local throttleModule = LibStub("Buffomat-Throttle") --[[@as ThrottleModule]]

--- Constructs the window. Only called from one location - WindowCommand()
function taskListPanelModule:ConstructWindow()
  local taskFrame = libGUI:Create("NgTaskListWindow")
  self.taskFrame = taskFrame

  taskFrame:SetLayout("Fill")
  taskFrame:ClearAllPoints()
  taskFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", BuffomatShared.X or 0, BuffomatShared.Y or 0)
  taskFrame:SetWidth(BuffomatShared.Width or 300)
  taskFrame:SetHeight(BuffomatShared.Height or 200)
  taskFrame:SetCallback("OnClose", function()
    taskListPanelModule:HideWindow()
  end)
  self:SetWindowScale(tonumber(BuffomatShared.UIWindowScale) or 1.0)

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

---@param holdOpen boolean
function taskListPanelModule:ToggleWindow(holdOpen)
  if self:IsWindowVisible() then
    self.windowCommand = "hide"
  else
    throttleModule:RequestTaskRescan("toggleWindow")
    self:ShowWindowHoldOpen(holdOpen)
  end
end

function taskListPanelModule:IsWindowVisible()
  return self.taskFrame ~= nil and self.taskFrame:IsVisible()
end

--- Do not call this directly. Called from the throttle module on timed updates.
function taskListPanelModule:WindowCommand(command)
  if not self.windowCommand then
    return
  end
  -- --------------------------------------------------
  if self.windowCommand == "hide" then
    if self.taskFrame ~= nil then
      self.taskFrame:Hide()
    end
    self.holdOpen = false

    throttleModule:RequestTaskRescan("hideWindow")
    --taskScanModule:ScanTasks("hide")
    -- --------------------------------------------------
  elseif self.windowCommand == "show" then
    if self.taskFrame == nil then
      self:ConstructWindow()
      self:SetWindowScale(tonumber(BuffomatShared.UIWindowScale) or 1.0)
    else
      self.taskFrame:Show()
    end
    self:SetAlpha(1.0)

    -- Show all messages if they were added while the window was hidden
    -- for _, message in pairs(self.messages or {}) do
    --   self:AddMessageLabel(message)
    -- end

    throttleModule:RequestTaskRescan("showWindow")
    taskScanModule:ScanTasks("show")
  end
  -- --------------------------------------------------
  self.windowCommand = nil
end

function taskListPanelModule:HideWindow()
  self.windowCommand = "hide"
end

---Attempt to close if holdOpen is false (holds open if user manually called up the window)
function taskListPanelModule:AutoClose()
  if BuffomatShared.AutoClose then
    if not self.holdOpen then
      self:HideWindow()
    end
  else
    local fade = BuffomatShared.FadeWhenNothingToDo or 0.65
    self:SetAlpha(fade) -- fade the window, default 65%
  end
end

function taskListPanelModule:ShowWindowHoldOpen(holdOpen)
  self.holdOpen = holdOpen
  self:ShowWindow()
end

function taskListPanelModule:ShowWindow()
  self.windowCommand = "show"
end

-- Reset the window to the default position and size, save the default position and size
function taskListPanelModule:ResetWindow()
  self.taskFrame:ClearAllPoints()
  self.taskFrame:SetPoint("Center", UIParent, "Center", 0, 0)
  self.taskFrame:SetWidth(200)
  self.taskFrame:SetHeight(200)
  BuffomatAddon.SaveWindowPosition()
  self:ShowWindow()
  BuffomatAddon:Print("Window position is reset.")
end

-- Add a message to the scroll panel (stacking down)
function taskListPanelModule:AddMessage(text)
  self.messages = {}
  tinsert(self.messages, text)

  if self:IsWindowVisible() then
    self:AddMessageLabel(text) -- construct actual label and show it
  end
end

---Only call this if the window is visible
function taskListPanelModule:AddMessageLabel(text)
  local message = libGUI:Create("Label")
  message:SetText(text)
  message:SetFullWidth(true)
  self.scrollPanel:AddChild(message)
end

-- Clear the scroll panel and create a new row with a buff button and menu
function taskListPanelModule:Clear()
  self.buffButton = nil
  self.messages = {}

  if self:IsWindowVisible() then
    self.scrollPanel:ReleaseChildren()
    self:CreateUIRow()
  end
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
  ngToolboxModule:TooltipWithTranslationKey(buffButton, "tooltip.TaskList.CastButton")
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

function taskListPanelModule:SavePosition()
  if self.taskFrame ~= nil then
    BuffomatShared.X = self.taskFrame.frame:GetLeft()
    BuffomatShared.Y = self.taskFrame.frame:GetTop()
    BuffomatShared.Width = self.taskFrame.frame:GetWidth()
    BuffomatShared.Height = self.taskFrame.frame:GetHeight()
  end
end

function taskListPanelModule:OnCombatStart()
  self:AutoClose()
end

function taskListPanelModule:OnCombatStop()
  if BuffomatShared.AutoOpen then
    self:ShowWindow()
  end
end