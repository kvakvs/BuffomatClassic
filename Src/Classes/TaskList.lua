local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomTaskListModule
local taskListModule = BuffomatModule.New("TaskList") ---@type BomTaskListModule

local taskModule = BuffomatModule.Import("Task") ---@type BomTaskModule

---@class BomTaskList
---@field tasks table<number, BomTask> This potentially becomes a macro action on the buff bu
---@field comments table<number, string>
---@field lowPrioComments table<number, string>

---@type BomTaskList
local taskListClass = {}
taskListClass.__index = taskListClass

---@return BomTaskList
function taskListModule:New()
  local fields = {} ---@type BomTaskList
  setmetatable(fields, taskListClass)

  fields.tasks = {}
  fields.comments = {}
  fields.lowPrioComments = {}

  return fields
end

---Adds a text line to display in the message frame. The line is stored in DisplayCache
---@param actionText string Text to display (target of the action) with icon and color
---@param actionLink string Text to display if inactive (just text)
---@param extraText string Text to display (extra comment)
---@param target BomUnit Distance to the party member, or group (if string)
---@param isInfo boolean Whether the text is info text or a cast
---@param prio number|nil Priority, a constant from BOM.TaskPriority
function taskListClass:Add(actionLink, actionText, extraText,
                           target, isInfo, prio)
  local new_task = taskModule:New(
          "", actionLink, actionText, extraText, target, isInfo, prio)
  tinsert(self.tasks, new_task)
end

---Adds a text line to display in the message frame. The line is stored in DisplayCache
---@param actionLink string Text to display (target of the action) with icon and color
---@param actionText string|nil Text to display if inactive (just text). Nil to use action_link
---@param prefixText string Text to display before spell (a verb?)
---@param extraText string Text to display (extra comment)
---@param target BomUnit Distance to the party member, or group (if string)
---@param isInfo boolean Whether the text is info text or a cast
---@param prio number|nil Priority, a constant from BOM.TaskPriority
function taskListClass:AddWithPrefix(prefixText,
                                     actionLink, actionText, extraText,
                                     target, isInfo, prio)
  local newTask = taskModule:New(
          prefixText, actionLink, actionText, extraText, target, isInfo, prio)
  tinsert(self.tasks, newTask)
end

---Add a comment text which WILL auto open buffomat window when it is displayed
function taskListClass:Comment(text)
  tinsert(self.comments, text)
end

---Add a comment text which WILL NOT auto open buffomat window and will display in grey
function taskListClass:LowPrioComment(text)
  tinsert(self.lowPrioComments, text)
end

---Clear the cached text, and clear the message frame
function taskListClass:Clear()
  BomC_ListTab_MessageFrame:Clear()
  wipe(self.tasks)
  wipe(self.comments)
  wipe(self.lowPrioComments)
end

---@param a GroupBuffTarget|BomUnit
---@param b GroupBuffTarget|BomUnit
local function bomCompareGroupsOrMembers(a, b)
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
  ---@param task BomTask
  for i, task in ipairs(self.tasks) do
    -- Refresh the copy of distance value
    if task.t == "memberBuffTarget" or task.t == "groupBuffTarget" then
      task.distance = task.target:GetDistance()
    end
  end

  table.sort(self.tasks, bomCompareGroupsOrMembers)

  for i, text in ipairs(self.lowPrioComments) do
    taskFrame:AddMessage(BOM.Color("aaaaaa", text))
  end

  for i, text in ipairs(self.comments) do
    taskFrame:AddMessage(text)
  end

  for i, task in ipairs(self.tasks) do
    if task.distance > 43 * 43 then
      taskFrame:AddMessage(task:FormatDisabledRed(BOM.L.ERR_RANGE))
    end
  end

  for i, task in ipairs(self.tasks) do
    if task.distance <= 43 * 43 then
      taskFrame:AddMessage(task:Format())
    end
  end
end
