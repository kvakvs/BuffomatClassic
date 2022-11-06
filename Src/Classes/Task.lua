--local TOCNAME, _ = ...
--local BOM = BuffomatAddon ---@type BomAddon
---@class BomTaskModule
local taskModule = {}
BomModuleManager.taskModule = taskModule

local buffomatModule = BomModuleManager.buffomatModule

---@class BomTask
--- @field target BomUnit|BomGroupBuffTarget Unit name
--- @field distance number Distance to the target or nearest unit in the group target
--- @field prefixText string The message to show before the spell
--- @field actionText string The message to display if inactive: spell name
--- @field actionLink string The message to display if active: spell link with icon
--- @field extraText string The extra message to display after the spell
--- @field priority number Sorting for display purposes
--- @field isInfo boolean Reports something to the user but no target or action
local taskClass = {}
taskClass.__index = taskClass

taskModule.TaskPriority = {
  Resurrection = 1,
  Default      = 10,
  SelfBuff     = 10,
  GroupBuff    = 100,
}

--Creates a new TaskListItem
---@param priority number|nil Sorting priority to display
---@param target BomUnit|BomGroupBuffTarget Unit to calculate distance to or boolean true
---@param actionText string|nil
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

  local fields = --[[---@type BomTask]] {}
  setmetatable(fields, taskClass)

  fields.actionLink = actionLink or ""
  fields.actionText = actionText or actionLink
  fields.prefixText = prefixText or ""
  fields.extraText = extraText or ""
  fields.target = target
  fields.distance = distance -- scan member distance or nearest party member
  fields.priority = priority or taskModule.TaskPriority.Default
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
          buffomatModule:Color(bomGray, self.prefixText),
          self.actionLink,
          buffomatModule:Color(bomGray, self.extraText))
end

function taskClass:FormatDisabledRed(reason)
  local target = self.target:GetText() .. " "
  if self.isInfo then
    target = ""
  end
  return string.format("%s %s %s",
          buffomatModule:Color(bomRed, reason),
          target,
          buffomatModule:Color(bomBleakRed, self.actionText))
end
