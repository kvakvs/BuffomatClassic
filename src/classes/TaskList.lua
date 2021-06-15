---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---@class TaskList
---@field tasks table<number, Task> This potentially becomes a macro action on the buff bu
---@field comments table<number, string>

---@type TaskList
BOM.Class.TaskList = {}
BOM.Class.TaskList.__index = BOM.Class.TaskList

local CLASS_TAG = "task_list"

function BOM.Class.TaskList:new()
  local fields = {
    t        = CLASS_TAG,
    tasks    = {},
    comments = {},
  }
  setmetatable(fields, BOM.Class.TaskList)
  return fields
end

---Adds a text line to display in the message frame. The line is stored in DisplayCache
---@param self TaskList
---@param action_text string|nil Text to display (target of the action)
---@param extra_text string Text to display (extra comment)
---@param target Member Distance to the party member, or group (if string)
---@param is_info boolean Whether the text is info text or a cast
---@param prio number|nil Priority, a constant from BOM.TaskPriority
function BOM.Class.TaskList.Add(self, action_text, extra_text, target, is_info, prio)
  local new_task = BOM.Class.Task:new(action_text, extra_text, target, prio)
  tinsert(self.tasks, new_task)
end

---@param self TaskList
function BOM.Class.TaskList.Comment(self, text)
  tinsert(self.comments, text)
end

---Clear the cached text, and clear the message frame
---@param self TaskList
function BOM.Class.TaskList.Clear(self)
  BomC_ListTab_MessageFrame:Clear()
  wipe(self.tasks)
  wipe(self.comments)
end

---@param a Group|Member
---@param b Group|Member
local function bomCompareGroupsOrMembers(a, b)
  if not b then
    return false -- can b be nil?
  end
  if not a then
    return true -- can a be nil?
  end
  return a.distance > b.distance or
          a.priority > b.priority
          or a.action_text > b.action_text
end

---Unload the contents of DisplayInfo cache into BomC_ListTab_MessageFrame
---The messages (tasks) are sorted
---@param self TaskList
function BOM.Class.TaskList.Display(self)
  --table.sort(bom_cast_messages, function(a, b)
  --  return a[2] > b[2] or (a[2] == b[2] and a[1] > b[1])
  --end)

  -- update distances if the players have moved
  for i, task in ipairs(self.tasks) do
    -- Refresh Member target, if the cache contents have changed.
    -- Do not refresh, if its a Group.
    --if task.t == "member" then
    --  task.target = BOM.Cache.GetMember(task.target.name, task.target.group)
    --end
    -- Refresh the copy of distance value
    --task.distance = task.target:GetDistance()

    -- Refresh the copy of distance value
    if task.t == "member" then
      task.distance = BOM.Tool.UnitDistanceSquared(task.target)
    end
  end

  table.sort(self.tasks, bomCompareGroupsOrMembers)

  --table.sort(bom_info_messages, function(a, b)
  --  return a[1] > b[1]
  --end)
  --table.sort(self.comments, function(a, b)
  --  -- Sort by by priority then by action text
  --  return a.priority > b.priority
  --          or a.action_text > b.action_text
  --end)

  for i, text in ipairs(self.comments) do
    BomC_ListTab_MessageFrame:AddMessage(text)
  end

  for i, task in ipairs(self.tasks) do
    if task.distance > 43 then
      BomC_ListTab_MessageFrame:AddMessage("RANGE " .. task:FormatInfoText())
    end
  end

  for i, task in ipairs(self.tasks) do
    if task.distance <= 43 then
      BomC_ListTab_MessageFrame:AddMessage(task:FormatText())
    end
  end
end
