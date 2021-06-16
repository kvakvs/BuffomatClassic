---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---@class Task
--- @field distance string|boolean Unit name or group number as string, to calculate whether player is in range to perform the task. Boolean true for no distance check.
--- @field prefix_text string The message to show before the spell
--- @field action_text string The message to display if inactive: spell name
--- @field action_link string The message to display if active: spell link with icon
--- @field extra_text string The extra message to display after the spell
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
---@param target Member|GroupBuffTarget Unit to calculate distance to or boolean true
---@param action_text string
---@param action_link string
---@param prefix_text string
---@param extra_text string
function BOM.Class.Task:new(prefix_text, action_link, action_text, extra_text,
                            target, priority)
  local distance = target:GetDistance()
  local fields = {
    t           = CLASS_TAG,
    action_link = action_link or "",
    action_text = action_text or action_link,
    prefix_text = prefix_text or "",
    extra_text  = extra_text or "",
    target      = target,
    distance    = distance, -- scan member distance or nearest party member
    priority    = priority or BOM.TaskPriority.Default
  }
  setmetatable(fields, BOM.Class.Task)
  return fields
end

local bomGRAY = "777777"
local bomRED = "cc4444"

function BOM.Class.Task.FormatText(self)
  return string.format("%s %s %s %s",
          self.target:GetText(),
          BOM.Color(bomGRAY, self.prefix_text),
          self.action_link,
          BOM.Color(bomGRAY, self.extra_text))
end

function BOM.Class.Task.FormatTextInactive(self, reason)
  return string.format("%s %s %s",
          BOM.Color(bomRED, reason),
          self.target:GetText(),
          self.action_text)
end
