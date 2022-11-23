--local TOCNAME, _ = ...
--local BOM = BuffomatAddon ---@type BomAddon

---@shape BomTaskListModule
local taskListModule = BomModuleManager.taskListModule ---@type BomTaskListModule

local taskModule = BomModuleManager.taskModule
local buffomatModule = BomModuleManager.buffomatModule
local _t = BomModuleManager.languagesModule

---@shape BomTaskList
---@field tasks BomTask[]
---@field comments string[]
---@field lowPrioComments string[]
---@field firstToCast BomTask
local taskListClass = {}
taskListClass.__index = taskListClass

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
local function bomOrderTasksByDistance(a, b)
  if not b then
    return false
  end
  if not a then
    return true
  end
  return a.distance < b.distance -- or
  --a.priority < b.priority or
  --a.action_text < b.action_text
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
  for i, task in ipairs(self.tasks) do
    -- Refresh the copy of distance value
    --if task.t == "memberBuffTarget" or task.t == "groupBuffTarget" then
    task.distance = task.target:GetDistance()
    --end
  end

  table.sort(self.tasks, bomOrderTasksByDistance)

  for i, text in ipairs(self.lowPrioComments) do
    taskFrame:AddMessage(buffomatModule:Color("aaaaaa", text))
  end

  for i, text in ipairs(self.comments) do
    taskFrame:AddMessage(text)
  end

  for i, task in ipairs(self.tasks) do
    if task.distance > 43 * 43 then
      taskFrame:AddMessage(task:FormatDisabledRed(_t("task.error.range")))
    end
  end

  for i, task in ipairs(self.tasks) do
    if task.distance <= 43 * 43 then
      taskFrame:AddMessage(task:Format())
    end
  end
end
