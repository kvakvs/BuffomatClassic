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
---@param action_text string Text to display (target of the action) with icon and color
---@param action_link string Text to display if inactive (just text)
---@param extra_text string Text to display (extra comment)
---@param target Member Distance to the party member, or group (if string)
---@param is_info boolean Whether the text is info text or a cast
---@param prio number|nil Priority, a constant from BOM.TaskPriority
function BOM.Class.TaskList.Add(self, action_link, action_text, extra_text,
                                target, is_info, prio)
  local new_task = BOM.Class.Task:new("",
          action_link, action_text,
          extra_text, target, is_info, prio)
  tinsert(self.tasks, new_task)
end

---Adds a text line to display in the message frame. The line is stored in DisplayCache
---@param self TaskList
---@param action_link string Text to display (target of the action) with icon and color
---@param action_text string|nil Text to display if inactive (just text). Nil to use action_link
---@param prefix_text string Text to display before spell (a verb?)
---@param extra_text string Text to display (extra comment)
---@param target Member Distance to the party member, or group (if string)
---@param _is_info boolean Whether the text is info text or a cast
---@param prio number|nil Priority, a constant from BOM.TaskPriority
function BOM.Class.TaskList.AddWithPrefix(self, prefix_text,
                                          action_link, action_text, extra_text,
                                          target, is_info, prio)
  local new_task = BOM.Class.Task:new(prefix_text,
          action_link, action_text, extra_text, target, is_info, prio)
  tinsert(self.tasks, new_task)
end

---@param self TaskList
function BOM.Class.TaskList.Comment(self, text)
  tinsert(self.comments, text)
end

---Clear the cached text, and clear the message frame
---@param self TaskList
function BOM.Class.TaskList.Clear(self)
  wipe(self.tasks)
  wipe(self.comments)
end

---@param a GroupBuffTarget|Member
---@param b GroupBuffTarget|Member
local function bomCompareGroupsOrMembers(a, b)
  if not b then return false end
  if not a then return true end
  return a.distance < b.distance or
          a.priority < b.priority or
          a.action_text < b.action_text
end

---Unload the contents of DisplayInfo cache into BomC_ListTab_MessageFrame
---The messages (tasks) are sorted
---@param self TaskList
function BOM.Class.TaskList.Display(self)
  BomC_ListTab_MessageFrame:Clear()
  --table.sort(bom_cast_messages, function(a, b)
  --  return a[2] > b[2] or (a[2] == b[2] and a[1] > b[1])
  --end)

  -- update distances if the players have moved
  ---@param task Task
  for i, task in ipairs(self.tasks) do
    -- Refresh the copy of distance value
    if task.t == "memberBuffTarget" or task.t == "groupBuffTarget" then
      task.distance = task.target:GetDistance()
    end
  end

  table.sort(self.tasks, bomCompareGroupsOrMembers)

  for i, text in ipairs(self.comments) do
    BomC_ListTab_MessageFrame:AddMessage(text)
  end

  for i, task in ipairs(self.tasks) do
    if task.distance > 43 * 43 then
      BomC_ListTab_MessageFrame:AddMessage(task:FormatTextInactive(BOM.L.ERR_RANGE))
    end
  end

  for i, task in ipairs(self.tasks) do
    if task.distance <= 43 * 43 then
      BomC_ListTab_MessageFrame:AddMessage(task:FormatText())
    end
  end
end
