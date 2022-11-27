local BOM = BuffomatAddon ---@type BomAddon

---@shape BomTaskModule
local taskModule = BomModuleManager.taskModule

local buffomatModule = BomModuleManager.buffomatModule
local partyModule = BomModuleManager.partyModule
local taskScanModule = BomModuleManager.taskScanModule

---BomTaskActionUse|BomTaskActionCast|BomTaskActionMacro
---@class BomTaskAction
---@field GetButtonText fun(self: any, task: BomTask): string
---@field UpdateMacro fun(self: any, m: BomMacro)
---@field CanCast fun(self: any): BomCanCastResult

-- TODO: Range check and power check and spellId can be stored here and postponed till we're ready to cast
---@class BomTask
---@field target BomUnitBuffTarget|BomGroupBuffTarget|nil Unit name
---@field distance number Distance to the target or nearest unit in the group target
---@field prefixText string The message to show before the spell
---@field actionText string The message to display if inactive: spell name
---@field actionLink string The message to display if active: spell link with icon
---@field extraText string The extra message to display after the spell
---@field priority number Sorting for display purposes
---@field isInfo boolean Reports something to the user but no target or action. Macro and cast button not updated.
---@field inRange boolean|nil Boolean if range check was done
---@field action BomTaskAction|nil
local taskClass = {}
taskClass.__index = taskClass

taskModule.PRIO_RESURRECTION = 100
taskModule.PRIO_DEFAULT = 200

--Creates a new TaskListItem
---@param actionText string|nil
---@param actionLink string
---@return BomTask
function taskModule:Create(actionLink, actionText)
  local fields = --[[---@type BomTask]] {}
  setmetatable(fields, taskClass)

  fields.actionLink = actionLink or ""
  fields.actionText = actionText or actionLink
  fields.prefixText = ""
  fields.extraText = ""
  fields.target = nil
  fields.distance = 0
  fields.priority = taskModule.PRIO_DEFAULT
  fields.isInfo = false

  return fields
end

---@alias BomCanCastResult number
taskModule.CAN_CAST_OK = 1 -- ready to cast
taskModule.CAN_CAST_NO_ACTION = 2 -- task doesn't have an action
taskModule.CAN_CAST_OOM = 3 -- not enough mana for this buff
taskModule.CAN_CAST_IS_DEAD = 3 -- target is dead and the spell is not a resurrection
taskModule.CAN_CAST_ON_CD = 4 -- spell not ready yet
taskModule.CAN_CAST_IS_INFO = 5 -- isInfo is true, not a real action

function taskClass:CanCast()
  if not self.action then
    return taskModule.CAN_CAST_NO_ACTION
  end

  if self.isInfo then
    return taskModule.CAN_CAST_IS_INFO
  end

  return (--[[---@not nil]] self.action):CanCast()
end

---@param target BomUnitBuffTarget|BomGroupBuffTarget
---@return BomTask
function taskClass:Target(target)
  self.distance = target:GetDistance()
  self.target = target
  return self
end

---@param inRange boolean
---@return BomTask
function taskClass:InRange(inRange)
  self.inRange = inRange
  return self
end

---@param prio number
---@return BomTask
function taskClass:Prio(prio)
  self.priority = prio
  return self
end

---Set the task to be a notification and not an action. Macro and cast button not updated.
---@return BomTask
function taskClass:IsInfo()
  self.isInfo = true
  return self
end

---@param t string
---@return BomTask
function taskClass:ExtraText(t)
  self.extraText = t
  return self
end

---@param t string
---@return BomTask
function taskClass:PrefixText(t)
  self.prefixText = t
  return self
end

---@return BomTask
---@param action BomTaskAction
function taskClass:Action(action)
  self.action = action
  return self
end

-- TODO move to const module
local bomGray = "777777"
local bomRed = "cc4444"
local bomBleakRed = "bb5555"

function taskClass:Format()
  local targetText
  if self.target then
    targetText = (--[[---@not nil]] self.target):GetText() .. " "
  else
    targetText = ""
  end
  if self.isInfo then
    targetText = ""
  end
  return string.format("%s%s %s %s",
          targetText,
          buffomatModule:Color(bomGray, self.prefixText),
          self.actionLink,
          buffomatModule:Color(bomGray, self.extraText))
end

function taskClass:FormatDisabledRed(reason)
  local targetText
  if self.target then
    targetText = (--[[---@not nil]] self.target):GetText() .. " "
  else
    tate = ""
  end
  if self.isInfo then
    target = ""
  end
  return string.format("%s %s %s",
          buffomatModule:Color(bomRed, reason),
          target,
          buffomatModule:Color(bomBleakRed, self.actionText))
end
