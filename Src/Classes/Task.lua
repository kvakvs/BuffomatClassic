local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomTaskModule
local taskModule = {}
BomModuleManager.taskModule = taskModule

local buffomatModule = BomModuleManager.buffomatModule

---@class BomTask
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

local taskClass = {} ---@type BomTask
taskClass.__index = taskClass

--Creates a new TaskListItem
---@param priority number|nil Sorting priority to display
---@param target BomUnit|BomGroupBuffTarget Unit to calculate distance to or boolean true
---@param actionText string
---@param actionLink string
---@param prefixText string
---@param extraText string
function taskModule:New(prefixText, actionLink, actionText, extraText,
                        target, isInfo, priority)
  local distance
  if target then
    distance = target:GetDistance()
  else
    distance = 0
  end

  local fields = {}  ---@type BomTask
  setmetatable(fields, taskClass)

  fields.action_link = actionLink or ""
  fields.action_text = actionText or actionLink
  fields.prefix_text = prefixText or ""
  fields.extra_text = extraText or ""
  fields.target = target
  fields.distance = distance -- scan member distance or nearest party member
  fields.priority = priority or BOM.TaskPriority.Default
  fields.isInfo = isInfo

  return fields
end

-- TODO move to const module
local bomGray = "777777"
local bomRed = "cc4444"
local bomBleakRed = "bb5555"

function taskClass:Format()
  local target = self.target:GetText() .. " "
  if self.isInfo then
    target = ""
  end
  return string.format("%s%s %s %s",
          target,
          buffomatModule:Color(bomGray, self.prefix_text),
          self.action_link,
          buffomatModule:Color(bomGray, self.extra_text))
end

function taskClass:FormatDisabledRed(reason)
  local target = self.target:GetText() .. " "
  if self.isInfo then
    target = ""
  end
  return string.format("%s %s %s",
          buffomatModule:Color(bomRed, reason),
          target,
          buffomatModule:Color(bomBleakRed, self.action_text))
end
