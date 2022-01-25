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
--- @field isInfo boolean Reports something to the user but no target or action

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
                            target, isInfo, priority)
  local distance = target:GetDistance()
  local fields = {
    t           = CLASS_TAG,
    action_link = action_link or "",
    action_text = action_text or action_link,
    prefix_text = prefix_text or "",
    extra_text  = extra_text or "",
    target      = target,
    distance    = distance, -- scan member distance or nearest party member
    priority    = priority or BOM.TaskPriority.Default,
    isInfo      = isInfo,
  }
  setmetatable(fields, BOM.Class.Task)
  return fields
end

local bomGray = "777777"
local bomRed = "cc4444"
local bomBleakRed = "bb5555"

function BOM.Class.Task.FormatText(self)
  local target = self.target:GetText() .. " "
  if self.isInfo then
    target = ""
  end
  return string.format("%s%s %s %s",
          target,
          BOM.Color(bomGray, self.prefix_text),
          self.action_link,
          BOM.Color(bomGray, self.extra_text))
end

function BOM.Class.Task.FormatTextInactive(self, reason)
  local target = self.target:GetText() .. " "
  if self.isInfo then
    target = ""
  end
  return string.format("%s %s %s",
          BOM.Color(bomRed, reason),
          target,
          BOM.Color(bomBleakRed, self.action_text))
end
