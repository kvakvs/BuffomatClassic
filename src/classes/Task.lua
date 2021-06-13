---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---@class Task
--- @field distance string|boolean Unit name or group number as string, to calculate whether player is in range to perform the task. Boolean true for no distance check.
--- @field action_text string The message to display: target and spell
--- @field extra_text string The extra message to display
--- @field priority number Sorting for display purposes

BOM.TaskPriority = {
  Resurrection = 1,
  Default      = 10,
  SelfBuff     = 10,
  GroupBuff    = 100,
}

---@type Task
BOM.Class.Task = {}
BOM.Class.Task.__index = BOM.Class.Task

local CLASS_TAG = "task_item"

---Creates a new TaskListItem
---@param priority number|nil Sorting priority to display
---@param target Member|Group Unit to calculate distance to or boolean true
---@param action_text string
---@param extra_text string
function BOM.Class.Task:new(action_text, extra_text, target, priority)
  local distance = target:GetDistance()
  local fields = {
    t           = CLASS_TAG,
    action_text = action_text or "",
    extra_text  = extra_text or "",
    member      = target,
    distance    = distance, -- scan member distance or nearest party member
    priority    = priority or BOM.TaskPriority.Default
  }
  setmetatable(fields, BOM.Class.Task)
  return fields
end

function BOM.Class.Task.FormatText(self)
  --if self.extra_text then
  return self.action_text .. " " .. BOM.Color("777777", self.extra_text)
  --end
  --return self.action_text
end

function BOM.Class.Task.FormatInfoText(self)
  --if self.extra_text then
  return self.action_text .. " " .. BOM.Color("bbaa22", self.extra_text)
  --end
  --return self.action_text
end
