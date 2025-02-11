--local TOCNAME, _ = ...
local BOM = BuffomatAddon

---@class BomTaskListModule
local taskListModule = BomModuleManager.taskListModule ---@type BomTaskListModule

local constModule = BomModuleManager.constModule
local taskModule = BomModuleManager.taskModule
local buffomatModule = BomModuleManager.buffomatModule
local _t = BomModuleManager.languagesModule
local allBuffsModule = BomModuleManager.allBuffsModule

---@class BomTaskList
---@field tasks BomTask[]
---@field comments string[]
---@field lowPrioComments string[]
local taskListClass = {}
taskListClass.__index = taskListClass

---@return BomTask|nil
function taskListClass:SelectTask()
  for _, t in ipairs(self.tasks) do
    local canCast = t:CanCast()
    if canCast == taskModule.CAN_CAST_OK then
      return t
      --else
      --  if canCast ~= taskModule.CAN_CAST_ON_CD
      --          and canCast ~= taskModule.CAN_CAST_IS_INFO
      --  then
      --    BOM:Debug(string.format("Can't cast %s = %s", t.actionLink or "?", canCast))
      --  end
    end
  end
  return nil
end

---@return BomTaskList
function taskListModule:New()
  local fields = --[[---@type BomTaskList]] {
    tasks           = {},
    comments        = {},
    lowPrioComments = {},
  }
  setmetatable(fields, taskListClass)
  return fields
end

-- ---Adds a text line to display in the message frame. The line is stored in DisplayCache
-- ---@param actionText string|nil Text to display (target of the action) with icon and color
-- ---@param actionLink string Text to display if inactive (just text)
-- ---@param extraText string Text to display (extra comment)
-- ---@param target BomUnitBuffTarget|BomGroupBuffTarget Distance to the party member, or group (if string)
-- ---@param isInfo boolean Whether the text is info text or a cast
-- ---@param prio number|nil Priority, a constant from taskModule.TaskPriority
-- ---@deprecated
--function taskListClass:Add_0(actionLink, actionText, extraText,
--                             target, isInfo, prio)
--  local newTask = taskModule:Create(
--          "", actionLink, actionText, extraText, target, isInfo, prio)
--  table.insert(self.tasks, newTask)
--end

---@param t BomTask
function taskListClass:Add(t)
  table.insert(self.tasks, t)
  self.firstToCast = t -- always first to cast is most recent; TODO: Respect prio
end

-- ---Adds a text line to display in the message frame. The line is stored in DisplayCache
-- ---@param actionLink string Text to display (target of the action) with icon and color
-- ---@param actionText string|nil Text to display if inactive (just text). Nil to use action_link
-- ---@param prefixText string Text to display before spell (a verb?)
-- ---@param extraText string|nil Text to display (extra comment)
-- ---@param target BomUnitBuffTarget|BomGroupBuffTarget Distance to the party member, or group (if string)
-- ---@param isInfo boolean Whether the text is info text or a cast
-- ---@param prio number|nil Priority, a constant from taskModule.TaskPriority
--function taskListClass:AddWithPrefix_0(prefixText,
--                                       actionLink, actionText, extraText,
--                                       target, isInfo, prio)
--  local newTask = taskModule:Create(
--          prefixText, actionLink, actionText, extraText, target, isInfo, prio)
--  table.insert(self.tasks, newTask)
--end

---Add a comment text which WILL auto open buffomat window when it is displayed
---@param text string
function taskListClass:Comment(text)
  table.insert(self.comments, text)
end

---Add a comment text which WILL NOT auto open buffomat window and will display in grey
---@param text string
function taskListClass:LowPrioComment(text)
  table.insert(self.lowPrioComments, text)
end

---Clear the cached text, and clear the message frame
function taskListClass:Clear()
  BomC_ListTab_MessageFrame:Clear()
  wipe(self.tasks)
  wipe(self.comments)
  wipe(self.lowPrioComments)
end

---@param a BomTask
---@param b BomTask
function taskListModule.OrderTasksByDistance(a, b)
  if not b then
    return false
  end
  if not a then
    return true
  end
  return a.distance < b.distance -- or
end

---@param a BomTask
---@param b BomTask
function taskListModule.OrderTasksByPriority(a, b)
  if not b then
    return false
  end
  if not a then
    return true
  end
  return a.priority < b.priority -- or
end

---@param a BomTask
---@param b BomTask
function taskListModule.OrderTasksByCustomOrderThenPriority(a, b)
  if not b then
    return false
  end
  if not a then
    return true
  end
  local aCustomSort = a.customSort or '5'
  local bCustomSort = b.customSort or '5'
  BOM:Print("a=" .. aCustomSort .. " b=" .. bCustomSort)
  if aCustomSort == bCustomSort then
    return a.priority < b.priority
  end
  return aCustomSort < bCustomSort
end

function taskListClass:Sort()
  --table.sort(self.tasks, taskListModule.OrderTasksByDistance)
  if buffomatModule.shared.CustomBuffSorting then
    for _, task in pairs(self.tasks) do
      if task.linkedBuffDef then
        task.customSort = task.linkedBuffDef.customSort or '5'
      else
        task.customSort = nil
      end
    end
    table.sort(self.tasks, taskListModule.OrderTasksByCustomOrderThenPriority)
  else
    table.sort(self.tasks, taskListModule.OrderTasksByPriority)
  end
end

---Unload the contents of DisplayInfo cache into BomC_ListTab_MessageFrame
---The messages (tasks) are sorted
function taskListClass:Display()
  local taskFrame = BomC_ListTab_MessageFrame
  taskFrame:Clear()

  --table.sort(bom_cast_messages, function(a, b)
  --  return a[2] > b[2] or (a[2] == b[2] and a[1] > b[1])
  --end)

  -- update distances if the players have moved
  for _i, task in pairs(self.tasks) do
    -- Refresh the copy of distance value
    if not task.target then
      task.distance = 0
    else
      task.distance = ( --[[---@not nil]] task.target):GetDistance()
    end
  end

  for _i, text in pairs(self.lowPrioComments) do
    taskFrame:AddMessage(buffomatModule:Color("aaaaaa", text))
  end

  for _i, text in pairs(self.comments) do
    taskFrame:AddMessage(text)
  end

  for _i, task in pairs(self.tasks) do
    if task.distance > 43 * 43 then
      taskFrame:AddMessage(task:FormatDisabledRed(_t("task.error.range")))
    end
  end

  for _i, task in pairs(self.tasks) do
    if task.distance <= 43 * 43 then
      BOM:Print("add task=" .. task.actionLink .. " csort=" .. (task.customSort or '?'))
      taskFrame:AddMessage(task:Format())
    end
  end
end

function taskListClass:CastButton_Nothing()
  --If don't have any strings to display, and nothing to do -
  --Clear the cast button
  self:CastButtonText(_t("castButton.NothingToDo"), false)

  for _i, spell in ipairs(allBuffsModule.selectedBuffs) do
    if #spell.skipList > 0 then
      wipe(spell.skipList)
    end
  end
end

-- ---@param task BomTask
-- ---@param buffCtx BomBuffScanContext
-- ---@deprecated Use :CastButton(task)
--function taskListClass:SetupButton(task, buffCtx)
--  -- TOO FAR
--  if task.inRange == false then
--    return self:CastButton_OutOfRange()
--  end
--  -- CASTING something else
--  if BOM.isPlayerCasting == "cast" then
--    return self:CastButton_Busy()
--  end
--  -- CHANNELING something else
--  if BOM.isPlayerCasting == "channel" then
--    return self:CastButton_BusyChanneling()
--  end
--  -- No buffing if someone is dead
--  if buffCtx.someoneIsDead and buffomatModule.shared.DeathBlock then
--    -- Have tasks and someone died and option is set to not buff
--    return self:CastButton_SomeoneIsDead()
--  end
--
--  --if task:CanCast() == false then
--  --  return self:CastButton_CantCast()
--  --end
--
--  self:CastButton(task)
--end

---Set text and enable the cast button (or disable)
---@param t string - text for the cast button
---@param enable boolean - whether to enable the button or not
function taskListClass:CastButtonText(t, enable)
  -- not really a necessary check but for safety
  if InCombatLockdown()
      or BomC_ListTab_Button == nil
      or BomC_ListTab_Button.SetText == nil then
    return
  end

  BomC_ListTab_Button:SetText(t)

  if enable then
    BomC_ListTab_Button:Enable()
  else
    taskListModule:WipeMacro(nil)
    BomC_ListTab_Button:Disable()
  end

  buffomatModule:FadeBuffomatWindow()
end

function taskListClass:CastButton_Busy()
  --Print player is busy (casting normal spell)
  self:CastButtonText(_t("castButton.Busy"), false)
  taskListModule:WipeMacro(nil)
end

function taskListClass:CastButton_BusyChanneling()
  --Print player is busy (casting channeled spell)
  self:CastButtonText(_t("castButton.BusyChanneling"), false)
  taskListModule:WipeMacro(nil)
end

---Success case, cast is allowed, macro will be set and button will be enabled
---@param task BomTask
function taskListClass:CastButton(task)
  BOM.theMacro:EnsureExists()
  wipe(BOM.theMacro.lines)

  local action = --[[---@not nil]] task.action
  self:CastButtonText(action:GetButtonText(task), true)

  -- Set the macro lines and update the Buffomat macro
  action:UpdateMacro(BOM.theMacro)
  BOM.theMacro:UpdateMacro()
end

function taskListClass:CastButton_SomeoneIsDead()
  self:CastButtonText(_t("castButton.inactive.DeadMember"), false)
end

--function taskListClass:CastButton_CantCast()
--  -- Range is good but cast is not possible
--  --self:CastButton(ERR_OUT_OF_MANA, false)
--  self:CastButtonText(_t("castButton.CantCastMaybeOOM"), false)
--end

function taskListClass:CastButton_OutOfRange()
  self:CastButtonText(ERR_SPELL_OUT_OF_RANGE, false)
  local skipreset = false

  for spellIndex, spell in ipairs(allBuffsModule.selectedBuffs) do
    if #spell.skipList > 0 then
      skipreset = true
      wipe(spell.skipList)
    end
  end

  if skipreset then
    buffomatModule:FastUpdateTimer()
    buffomatModule:RequestTaskRescan("skipReset")
  end
end -- if inrange

--- Clears the Buffomat macro
---@param command string|nil
function taskListModule:WipeMacro(command)
  local macro = BOM.theMacro

  macro:EnsureExists()
  wipe(macro.lines)

  if command then
    table.insert(macro.lines, --[[---@not nil]] command)
  end

  macro.icon = constModule.MACRO_ICON_DISABLED
  macro:UpdateMacro()
end

---Updates the BOM macro
-- -@param member table - next target to buff
-- -@param spellId number - spell to cast
-- -@param command string - bag command
-- -@param temporaryDownrank boolean Choose previous rank for some spells like Flametongue 10 on offhand
--function taskScanModule:UpdateMacro(member, spellId, command, temporaryDownrank)
-- ---@param action BomTaskAction
--function taskListModule:UpdateMacro(action)
--  local macro = BOM.theMacro
--  macro:Recreate()
--  wipe(macro.lines)
--
--  action:UpdateMacro(macro)
--  macro.icon = constModule.MACRO_ICON
--
--  macro:UpdateMacro()
--end